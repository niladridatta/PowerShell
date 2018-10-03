@echo off"
SET $Projkey_Name=%1
SET $Proj_Name=%2
SET $ProjSoln_Name=%3
SET $Prod_Ver=%4
rem SET $Tests_Avl=%5
SET $Cov_Path=%5
REM SET $Test_Results_Path=%7

@echo %$Projkey_Name%
@echo %$Proj_Name%
SET $DotNet=C:\Program Files\dotnet\dotnet.exe
SET $SonarQube=C:\SonarQube\sonar-scanner-msbuild-4.2.0.1214-netcoreapp2.0\SonarScanner.MSBuild.dll
@echo %$SonarQube%
"%$DotNet%" "%$SonarQube%" begin /k:"%$Projkey_Name%" /n:"%$Proj_Name%" /v:"%$Prod_Ver%" /d:sonar.cs.opencover.reportsPaths="%$Cov_Path%" 
"%$DotNet%"  build "%$ProjSoln_Name%"
"%$DotNet%" "%$SonarQube%" end 



