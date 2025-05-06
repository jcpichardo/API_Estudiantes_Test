FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copiar todos los archivos
COPY . ./

# Crear un paquete NuGet a partir del DLL
RUN mkdir -p /app/nuget/lib/net8.0/
RUN find . -name "ControlEscolarCore.dll" -exec cp {} /app/nuget/lib/net8.0/ \;

# Crear un archivo nuspec
RUN echo '<?xml version="1.0"?>\
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">\
  <metadata>\
    <id>ControlEscolarCore</id>\
    <version>1.0.0</version>\
    <authors>LocalDev</authors>\
    <description>Local package</description>\
  </metadata>\
</package>' > /app/nuget/ControlEscolarCore.nuspec

# Crear el paquete NuGet
RUN cd /app/nuget && dotnet pack ControlEscolarCore.nuspec -o /app/localpackages

# Configurar la fuente del paquete local
RUN dotnet nuget add source /app/localpackages -n LocalPackages

# Instalar el paquete en el proyecto
RUN dotnet add API_Estudiantes_Test/API_Estudiantes_Test.csproj package ControlEscolarCore -s /app/localpackages

# Compilar
RUN dotnet publish API_Estudiantes_Test/API_Estudiantes_Test.csproj -c Release -o /app/out

# Etapa final
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 80
EXPOSE 443
ENTRYPOINT ["dotnet", "API_Estudiantes_Test.dll"]