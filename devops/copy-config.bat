@echo off

setlocal

set ZLIB_STATICLIB=zlib.lib
set ZLIB_STATICLIB_PDB=zlib.pdb

set PLATFORM=%~1
set CONFIG=%~2

mkdir "..\nuget\build\native\lib\%PLATFORM%\%CONFIG%"

copy /Y "%ZLIB_STATICLIB%" "..\nuget\build\native\lib\%PLATFORM%\%CONFIG%\"
copy /Y "%ZLIB_STATICLIB_PDB%" "..\nuget\build\native\lib\%PLATFORM%\%CONFIG%\"
