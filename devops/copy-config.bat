@echo off

setlocal

set ZLIB_STATICLIB=zlibstatic

set PLATFORM=%~1
set CONFIG=%~2

if "%CONFIG%" == "Debug" (set SUFFIX=d) else (set SUFFIX=)

mkdir "..\nuget\build\native\lib\%PLATFORM%\%CONFIG%"

copy /Y "install\%PLATFORM%\%CONFIG%\lib\%ZLIB_STATICLIB%%SUFFIX%.lib" "..\nuget\build\native\lib\%PLATFORM%\%CONFIG%\"

if EXIST "install\%PLATFORM%\%CONFIG%\lib\%ZLIB_STATICLIB%%SUFFIX%.pdb" (
  copy /Y "install\%PLATFORM%\%CONFIG%\lib\%ZLIB_STATICLIB%%SUFFIX%.pdb" "..\nuget\build\native\lib\%PLATFORM%\%CONFIG%\"
)
