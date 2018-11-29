unit RadioMOR.PlayList;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils, System.Generics.Collections,
  System.Generics.Defaults, System.RegularExpressions,
  System.NetEncoding, RadioMOR.Types;

type
  TM3UPlayList = class(TObject)
    private
      FFileName: TFileName;
      FOnLoadingComplete: TNotifyEvent;
      FSources: TObjectList<TRadioStation>;
      function MediaSourceFileExists(AURL: string): Boolean;
      function MediaSourceExtractFileName(AURL: string): string;
      function MediaSourceAbsolutePath(ASourceName: string): string;
      procedure ConvertToPLS(AOut: TStrings);
    public
      const CONV_FORMAT_PLS = 1;
    public
      constructor Create; overload; virtual;
      constructor Create(AFileName: TFileName); overload; virtual;
      destructor Destroy; override;
      procedure Clear(CanUpdate: Boolean = True);
      procedure LoadFromFile(AFileName: TFileName);
      procedure Refresh;
      procedure Convert(AFormat: Byte; AOutList: TStrings);
      function GetItemIndexByID(AID: string): Integer;
      function GetItemIndexByURL(AURL: string): Integer;
      function SourceExists(AID: string): Boolean;
      procedure GetText(AOut: TStrings);
      property FileName: TFileName read FFileName;
      property Sources: TObjectList<TRadioStation> read FSources;
      property OnLoadingComplete: TNotifyEvent read FOnLoadingComplete write FOnLoadingComplete;
    end;

implementation

{ TM3UPlayList }

procedure TM3UPlayList.Clear(CanUpdate: Boolean);
begin
  FSources.Clear;
  if (CanUpdate) and (@OnLoadingComplete <> nil) then OnLoadingComplete(Self);
end;

constructor TM3UPlayList.Create;
begin
  inherited Create;
  FSources := TObjectList<TRadioStation>.Create(True);
end;

procedure TM3UPlayList.Convert(AFormat: Byte; AOutList: TStrings);
begin
  if AOutList = nil then Exit;

  case AFormat of
    CONV_FORMAT_PLS: Self.ConvertToPLS(AOutList);

  end;
end;

procedure TM3UPlayList.ConvertToPLS(AOut: TStrings);
var
  i: Integer;
  src: TRadioStation;
  TitleFormat: string;
begin
  i := 0;
  AOut.Clear;

  AOut.Add('[playlist]');
  AOut.Add('');

  for src in FSources do
  begin
    Inc(i);

    if src.Title.IsEmpty
      then TitleFormat := 'Title%d=%s'
      else TitleFormat := 'Title%d=%s - %s';

    AOut.Add(Format('File%d=%s', [i, src.URL]));
    AOut.Add(Format(TitleFormat, [i, src.Station, src.Title]));
    AOut.Add(Format('Length%d=%d', [i, src.Duration]));
    AOut.Add('');
  end;

  AOut.Add(Format('NumberOfEntries=%d', [i]));
  AOut.Add('Version=2');
end;

constructor TM3UPlayList.Create(AFileName: TFileName);
begin
  Create;
  LoadFromFile(AFileName);
end;

destructor TM3UPlayList.Destroy;
begin
  FSources.Clear;
  FSources.Free;
  inherited;
end;

function TM3UPlayList.GetItemIndexByID(AID: string): Integer;
var
  obj: TRadioStation;
  i: Integer;
begin
  Result := -1;
  for i := 0 to FSources.Count - 1 do
  begin
    if CompareText(FSources[i].ID, AID) = 0 then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TM3UPlayList.GetItemIndexByURL(AURL: string): Integer;
var
  obj: TRadioStation;
  i: Integer;
  id: string;
begin
  Result := -1;
  id := TRadioStation.GenerateID(AURL);
  for i := 0 to FSources.Count - 1 do
  begin
    if CompareText(FSources[i].ID, id) = 0 then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TM3UPlayList.GetText(AOut: TStrings);
var
  src: TRadioStation;
  enc: THTMLEncoding;
  TitleFormat: string;
  _station: string;
  _title: string;
