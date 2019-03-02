unit Check;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PsAPI, StdCtrls;

//ͨ�����ھ����ȡ����PID
//Windows.GetWindowThreadProcessId(Handle, @PID)

//ö�����н��̵�PID,����һ array of DWord ,������(����һ����), �������� -1 Ϊ����
function EnumProcessesPID(lpidProcess: LPDWORD; cb: DWORD): Integer;

//ö�����н��̵�PID,����һ ����PID�������� array of DWord ,������(����һ����), �������� -1 Ϊ����
function EnumProcessesModuleByPID(dwPID: LongWord; lpidProcess: LPDWORD; cb: DWORD): Integer;

//ͨ��PID��ȡ��������·��������һ ����PID����������ģʽID, ������(����·��������)�� ������ ���������ȣ� ����·������
function GetProcessPathByPID(dwPID, nModule: LongWord; Buffer: PChar; BufferLen: Integer): Integer;

//ͨ��PID��ȡ�������ƣ�����һ ����PID����������ģʽID�� ������(����·��������)�� ������ ���������ȣ� ����·������
function GetProcessNameByPID(dwPID, nModule: LongWord; Buffer: PChar; BufferLen: Integer): Integer;

implementation

function EnumProcessesPID(lpidProcess: LPDWORD; cb: DWORD): Integer;
var
  nCount: LongWord;
begin
  Result := -1;
  if not EnumProcesses(lpidProcess, cb, nCount) then
    exit;
  Result := nCount div 4;
end;

function EnumProcessesModuleByPID(dwPID: LongWord; lpidProcess: LPDWORD; cb: DWORD): Integer;
var
  nCount: LongWord;
  Handle: THandle;
begin
  Result := -1;
  if dwPID > 10 then begin
    Handle := OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwPID);
    try
      if not EnumProcessModules(Handle, lpidProcess, cb, nCount) then
        exit;
    finally
      CloseHandle(Handle);
    end;
    Result := nCount div 4;
  end;
end;

function GetProcessPathByPID(dwPID, nModule: LongWord; Buffer: PChar; BufferLen: Integer): Integer;
var
  Handle: THandle;
begin
  Result := -1;
  if dwPID > 10 then begin
    Handle := OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwPID);
    try
      if Handle > 0 then begin
        Result := GetModuleFileNameEx(Handle, nModule, Buffer, BufferLen);
      end;
    finally
      CloseHandle(Handle);
    end;
  end;
end;

function GetProcessNameByPID(dwPID, nModule: LongWord; Buffer: PChar; BufferLen: Integer): Integer;
var
  Handle: THandle;
begin
  Result := -1;
  if dwPID > 10 then begin
    Handle := OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwPID);
    try
      if Handle > 0 then begin
        Result := GetModuleBaseNameA(Handle, nModule, Buffer, BufferLen);
      end;
    finally
      CloseHandle(Handle);
    end;
  end;
end;

end.

