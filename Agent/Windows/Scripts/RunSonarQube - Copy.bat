@echo off
SET $Projkey_Name=%1
SET $Proj_Name=%2
SET $ProjSoln_Name=%3
SET $Prod_Ver=%4
  
@echo %$Projkey_Name%
@echo %$Proj_Name%
SET $DotNet=C:\Program Files\dotnet\dotnet.exe
SET $SonarQube=C:\SonarQube\sonar-scanner-msbuild-4.2.0.1214-netcoreapp2.0\SonarScanner.MSBuild.dll
@echo %$SonarQube%
"%$DotNet%" "%$SonarQube%" begin /k:"%$Projkey_Name%" /n:"%$Proj_Name%" /v:"%$Prod_Ver%"
"%$DotNet%"  build "%$ProjSoln_Name%"
"%$DotNet%" "%$SonarQube%" end 



