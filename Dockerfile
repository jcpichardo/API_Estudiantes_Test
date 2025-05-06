# Etapa de construcción con diagnóstico detallado
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copiar todo el contenido
COPY . ./

# Diagnóstico: Listar estructura completa
RUN find . -type f | grep -E '\.(dll|csproj|cs)$' | sort

# Verificar específicamente si existe el DLL de ControlEscolarCore
RUN find . -name "ControlEscolarCore.dll" -o -name "ControlEscolarCore*.dll" | sort

# Verificar el contenido del archivo csproj
RUN cat API_Estudiantes_Test/API_Estudiantes_Test.csproj

# Copiar manualmente la biblioteca a donde .NET pueda encontrarla
RUN mkdir -p /root/.nuget/packages/controlescolarcore/1.0.0/lib/net8.0/
RUN find . -name "ControlEscolarCore.dll" -exec cp {} /root/.nuget/packages/controlescolarcore/1.0.0/lib/net8.0/ \;

# Restaurar paquetes
RUN dotnet restore

# Compilar con verbosidad detallada para ver qué está fallando
RUN dotnet publish API_Estudiantes_Test/API_Estudiantes_Test.csproj -c Release -o /app/out -v d

# Etapa final
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .

# Asegurarnos de copiar también el DLL de ControlEscolarCore
COPY --from=build /root/.nuget/packages/controlescolarcore/1.0.0/lib/net8.0/ControlEscolarCore.dll .

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "API_Estudiantes_Test.dll"]