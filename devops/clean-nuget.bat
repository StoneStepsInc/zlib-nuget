@echo off

echo Removing Nuget output directories

if EXIST nuget\licenses rmdir /S /Q nuget\licenses
if EXIST nuget\build\native\lib rmdir /S /Q nuget\build\native\lib
if EXIST nuget\build\native\include rmdir /S /Q nuget\build\native\include
