FROM mcr.microsoft.com/dotnet/sdk:8.0 as build-stage

# Install nvm for managing node & npm
RUN mkdir -p /usr/local/.nvm
ENV NVM_DIR=/usr/local/.nvm
RUN apt-get update && apt-get install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Use nvm to install latest node
ENV NODE_VERSION=21.5.0
RUN [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
 && nvm install ${NODE_VERSION}
ENV PATH="${PATH}:/usr/local/.nvm/versions/node/v${NODE_VERSION}/bin"

COPY ./DotnetTemplate.Web /opt/dotnet/DotnetTemplate.Web/
WORKDIR /opt/dotnet/DotnetTemplate.Web
RUN dotnet publish -c Release -o /opt/dotnet/out

FROM mcr.microsoft.com/dotnet/aspnet:8.0 as runtime

WORKDIR /opt/app
COPY --from=build-stage /opt/dotnet/out /opt/app/
ENTRYPOINT ["dotnet", "./DotnetTemplate.Web.dll"]