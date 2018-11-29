unit RadioMOR.BassRadio;

interface

uses
  System.SysUtils, Vcl.Dialogs, Winapi.Windows, Vcl.ExtCtrls, BASS, Winapi.Messages,
  System.Classes, System.WideStrUtils, System.RegularExpressions;

const
  RadioLoading: string = 'Загрузка...';
  BASSErrCodes: array[-1..44] of String = (
    'Some other mystery error',
    'All is OK',
    'Memory error',
    'Can''t open the file',
    'Can''t find a free sound driver',
    'The sample buffer was lost',
    'Invalid handle',
    'Unsupported sample format',
    'Invalid playback position',
    'BASS_Init has not been successfully called',
    'BASS_Start has not been successfully called',
    'Unknown error',
    'Unknown error',
    'Unknown error',
    'Unknown error',
    'Already initialized/paused/whatever',
    'Unknown error',
    'Not paused',
    'Unknown error',
    'Can''t get a free channel',
    'An illegal type was specified',
    'An illegal parameter was specified',
    'No 3D support',
    'No EAX support',
    'Illegal device number',
    'Not playing',
    'Illegal sample rate',
    'Unknown error',
    'The stream is not a file stream',
    'Unknown error',
    'No hardware voices available',
    'Unknown error',
    'The MOD music has no sequence data',
    'No internet connection could be opened',
    'Couldn''t create the file',
    'Effects are not enabled',
    'The channel is playing',
    'Unknown error',
    'Requested data is not available',
    'The channel is a "decoding channel"',
    'A sufficient DirectX version is not installed',
    'Connection timedout',
    'Unsupported file format',
    'Unavailable speaker',
    'Invalid BASS version (used by add-ons)',
    'Codec is not available/supported'
  );

type
  TBassState = (bsNone, bsBusy, bsPlay, bsPause, bsStop, bsRecovery);

  TRadioState = TBassState.bsNone..TBassState.bsRecovery;

  TRadioMetaData = record
    Name: string;
    Description: string;
    Genre: string;
    URL: string;
    Bitrate: string;
    Samplerate: string;
    Channels: string;
    procedure Clear;
  end;

  TBassRadio = class(TObject)
  private
    FHandle: HWND;
    FStream: HSTREAM;
    FStreamThread: THandle;
    FURL: string;
    FFreeStreamOnStop: Boolean;
    FState: TRadioState;
    FTitle: string;
    FCustomTitle: string;
    FUseCustomTitle: Boolean;
    FErrMessage: string;
    FStreamStatus: string;
    FStreamTitle: string;
    FProcessInfo: string;
    FMetaData: TRadioMetaData;
    FRecoveryOnConnectionLoss: Boolean;
    FConnectionRecovery: Boolean;
    FConnectionRecoveryTimer: TTimer;
    FVolume: Byte;
    FOnPlay: TNotifyEvent;
    FOnStop: TNotifyEvent;
    FOnTitleChange: TNotifyEvent;
    FOnPlayEnd: TNotifyEvent;
    FOnStreamFree: TNotifyEvent;
    procedure Clear;
    procedure GetLoadingProgress;
    procedure GetMetaData;
    procedure SetVolume(Value: Byte);
    procedure EnableConnectionRecovery(AEnable: Boolean);
    procedure OnConnectionRecoveryTimer(Sender: TObject);
    function BassErrorString: string;
    function GetSamplerate: Integer;
    function GetBitrate: Integer;
    function GetChannels: Integer;
    function DecodeMetaText(AInput: string): string;
  protected
    { Protected declarations }
    destructor Destroy; override;
  public
    { Public declarations }
    constructor Create(AHandle: HWND; AFreeStreamOnStop: Boolean = True); virtual;
    procedure Play(AURL: string);
    procedure Stop;
    procedure SetCustomTitle(ATitle: string; AForced: Boolean = False);
    function ElapsedTime: string;
    property URL: string read FURL;
    property Stream: HSTREAM read FStream;
    property State: TRadioState read FState;
    property Title: string read FTitle;
    property StreamTitle: string read FStreamTitle;
    property StreamStatus: string read FStreamStatus;
    property ProcessInfo: string read FProcessInfo;
    property Samplerate: Integer read GetSamplerate;
    property Bitrate: Integer read GetBitrate;
    property Channels: Integer read GetChannels;
    property ErrMessage: string read FErrMessage;
    property MetaData: TRadioMetaData read FMetaData;
    property RecoveryOnConnectionLoss: Boolean read FRecoveryOnConnectionLoss write FRecoveryOnConnectionLoss;
    property Volume: Byte read FVolume write SetVolume;
    property OnPlay: TNotifyEvent read FOnPlay write FOnPlay;
    property OnStop: TNotifyEvent read FOnStop write FOnStop;
    property OnTitleChange: TNotifyEvent read FOnTitleChange write FOnTitleChange;
    property OnPlayEnd: TNotifyEvent read FOnPlayEnd write FOnPlayEnd;
    property OnStreamFree: TNotifyEvent read FOnStreamFree write FOnStreamFree;
  end;

