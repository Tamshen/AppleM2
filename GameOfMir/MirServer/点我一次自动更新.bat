@echo off
echo 程序文件文件更新前,确保服务器已经关闭了所有程序!
pause

set MSDIR=D:\MirServer
Copy DBServer.exe %MSDIR%\DBServer\ /y
Copy LoginSrv.exe %MSDIR%\LoginSrv\ /y
Copy RunGate.exe %MSDIR%\RunGate\ /y
Copy SelGate.exe %MSDIR%\SelGate\ /y
Copy LoginGate.exe %MSDIR%\LoginGate\ /y
Copy M2Server.exe %MSDIR%\Mir200\ /y
Copy CoralWry.dat %MSDIR%\Mir200\ /y
Copy GameCenter.exe %MSDIR%\ /y
Copy LogDataServer.exe %MSDIR%\LogServer\ /y
echo 程序文件文件已更新完成. . .
pause