# Documentation for dotnet can be found here: https://nixos.org/manual/nixpkgs/unstable/#dotnet

{
  buildDotnetModule,
  dotnetCorePackages,
}:

let
  sdk_8_0 = dotnetCorePackages.sdk_8_0;
  sdk_9_0 = dotnetCorePackages.sdk_9_0;
  combinePackages = dotnetCorePackages.combinePackages [
    sdk_8_0
    sdk_9_0
  ];
in
buildDotnetModule {
  pname = "GenerateAnswerFile";
  version = "2.2";

  # Path to your source directory
  src = ./src;

  # Relative path to your .csproj file inside src
  projectFile = [ 
    "GenerateAnswerFile/GenerateAnswerFile.csproj"
    "Ookii.AnswerFile/Ookii.AnswerFile.csproj" 
  ];

  testProjectFiles = [ 
    "Ookii.AnswerFile.Tests/Ookii.AnswerFile.Tests.csproj" 
  ];
  
  # .NET SDK and runtime versions
  dotnet-sdk = combinePackages;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  dotnetBuildFlags = [ "--framework net9.0" ];
  dotnetInstallFlags = [ "--framework net9.0" ];

  # Path to your NuGet deps file (can be generated automatically)
  nugetDeps = ./deps.json;
}
