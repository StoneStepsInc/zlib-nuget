@echo off

setlocal

rem keep the library name as-is (in zLib 1.3.2 the static library is named zs.lib)
set ZLIB_STATIC=zs
set ZLIB_STATIC_COMPAT=zlibstatic

set PLATFORM=%~1
set BLD_CONFIG=%~2
set PKG_CONFIG=%~3

if "%PKG_CONFIG%" == "" set PKG_CONFIG=%BLD_CONFIG%

if "%PKG_CONFIG%" == "Debug" (set SUFFIX=d) else (set SUFFIX=)

mkdir "..\nuget\build\native\lib\%PLATFORM%\%PKG_CONFIG%"

copy /Y "install\%PLATFORM%\%BLD_CONFIG%\lib\%ZLIB_STATIC%%SUFFIX%.lib" "..\nuget\build\native\lib\%PLATFORM%\%PKG_CONFIG%\"
copy /Y "install\%PLATFORM%\%BLD_CONFIG%\lib\%ZLIB_STATIC%%SUFFIX%.lib" "..\nuget\build\native\lib\%PLATFORM%\%PKG_CONFIG%\%ZLIB_STATIC_COMPAT%%SUFFIX%.lib"

if EXIST "build\%PLATFORM%\%BLD_CONFIG%\%ZLIB_STATIC%%SUFFIX%.pdb" (
  copy /Y "build\%PLATFORM%\%BLD_CONFIG%\%ZLIB_STATIC%%SUFFIX%.pdb" "..\nuget\build\native\lib\%PLATFORM%\%PKG_CONFIG%\"
)
