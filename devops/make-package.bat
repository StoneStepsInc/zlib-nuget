@echo off

setlocal

if "%~1" == "" (
  echo Package revision must be provided as the first argument
  goto :EOF
)

set PKG_VER=1.3
rem used only if upstream version lacks the patch component; should be commented out otherwise (see README.md)
set PKG_VER_PATCH=.0
set PKG_REV=%~1

set ZLIB_FNAME=zlib13.zip
set ZLIB_DNAME=zlib-%PKG_VER%
rem zLib's original signature for .zip is available on zlib.net
set ZLIB_SHA256=c561d09347f674f0d72692e7c75d9898919326c532aab7f8c07bb43b07efeb38

set PATCH=c:\Program Files\Git\usr\bin\patch.exe
set SEVENZIP_EXE=c:\Program Files\7-Zip\7z.exe
set VCVARSALL=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall

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
"%PATCH%" -p 1 --unified --input ..\patches\Makefile.msc.patch

mkdir ..\nuget\licenses
copy LICENSE ..\nuget\licenses\LICENSE.txt

rem
rem Header files (see ZLIB_PUBLIC_HDRS in CMakeLists.txt)
rem
mkdir ..\nuget\build\native\include
copy zlib.h ..\nuget\build\native\include\
copy zconf.h ..\nuget\build\native\include\

rem
rem Keep using nmake while it is available in the source package,
rem because CMake-generated output requires even more patching,
rem as we would need to enable PDBs for release builds, rename
rem libraries and change install to collect different platforms
rem and configurations, which are not set up well in CMakeLists.txt
rem (e.g. install prefix must be specified when build scripts
rem are generated, so there's no way to collect installed files
rem per configuration, etc).
rem

rem
rem x86 Debug
rem 

call "%VCVARSALL%" x86

nmake -f win32\Makefile.msc LOC=-DZLIB_WINAPI DEBUG=1

call ..\devops\copy-config Win32 Debug

nmake -f win32\Makefile.msc LOC=-DZLIB_WINAPI DEBUG=1 clean

rem
rem x86 Release
rem 

nmake -f win32\Makefile.msc LOC=-DZLIB_WINAPI

call ..\devops\copy-config Win32 Release

nmake -f win32\Makefile.msc LOC=-DZLIB_WINAPI clean

rem
rem x64 Debug
rem 

call "%VCVARSALL%" x64

nmake -f win32\Makefile.msc LOC=-DZLIB_WINAPI DEBUG=1

call ..\devops\copy-config x64 Debug

nmake -f win32\Makefile.msc LOC=-DZLIB_WINAPI DEBUG=1 clean

rem
rem x64 Release
rem 

nmake -f win32\Makefile.msc LOC=-DZLIB_WINAPI

call ..\devops\copy-config x64 Release

nmake -f win32\Makefile.msc LOC=-DZLIB_WINAPI clean

cd ..

rem
rem Create a package
rem

nuget pack nuget\StoneSteps.zLib.VS2022.Static.nuspec -Version %PKG_VER%%PKG_VER_PATCH%.%PKG_REV%
