unit fmServerStatistics;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, RadioMOR.Types,
  RadioMOR.Common, RadioMOR.GlobalVar;

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

{ TForm_ServerStatistics }

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

procedure TForm_ServerStatistics.ListView_StatisticsData(Sender: TObject;
  Item: TListItem);
var
  i: Integer;
begin
  while Item.SubItems.Count < 12 do
    Item.SubItems.Add('');

  i := PlayList.GetItemIndexByURL(FList[Item.Index].ListenURL);

  if i > -1
    then Item.Caption := PlayList.Sources[i].Station
    else Item.Caption := FList[Item.Index].ListenURL;
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
begin
  FServerURL := Value;
  ListView_Statistics.Clear;
  GetIcecastServerStatistics(Value, FList);
  ListView_Statistics.Items.Count := FList.Count;
end;

end.