begin
  if AOut = nil then Exit;

  enc := THTMLEncoding.Create;

  AOut.Clear;
  AOut.Add('#EXTM3U');
  for src in FSources do
  begin
    if src.Title.IsEmpty
      then TitleFormat := '#EXTINF:%d,%s'
      else TitleFormat := '#EXTINF:%d,%s - %s';

    try
      _station := enc.Decode(src.Station);
    except
      _station := src.Station;
    end;

    try
      _title := enc.Decode(src.Title);
    except
      _title := src.Title;
    end;

    AOut.Add('');
    AOut.Add(Format(TitleFormat, [src.Duration, _station, _title]));
    AOut.Add(src.URL);
  end;

  enc.Free;
end;

function TM3UPlayList.MediaSourceAbsolutePath(ASourceName: string): string;
begin
  if MediaSourceFileExists(ASourceName)
    then Result := ASourceName
    else Result := ExtractFilePath(FFileName) + ASourceName;
end;

function TM3UPlayList.MediaSourceExtractFileName(AURL: string): string;
var
  RegEx: TRegEx;
begin
  Result := AURL;
  RegEx := TRegEx.Create('^http.*', [roIgnoreCase]);
  if not RegEx.IsMatch(AURL) then
  begin
    { ׃האכÿול נאסרטנוםטו פאיכא }
    RegEx := TRegEx.Create('\.[^\.]*$', [roIgnoreCase]);
    Result := RegEx.Replace(ExtractFileName(AURL), '');
  end;
end;

function TM3UPlayList.MediaSourceFileExists(AURL: string): Boolean;
var
  RegEx: TRegEx;
begin
  RegEx := TRegEx.Create('^http.*', [roIgnoreCase]);
  Result := RegEx.IsMatch(AURL) or FileExists(AURL);
end;

procedure TM3UPlayList.LoadFromFile(AFileName: TFileName);
var
  M3UContent: TStringList;
  str: string;
  idx: Integer;
  EXTINF: TRegEx;
  EXT_Exclude: TRegEx;
  objSource: TRadioStation;
begin
  if FileExists(AFileName) then
  begin
    idx := -1;
    FSources.Clear;
    FFileName := AFileName;
    Clear(False);
    M3UContent := TStringList.Create;
    try
      M3UContent.LoadFromFile(FFileName);
      EXTINF := TRegEx.Create('^#EXTINF:-{0,1}\d+,.*$', [roIgnoreCase]);
      EXT_Exclude := TRegEx.Create('^((?!http).*)|(.*\.flac)$', [roIgnoreCase]);
      for str in M3UContent do
      begin
        Inc(idx);
        if not EXTINF.IsMatch(str) then Continue;
        if idx + 1 > M3UContent.Count - 1 then Continue;

        objSource := TRadioStation.Create(
          M3UContent[idx],
          MediaSourceAbsolutePath(M3UContent[idx + 1])
        );

        try
          if EXT_Exclude.IsMatch(objSource.URL)
            then raise Exception.Create('Wrong URL or Stream format!');

          if SourceExists(objSource.ID)
            then raise Exception.Create('Source already exists in the list!');

          FSources.Add(objSource);
        except
          objSource.Free;
        end;
      end;
    finally
      M3UContent.Free;
    end;
  end;

  FSources.Sort(TComparer<TRadioStation>.Construct(
      function (const L, R: TRadioStation): Integer
        begin
          Result := CompareText(
              AnsiLowerCase(Format('%s - %s', [L.Station, L.Title])),
              AnsiLowerCase(Format('%s - %s', [R.Station, R.Title]))
          );
        end
      )
  );

  if @FOnLoadingComplete <> nil then FOnLoadingComplete(Self);
end;

procedure TM3UPlayList.Refresh;
begin
  Clear(False);
  LoadFromFile(FFileName);
end;


function TM3UPlayList.SourceExists(AID: string): Boolean;
var
  obj: TRadioStation;
begin
  Result := False;
  for obj in FSources do
  begin
    if CompareText(obj.ID, AID) = 0 then
    begin
      Result := True;
      Break;
    end;
  end;
end;

end.
