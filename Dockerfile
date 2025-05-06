# Etapa de construcción
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copiar el proyecto actual
COPY . ./

# Crear una carpeta para las referencias externas e identificar la ruta del DLL
RUN mkdir -p /app/referencias/
# [IMPORTANTE] Asegúrate de que el archivo .dll esté en tu repositorio
# o cópialo a esta ubicación antes del build

# Mostrar estructura para depuración
RUN find . -type f -name "*.dll" | sort

# Restaurar dependencias explícitamente
RUN dotnet restore "API_Estudiantes_Test/API_Estudiantes_Test.csproj" --source "https://api.nuget.org/v3/index.json"

# Publicar el proyecto principal 
RUN dotnet publish "API_Estudiantes_Test/API_Estudiantes_Test.csproj" -c Release -o /app/out

# Etapa final
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 80
EXPOSE 443

# Listar contenido para verificar
RUN ls -la

ENTRYPOINT ["dotnet", "API_Estudiantes_Test.dll"]