implementation

{ Event Handlers }

procedure Handle_StreamDownload(ABuffer: Pointer; ALength: DWORD; AUser: Pointer); stdcall;
begin
 if (ABuffer <> nil) and (ALength = 0) then
 begin
   TBassRadio(AUser).FStreamStatus := PAnsiChar(ABuffer);
 end;
end;

procedure Handle_FreeStream(AHandle: HSYNC; AStream, AData: DWORD; AUser: Pointer); stdcall;
begin
  TBassRadio(AUser).FState := bsNone;
  if Assigned(@TBassRadio(AUser).FOnStreamFree)
    then TBassRadio(AUser).FOnStreamFree(TBassRadio(AUser));
end;

procedure Handle_PlayEnd(AHandle: HSYNC; AStream, AData: DWORD; AUser: Pointer); stdcall;
var
  _url: string;
  _title: string;
  _customtitle: Boolean;
begin
  { Создаем резервные копии полей радио, т.к. после вызова метода Stop они затрутся }
  _url := TBassRadio(AUser).FURL;
  _title := TBassRadio(AUser).FCustomTitle;
  _customtitle := TBassRadio(AUser).FUseCustomTitle;

  TBassRadio(AUser).Stop;

  if TBassRadio(AUser).FRecoveryOnConnectionLoss then
  begin
    { Восстанавливаем значения полей радио и пытаемся восстановить подключение }
    TBassRadio(AUser).FURL := _url ;
    TBassRadio(AUser).FCustomTitle := _title;
    TBassRadio(AUser).FUseCustomTitle := _customtitle;
    TBassRadio(AUser).EnableConnectionRecovery(True);
  end;

  if Assigned(@TBassRadio(AUser).FOnPlayEnd)
    then TBassRadio(AUser).FOnPlayEnd(TBassRadio(AUser));
end;

procedure Handle_MetaReceive(AHandle: HSYNC; AStream, AData: DWORD; AUser: Pointer); stdcall;
var
  Title: string;
  Meta: PAnsiChar;
  p: Integer;
