@echo off

setlocal

set ARCH="x64","Win32"
set CONFIG="ABC (D)","XYZ (R)","Debug","Release"

for %%p in (%ARCH%) do for %%c in (%CONFIG%) do msbuild /t:Rebuild /p:Configuration="%%~c";Platform="%%~p" sample-zpipe\zpipe.vcxproj

for %%p in (%ARCH%) do for %%c in (%CONFIG%) do echo %%~c/%%~p Sample text | "sample-zpipe\%%~p\%%~c\zpipe" | "sample-zpipe\%%~p\%%~c\zpipe" -d
