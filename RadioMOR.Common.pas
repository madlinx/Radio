unit RadioMOR.Common;

interface

uses
  System.SysUtils, Winapi.Windows, Vcl.Graphics, System.TypInfo, Winapi.ShlObj,
  System.IniFiles, Vcl.Dialogs, Winapi.Messages, Winapi.TlHelp32, Winapi.PsAPI,
  System.Classes, RadioMOR.Types, System.RegularExpressions, IdHTTP, System.JSON,
  System.WideStrUtils, System.DateUtils;

function ReduceBrightness(AColor: TColor; Percent: Byte): TColor;
function IncreaseBrightness(AColor: TColor; Percent: Byte): TColor;
function ColorToShadeOfGray(AColor: TColor): TColor;
function InvertColor(AColor: TColor): TColor;
function GetFileInfo(const FileName: TFileName; Information: string): string;
function GetFileVer(const sgFileName: string): string;
function GetTextWidthInPixels(const AText: string; ATextFont: TFont): Integer;
function GetSpecialFolderPath(AFolderID: DWORD): string;
function AppInstanceExists(AClassName: string): Boolean;
function FixCharset(AValue: string): string;
procedure GetIcecastServerStatistics(AURL: string; AStatictics: TIcecastStatisticsList);

implementation

function ReduceBrightness(AColor: TColor; Percent: Byte): TColor;
var
  R, G, B: Byte;
  Cl: Integer;
begin
  Cl := ColorToRGB(AColor);
  R := GetRValue(Cl);
  G := GetGValue(Cl);
  B := GetBValue(Cl);
  R := R - MulDiv(R, Percent, 100);
  G := G - MulDiv(G, Percent, 100);
  B := B - MulDiv(B, Percent, 100);
  Result := RGB(R, G, B);
end;

function IncreaseBrightness(AColor: TColor; Percent: Byte): TColor;
var
  R, G, B: Byte;
  Cl: Integer;
begin
  Cl := ColorToRGB(AColor);
  R := GetRValue(Cl);
  G := GetGValue(Cl);
  B := GetBValue(Cl);
  R := R + MulDiv(255 - R, Percent, 100);
  G := G + MulDiv(255 - G, Percent, 100);
  B := B + MulDiv(255 - B, Percent, 100);
  Result := RGB(R, G, B);
end;

function ColorToShadeOfGray(AColor: TColor): TColor;
var
  R, G, B, Gray: Byte;
  Cl: Integer;
begin
  Cl := ColorToRGB(AColor);
  R := GetRValue(Cl);
  G := GetGValue(Cl);
  B := GetBValue(Cl);
  Gray := Round((0.30 * R) + (0.59 * G) + (0.11 * B));
  Result := RGB(Gray, Gray, Gray);
end;

function InvertColor(AColor: TColor): TColor;
var
  R, G, B: Byte;
  Cl: Integer;
begin
  Cl := ColorToRGB(AColor);
  R := GetRValue(Cl);
  G := GetGValue(Cl);
  B := GetBValue(Cl);
  R := 255 - R;
  G := 255 - G;
  B := 255 - B;
  Result := RGB(R, G, B);
end;

function GetTextWidthInPixels(const AText: string; ATextFont: TFont): Integer;
var
  c: TBitmap;
begin
  Result := 0;
  c := TBitmap.Create;
  try
    c.Canvas.Font.Assign(ATextFont);
    Result := c.Canvas.TextWidth(AText);
  finally
    c.Free;
  end;
end;

function GetFileVer( const sgFileName : string ) : string;
var
  infoSize: DWORD;
  verBuf:   pointer;
  verSize:  UINT;
  wnd:      UINT;
  FixedFileInfo : PVSFixedFileInfo;