begin
  TBassRadio(AUser).GetMetaData;

  if not TBassRadio(AUser).FUseCustomTitle then
  case TBassRadio(AUser).FMetaData.Name.IsEmpty of
    False: TBassRadio(AUser).FTitle := Trim(TBassRadio(AUser).FMetaData.Name);
    True: begin
      if TBassRadio(AUser).FCustomTitle.IsEmpty then
      begin
        Title := StringReplace(TBassRadio(AUser).URL, '/', '\', [rfReplaceAll]);
        TBassRadio(AUser).FTitle := ExtractFileName(Title);
      end else
      begin
        TBassRadio(AUser).FTitle := TBassRadio(AUser).FCustomTitle;
      end;
    end;
  end else TBassRadio(AUser).FTitle := TBassRadio(AUser).FCustomTitle;

  Title := '';
  Meta := BASS_ChannelGetTags(TBassRadio(AUser).FStream, BASS_TAG_META);
  if (Meta <> nil) then
  begin
    p := Pos('StreamTitle=', string(Meta));
    if (p > 0) then
    begin
      p := p + 13;
      Title := Copy(Meta, p, Pos(';', string(Meta)) - p - 1);
    end;
  end;
  TBassRadio(AUser).FStreamTitle := TBassRadio(AUser).DecodeMetaText(Title);

  if Assigned(@TBassRadio(AUser).FOnTitleChange)
    then TBassRadio(AUser).FOnTitleChange(TBassRadio(AUser));
end;

{ TBassRadio }

procedure TBassRadio.EnableConnectionRecovery(AEnable: Boolean);
begin
  FConnectionRecovery := AEnable;
  FConnectionRecoveryTimer.Enabled := AEnable;
  FConnectionRecoveryTimer.Tag := 0;
end;

function TBassRadio.BassErrorString: string;
var
  ErrCode: Integer;
begin
  ErrCode := BASS_ErrorGetCode;
  case ErrCode of
    BASS_ERROR_UNKNOWN  : Result := 'BASS_ERROR_UNKNOWN';
    BASS_ERROR_MEM      : Result := 'BASS_ERROR_MEM';
    BASS_ERROR_FILEOPEN : Result := 'BASS_ERROR_FILEOPEN';
    BASS_ERROR_DRIVER   : Result := 'BASS_ERROR_DRIVER';
    BASS_ERROR_BUFLOST  : Result := 'BASS_ERROR_BUFLOST';
    BASS_ERROR_HANDLE   : Result := 'BASS_ERROR_HANDLE';
    BASS_ERROR_FORMAT   : Result := 'BASS_ERROR_FORMAT';
    BASS_ERROR_POSITION : Result := 'BASS_ERROR_POSITION';
    BASS_ERROR_INIT     : Result := 'BASS_ERROR_INIT';
    BASS_ERROR_START    : Result := 'BASS_ERROR_START';
    BASS_ERROR_ALREADY  : Result := 'BASS_ERROR_ALREADY';
    BASS_ERROR_NOCHAN   : Result := 'BASS_ERROR_NOCHAN';
    BASS_ERROR_ILLTYPE  : Result := 'BASS_ERROR_ILLTYPE';
    BASS_ERROR_ILLPARAM : Result := 'BASS_ERROR_ILLPARAM';
    BASS_ERROR_NO3D     : Result := 'BASS_ERROR_NO3D';
    BASS_ERROR_NOEAX    : Result := 'BASS_ERROR_NOEAX';
    BASS_ERROR_DEVICE   : Result := 'BASS_ERROR_DEVICE';
    BASS_ERROR_NOPLAY   : Result := 'BASS_ERROR_NOPLAY';
    BASS_ERROR_FREQ     : Result := 'BASS_ERROR_FREQ';
    BASS_ERROR_NOTFILE  : Result := 'BASS_ERROR_NOTFILE';
    BASS_ERROR_NOHW     : Result := 'BASS_ERROR_NOHW';
    BASS_ERROR_EMPTY    : Result := 'BASS_ERROR_EMPTY';
    BASS_ERROR_NONET    : Result := 'BASS_ERROR_NONET';
    BASS_ERROR_CREATE   : Result := 'BASS_ERROR_CREATE';
    BASS_ERROR_NOFX     : Result := 'BASS_ERROR_NOFX';
    BASS_ERROR_NOTAVAIL : Result := 'BASS_ERROR_NOTAVAIL';
    BASS_ERROR_DECODE   : Result := 'BASS_ERROR_DECODE';
    BASS_ERROR_DX       : Result := 'BASS_ERROR_DX';
    BASS_ERROR_TIMEOUT  : Result := 'BASS_ERROR_TIMEOUT';
    BASS_ERROR_FILEFORM : Result := 'BASS_ERROR_FILEFORM';
    BASS_ERROR_SPEAKER  : Result := 'BASS_ERROR_SPEAKER';
    BASS_ERROR_VERSION  : Result := 'BASS_ERROR_VERSION';
    BASS_ERROR_CODEC    : Result := 'BASS_ERROR_CODEC';
    BASS_ERROR_ENDED    : Result := 'BASS_ERROR_ENDED';
  end;
  Result := Result + ' (' + IntToStr(ErrCode) + ')';
end;

procedure TBassRadio.Clear;
begin
  FURL := '';
  FTitle := '';
  FCustomTitle := '';
  FUseCustomTitle := False;
  FErrMessage := '';
  FStreamStatus := '';
  FProcessInfo := '';
  FStreamTitle := '';
  FMetaData.Clear;
end;

constructor TBassRadio.Create(AHandle: HWND; AFreeStreamOnStop: Boolean = True);
var
  BassInfo: BASS_INFO;
begin
  Self.FHandle := AHandle;
  FFreeStreamOnStop := AFreeStreamOnStop;
  FState := bsNone;
  FRecoveryOnConnectionLoss := False;
  FVolume := 100;
//  BASS_SetConfig(BASS_CONFIG_DEV_DEFAULT, 1);
  if not BASS_Init(-1, 44100, 0, AHandle, nil) then
  begin
    raise Exception.Create('BASS.DLL not Loaded!' + #13 + BassErrorString);
    Halt;
  end else
  begin
    BASS_GetInfo(BassInfo);
    if (BassInfo.maxrate > 44100) then
    begin
      BASS_Free;
      if not BASS_Init(-1, BassInfo.maxrate, 0, AHandle, nil) then
        if not BASS_Init(-1, 44100, 0, AHandle, nil) then
        begin
          raise Exception.Create('BASS.DLL not Loaded!' + #13 + BassErrorString);
          Halt;
        end;
    end;
  end;
  BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST, 1);
  BASS_SetConfig(BASS_CONFIG_NET_PREBUF, 0);

  FConnectionRecoveryTimer := TTimer.Create(nil);
  with FConnectionRecoveryTimer do
  begin
    Enabled := False;
    Interval := 1000;
    OnTimer := OnConnectionRecoveryTimer;
    Tag := 0;
  end;
end;

destructor TBassRadio.Destroy;
begin
  BASS_ChannelStop(FStream);
  BASS_StreamFree(FStream);
  BASS_Free;
  FConnectionRecoveryTimer.Free;
  inherited;
end;

function TBassRadio.ElapsedTime: string;
var
  Seconds: Double;
  m, s: Integer;
begin
  Seconds := BASS_ChannelBytes2Seconds(FStream,
    BASS_ChannelGetPosition(FStream, BASS_POS_BYTE));
  s := Round(Seconds);
  m := s div 60;
  if m < 60 then Result := Format('%.2d:%.2d', [m, s mod 60])
    else Result := Format('%.d:%.2d:%.2d', [m div 60, m mod 60, s mod 60]);
end;

function TBassRadio.DecodeMetaText(AInput: string): string;
var
  RegEx: TRegEx;
  res: string;
begin
  case DetectUTF8Encoding(AnsiString(AInput)) of
    etUSASCII: begin
      res := AInput;
    end;

    etUTF8: begin
      RegEx := TRegEx.Create('п»ї', [roIgnoreCase]);
      res := UTF8ToString(RegEx.Replace(AInput, ''));
    end;

    etANSI: begin
      res := AInput;
    end;

    else begin
      res := AInput;
    end;
  end;

  Result := Trim(res);
end;

procedure TBassRadio.GetMetaData;
var
  ICY: PAnsiChar;
  valList: TStringList;
  i: Integer;
  tagName: TRegEx;
  tagDescription: TRegEx;
  tagGenre: TRegEx;
  tagURL: TRegEx;
  tagBitrate: TRegEx;
  tagAudioInfo: TRegEx;
begin
  tagName := TRegEx.Create('^icy-name:\s*', [roIgnoreCase]);
  tagDescription := TRegEx.Create('^icy-description:\s*', [roIgnoreCase]);
  tagGenre := TRegEx.Create('^icy-genre:\s*', [roIgnoreCase]);
  tagURL := TRegEx.Create('^icy-url:\s*', [roIgnoreCase]);
  tagBitrate := TRegEx.Create('^icy-br:\s*', [roIgnoreCase]);
  tagAudioInfo := TRegEx.Create('^ice-audio-info:\s*', [roIgnoreCase]);

  FMetaData.Clear;
  ICY := BASS_ChannelGetTags(FStream, BASS_TAG_ICY);
  if ICY = nil
    then ICY := BASS_ChannelGetTags(FStream, BASS_TAG_HTTP);

  if ICY <> nil then
  while ICY^ <> #0 do
  begin
    if tagName.IsMatch(ICY) then
    begin
      FMetaData.Name := DecodeMetaText(Trim(tagName.Replace(ICY, '')));
    end

    else if tagDescription.IsMatch(ICY) then
    begin
      FMetaData.Description := DecodeMetaText(Trim(tagDescription.Replace(ICY, '')));
    end

    else if tagGenre.IsMatch(ICY) then
    begin
      FMetaData.Genre := DecodeMetaText(Trim(tagGenre.Replace(ICY, '')));
    end

    else if tagURL.IsMatch(ICY) then
    begin
      FMetaData.URL := Trim(tagURL.Replace(ICY, ''));
    end

    else if tagBitrate.IsMatch(ICY) then
    begin
      FMetaData.Bitrate := Trim(tagBitrate.Replace(ICY, ''));
    end

    else if tagAudioInfo.IsMatch(ICY) then
    begin
      valList := TStringList.Create;
      try
        valList.Delimiter := ';';
        valList.StrictDelimiter := True;
        valList.DelimitedText := Trim(tagAudioInfo.Replace(ICY, ''));
        for i := 0 to valList.Count - 1 do
        begin
          if TRegEx.Match(valList.Names[i], 'bitrate', [roIgnoreCase]).Success
            then FMetaData.Bitrate := valList.ValueFromIndex[i]

          else if TRegEx.Match(valList.Names[i], 'samplerate', [roIgnoreCase]).Success
            then FMetaData.Samplerate := valList.ValueFromIndex[i]

          else if TRegEx.Match(valList.Names[i], 'channels', [roIgnoreCase]).Success
            then FMetaData.Channels := valList.ValueFromIndex[i]
        end;
      finally
        valList.Free;
      end;
    end;

    ICY := ICY + Length(ICY) + 1;
  end;
end;

function TBassRadio.GetChannels: Integer;
var
  ChannelInfo: BASS_CHANNELINFO;
begin
	Result := 0;
	if State in [bsNone, bsBusy] then Exit;
  BASS_ChannelGetInfo(FStream, ChannelInfo);
  Result := ChannelInfo.chans;
end;

procedure TBassRadio.GetLoadingProgress;
var
  Len, Progress: DWORD;
begin
  repeat
    Len := BASS_StreamGetFilePosition(FStream, BASS_FILEPOS_END);
    if (Len = DW_ERROR) then Break;
    Progress := BASS_StreamGetFilePosition(FStream, BASS_FILEPOS_BUFFER) * 100 div Len;
    FProcessInfo := Format(RadioLoading + ' %d%%', [Progress]);
    if Assigned(@FOnTitleChange) then FOnTitleChange(Self);
  until
    (Progress > 90) or (BASS_StreamGetFilePosition(FStream, BASS_FILEPOS_CONNECTED) = 0);
  FProcessInfo := '';
end;

function TBassRadio.GetSamplerate: Integer;
var
  ChannelInfo: BASS_CHANNELINFO;
begin
	Result := 0;
	if State in [bsNone, bsBusy] then Exit;
  BASS_ChannelGetInfo(FStream, ChannelInfo);
  Result := ChannelInfo.freq;
end;

procedure TBassRadio.OnConnectionRecoveryTimer(Sender: TObject);
const
  _timeout: Cardinal = 15;
begin
  FState := bsRecovery;
  if FConnectionRecoveryTimer.Tag >= _timeout then
  begin
    FConnectionRecoveryTimer.Enabled := False;
    FConnectionRecoveryTimer.Tag := 0;
    FState := bsNone;
    Self.Play(FURL);
  end else
  begin
    FConnectionRecoveryTimer.Tag := FConnectionRecoveryTimer.Tag + 1;
    FProcessInfo := Format(
        'Попытка переподключения... %d',
        [(_timeout + 1) - FConnectionRecoveryTimer.Tag]
    );
    if Assigned(FOnTitleChange) then FOnTitleChange(Self);
  end;
end;

function TBassRadio.GetBitrate: Integer;
begin
  try
    Result := Round(
        BASS_StreamGetFilePosition(FStream, BASS_FILEPOS_END) * 8
        / BASS_GetConfig(BASS_CONFIG_NET_BUFFER)
    );
  except
    Result := 0;
  end;
end;

procedure TBassRadio.Play(AURL: string);
var
  _recovery: Boolean;
begin
  if CompareText(AURL, FURL) = 0
    then _recovery := FConnectionRecovery
    else _recovery := False;

  if (CompareText(AURL, FURL) <> 0) or (State in [bsNone, bsStop]) then
    try
      Stop;
      FState := bsBusy;
      FProcessInfo := RadioLoading;
      FURL := AURL;
      if Assigned(@FOnTitleChange) then FOnTitleChange(Self);
      FStream := BASS_StreamCreateURL(
          PAnsiChar(AnsiString(AURL)),
          0,
          BASS_STREAM_BLOCK or BASS_STREAM_STATUS or BASS_STREAM_AUTOFREE,
          @Handle_StreamDownload,
          Self
      );
      if FStream = 0 then
      begin
        FState := bsNone;
        FErrMessage := BassErrorString;
        FProcessInfo := '';
        EnableConnectionRecovery(_recovery);
      end else
      begin
        EnableConnectionRecovery(False);
        GetLoadingProgress;
        GetMetaData;
        BASS_ChannelSetSync(FStream, BASS_SYNC_END, 0, @Handle_PlayEnd, Self);
        BASS_ChannelSetSync(FStream, BASS_SYNC_FREE, 0, @Handle_FreeStream, Self);
        BASS_ChannelSetSync(FStream, BASS_SYNC_META, 0, @Handle_MetaReceive, Self);
        Volume := FVolume;
        case Boolean(BASS_ChannelPlay(FStream, False)) of
          False: begin
            FErrMessage := BassErrorString;
            FState := bsStop;
          end;
          True: FState := bsPlay;
        end;
      end;
      Handle_MetaReceive(FHandle, FStream, 0, Self);
      if Assigned(@FOnPlay) then FOnPlay(Self);
    except
      on E:Exception do
      begin
        FState := bsNone;
        BASS_StreamFree(FStream);
        FErrMessage := 'Ошибка:' + E.Message;
      end;
    end;
end;

procedure TBassRadio.SetCustomTitle(ATitle: string; AForced: Boolean);
begin
  FCustomTitle := ATitle;
  FUseCustomTitle := AForced;
  Handle_MetaReceive(FHandle, FStream, 0, Self);
end;

procedure TBassRadio.SetVolume(Value: Byte);
begin
  FVolume := Value;
  if FVolume > 100 then FVolume := 100;
  BASS_ChannelSetAttribute(FStream, BASS_ATTRIB_VOL, FVolume / 100);
end;

procedure TBassRadio.Stop;
begin
  EnableConnectionRecovery(False);
  if not (Self.State in [bsNone, bsStop]) then
  begin
    BASS_ChannelStop(FStream);
    Clear;
    FState := bsStop;
    if FFreeStreamOnStop then
    begin
      BASS_StreamFree(FStream);
      FState := bsNone;
    end;
    if Assigned(@FOnStop) then FOnStop(Self);
  end;
end;

{ TRadioMetaData }

procedure TRadioMetaData.Clear;
begin
  Name := '';
  Description := '';
  Genre := '';
  URL := '';
  Bitrate := '';
  Samplerate := '';
  Channels := '';
end;

end.
