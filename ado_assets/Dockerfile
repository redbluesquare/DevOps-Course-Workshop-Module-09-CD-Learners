FROM mcr.microsoft.com/dotnet/sdk:8.0 as build-stage

RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash - &&\
apt-get install -y nodejs

COPY ./DotnetTemplate.Web /opt/dotnet/DotnetTemplate.Web/
WORKDIR /opt/dotnet/DotnetTemplate.Web
RUN dotnet publish -c Release -o /opt/dotnet/out

FROM mcr.microsoft.com/dotnet/aspnet:8.0 as runtime

WORKDIR /opt/app
COPY --from=build-stage /opt/dotnet/out /opt/app/
ENTRYPOINT ["dotnet", "./DotnetTemplate.Web.dll"]