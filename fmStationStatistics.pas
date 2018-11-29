unit fmStationStatistics;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, RadioMOR.Types;

type
  TForm_StationStatistics = class(TForm)
    Button_Close: TButton;
    Label_StreamName: TLabel;
    Label_StreamDescription: TLabel;
    Label_ContentType: TLabel;
    Label_StreamStarted: TLabel;
    Label_Bitrate: TLabel;
    Label_Listeners: TLabel;
    Label_Genre: TLabel;
    Label_StreamURL: TLabel;
    Label_CurrentlyPlaying: TLabel;
    Edit_StreamName: TEdit;
    Edit_StreamDescription: TEdit;
    Edit_ContentType: TEdit;
    Edit_StreamStarted: TEdit;
    Edit_Channels: TEdit;
    Edit_Bitrate: TEdit;
    Edit_Listeners: TEdit;
    Edit_ListenersPeak: TEdit;
    Edit_Genre: TEdit;
    Edit_StreamURL: TEdit;
    Edit_CurrentlyPlaying: TEdit;
    Label_Channels: TLabel;
    Label_ListenersPeak: TLabel;
    Button1: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_CloseClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FRadioStation: TRadioStation;
    FCallingForm: TForm;
    procedure SetCallingForm(const Value: TForm);
    procedure SetRadioStation(const Value: TRadioStation);
  public
    property CallingForm: TForm write SetCallingForm;
    property RadioStation: TRadioStation write SetRadioStation;
  end;

var
  Form_StationStatistics: TForm_StationStatistics;

implementation

{$R *.dfm}

{ TForm_StationProperties }

procedure TForm_StationStatistics.Button1Click(Sender: TObject);
begin
  SetRadioStation(FRadioStation);
end;

procedure TForm_StationStatistics.Button_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_StationStatistics.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
  end;
  FCallingForm := nil;
  FRadioStation := nil;
end;

procedure TForm_StationStatistics.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
end;

procedure TForm_StationStatistics.SetRadioStation(const Value: TRadioStation);
var
  Statistics: TIcecastStatistics;
begin
  FRadioStation := Value;

  FillChar(Statistics, SizeOf(TIcecastStatisticsList), #0);
  if Value <> nil
    then Value.GetIcecastStatus(@Statistics);

  Edit_StreamName.Text := Statistics.StreamName;
  Edit_StreamDescription.Text := Statistics.StreamDescription;
  Edit_ContentType.Text := Statistics.ContentType;
  Edit_StreamStarted.Text := Statistics.StreamStarted.AsString('ddd, d mmm yyyy tt');
  Edit_Channels.Text := Statistics.Channels.AsString;
  Edit_Bitrate.Text := Statistics.Bitrate.AsString;
  Edit_Listeners.Text := FormatFloat('#,##0', Statistics.Listeners);
  Edit_ListenersPeak.Text := FormatFloat('#,##0', Statistics.ListenersPeak);
  Edit_Genre.Text := Statistics.Genre;
  Edit_StreamURL.Text := Statistics.StreamURL;
  Edit_CurrentlyPlaying.Text := Statistics.CurrentlyPlaying;
end;

end.
