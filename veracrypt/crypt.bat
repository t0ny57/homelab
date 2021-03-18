:: VeraCrypt Mouting Script
@echo off
set VC_EXE="path to Vera Crypt.exe"
set VC_CONTAINER=path to vc container
set VC_LETTER=K:
set VC_HASH=sha256 or sha512 or whirlpool or ripemd160 

if not exist %VC_EXE% (
	start %comspec% /c "mode 40,10&title Warning&color 0C&echo.&echo. %VC_EXE% doesn't exist&echo.&echo. Press a Enter key!&pause>NUL"
  
)else if exist %VC_LETTER% (
	start %comspec% /c "mode 40,10&title Warning&color 0C&echo.&echo.%VC_LETTER% is already in use&echo.&echo. Press a Enter key!&pause>NUL"
  
) else if not exist %VC_CONTAINER% (
	start %comspec% /c "mode 40,10&title Warning&color 0C&echo.&echo.%VC_CONTAINER% doesn't exist&echo.&echo. Press a Enter key!&pause>NUL"
  
) else if exist "%VC_CONTAINER%" (
 %VC_EXE%  /v "%VC_CONTAINER%" /l %VC_LETTER% /q /hash %VC_HASH%
)