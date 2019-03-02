unit Share;

interface

uses
  MSHTML, ActiveX, Variants, SysUtils, Graphics, Windows, ShlObj, ComObj, DateUtils;

const
  XML_MASTERNODE = 'XMLSetup';
  XML_SERVER_MASTERNODE = 'ServerList';
  XML_SERVER_GROUP = 'Group';
  XML_SERVER_SERVER = 'Server';
  XML_SERVER_NAME = 'Name';
  XML_SERVER_NODE_ADDRS = 'Addrs';
  XML_SERVER_NODE_PORT = 'Port';
  XML_SERVER_NODELIST = 'Child';
  XML_URL_MASTERNODE = 'Url';
  //XML_URL_HOME = 'Home';
  XML_URL_LFRAME = 'Loginframe';
  XML_URL_CONTACTGM = 'ContactGM';
  XML_URL_PAYMENT = 'Payment';
  XML_URL_REGISTER = 'Register';
  XML_URL_CHANGEPASS = 'ChangePass';
  XML_URL_LostPASS = 'LostPass';
  XML_UPDATE_MASTERNODE = 'UpDate';
  XML_CONFIG = 'Config';
  XML_UPDATE_SAVEDIR = 'SDir';
  XML_UPDATE_FILENAME = 'FName';
  XML_UPDATE_DOWNPATH = 'DUrl';
  XML_UPDATE_ZIP = 'ZIP';
  XML_UPDATE_CHECK = 'Check';
  XML_UPDATE_DOWNTYPE = 'DType';
  XML_UPDATE_DATE = 'Date';
  XML_UPDATE_VAR = 'VAR';
  XML_UPDATE_MD5 = 'MD5';
  XML_UPDATE_ID = 'ID';

  XML_ZIP_NO = '0';
  XML_ZIP_YES = '1';

  XML_CHECK_VAR = '0';
  XML_CHECK_EXISTS = '1';
  XML_CHECK_PACK = '2';
  XML_CHECK_MD5 = '3';

  XML_DOWNTYPE_DEF = '0';
  XML_DOWNTYPE_BAIDU = '1';

  BMP_PART_SIZE = $7CCF0;
  BMP_MAX_SIZE = $7CD2E;

type
  TBmpPartBuffer = array[0..BMP_PART_SIZE - 1] of Char;

  TBmpPartInfo = packed record
    BitmapFileHeader: TBitmapFileHeader;
    BitmapInfoHeader: TBitmapInfoHeader;
    nFileSize: Integer;
    nDataSize: Integer;
    //Data: TBmpPartBuffer;
  end;

function HtmlToText(HtmlText: WideString): WideString;
procedure CreateShortCut(FilePath: string; sName: string);

implementation

function HtmlToText(HtmlText: WideString): WideString;
var
  V: OleVariant;
  Document: IHTMLDocument2;
begin
  Result := HtmlText;
  if HtmlText = '' then
    Exit;
  CoInitialize(nil);
  Document := CoHTMLDocument.Create as IHtmlDocument2;
  try
    V := VarArrayCreate([0, 0], varVariant);
    V[0] := HtmlText;
    Document.Write(PSafeArray(TVarData(v).VArray));
    Document.Close;
    Result := Trim(Document.body.outerText);
  finally
    Document := nil;
    CoUninitialize;
  end;
end;

procedure CreateShortCut(FilePath: string; sName: string); //������ݷ�ʽ
var
  tmpObject: IUnknown;
  tmpSLink: IShellLink;
  tmpPFile: IPersistFile;
  PIDL: PItemIDList;
  StartupDirectory: array[0..MAX_PATH] of Char;
  LinkFilename: WideString;
  Name: string;
begin
  try
    tmpObject := CreateComObject(CLSID_ShellLink); //����������ݷ�ʽ�������չ
    tmpSLink := tmpObject as IShellLink; //ȡ�ýӿ�
    tmpPFile := tmpObject as IPersistFile; //��������*.lnk�ļ��Ľӿ�
    tmpSLink.SetPath(pChar(FilePath)); //�趨notepad.exe����·��
    tmpSLink.SetWorkingDirectory(pChar(ExtractFilePath(FilePath))); //�趨����Ŀ¼
    SHGetSpecialFolderLocation(0, CSIDL_DESKTOPDIRECTORY, PIDL); //��������Itemidlist
    SHGetPathFromIDList(PIDL, StartupDirectory); //�������·��
    Name := '\' + sName + '.lnk';
    LinkFilename := StartupDirectory + Name;
    tmpPFile.Save(pWChar(LinkFilename), FALSE); //����*.lnk�ļ�
  except
  end;
end;

//ʱ��ת��ΪGMT��ʽ

function DateTimeToGMT(const DateTime: TDateTime): string;
begin
  Result := FormatDateTime('ddd, dd mmm yyyy hh:mm:ss', IncHour(DateTime, -8));
  Result := StringReplace(Result, 'һ��', 'Jan', [rfReplaceAll]);
  Result := StringReplace(Result, '����', 'Feb', [rfReplaceAll]);
  Result := StringReplace(Result, '����', 'Mar', [rfReplaceAll]);
  Result := StringReplace(Result, '����', 'Apr', [rfReplaceAll]);
  Result := StringReplace(Result, '����', 'May', [rfReplaceAll]);
  Result := StringReplace(Result, '����', 'Jun', [rfReplaceAll]);
  Result := StringReplace(Result, '����', 'Jul', [rfReplaceAll]);
  Result := StringReplace(Result, '����', 'Aug', [rfReplaceAll]);
  Result := StringReplace(Result, '����', 'Sep', [rfReplaceAll]);
  Result := StringReplace(Result, 'ʮ��', 'Oct', [rfReplaceAll]);
  Result := StringReplace(Result, 'ʮһ��', 'Nov', [rfReplaceAll]);
  Result := StringReplace(Result, 'ʮ����', 'Dec', [rfReplaceAll]);
  Result := StringReplace(Result, '������', 'Sun', [rfReplaceAll]);
  Result := StringReplace(Result, '����һ', 'Mon', [rfReplaceAll]);
  Result := StringReplace(Result, '���ڶ�', 'Tue', [rfReplaceAll]);
  Result := StringReplace(Result, '������', 'Wed', [rfReplaceAll]);
  Result := StringReplace(Result, '������', 'Thu', [rfReplaceAll]);
  Result := StringReplace(Result, '������', 'Fri', [rfReplaceAll]);
  Result := StringReplace(Result, '������', 'Sat', [rfReplaceAll]);
  Result := Result + ' GMT';
end;

initialization
  OleInitialize(nil);

finalization
  try
    OleUninitialize;
  except
  end;

end.

