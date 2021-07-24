@echo off

setlocal

rem
rem The only reason this batch file exists is that `set /p` won't
rem work within a single batch file, so we need to call this batch
rem file with the SHA-256 value in the standard input, so we can
rem evaluate it and return success (0) or failure (1).
rem
set /p SHA256_7zip=

set SHA256=%SHA256_7zip:~-64%

if /I "%SHA256%" == "%~1" (
  exit 0
) else (
  echo Bad SHA-256 signatire
  exit 1
)
