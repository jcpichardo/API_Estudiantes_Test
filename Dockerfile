# Etapa de construcción
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copiar toda la solución
COPY . ./

# Mostrar la estructura de directorios para depuración
RUN find . -type f -name "*.csproj" | sort

# Encontrar y compilar primero el proyecto ControlEscolarCore
RUN find . -name "ControlEscolarCore.csproj" -exec dotnet build {} -c Release \;

# Restaurar todas las dependencias de toda la solución
RUN dotnet restore

# Buscar y compilar la solución completa si existe
RUN find . -name "*.sln" -exec dotnet build {} -c Release \;

# Compilar el proyecto API
RUN find . -name "API_Estudiantes_Test.csproj" -exec dotnet publish {} -c Release -o /app/out \;

# Etapa final
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 80
EXPOSE 443

# Mostrar los DLLs disponibles
RUN ls -la

# Punto de entrada específico
ENTRYPOINT ["dotnet", "API_Estudiantes_Test.dll"]