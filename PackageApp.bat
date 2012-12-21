@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

:target
::set AIR_TARGET=
::set AIR_TARGET=-captive-runtime
set AIR_TARGET=bundle
set OPTIONS=

:output
if not exist %AIR_PATH% md %AIR_PATH%
::set OUTPUT=%AIR_PATH%\%AIR_NAME%%AIR_TARGET%.air
set OUTPUT=bin\%AIR_NAME%

call bat\Packager.bat

pause