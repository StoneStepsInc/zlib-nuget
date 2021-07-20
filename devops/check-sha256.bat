@echo off

setlocal

set /p SHA256_7zip=

set SHA256=%SHA256_7zip:~-64%

if /I "%SHA256%" == "%~1" (
  exit 0
) else (
  exit 1
)
