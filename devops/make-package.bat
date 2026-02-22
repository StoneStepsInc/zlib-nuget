@echo off

setlocal

if "%~1" == "" (
  echo Package revision must be provided as the first argument
  goto :EOF
)

set PKG_VER=1.3.2
rem used only if upstream version lacks the patch component; should be commented out otherwise (see README.md)
rem set PKG_VER_PATCH=.0
set PKG_REV=%~1

set ZLIB_FNAME=zlib-%PKG_VER%.tar.gz 
set ZLIB_DNAME=zlib-%PKG_VER%
rem zLib's original signature for .zip is available on zlib.net
set ZLIB_SHA256=bb329a0a2cd0274d05519d61c667c062e06990d72e125ee2dfa8de64f0119d16

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

tar -xzf %ZLIB_FNAME%

cd %ZLIB_DNAME%

copy /Y CMakeLists.txt CMakeLists_%PKG_VER%.txt

rem
rem Patch the source to generate debug symbols for all builds and
rem make sure dynamic MSVC CRT is used.
rem
"%PATCH%" --strip 1 --unified --binary --input ..\patches\cmake-stdcall.patch

rem
rem Build Win32 artifacts
rem
call "%VCVARSALL%" x86

cmake -S . -B build/Win32 -A Win32 -DZLIB_BUILD_TESTING=OFF -DZLIB_BUILD_SHARED=OFF

cmake --build build/Win32 --config Debug
cmake --build build/Win32 --config RelWithDebInfo

cmake --install build/Win32 --config Debug --prefix install/Win32/Debug
cmake --install build/Win32 --config RelWithDebInfo --prefix install/Win32/RelWithDebInfo

call ..\devops\copy-config Win32 Debug
call ..\devops\copy-config Win32 RelWithDebInfo Release

rem cmake --build build/Win32 --config Debug --target clean
rem cmake --build build/Win32 --config RelWithDebInfo --target clean

rem
rem Build x64 artifacts
rem

call "%VCVARSALL%" x64

cmake -S . -B build/x64 -A x64 -DZLIB_BUILD_TESTING=OFF -DZLIB_BUILD_SHARED=OFF

cmake --build build/x64 --config Debug
cmake --build build/x64 --config RelWithDebInfo

cmake --install build/x64 --config Debug --prefix install/x64/Debug
cmake --install build/x64 --config RelWithDebInfo --prefix install/x64/RelWithDebInfo

call ..\devops\copy-config x64 Debug
call ..\devops\copy-config x64 RelWithDebInfo Release

rem cmake --build build/x64 --config Debug --target clean
rem cmake --build build/x64 --config Debug --target clean

rem
rem license
rem
mkdir ..\nuget\licenses
copy LICENSE ..\nuget\licenses\LICENSE.txt

rem
rem header files (same across all builds)
rem
mkdir ..\nuget\build\native\include
copy install\x64\RelWithDebInfo\include\zlib.h ..\nuget\build\native\include\
copy install\x64\RelWithDebInfo\include\zconf.h ..\nuget\build\native\include\

cd ..

rem
rem Create a package
rem

nuget pack nuget\StoneSteps.zLib.VS2022.Static.nuspec -Version %PKG_VER%%PKG_VER_PATCH%.%PKG_REV%
