@echo off

setlocal

rem keep the library name as-is (in zLib 1.3.2 the static library is named zs.lib)
set ZLIB_STATICLIB_COMPAT=zs
set PKG_ZLIB_STATICLIB=zlibstatic

set PLATFORM=%~1
set BLD_CONFIG=%~2
set PKG_CONFIG=%~3

if "%PKG_CONFIG%" == "" set PKG_CONFIG=%BLD_CONFIG%

if "%PKG_CONFIG%" == "Debug" (set SUFFIX=d) else (set SUFFIX=)

mkdir "..\nuget\build\native\lib\%PLATFORM%\%PKG_CONFIG%"

copy /Y "install\%PLATFORM%\%BLD_CONFIG%\lib\%ZLIB_STATICLIB_COMPAT%%SUFFIX%.lib" "..\nuget\build\native\lib\%PLATFORM%\%PKG_CONFIG%\"
copy /Y "install\%PLATFORM%\%BLD_CONFIG%\lib\%ZLIB_STATICLIB_COMPAT%%SUFFIX%.lib" "..\nuget\build\native\lib\%PLATFORM%\%PKG_CONFIG%\%PKG_ZLIB_STATICLIB%%SUFFIX%.lib"

if EXIST "build\%PLATFORM%\%BLD_CONFIG%\%ZLIB_STATICLIB_COMPAT%%SUFFIX%.pdb" (
  copy /Y "build\%PLATFORM%\%BLD_CONFIG%\%ZLIB_STATICLIB_COMPAT%%SUFFIX%.pdb" "..\nuget\build\native\lib\%PLATFORM%\%PKG_CONFIG%\"
)
