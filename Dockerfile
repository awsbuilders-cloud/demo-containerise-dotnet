# FROM sets the base image as sdk:3.1 from microsoft
# https://hub.docker.com/_/microsoft-dotnet-core
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build

# Sets the working directory for commands like RUN , ENTRYPOINT and COPY
WORKDIR /source

# copy csproj and restore as distinct layers
COPY aspnetapp.sln .
COPY aspnetapp/*.csproj ./aspnetapp/
RUN dotnet restore -r linux-x64 

# copy everything else to build app
COPY aspnetapp/. ./aspnetapp/
WORKDIR /source/aspnetapp

# Build the application to the /app folder
RUN dotnet publish -c release -o /app -r linux-x64 --self-contained false --no-restore

# final stage/image
# 3.1-bionic used for Ubuntu 18.04
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-bionic
WORKDIR /app

# Copy artifacts from the previous docker build
COPY --from=build /app ./
ENTRYPOINT ["./aspnetapp"]
