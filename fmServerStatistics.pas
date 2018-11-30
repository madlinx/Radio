unit fmServerStatistics;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, RadioMOR.Types,
  RadioMOR.Common, RadioMOR.GlobalVar, System.RTTI;

type
  TForm_ServerStatistics = class(TForm)
    ListView_Statistics: TListView;
    Button_Close: TButton;
    Button_Refresh: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button_RefreshClick(Sender: TObject);
    procedure ListView_StatisticsData(Sender: TObject; Item: TListItem);
    procedure Button_CloseClick(Sender: TObject);
    procedure ListView_StatisticsColumnClick(Sender: TObject;
      Column: TListColumn);
  private
    FServerURL: string;
    FCallingForm: TForm;
    FList: TIcecastStatisticsList;
    procedure SetCallingForm(const Value: TForm);
    procedure SetServerURL(const Value: string);
  public
    property CallingForm: TForm write SetCallingForm;
    property ServerURL: string write SetServerURL;
  end;

var
  Form_ServerStatistics: TForm_ServerStatistics;

implementation

{$R *.dfm}

var
  SortOrder: Integer;
  SortPropertyName: string;

{ TForm_ServerStatistics }

function CompareByPropertyName(P1, P2: Pointer): Integer;
var
  RTTIType: TRTTIType;
  TypeFields: TArray<TRttiField>;
  TypeField: TRttiField;
  i: Integer;

  Obj1: TIcecastStatistics;
  Obj2: TIcecastStatistics;
  ValueP1: Variant;
  ValueP2: Variant;
begin
  if SortPropertyName.IsEmpty then
  begin
    Result := 0;
    Exit;
  end;

  Obj1 := PIcecastStatistics(P1)^;
  Obj2 := PIcecastStatistics(P2)^;

  RTTIType := TRTTIContext.Create.GetType(TypeInfo(TIcecastStatistics));
  TypeFields := RTTIType.GetFields;

  for TypeField in TypeFields do
    if CompareText(SortPropertyName, TypeField.Name) = 0 then Break;

  ValueP1 := TypeField.GetValue(@Obj1).AsVariant;
  ValueP2 := TypeField.GetValue(@Obj2).AsVariant;

  if VarCompareValue(ValueP1, ValueP2) = vrEqual then
  begin
    Result := 0;
  end else if VarCompareValue(ValueP1, ValueP2) = vrGreaterThan then
  begin
    Result := 1;
  end else
  begin
    Result := -1;
  end;

  Result := Result * SortOrder;
end;

procedure TForm_ServerStatistics.Button_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_ServerStatistics.Button_RefreshClick(Sender: TObject);
begin
  ListView_Statistics.Clear;
  GetIcecastServerStatistics(FServerURL, FList);
  ListView_Statistics.Items.Count := FList.Count;
end;

procedure TForm_ServerStatistics.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
  end;
  FCallingForm := nil;
  FServerURL := '';
  ListView_Statistics.Clear;
  FList.Clear;
end;

procedure TForm_ServerStatistics.FormCreate(Sender: TObject);
begin
  FList := TIcecastStatisticsList.Create(True);
end;

procedure TForm_ServerStatistics.FormDestroy(Sender: TObject);
begin
  FList.Free;
end;

procedure TForm_ServerStatistics.ListView_StatisticsColumnClick(Sender: TObject;
  Column: TListColumn);
var
  CurrentSortedField: string;
begin
  CurrentSortedField := SortPropertyName;

  case Column.Index of
    0: SortPropertyName := 'Station';
    1: SortPropertyName := 'StreamName';
    2: SortPropertyName := 'StreamDescription';
    3: SortPropertyName := 'ContentType';
    4: SortPropertyName := 'StreamStarted';
    5: SortPropertyName := 'Channels';
    6: SortPropertyName := 'Bitrate';
    7: SortPropertyName := 'Samplerate';
    8: SortPropertyName := 'Listeners';
    9: SortPropertyName := 'ListenersPeak';
    10: SortPropertyName := 'Genre';
    11: SortPropertyName := 'StreamURL';
    12: SortPropertyName := 'CurrentlyPlaying';
    else SortPropertyName := '';
  end;

  if CompareText(CurrentSortedField, SortPropertyName) = 0
    then SortOrder := SortOrder * -1
    else SortOrder := 1;

  FList.Sort(CompareByPropertyName);
  ListView_Statistics.Invalidate;
end;

procedure TForm_ServerStatistics.ListView_StatisticsData(Sender: TObject;
  Item: TListItem);
begin
  while Item.SubItems.Count < 12 do
    Item.SubItems.Add('');

  Item.Caption := FList[Item.Index].Station;
  Item.SubItems[0] := FList[Item.Index].StreamName;
  Item.SubItems[1] := FList[Item.Index].StreamDescription;
  Item.SubItems[2] := FList[Item.Index].ContentType;
  Item.SubItems[3] := FList[Item.Index].StreamStarted.AsString('ddd, d mmm yyyy tt');
  Item.SubItems[4] := FList[Item.Index].Channels.AsString;
  Item.SubItems[5] := FList[Item.Index].Bitrate.AsString;
  Item.SubItems[6] := FList[Item.Index].Samplerate.AsString;
  Item.SubItems[7] := FormatFloat('#,##0', FList[Item.Index].Listeners);
  Item.SubItems[8] := FormatFloat('#,##0', FList[Item.Index].ListenersPeak);
  Item.SubItems[9] := FList[Item.Index].Genre;
  Item.SubItems[10] := FList[Item.Index].StreamURL;
  Item.SubItems[11] := FList[Item.Index].CurrentlyPlaying;
end;

procedure TForm_ServerStatistics.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
end;

procedure TForm_ServerStatistics.SetServerURL(const Value: string);
var
  i: Integer;
  item: PIcecastStatistics;
begin
  FServerURL := Value;
  SortOrder := 1;
  ListView_Statistics.Clear;
  GetIcecastServerStatistics(Value, FList);

  for item in FList do
  begin
    i := PlayList.GetItemIndexByURL(item^.ListenURL);
    if i > -1
      then item^.Station := PlayList.Sources[i].Station
      else item^.Station := item^.ListenURL;
  end;

  ListView_Statistics.Items.Count := FList.Count;
end;

end.
