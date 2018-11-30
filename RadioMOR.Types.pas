unit RadioMOR.Types;

interface

uses
   System.SysUtils, System.Hash, System.RegularExpressions, Winapi.Windows,
   System.WideStrUtils, System.DateUtils, System.Classes, IdHTTP, System.JSON;

const
  RADIO_VIEW_STANDARD = 1;
  RADIO_VIEW_PLAYLIST = 2;

  RADIO_HEIGHT_STANDARD = 130;
  RADIO_HEIGHT_PLAYLIST = 335;

  RADIO_INI_FILE_APPLICATION = 'radiomor.ini';
  RADIO_INI_FILE_PERSONAL    = 'settings.ini';

  PLAYLIST_MENU_REFRESH = 0;
  PLAYLIST_MENU_PLAY    = 2;
  PLAYLIST_MENU_STAT    = 3;
  PLAYLIST_MENU_SRVSTAT = 5;

  MSGFLT_RESET    = 0;
  MSGFLT_ALLOW    = 1;
  MSGFLT_DISALLOW = 2;

type
  TStreamChannels = type Integer;

  TStreamChannelsHelper = record helper for TStreamChannels
  public
    function AsString: string;
  end;

type
  TStreamDateTime = type TDateTime;

  TStreamDateTimeHelper = record helper for TStreamDateTime
  public
    function AsString(AFormat: string): string;
  end;

type
  TStreamBitrate = type Integer;

  TStreamBitrateHelper = record helper for TStreamBitrate
  public
    function AsString: string;
  end;

type
  TStreamSamplerate = type Integer;

  TStreamSamplerateHelper = record helper for TStreamSamplerate
  public
    function AsString: string;
  end;

type
  PIcecastStatistics = ^TIcecastStatistics;
  TIcecastStatistics = record
    Station: string;
    StreamName:	string;
    StreamDescription: string;
    ContentType: string;
    StreamStarted: TStreamDateTime;
    Channels: TStreamChannels;
    Bitrate: TStreamBitrate;
    Samplerate: TStreamSamplerate;
    Listeners: Integer;
    ListenersPeak: Integer;
    Genre: string;
    StreamURL: string;
    CurrentlyPlaying: string;
    ListenURL: string;
  end;

  TIcecastStatisticsList = class(TList)
  private
    FOwnsObjects: Boolean;
    function Get(Index: Integer): PIcecastStatistics;
  public
    constructor Create(AOwnsObjects: Boolean = True); reintroduce;
    destructor Destroy; override;
    function Add(Value: PIcecastStatistics): Integer;
    procedure Clear; override;
    property Items[Index: Integer]: PIcecastStatistics read Get; default;
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
  end;

type
  TRadioStation = class(TObject)
  private
    FID: string;
    FURL: string;
    FDuration: Integer;
    FStation: string;
    FTitle: string;
    function FixCharset(AValue: string): string;
  public
    class function GenerateID(AURL: string): string;
    constructor Create(AEXTINF, AURL: string);
    procedure GetIcecastStatus(AOut: PIcecastStatistics);
    property ID: string read FID;
    property Duration: Integer read FDuration;
    property URL: string read FURL;
    property Station: string read FStation;
    property Title: string read FTitle;
  end;

type
  TChangeFilterStruct = record
    cbSize: DWORD;
    ExtStatus: DWORD;
  end;

  PChangeFilterStruct = ^TChangeFilterStruct;

type
  TCustomFontArray = array of HFONT;

implementation

{ TRadioStation }

constructor TRadioStation.Create(AEXTINF, AURL: string);
var
  RegEx: TRegEx;
begin
  inherited Create;

  RegEx := TRegEx.Create('(^#EXTINF:\s*)|(,.*$)', [roIgnoreCase]);
  FDuration := StrToIntDef(Trim(RegEx.Replace(AEXTINF, '')), -1);

  RegEx := TRegEx.Create('(^#EXTINF:-{0,1}\d+,)|(\s+-\s+.*$)', [roIgnoreCase]);
  FStation := Trim(RegEx.Replace(AEXTINF, ''));

  RegEx := TRegEx.Create('^#EXTINF:-{0,1}\d+,.*\s-\s.*', [roIgnoreCase]);
  if not RegEx.IsMatch(AEXTINF) then FTitle := '' else
  begin
    RegEx := TRegEx.Create('(^#EXTINF:-{0,1}\d+,)|(.*[^\s]\s-\s)', [roIgnoreCase]);
    FTitle := Trim(RegEx.Replace(AEXTINF, ''));
  end;

  Self.FURL := AURL;
  Self.FID := GenerateID(AURL);
