using System.Net;
using System.Text.Json;

namespace GimXSoft.Api.Middleware;

/// <summary>
/// RFC 9457 Problem Details standard error contract.
/// </summary>
public class ProblemDetailsResponse
{
    public string Type { get; set; } = "https://tools.ietf.org/html/rfc9457";
    public string Title { get; set; } = string.Empty;
    public int Status { get; set; }
    public string Detail { get; set; } = string.Empty;
    public string Instance { get; set; } = string.Empty;
    public string ErrorCode { get; set; } = string.Empty;
    public string CorrelationId { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    public IDictionary<string, string[]>? Errors { get; set; }
}

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;
    private readonly IWebHostEnvironment _env;

    public ExceptionHandlingMiddleware(
        RequestDelegate next,
        ILogger<ExceptionHandlingMiddleware> logger,
        IWebHostEnvironment env)
    {
        _next = next;
        _logger = logger;
        _env = env;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);

            // Handle bare status codes returned without a response body
            if (!context.Response.HasStarted && context.Response.StatusCode >= 400 && context.Response.ContentLength == null)
            {
                await HandleStatusCodeAsync(context, context.Response.StatusCode);
            }
        }
        catch (Exception ex)
        {
            var correlationId = context.TraceIdentifier;
            _logger.LogError(ex, "Unhandled exception [CorrelationId: {CorrelationId}]: {Message}", correlationId, ex.Message);
            await HandleExceptionAsync(context, ex, correlationId);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception, string correlationId)
    {
        if (context.Response.HasStarted)
        {
            _logger.LogWarning("The response has already started, cannot write ProblemDetails for {CorrelationId}", correlationId);
            return;
        }

        context.Response.ContentType = "application/problem+json";

        var (statusCode, title, errorCode, safeDetail) = MapException(exception);
        context.Response.StatusCode = (int)statusCode;

        var problemDetails = new ProblemDetailsResponse
        {
            Type = GetRfcTypeForStatus(statusCode),
            Title = title,
            Status = (int)statusCode,
            Detail = safeDetail,
            Instance = context.Request.Path,
            ErrorCode = errorCode,
            CorrelationId = correlationId,
            Timestamp = DateTime.UtcNow
        };

        // If ArgumentException or validation-related, capture parameter name if available
        if (exception is ArgumentException argEx && !string.IsNullOrWhiteSpace(argEx.ParamName))
        {
            problemDetails.Errors = new Dictionary<string, string[]>
            {
                [argEx.ParamName] = new[] { argEx.Message }
            };
        }

        var json = JsonSerializer.Serialize(problemDetails, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            WriteIndented = false
        });

        await context.Response.WriteAsync(json);
    }

    private static async Task HandleStatusCodeAsync(HttpContext context, int statusCode)
    {
        context.Response.ContentType = "application/problem+json";
        var httpStatus = (HttpStatusCode)statusCode;

        var problemDetails = new ProblemDetailsResponse
        {
            Type = GetRfcTypeForStatus(httpStatus),
            Title = GetTitleForStatus(httpStatus),
            Status = statusCode,
            Detail = GetDefaultDetailForStatus(httpStatus),
            Instance = context.Request.Path,
            ErrorCode = GetErrorCodeForStatus(httpStatus),
            CorrelationId = context.TraceIdentifier,
            Timestamp = DateTime.UtcNow
        };

        var json = JsonSerializer.Serialize(problemDetails, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });

        await context.Response.WriteAsync(json);
    }

    private (HttpStatusCode status, string title, string errorCode, string safeDetail) MapException(Exception ex)
    {
        return ex switch
        {
            KeyNotFoundException knf => (
                HttpStatusCode.NotFound,
                "Resource Not Found",
                "RESOURCE_NOT_FOUND",
                knf.Message
            ),
            UnauthorizedAccessException uae => (
                HttpStatusCode.Unauthorized,
                "Unauthorized Access",
                "UNAUTHORIZED",
                uae.Message.Contains("password", StringComparison.OrdinalIgnoreCase)
                    ? "Invalid credentials provided."
                    : uae.Message
            ),
            ArgumentNullException ane => (
                HttpStatusCode.BadRequest,
                "Missing Required Argument",
                "VALIDATION_FAILED",
                $"Required field '{ane.ParamName}' is missing."
            ),
            ArgumentException ae => (
                HttpStatusCode.BadRequest,
                "Validation Error",
                "VALIDATION_FAILED",
                ae.Message
            ),
            InvalidOperationException ioe => (
                HttpStatusCode.Conflict,
                "Business Conflict",
                "BUSINESS_CONFLICT",
                ioe.Message
            ),
            TimeoutException => (
                HttpStatusCode.RequestTimeout,
                "Request Timeout",
                "REQUEST_TIMEOUT",
                "The operation timed out while waiting for a response."
            ),
            NotSupportedException nse => (
                HttpStatusCode.UnsupportedMediaType,
                "Unsupported Operation",
                "UNSUPPORTED_MEDIA",
                nse.Message
            ),
            _ => (
                HttpStatusCode.InternalServerError,
                "Internal Server Error",
                "INTERNAL_SERVER_ERROR",
                // In production / general use, never expose internal database/SQL/stack details to clients!
                "An unexpected internal error occurred. Please reference the correlation ID when contacting support."
            )
        };
    }

    private static string GetRfcTypeForStatus(HttpStatusCode status) => (int)status switch
    {
        400 => "https://tools.ietf.org/html/rfc9457#section-3.1",
        401 => "https://tools.ietf.org/html/rfc9457#section-3.1",
        403 => "https://tools.ietf.org/html/rfc9457#section-3.1",
        404 => "https://tools.ietf.org/html/rfc9457#section-3.1",
        409 => "https://tools.ietf.org/html/rfc9457#section-3.1",
        422 => "https://tools.ietf.org/html/rfc9457#section-3.1",
        429 => "https://tools.ietf.org/html/rfc9457#section-3.1",
        _ => "https://tools.ietf.org/html/rfc9457"
    };

    private static string GetTitleForStatus(HttpStatusCode status) => status switch
    {
        HttpStatusCode.BadRequest => "Bad Request",
        HttpStatusCode.Unauthorized => "Unauthorized",
        HttpStatusCode.Forbidden => "Forbidden",
        HttpStatusCode.NotFound => "Not Found",
        HttpStatusCode.Conflict => "Conflict",
        HttpStatusCode.UnsupportedMediaType => "Unsupported Media Type",
        HttpStatusCode.UnprocessableEntity => "Unprocessable Entity",
        HttpStatusCode.TooManyRequests => "Too Many Requests",
        HttpStatusCode.InternalServerError => "Internal Server Error",
        HttpStatusCode.BadGateway => "Bad Gateway",
        HttpStatusCode.ServiceUnavailable => "Service Unavailable",
        HttpStatusCode.GatewayTimeout => "Gateway Timeout",
        _ => "HTTP Error"
    };

    private static string GetErrorCodeForStatus(HttpStatusCode status) => status switch
    {
        HttpStatusCode.BadRequest => "BAD_REQUEST",
        HttpStatusCode.Unauthorized => "UNAUTHORIZED",
        HttpStatusCode.Forbidden => "FORBIDDEN",
        HttpStatusCode.NotFound => "NOT_FOUND",
        HttpStatusCode.Conflict => "CONFLICT",
        HttpStatusCode.UnsupportedMediaType => "UNSUPPORTED_MEDIA_TYPE",
        HttpStatusCode.UnprocessableEntity => "VALIDATION_FAILED",
        HttpStatusCode.TooManyRequests => "RATE_LIMIT_EXCEEDED",
        HttpStatusCode.InternalServerError => "INTERNAL_SERVER_ERROR",
        HttpStatusCode.BadGateway => "BAD_GATEWAY",
        HttpStatusCode.ServiceUnavailable => "SERVICE_UNAVAILABLE",
        HttpStatusCode.GatewayTimeout => "GATEWAY_TIMEOUT",
        _ => "GENERIC_ERROR"
    };

    private static string GetDefaultDetailForStatus(HttpStatusCode status) => status switch
    {
        HttpStatusCode.Unauthorized => "Authentication credentials were missing or invalid.",
        HttpStatusCode.Forbidden => "You do not have the required permissions to access this resource.",
        HttpStatusCode.NotFound => "The requested resource could not be found.",
        HttpStatusCode.TooManyRequests => "Rate limit exceeded. Please wait before retrying.",
        HttpStatusCode.InternalServerError => "An unexpected error occurred on the server.",
        HttpStatusCode.ServiceUnavailable => "The service is temporarily unavailable. Please try again later.",
        _ => "An error occurred while processing the request."
    };
}