begin
  Result := '';
  infoSize := GetFileVersionInfoSize(PChar(sgFileName), wnd);
  if infoSize <> 0 then
  begin
    GetMem(verBuf, infoSize);
    try
      if GetFileVersionInfo(PChar(sgFileName), wnd, infoSize, verBuf) then
      begin
        VerQueryValue(verBuf, '\', Pointer(FixedFileInfo), verSize);

        Result := IntToStr(FixedFileInfo.dwFileVersionMS div $10000) + '.' +
                  IntToStr(FixedFileInfo.dwFileVersionMS and $0FFFF) + '.' +
                  IntToStr(FixedFileInfo.dwFileVersionLS div $10000) + '.' +
                  IntToStr(FixedFileInfo.dwFileVersionLS and $0FFFF);
      end;
    finally
      FreeMem(verBuf);
    end;
  end;
end;

function GetFileInfo(const FileName: TFileName; Information: string): string;
type
  PDWORD = ^DWORD;
  PLangAndCodePage = ^TLangAndCodePage;
  TLangAndCodePage = packed record
    wLanguage: WORD;
    wCodePage: WORD;
  end;
  PLangAndCodePageArray = ^TLangAndCodePageArray;
  TLangAndCodePageArray = array[0..0] of TLangAndCodePage;
var
  loc_InfoBufSize: DWORD;
  loc_InfoBuf: PChar;
  loc_VerBufSize: DWORD;
  loc_VerBuf: PChar;
  cbTranslate: DWORD;
  lpTranslate: PDWORD;
  i: DWORD;
begin
  Result := '';
  if (Length(FileName) = 0) or (not FileExists(FileName)) then Exit;
  loc_InfoBufSize := GetFileVersionInfoSize(PChar(FileName), loc_InfoBufSize);
  if loc_InfoBufSize > 0 then
  begin
    loc_VerBuf := nil;
    loc_InfoBuf := AllocMem(loc_InfoBufSize);
    try
      if not GetFileVersionInfo(PChar(FileName), 0, loc_InfoBufSize, loc_InfoBuf)
        then
        exit;
      if not VerQueryValue(loc_InfoBuf, '\\VarFileInfo\\Translation',
        Pointer(lpTranslate), DWORD(cbTranslate)) then
        exit;
      for i := 0 to (cbTranslate div SizeOf(TLangAndCodePage)) - 1 do
      begin
        if VerQueryValue(
          loc_InfoBuf,
          PChar(Format(
            'StringFileInfo\0%x0%x\%s', [
            PLangAndCodePageArray(lpTranslate)[i].wLanguage,
            PLangAndCodePageArray(lpTranslate)[i].wCodePage,
            Information])),
            Pointer(loc_VerBuf),
          DWORD(loc_VerBufSize)
          ) then
        begin
          Result := loc_VerBuf;
          Break;
        end;
      end;
    finally
      FreeMem(loc_InfoBuf, loc_InfoBufSize);
    end;
  end;
end;

function GetSpecialFolderPath(AFolderID: DWORD): string;
var
  DirPath: PChar;
begin
  Result := '';
  //if (GetDriveType(PChar(DirPath)) = DRIVE_REMOTE) then
  begin
    DirPath := StrAlloc(MAX_PATH);
    if SHGetSpecialFolderPath(0, DirPath, AFolderID, True) then
    begin
      Result := Format('%s%s', [IncludeTrailingBackslash(string(DirPath)), 'RadioMOR']);
      if not DirectoryExists(Result) then
        if not ForceDirectories(Result) then Result := '';
    end;
    StrDispose(DirPath);
  end;
end;

function AppInstanceExists(AClassName: string): Boolean;
const
  PROCESS_NAME_NATIVE = $00000001;
  PROCESS_QUERY_LIMITED_INFORMATION = $1000;
var
  hW: THandle;
  CopyDataStruct : TCopyDataStruct;
  Res: NativeInt;
  MsgBoxParam: TMsgBoxParams;
begin
  hW := 0;
  Result := False;
  hW := FindWindow(PChar(AClassName), nil);
  if hW > 0 then
  try
    with CopyDataStruct do
    begin
      dwData := 0;
      cbData := MAX_PATH;
      lpData := PChar('SHOW_WINDOW');
    end;

    Res := SendMessage(hW, WM_COPYDATA, Integer(0), Integer(@CopyDataStruct)) ;

    if Res = 0 then
    begin
      MessageBeep(MB_ICONASTERISK);
      MessageDlg(
        'Программа "Радио МНПЗ" уже запущена.',
        mtInformation,
        [mbOk],
        0
      );
    end else
    begin
      SetForegroundWindow(hW);
      //ShowWindow(MainWindow, SW_SHOW);
      //SetWindowPos(MainWindow,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
    end;
    Result := True;
  except
    Result := False;
  end;
end;

function FixCharset(AValue: string): string;
var
  RegEx: TRegEx;
  res: string;
begin
  case DetectUTF8Encoding(AnsiString(AValue)) of
    etUSASCII: begin
      res := AValue;
    end;

    etUTF8: begin
      RegEx := TRegEx.Create('п»ї', [roIgnoreCase]);
      res := UTF8ToString(RegEx.Replace(AValue, ''));
    end;

    etANSI: begin
      res := AValue;
    end;

    else begin
      res := AValue;
    end;
  end;

  Result := Trim(res);
end;

procedure GetIcecastServerStatistics(AURL: string; AStatictics: TIcecastStatisticsList);
var
  RegEx: TRegEx;
  IcecastURL: string;
  IdHTTP: TIdHTTP;
  ResponseContent: TStringStream ;
  JSONObject: TJSONObject;
  JSONArray: TJSONArray;
  JSONValue: TJSONValue;
  Statistics: PIcecastStatistics;
begin
  AStatictics.Clear;
  JSONObject := nil;
  RegEx := TRegEx.Create('^((http|https):\/\/)(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)*([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])*(:\d{1,5})*', [roIgnoreCase]);
  IcecastURL := RegEx.Match(AURL).Value;
  if IcecastURL.IsEmpty
    then Exit;

  IdHTTP := TIdHTTP.Create();
  try
    ResponseContent := TStringStream.Create;
    try
      IdHTTP.Get(IcecastURL + '/status-json.xsl', ResponseContent);
      ResponseContent.Position := 0;
      JSONObject := TJSONObject.ParseJSONValue(
        TEncoding.UTF8.GetBytes(ResponseContent.DataString), 0
      ) as TJSONObject;
      JSONObject := JSONObject.GetValue('icestats') as TJSONObject;
      JSONArray := JSONObject.GetValue('source') as TJSONArray;

      for JSONValue in JSONArray do
      try
        New(Statistics);
        FillChar(Statistics^, SizeOf(TIcecastStatistics), #0);
        with Statistics^ do
        begin
          try StreamName := FixCharset(JSONValue.GetValue<string>('server_name')) except end;
          try StreamDescription := FixCharset(JSONValue.GetValue<string>('server_description')) except end;
          try ContentType := FixCharset(JSONValue.GetValue<string>('server_type')) except end;
          try
            RegEx := TRegEx.Create('(?<=(T\d{2}:\d{2}:\d{2})[+-])(\d{2})', [roIgnoreCase]);
            StreamStarted := ISO8601ToDate(
              RegEx.Replace(JSONValue.GetValue<string>('stream_start_iso8601'), '$2:'),
              False
            );
          except

          end;
          try Channels := JSONValue.GetValue<Integer>('channels') except end;
          try Bitrate := JSONValue.GetValue<Integer>('bitrate') except end;
          try Samplerate := JSONValue.GetValue<Integer>('samplerate') except end;
          try Listeners := JSONValue.GetValue<Integer>('listeners') except end;
          try ListenersPeak := JSONValue.GetValue<Integer>('listener_peak') except end;
          try Genre := FixCharset(JSONValue.GetValue<string>('genre')) except end;
          try StreamURL := FixCharset(JSONValue.GetValue<string>('server_url')) except end;
          try CurrentlyPlaying := FixCharset(JSONValue.GetValue<string>('title')) except end;
          try ListenURL := FixCharset(JSONValue.GetValue<string>('listenurl')) except end;
        end;
        AStatictics.Add(Statistics);
      except
        Dispose(Statistics);
      end;
    finally
      ResponseContent.Free;
    end;
  finally
    IdHTTP.Free;
  end;
end;

end.