end;

function TRadioStation.FixCharset(AValue: string): string;
var
  RegEx: TRegEx;
  res: string;
begin
  case DetectUTF8Encoding(AnsiString(AValue)) of
    etUSASCII: begin
      res := AValue;
    end;

    etUTF8: begin
      RegEx := TRegEx.Create('﻿', [roIgnoreCase]);
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

class function TRadioStation.GenerateID(AURL: string): string;
var
  HashSHA1: THashSHA1;
begin
  HashSHA1 := THashSHA1.Create;
  HashSHA1.Update(AnsiLowerCase(Trim(AURL)));
  Result := HashSHA1.HashAsString;
end;

procedure TRadioStation.GetIcecastStatus(AOut: PIcecastStatistics);
var
  RegEx: TRegEx;
  IcecastURL: string;
  IdHTTP: TIdHTTP;
  ResponseContent: TStringStream ;
  JSONObject: TJSONObject;
  JSONArray: TJSONArray;
  JSONValue: TJSONValue;
begin
  FillChar(AOut^, SizeOf(TIcecastStatistics), #0);
  JSONObject := nil;
  RegEx := TRegEx.Create('^((http|https):\/\/)(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)*([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])*(:\d{1,5})*', [roIgnoreCase]);
  IcecastURL := RegEx.Match(Self.FURL).Value;
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
        if Self.FID = GenerateID(JSONValue.GetValue<string>('listenurl')) then
        begin
          with AOut^ do
          begin
            Station := Self.FStation;
            try StreamName := FixCharset(JSONValue.GetValue<string>('server_name')) except end;
            try StreamDescription := FixCharset(JSONValue.GetValue<string>('server_description')) except end;
            try ContentType := FixCharset(JSONValue.GetValue<string>('server_type')) except end;
            try 
              RegEx := TRegEx.Create('(?<=(T\d{2}:\d{2}:\d{2})[+-])(\d{2})', [roIgnoreCase]);
              StreamStarted := ISO8601ToDate(RegEx.Replace(JSONValue.GetValue<string>('stream_start_iso8601'), '$2:'));
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
          Break;
        end;
      except

      end;
    finally
      ResponseContent.Free;
    end;
  finally
    IdHTTP.Free;
  end;
end;

{ TIcecastStatisticsList }

function TIcecastStatisticsList.Add(Value: PIcecastStatistics): Integer;
begin
  Result := inherited Add(Value);
end;

procedure TIcecastStatisticsList.Clear;
var
  i: Integer;
begin
  if FOwnsObjects
    then for i := Self.Count - 1 downto 0 do
      Dispose(Self.Items[i]);

  inherited Clear;
end;

constructor TIcecastStatisticsList.Create(AOwnsObjects: Boolean);
begin
  inherited Create;
  FOwnsObjects := AOwnsObjects;
end;

destructor TIcecastStatisticsList.Destroy;
begin
  Clear;
  inherited;
end;

function TIcecastStatisticsList.Get(Index: Integer): PIcecastStatistics;
begin
  Result := PIcecastStatistics(inherited Get(Index));
end;

{ TStreamChannelsHelper }

function TStreamChannelsHelper.AsString: string;
begin
  case Self of
    0: Result := '';
    1: Result := 'Моно';
    2: Result := 'Стерео';
    else Result := IntToStr(Self);
  end;
end;

{ TStreamDateHelper }

function TStreamDateTimeHelper.AsString(AFormat: string): string;
begin
  if Self = 0
    then Result := ''
    else Result := FormatDateTime(AFormat, Self);
end;

{ TStreamBitrateHelper }

function TStreamBitrateHelper.AsString: string;
begin
  if Self = 0
    then Result := ''
    else Result := FormatFloat('#,##0 kbps', Self);
end;

{ TStreamSamplerateHelper }

function TStreamSamplerateHelper.AsString: string;
begin
  if Self = 0
    then Result := ''
    else Result := Format('%d KHz', [Round(Self / 1000)]);
end;

end.
