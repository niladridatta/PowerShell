@echo off
SET $Projkey_Name=%1
SET $Proj_Name=%2
SET $ProjSoln_Name=%3
SET $Prod_Ver=%4
SET $Tests_Avl=%5
SET $Cov_Path=%6

REM SET $Test_Results_Path=%7



@echo %$Projkey_Name%
@echo %$Proj_Name%
SET $DotNet=C:\Program Files\dotnet\dotnet.exe
SET $SonarQube=C:\SonarQube\sonar-scanner-msbuild-4.2.0.1214-netcoreapp2.0\SonarScanner.MSBuild.dll
REM @echo %$SonarQube%

"%$DotNet%" "%$SonarQube%" begin /k:"%$Projkey_Name%" /n:"%$Proj_Name%" /v:"%$Prod_Ver%" /d:sonar.cs.opencover.reportsPaths="%$Cov_Path%"
"%$DotNet%"  build "%$ProjSoln_Name%"
"%$DotNet%" "%$SonarQube%" end 

REM if %%5%% == "1"  ("%$DotNet%" "%$SonarQube%" begin /k:"%$Projkey_Name%" /n:"%$Proj_Name%" /v:"%$Prod_Ver%" /d:sonar.cs.opencover.reportsPaths="%$Cov_Path%")
REM if %%5%% == "0"  ("%$DotNet%" "%$SonarQube%" begin /k:"%$Projkey_Name%" /n:"%$Proj_Name%" /v:"%$Prod_Ver%"
				REM "%$DotNet%"  build "%$ProjSoln_Name%"
				REM "%$DotNet%" "%$SonarQube%" end 
				REM )



 
REM /d:sonar.cs.nunit.reportsPaths=%$Test_Results_Path%" 






 
 
 
 
 
 
 
 
 
 
 
 












REM "C:\Program Files\dotnet\dotnet.exe" "C:\SonarQube\sonar-scanner-msbuild-4.2.0.1214-netcoreapp2.0\SonarScanner.MSBuild.dll" begin /k:"ANCC" /n:"AN360CoreCommon" /v:"1.0.109"
REM "C:\Program Files\dotnet\dotnet.exe" build "core-common.sln"
REM "C:\Program Files\dotnet\dotnet.exe" "C:\SonarQube\sonar-scanner-msbuild-4.2.0.1214-netcoreapp2.0\SonarScanner.MSBuild.dll" end

REM "C:\Program Files\dotnet\dotnet.exe" "C:\SonarQube\sonar-scanner-msbuild-4.2.0.1214-netcoreapp2.0\SonarScanner.MSBuild.dll" begin /k:"NDSC" /n:"AN360NexusDataServiceCore" /v:"1.0.74"
REM "C:\Program Files\dotnet\dotnet.exe" build "NexusDataServices\SessionManagementService\SessionManagementService.csproj"

