FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copiar todos los archivos
COPY . ./

# Crear directorio para la biblioteca
RUN mkdir -p /app/referencias

# Verificar si el archivo DLL existe y dónde
RUN find . -name "ControlEscolarCore.dll" -type f

# Intentar encontrar y copiar el DLL (ajusta la ruta según lo que muestre el comando anterior)
# Asumiendo que el DLL está en algún lugar del proyecto
RUN find . -name "ControlEscolarCore.dll" -type f -exec cp {} /app/referencias/ \; || echo "No se encontró el DLL"

# Listar el contenido del directorio referencias para verificar
RUN ls -la /app/referencias/

# Modificar el archivo .csproj para incluir la referencia correctamente
# Necesitamos usar sed para modificar el archivo XML
RUN sed -i 's|<Project Sdk="Microsoft.NET.Sdk.Web">|<Project Sdk="Microsoft.NET.Sdk.Web">\n  <ItemGroup>\n    <Reference Include="ControlEscolarCore">\n      <HintPath>../referencias/ControlEscolarCore.dll</HintPath>\n      <Private>true</Private>\n    </Reference>\n  </ItemGroup>|' API_Estudiantes_Test/API_Estudiantes_Test.csproj

# Mostrar el contenido del archivo .csproj después de la modificación
RUN cat API_Estudiantes_Test/API_Estudiantes_Test.csproj

# Compilar con verbosidad para ver los problemas
RUN dotnet publish API_Estudiantes_Test/API_Estudiantes_Test.csproj -c Release -o /app/out -v n

# Copiar el DLL manualmente a la carpeta de salida
RUN cp /app/referencias/ControlEscolarCore.dll /app/out/ || echo "No se pudo copiar el DLL"

# Etapa final
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 80
EXPOSE 443

# Listar el contenido de la carpeta para verificación
RUN ls -la

ENTRYPOINT ["dotnet", "API_Estudiantes_Test.dll"]