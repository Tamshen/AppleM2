unit Share;

interface
uses
  Windows, Classes, JSocket;

const
  GATEMAXSESSION = 20; //����û�������
  MAXREADSIZE = 1024 * 1024;

type
  pTUserSession = ^TUserSession;
  TUserSession = packed record
    Socket: TCustomWinSocket; //0x00
    SocketHandle: Integer; //0x28
    sRemoteIPaddr: string; //0x04
    ReadBuffer: PChar;
    nReadLength: Integer;
    SendBuffer: PChar;
    nSendLength: Integer;
    boConnectCheck: Boolean; //�Ƿ�ͨ�����Ӽ��
    dwConnectTick: LongWord;
    FileStream: TFileStream;
    //nSendLength: Integer;
  end;

var
  g_SessionArray: array[0..GATEMAXSESSION - 1] of TUserSession;
  g_nSessionCount: Integer = 0;
  g_dwCheckSessionTick: LongWord = 0;

implementation

end.
