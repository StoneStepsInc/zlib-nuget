@echo off

setlocal

if "%~1" == "" (
  echo Package revision must be provided as the first argument
  goto :EOF
)

set PKG_VER=1.2.12
set PKG_REV=%~1

set ZLIB_FNAME=zlib1212.zip
set ZLIB_DNAME=zlib-%PKG_VER%
set ZLIB_SHA256=173e89893dcb8b4a150d7731cd72f0602f1d6b45e60e2a54efdf7f3fc3325fd7

set PATCH=c:\Program Files\Git\usr\bin\patch.exe
set SEVENZIP_EXE=c:\Program Files\7-Zip\7z.exe
set VCVARSALL=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall

curl --output %ZLIB_FNAME% https://zlib.net/%ZLIB_FNAME%

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
"%PATCH%" --unified --input ..\patches\crc32.c.patch crc32.c

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

nuget pack nuget\StoneSteps.zLib.Static.nuspec -Version %PKG_VER%.%PKG_REV%
