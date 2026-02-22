@echo off

setlocal

set ARCH="x64","Win32"
set CONFIG="Custom (D)","Custom (R)","Debug","Release"

rem delete all output directories, so if one configuration fails, we don't run stale binaries
for %%p in (%ARCH%) do rmdir /S /Q "sample-zpipe\\%%~p" "sample-zpipe\\applib\\%%~p"

rem IntDir is set in VS, but not in MSBuild, and will default to project name under applib (i.e. applib/applib), which is not in .gitignore
for %%p in (%ARCH%) do for %%c in (%CONFIG%) do msbuild /t:Rebuild /p:Configuration="%%~c";Platform="%%~p";IntDir="%%~p\\%%~c\\" sample-zpipe\zpipe.vcxproj

echo.

rem test the original zpipe redirection
for %%p in (%ARCH%) do for %%c in (%CONFIG%) do echo %%~c/%%~p Sample text | "sample-zpipe\%%~p\%%~c\zpipe" | "sample-zpipe\%%~p\%%~c\zpipe" -d

echo.

rem test calling the project-level static library
for %%p in (%ARCH%) do for %%c in (%CONFIG%) do echo %%~c/%%~p Sample text | "sample-zpipe\%%~p\%%~c\zpipe" -t AAAAAAABBBBBBBCCCCCCC
