# syntax=docker/dockerfile:1

# Use the official Microsoft .NET 9.0 SDK image (includes .NET 8.0 and 9.0)
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

# Create a non-root user for security best practices
# USER app

# Set the working directory
WORKDIR /app

# Copy global.json to pin SDK version (if present)
COPY global.json ./

# Copy solution and project files
COPY *.sln ./
COPY src/ ./src/
COPY tests/ ./tests/
COPY Directory.* ./
COPY .config ./

# Restore dependencies for all projects
RUN dotnet restore

# Build all projects for both Debug and Release
RUN dotnet build --configuration Debug --no-restore
RUN dotnet build --configuration Release --no-restore

# Run tests for both target frameworks and configurations
RUN dotnet test --configuration Debug --no-build --verbosity normal
RUN dotnet test --configuration Release --no-build --verbosity normal

# The image is for CI/CD build/test only, not for running apps
# No ENTRYPOINT or CMD is set
