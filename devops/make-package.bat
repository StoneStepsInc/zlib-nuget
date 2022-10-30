@echo off

setlocal

if "%~1" == "" (
  echo Package revision must be provided as the first argument
  goto :EOF
)

set PKG_VER=1.2.13
set PKG_REV=%~1

set ZLIB_FNAME=zlib1213.zip
set ZLIB_DNAME=zlib-%PKG_VER%
rem zLib's original signature for .zip is available on zlib.net
set ZLIB_SHA256=d233fca7cf68db4c16dc5287af61f3cd01ab62495224c66639ca3da537701e42

set PATCH=c:\Program Files\Git\usr\bin\patch.exe
set SEVENZIP_EXE=c:\Program Files\7-Zip\7z.exe
set VCVARSALL=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall

curl --location --output %ZLIB_FNAME% https://github.com/madler/zlib/releases/download/v%PKG_VER%/%ZLIB_FNAME%

"%SEVENZIP_EXE%" h -scrcSHA256 %ZLIB_FNAME% | findstr /C:"SHA256 for data" | call devops\check-sha256 "%ZLIB_SHA256%"

if ERRORLEVEL 1 (
  echo SHA-256 signature for %ZLIB_FNAME% does not match
  goto :EOF
)

"%SEVENZIP_EXE%" x %ZLIB_FNAME%

cd %ZLIB_DNAME%

rem
rem Patch the source to work around build problems
rem
"%PATCH%" --unified --input ..\patches\Makefile.msc.patch win32\Makefile.msc

rem there's no dedicated license file, only what's in zlib.h
mkdir ..\nuget\licenses
copy zlib.h ..\nuget\licenses\zlib.h.txt

rem
rem Header files
rem
mkdir ..\nuget\build\native\include
copy *.h ..\nuget\build\native\include\

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

nuget pack nuget\StoneSteps.zLib.VS2022.Static.nuspec -Version %PKG_VER%.%PKG_REV%
