using System.Text;
using GimXSoft.Api.Data;
using GimXSoft.Api.Middleware;
using GimXSoft.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using dotenv.net;
using Npgsql;

// Enable legacy timestamp behavior for Npgsql so UTC and DateTime timestamps work cleanly across all tables
AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

// Load local .env if present
DotEnv.Load();
var envVars = DotEnv.Read();

var builder = WebApplication.CreateBuilder(args);

// Configure URL / port (defaulting to port 5128 for GimXSoft standard)
string? urlFromEnv = envVars.TryGetValue("URL", out var u) && !string.IsNullOrWhiteSpace(u) ? u : null;
string? urlFromAspnet = Environment.GetEnvironmentVariable("ASPNETCORE_URLS");
var appUrl = urlFromEnv ?? urlFromAspnet ?? "http://+:5128";
builder.WebHost.UseUrls(appUrl);

// Resolve connection string from environment variables, .env, or appsettings.json
string? rawConnStr = Environment.GetEnvironmentVariable("DATABASE_URL")
    ?? (envVars.TryGetValue("DATABASE_URL", out var envDbUrl) && !string.IsNullOrWhiteSpace(envDbUrl) ? envDbUrl : null)
    ?? (envVars.TryGetValue("DB_LINK", out var envDbLink) && !string.IsNullOrWhiteSpace(envDbLink) ? envDbLink : null)
    ?? builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Host=localhost;Port=5432;Database=mydb;Username=user;Password=mypassword;Include Error Detail=true";

// Helper to convert standard URI (postgres://user:password@host:port/database) to Npgsql connection string
static string ParsePostgresConnectionString(string connectionString)
{
    if (connectionString.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase) ||
        connectionString.StartsWith("postgresql://", StringComparison.OrdinalIgnoreCase))
    {
        var uri = new Uri(connectionString);
        var userInfo = uri.UserInfo.Split(':');
        var username = userInfo.Length > 0 ? Uri.UnescapeDataString(userInfo[0]) : "user";
        var password = userInfo.Length > 1 ? Uri.UnescapeDataString(userInfo[1]) : "";
        var host = uri.Host;
        var port = uri.Port > 0 ? uri.Port : 5432;
        var database = uri.AbsolutePath.TrimStart('/');
        return $"Host={host};Port={port};Database={database};Username={username};Password={password};Include Error Detail=true";
    }
    return connectionString;
}

bool isPostgreSql = rawConnStr.Contains("Host=", StringComparison.OrdinalIgnoreCase)
                 || rawConnStr.Contains("Server=", StringComparison.OrdinalIgnoreCase)
                 || rawConnStr.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase)
                 || rawConnStr.StartsWith("postgresql://", StringComparison.OrdinalIgnoreCase);

builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    if (isPostgreSql)
    {
        var npgsqlConn = ParsePostgresConnectionString(rawConnStr);
        options.UseNpgsql(npgsqlConn, npgsqlOptions =>
        {
            npgsqlOptions.EnableRetryOnFailure(
                maxRetryCount: 5,
                maxRetryDelay: TimeSpan.FromSeconds(5),
                errorCodesToAdd: null);
        });
    }
    else
    {
        options.UseSqlite(rawConnStr);
    }
});

// 2. Add Services
builder.Services.AddScoped<ICurrentTenantService, CurrentTenantService>();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddSingleton<IWhatsAppCloudApiClient, WhatsAppCloudApiClient>();
builder.Services.AddHostedService<WhatsAppSchedulerBackgroundService>();

// 3. Add JWT Authentication
var jwtSettings = builder.Configuration.GetSection("Jwt");
var secretKey = jwtSettings["Key"] ?? "GimXSoft_Super_Secret_Key_For_JWT_Signing_2026_Minimum_32_Bytes_Long!";
var keyBytes = Encoding.UTF8.GetBytes(secretKey);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false; // Dev environment
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(keyBytes),
        ValidateIssuer = true,
        ValidIssuer = jwtSettings["Issuer"] ?? "GimXSoft.Api",
        ValidateAudience = true,
        ValidAudience = jwtSettings["Audience"] ?? "GimXSoft.Client",
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();

// 4. Add CORS for Flutter Web
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.SetIsOriginAllowed(_ => true)
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials()
              .WithExposedHeaders("X-Total-Count", "Content-Disposition");
    });
});

// 5. Add Controllers and JSON configuration
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
    });

// 6. Add Swagger with Bearer Auth documentation
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "GIMXSOFT Multi-Tenant Gym CRM API",
        Version = "v1",
        Description = "Enterprise SaaS API for gym, fitness center and franchise management with strict multi-tenant isolation."
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "Enter JWT Bearer token: Bearer {token}",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

// 7. Seed database on startup with retry resilience (for containerized DB startup delays)
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    const int maxRetries = 10;
    for (int retry = 1; retry <= maxRetries; retry++)
    {
        try
        {
            logger.LogInformation("Ensuring database is created and seeded (Attempt {Attempt}/{MaxRetries})...", retry, maxRetries);
            await DbInitializer.SeedAsync(context);
            logger.LogInformation("Database initialized and seeded successfully.");
            break;
        }
        catch (Exception ex) when (retry < maxRetries)
        {
            logger.LogWarning(ex, "Database connection not ready on attempt {Attempt}. Retrying in 2 seconds...", retry);
            await Task.Delay(2000);
        }
    }
}

// 8. Pipeline configuration
app.UseMiddleware<ExceptionHandlingMiddleware>();

if (app.Environment.IsDevelopment() || app.Configuration.GetValue<bool>("EnableSwagger", true))
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "GimXSoft API v1");
        c.RoutePrefix = "swagger";
    });
}

app.UseCors("AllowAll");

app.UseAuthentication();
app.UseMiddleware<TenantResolutionMiddleware>();
app.UseAuthorization();

app.MapControllers();

app.Run();
