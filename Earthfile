VERSION 0.7
FROM mcr.microsoft.com/dotnet/sdk:7.0
WORKDIR /source

deps:
    ARG OUTPUT_ROOT=/output
    ARG TEST_ROOT=/tests
    ARG TEMP_ROOT=/temp
    # Dotnet tools and scripts installed by PSGet
    ENV PATH=$HOME/.dotnet/tools:$HOME/.local/share/powershell/Scripts:$PATH
    RUN mkdir $OUTPUT_ROOT $TEST_ROOT $TEMP_ROOT /Tasks /Pansies
    # I'm using Invoke-Build tasks from this other repo which rarely changes
    GIT CLONE git@github.com:PoshCode/Tasks.git /Tasks
    # This is a dependency for TerminalBlocks
    GIT CLONE git@github.com:PoshCode/Pansies.git /Pansies
    # Dealing with dependencies first allows docker to cache packages for us
    # So the dependency cach only re-builds when you add a new dependency
    COPY RequiredModules.psd1 .
    COPY *.csproj .
    RUN ["pwsh", "--file", "/Tasks/_Bootstrap.ps1", "-RequiredModulesPath", "RequiredModules.psd1", "-verbose"]

build:
    ARG EARTHLY_BUILD_SHA
    ARG EARTHLY_GIT_BRANCH
    ARG OUTPUT_ROOT=/output
    ARG TEST_ROOT=/tests
    ARG TEMP_ROOT=/tmp
    # ARG VERSION=1.0.0
    # ARG CONFIGURATION=Release
    FROM +deps
    COPY . .
    # make sure you have bin and obj in .earthlyignore, as their content from context might cause problems
    RUN ["pwsh", "--command", "Invoke-Build", "-File", "Build.build.ps1"]

    # SAVE ARTIFACT [--keep-ts] [--keep-own] [--if-exists] [--force] <src> [<artifact-dest-path>] [AS LOCAL <local-path>]
    SAVE ARTIFACT $OUTPUT_ROOT/TerminalBlocks AS LOCAL .
# runtime:
#     FROM mcr.microsoft.com/dotnet/aspnet:7.0
#     WORKDIR /app
#     COPY +build/output .
#     ENTRYPOINT ["dotnet", "ContainerApp.WebApp.dll"]
#     SAVE IMAGE --push containerapp-webapp:earthly
