unit DataModule1;

interface

uses
  System.SysUtils, System.Classes, Vcl.ExtCtrls, Vcl.Dialogs, Vcl.ImgList,
  Vcl.Controls, RadioMOR.BassRadio, Vcl.Menus, Vcl.StdCtrls, Forms, System.Types,
  Winapi.Windows, Vcl.Graphics, BASS, Vcl.Themes, Vcl.ActnPopup,
  System.ImageList, RadioMOR.Common, RadioMOR.GlobalVar, Vcl.AppEvnts,
  System.Win.TaskbarCore, Vcl.Taskbar, System.Actions, Vcl.ActnList,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, RadioMOR.Types;

type
  TPopupMenu = class(Vcl.ActnPopup.TPopupActionBar);

type
  TDM1 = class(TDataModule)
    ImageList1: TImageList;
    Timer_ElapsedTime: TTimer;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Timer_ScrollStationName: TTimer;
    ColorDialog1: TColorDialog;
    PlayListPopupMenu: TPopupMenu;
    RefreshPlaylist: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    OpenDialog: TOpenDialog;
    N7: TMenuItem;
    N8: TMenuItem;
    ActionManager1: TActionManager;
    Previous: TAction;
    Play: TAction;
    Stop: TAction;
    Next: TAction;
    Mute: TAction;
    Timer_ScrollStreamTitle: TTimer;
    StationsProperties: TMenuItem;
    ServerStatistics: TMenuItem;
    procedure Timer_ElapsedTimeTimer(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure Timer_ScrollStationNameTimer(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure RefreshPlaylistClick(Sender: TObject);
    procedure PlayListPopupMenuPopup(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure PreviousExecute(Sender: TObject);
    procedure PlayExecute(Sender: TObject);
    procedure StopExecute(Sender: TObject);
    procedure NextExecute(Sender: TObject);
    procedure MuteExecute(Sender: TObject);
    procedure Timer_ScrollStreamTitleTimer(Sender: TObject);
    procedure StationsPropertiesClick(Sender: TObject);
    procedure ServerStatisticsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM1: TDM1;

implementation

uses fmMainForm, fmAbout, fmSettings, fmStationStatistics, fmServerStatistics;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM1.ServerStatisticsClick(Sender: TObject);
begin
  with Form_ServerStatistics do
  begin
    CallingForm := RadioMOR_MainForm;
    ServerURL := PlayList.Sources[0].URL;
    Position := poMainFormCenter;
    Show;
    RadioMOR_MainForm.Enabled := False;
  end;
end;

procedure TDM1.StationsPropertiesClick(Sender: TObject);
begin
  with Form_StationStatistics do
  try
    CallingForm := RadioMOR_MainForm;
    RadioStation := PlayList.Sources[RadioMOR_MainForm.ListView1.Selected.Index];
    Position := poMainFormCenter;
    Show;
    RadioMOR_MainForm.Enabled := False;
  except

  end;
end;

procedure TDM1.MuteExecute(Sender: TObject);
begin
  RadioMOR_MainForm.Image1Click(Self);
end;

procedure TDM1.N1Click(Sender: TObject);
var
  DevNumber: Integer;
  DevInfo: BASS_DEVICEINFO;
  i: Integer;
  res: Integer;
  lFont: TLogFont;
  sFontName: string;
begin
  DevNumber := 0;
  with Form2 do
  begin
    UpdateParameterControls;
    Position := poMainFormCenter;
    Show;
  end;
  RadioMOR_MainForm.Enabled := False;
end;

procedure TDM1.N3Click(Sender: TObject);
begin
  with Form8 do
  begin
    Label1.Caption := 'Радио МНПЗ';
    Label3.Caption := 'Версия ' + GetFileInfo(Application.ExeName, 'ProductVersion');
    {$IFDEF WIN64}
      Label3.Caption := Label3.Caption + ' (64 bit)';
      BassDllVersionLabel.Caption := GetFileVer(ExtractFilePath(Application.ExeName) + 'bass64.dll');
    {$ELSE}
      BassDllVersionLabel.Caption := GetFileVer(ExtractFilePath(Application.ExeName) + 'bass.dll');
    {$ENDIF}
    JvScrollText1.Font.Color := TStyleManager.ActiveStyle.GetStyleFontColor(sfWindowTextNormal);
    JvScrollText1.Reset;
    Position := poMainFormCenter;
    Show;
  end;
  RadioMOR_MainForm.Enabled := False;
end;

procedure TDM1.RefreshPlaylistClick(Sender: TObject);
var
  _key: Word;
begin
  _key := VK_F5;
  RadioMOR_MainForm.ListView1KeyDown(Self, _key, []);
end;

procedure TDM1.N6Click(Sender: TObject);
begin
  try
    StationIndex := RadioMOR_MainForm.ListView1.Selected.Index;
    RadioMOR_MainForm.Button1Click(Self);
  except

  end;
end;

procedure TDM1.N8Click(Sender: TObject);
begin
  with OpenDialog do
  begin
    Title := 'Открыть список воспроизведения';
    Filter := 'Список воспроизведения M3U|*.m3u';
    FilterIndex := 1;
    if Execute(RadioMOR_MainForm.Handle) then
    begin
      Radio.Stop;
      PlayListFileName := FileName;
      PlayList.LoadFromFile(FileName);
    end;
  end;
end;

procedure TDM1.NextExecute(Sender: TObject);
begin
  RadioMOR_MainForm.Button10Click(Self);
end;

procedure TDM1.PlayExecute(Sender: TObject);
begin
  RadioMOR_MainForm.Button1Click(Self);
end;

procedure TDM1.PlayListPopupMenuPopup(Sender: TObject);
begin
  PlayListPopupMenu.Items[PLAYLIST_MENU_PLAY].Enabled := RadioMOR_MainForm.ListView1.SelCount > 0;
  PlayListPopupMenu.Items[PLAYLIST_MENU_STAT].Enabled := RadioMOR_MainForm.ListView1.SelCount > 0;
  PlayListPopupMenu.Items[PLAYLIST_MENU_SRVSTAT].Enabled := PlayList.Sources.Count > 0;
end;

procedure TDM1.PreviousExecute(Sender: TObject);
begin
  RadioMOR_MainForm.Button9Click(Self);
end;

procedure TDM1.StopExecute(Sender: TObject);
begin
  RadioMOR_MainForm.Button3Click(Self);
end;

procedure TDM1.Timer_ElapsedTimeTimer(Sender: TObject);
begin
  if Radio.State = bsPlay then begin
    RadioMOR_MainForm.PlayTimeLabel.Caption := Radio.ElapsedTime;
  end else begin
    DM1.Timer_ElapsedTime.Enabled := False;
    RadioMOR_MainForm.PlayTimeLabel.Caption := '00:00';
    Spectrum.StopDraw;
  end;
  with RadioMOR_MainForm do
  begin
    BitrateLabel.Left := PlayTimeLabel.Left + PlayTimeLabel.Width;
    BitrateLabel.Width := StationNumLabel.Left - BitrateLabel.Left;
  end;
end;

procedure TDM1.Timer_ScrollStationNameTimer(Sender: TObject);
var
  Txt: string;
  TxtLabel: TLabel;
  uFormat: Cardinal;
begin
  uFormat := DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;

  if DrawPos1_StationName = 0
    then Timer_ScrollStationName.Interval := 35;

  Txt := Radio.Title + ' :: ';
  TxtLabel := RadioMOR_MainForm.StationNameLabel;
  if TxtLabel.Caption <> '' then TxtLabel.Caption := '';
  {
  //if rgDirection.ItemIndex = 0 then //left
  Form1.StationNameLabel.Caption := Copy(Txt, 2, length(txt) - 1) + Copy(Txt, 1, 1);
  //else //right
  // lblMarquee.Caption:= Copy(Txt,length(txt)-1,1) + Copy(Txt, 1, length(Txt)-1);
  }

  TxtLabel.Canvas.Brush.Style := bsClear;
  TxtLabel.Canvas.Font := TxtLabel.Font;
  TxtLabel.Canvas.Brush.Color := TxtLabel.Color;
  TxtLabel.Repaint;

  if DrawPos1_StationName > - TextWidth_StationName  then
  begin
    if TextWidth_StationName + DrawPos1_StationName = TxtLabel.Width then DrawPos2_StationName := TxtLabel.Width;
    Dec(DrawPos1_StationName);
    with DrawRect_StationName do
    begin
      Left   := DrawPos1_StationName;
      Right  := TxtLabel.Width;
    end;
    DrawText(TxtLabel.Canvas.Handle, PChar(Txt), Length(Txt), DrawRect_StationName, uFormat);
  end;

  if DrawPos2_StationName > - TextWidth_StationName then
  begin
    if TextWidth_StationName + DrawPos2_StationName = TxtLabel.Width then DrawPos1_StationName := TxtLabel.Width;
    Dec(DrawPos2_StationName);
    with DrawRect_StationName do
    begin
      Left   := DrawPos2_StationName;
      Right  := TxtLabel.Width;
    end;
    DrawText(TxtLabel.Canvas.Handle, PChar(Txt), Length(Txt), DrawRect_StationName, uFormat);
  end;
end;

procedure TDM1.Timer_ScrollStreamTitleTimer(Sender: TObject);
var
  Txt: string;
  TxtLabel: TLabel;
  uFormat: Cardinal;
begin
  uFormat := DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;

  if DrawPos1_StreamTitle = 0
    then Timer_ScrollStreamTitle.Interval := 35;

  Txt := Radio.StreamTitle + ' :: ';
  TxtLabel := RadioMOR_MainForm.InfoLabel;
  if TxtLabel.Caption <> '' then TxtLabel.Caption := '';

  TxtLabel.Canvas.Brush.Style := bsClear;
  TxtLabel.Canvas.Font := TxtLabel.Font;
  TxtLabel.Canvas.Brush.Color := TxtLabel.Color;
  TxtLabel.Repaint;

  if DrawPos1_StreamTitle > - TextWidth_StreamTitle  then
  begin
    if TextWidth_StreamTitle + DrawPos1_StreamTitle = TxtLabel.Width
      then DrawPos2_StreamTitle := TxtLabel.Width;
    Dec(DrawPos1_StreamTitle);
    with DrawRect_StreamTitle do
    begin
      Left   := DrawPos1_StreamTitle;
      Right  := TxtLabel.Width;
    end;
    DrawText(TxtLabel.Canvas.Handle, PChar(Txt), Length(Txt), DrawRect_StreamTitle, uFormat);
  end;

  if DrawPos2_StreamTitle > - TextWidth_StreamTitle then
  begin
    if TextWidth_StreamTitle + DrawPos2_StreamTitle = TxtLabel.Width
      then DrawPos1_StreamTitle := TxtLabel.Width;
    Dec(DrawPos2_StreamTitle);
    with DrawRect_StreamTitle do
    begin
      Left   := DrawPos2_StreamTitle;
      Right  := TxtLabel.Width;
    end;
    DrawText(TxtLabel.Canvas.Handle, PChar(Txt), Length(Txt), DrawRect_StreamTitle, uFormat);
  end;
end;

end.
