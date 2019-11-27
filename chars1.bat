set PLAYONLINE_HOME=D:\Software\SteamLibrary\steamapps\common\FFXINA\SquareEnix\PlayOnlineViewer
set ASHITA_HOME=D:\Software\Ashita
copy "%PLAYONLINE_HOME%\usr\all\chars1.bin" "%PLAYONLINE_HOME%\usr\all\login_w.bin"
del /Q %ASHITA_HOME%\config\boot\*
mkdir %ASHITA_HOME%\config\boot\
copy "%ASHITA_HOME%\config\bootChars1\*" "%ASHITA_HOME%\config\boot"
%ASHITA_HOME%\Ashita.exe