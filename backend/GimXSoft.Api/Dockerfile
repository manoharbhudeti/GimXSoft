# Multi-stage build for GIMXSOFT ASP.NET Core Web API
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY GimXSoft.Api.csproj ./
RUN dotnet restore GimXSoft.Api.csproj

# Copy the rest of the application files and build
COPY . ./
RUN dotnet publish GimXSoft.Api.csproj -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 5128

ENV ASPNETCORE_URLS=http://+:5128
ENV ASPNETCORE_ENVIRONMENT=Development

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "GimXSoft.Api.dll"]
