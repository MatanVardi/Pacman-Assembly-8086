@echo off
echo Assembling the code...
tasm /zi pacman.asm
if errorlevel 1 goto error
echo Linking the object file...
tlink /v pacman.obj
if errorlevel 1 goto error
echo Build successful!
goto end

:error
echo Build failed! Check the error messages above.
:end
