# Etapa de construcción
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copiar toda la solución
COPY . ./

# Listar los directorios para depuración
RUN ls -la

# Restaurar todas las dependencias de la solución
RUN dotnet restore

# Compilar la solución completa para asegurar que todas las dependencias estén resueltas
RUN find . -name "*.sln" -exec dotnet build {} -c Release \;

# Publicar el proyecto API específico
RUN find . -name "API_Estudiantes_Test.csproj" -exec dotnet publish {} -c Release -o /app/out \;

# Etapa final
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 80
EXPOSE 443

# Mostrar los DLLs disponibles para verificación
RUN ls -la *.dll

# Usar el nombre exacto del DLL que deseas ejecutar
ENTRYPOINT ["dotnet", "API_Estudiantes_Test.dll"]