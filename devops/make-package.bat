@echo off

setlocal

if "%~1" == "" (
  echo Package revision must be provided as the first argument
  goto :EOF
)

set PKG_VER=1.3.1
rem used only if upstream version lacks the patch component; should be commented out otherwise (see README.md)
rem set PKG_VER_PATCH=.0
set PKG_REV=%~1

set ZLIB_FNAME=zlib131.zip
set ZLIB_DNAME=zlib-%PKG_VER%
rem zLib's original signature for .zip is available on zlib.net
set ZLIB_SHA256=72af66d44fcc14c22013b46b814d5d2514673dda3d115e64b690c1ad636e7b17

set PATCH=%PROGRAMFILES%\Git\usr\bin\patch.exe
set SEVENZIP_EXE=%PROGRAMFILES%\7-Zip\7z.exe
set VCVARSALL=%PROGRAMFILES%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall

if NOT EXIST %ZLIB_FNAME% (
  curl --location --output %ZLIB_FNAME% https://github.com/madler/zlib/releases/download/v%PKG_VER%/%ZLIB_FNAME%
)

"%SEVENZIP_EXE%" h -scrcSHA256 %ZLIB_FNAME% | findstr /C:"SHA256 for data" | call devops\check-sha256 "%ZLIB_SHA256%"

if ERRORLEVEL 1 (
  echo SHA-256 signature for %ZLIB_FNAME% does not match
  goto :EOF
)

"%SEVENZIP_EXE%" x %ZLIB_FNAME%

cd %ZLIB_DNAME%

rem
rem Patch the source to generate debug symbols for all builds and
rem make sure dynamic MSVC CRT is used.
rem
"%PATCH%" --strip 1 --unified --binary --input ..\patches\cmake-install-prefix.patch

mkdir ..\nuget\licenses
copy LICENSE ..\nuget\licenses\LICENSE.txt

rem
rem Build Win32 artifacts
rem
call "%VCVARSALL%" x86

cmake -S . -B build/Win32 -A Win32 -DZLIB_BUILD_EXAMPLES=OFF

cmake --build build/Win32 --config Debug
cmake --build build/Win32 --config Release

cmake --install build/Win32 --config Debug --prefix install/Win32/Debug
cmake --install build/Win32 --config Release --prefix install/Win32/Release

call ..\devops\copy-config Win32 Debug
call ..\devops\copy-config Win32 Release

cmake --build build/Win32 --config Debug --target clean
cmake --build build/Win32 --config Release --target clean

rem
rem Build x64 artifacts
rem

call "%VCVARSALL%" x64

cmake -S . -B build/x64 -A x64 -DZLIB_BUILD_EXAMPLES=OFF

cmake --build build/x64 --config Debug
cmake --build build/x64 --config Release

cmake --install build/x64 --config Debug --prefix install/x64/Debug
cmake --install build/x64 --config Release --prefix install/x64/Release

call ..\devops\copy-config x64 Debug
call ..\devops\copy-config x64 Release

cmake --build build/x64 --config Debug --target clean
cmake --build build/x64 --config Debug --target clean

rem
rem Copy header files (same across all builds)
rem
mkdir ..\nuget\build\native\include
copy install\x64\Release\include\zlib.h ..\nuget\build\native\include\
copy install\x64\Release\include\zconf.h ..\nuget\build\native\include\

cd ..

rem
rem Create a package
rem

nuget pack nuget\StoneSteps.zLib.VS2022.Static.nuspec -Version %PKG_VER%%PKG_VER_PATCH%.%PKG_REV%
