unit fmMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, IniFiles, Vcl.Imaging.pngimage,
  Winapi.CommCtrl, Vcl.ImgList, Vcl.Buttons, Vcl.Themes, Winapi.ShlObj,
  Vcl.ToolWin, System.Generics.Collections, System.RegularExpressions,
  RadioMOR.GlobalVar, RadioMOR.BassRadio, RadioMOR.PlayList, RadioMOR.Common,
  BASS, BASS.Spectrum, Vcl.Taskbar, System.Win.TaskbarCore, System.StrUtils,
  RadioMOR.Types;

type
  TTrackBar = class(ComCtrls.TTrackBar)
    protected
      function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  end;

type
  TListView = class(ComCtrls.TListView)
  private
    procedure CNMeasureItem(var Message: TWMMeasureItem); message CN_MEASUREITEM;
  end;

  TRadioMOR_MainForm = class(TForm)
    DisplayPanel: TPanel;
    SpectrumPanel: TPanel;
    StationNumLabel: TLabel;
    BitrateLabel: TLabel;
    StationNameLabel: TLabel;
    InfoLabel: TLabel;
    PlayTimeLabel: TLabel;
    ListView1: TListView;
    ControlPanel: TPanel;
    Button9: TButton;
    Button12: TButton;
    Button11: TButton;
    Button10: TButton;
    Button3: TButton;
    Button1: TButton;
    TrackBar1: TTrackBar;
    Image1: TImage;
    VolumeLabel: TLabel;
    DisplayBg: TPaintBox;
    SpectrumBg: TPaintBox;
    Taskbar: TTaskbar;
    procedure VolumeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DisplayPanelResize(Sender: TObject);
    procedure DisplayBgPaint(Sender: TObject);
    procedure SpectrumBgPaint(Sender: TObject);
    procedure ControlPanelResize(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListView1DrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListView1Resize(Sender: TObject);
    procedure StationNameLabelClick(Sender: TObject);
  protected
    procedure WndProc(var Message: TMessage); override;
  private
    { Private declarations }
    FDisplayBackground: TBitmap;
    FSpectrumBackground: TBitmap;
    FSelectionColor: TColor;
    FView: Byte;
    FWindowHeight: Integer;
    FTrackBarWndProc: TWndMethod;
    FListViewWndProc: TWndMethod;
    procedure TrackBarWndProc(var Msg: TMessage);
    procedure ListViewWndProc(var Msg: TMessage);
    procedure RegisterTaskbarButtonCreatedMessage;
    procedure CreateDisplayBackground;
    procedure DisplayStationOfflineInfo(AIndex: PInteger);
    procedure ScrollToActiveStation;
    procedure OnPlayListUpdate(Sender: TObject);
    procedure OnRadioPlay(BassObj: TObject);
    procedure OnRadioStop(BassObj: TObject);
    procedure OnRadioTitleChange(BassObj: TObject);
    procedure OnRadioPlayEnd(BassObj: TObject);
    procedure OnRadioStreamFree(BassObj: TObject);
    procedure SetView(AView: Byte);
    function GenerateStationName(AStation: TRadioStation): string;
  public
    { Public declarations }
    procedure ReadAppSettings;
    procedure WriteAppSettings;
    procedure ReadPersonalSettings;
    procedure WritePersonalSettings;
    procedure ApplySettings;
    procedure SetDisplayColor(AColor: TColor);
  end;

var
  RadioMOR_MainForm: TRadioMOR_MainForm;

  Radio: TBassRadio;
  Spectrum: TSpectrum;

  TextWidth_StationName: Integer;
  DrawRect_StationName: TRect;
  DrawPos1_StationName: Integer;
  DrawPos2_StationName: Integer;

  TextWidth_StreamTitle: Integer;
  DrawRect_StreamTitle: TRect;
  DrawPos1_StreamTitle: Integer;
  DrawPos2_StreamTitle: Integer;

implementation

uses DataModule1, fmStationStatistics;

{$R *.dfm}
{$R Resources\Fonts\fonts.res}

function LoadFontsCallback(hModule: HMODULE; lpType, lpName: PChar;
  lParam: Longint): BOOL; stdcall;
var
  resName: string;
  regExp: TRegEx;
  ResAddr: Pointer;
  Res: HGLOBAL;
  Src: HRSRC;
  FontCount: DWORD;
  ResSize: DWORD;
begin
  if (Cardinal(lpName) shr 16) = 0 then
    resName := PChar(IntToStr(Integer(lpName)))
  else
    resName := lpName;

  regExp := TRegEx.Create('^font\d+$', [roIgnoreCase]);

  if regExp.IsMatch(resName) then
  begin
    Src := FindResource(hInstance, PChar(resName), RT_RCDATA);
    if Src <> 0 then
    begin
      Res := LoadResource(hInstance, Src);
      ResAddr := LockResource(Res);
      ResSize := SizeofResource(hInstance, Src);
      SetLength(aFonts, Length(aFonts) + 1);
      aFonts[High(aFonts)] := AddFontMemResourceEx(ResAddr, ResSize, 0, @FontCount);
      UnlockResource(Res);
      FreeResource(Src);
    end;
  end;

  Result := True;
end;

procedure TRadioMOR_MainForm.Image1Click(Sender: TObject);
begin
  if TrackBar1.Position > 0 then
  begin
    TrackBar1.Tag := TrackBar1.Position;
    TrackBar1.Position := 0;
  end else
  begin
    if TrackBar1.Tag > 0
      then TrackBar1.Position := TrackBar1.Tag
      else TrackBar1.Position := 25;
    TrackBar1.Tag := 0;
  end;
end;

procedure TRadioMOR_MainForm.ListView1Data(Sender: TObject; Item: TListItem);

begin
  if Item.Index <= PlayList.Sources.Count - 1 then
  begin
    Item.Caption := Format('%d.  %s', [Item.Index + 1, GenerateStationName(PlayList.Sources[Item.Index])]);
    Item.SubItems.Add(PlayList.Sources[Item.Index].URL);
  end;
end;

procedure TRadioMOR_MainForm.ListView1DrawItem(Sender: TCustomListView; Item: TListItem;
  Rect: TRect; State: TOwnerDrawState);
var
  R: TRect;
begin
  ListView_GetItemRect(Sender.Handle, Item.Index, R, LVIR_LABEL);

  case InvertSelector of
    True: begin
      Sender.Canvas.Brush.Color := StyleServices.GetStyleColor(scListView);
      Sender.Canvas.Font.Color := DisplayColor;
      Sender.Canvas.FillRect(R);

      if PlayList.Sources[Item.Index].ID = StationID then
      begin
        Sender.Canvas.Brush.Color := FSelectionColor;
        Sender.Canvas.Font.Color := clWhite;
        Sender.Canvas.FillRect(R);
      end;

      if (odSelected in State)
      or (odFocused in State) then
      begin
        Sender.Canvas.Pen.Color := DisplayColor;
        Sender.Canvas.Polygon(
          [
             Point(R.TopLeft.X, R.TopLeft.Y),
             Point(R.BottomRight.X - 1, R.TopLeft.Y),
             Point(R.BottomRight.X - 1, R.BottomRight.Y - 1),
             Point(R.TopLeft.X, R.BottomRight.Y - 1)
          ]
        );
      end;
    end;

    False: begin
      if (odSelected in State)
      or (odFocused in State) then
      begin
        Sender.Canvas.Brush.Color := FSelectionColor;
        Sender.Canvas.Font.Color := clWhite;
      end else begin
        Sender.Canvas.Brush.Color := StyleServices.GetStyleColor(scListView);
        Sender.Canvas.Font.Color := DisplayColor;
      end;

      Sender.Canvas.FillRect(R);
      if PlayList.Sources[Item.Index].ID = StationID then
      begin
        Sender.Canvas.Pen.Color := DisplayColor;
        Sender.Canvas.Polygon(
          [
             Point(R.TopLeft.X, R.TopLeft.Y),
             Point(R.BottomRight.X - 1, R.TopLeft.Y),
             Point(R.BottomRight.X - 1, R.BottomRight.Y - 1),
             Point(R.TopLeft.X, R.BottomRight.Y - 1)
          ]
        );
      end;
    end;
  end;

  Sender.Canvas.TextOut(R.Left + 6, R.Top + 2, Item.Caption);
end;

procedure TRadioMOR_MainForm.ListView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_F5: begin
      ListView1.Clear;
      PlayList.Refresh;
    end;

    VK_RETURN: begin
      if Assigned(ListView1.Selected) then
      begin
        StationIndex := ListView1.Selected.Index;
        Button1Click(Self);
      end;
    end;
  end;
end;

procedure TRadioMOR_MainForm.ListView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  UserInfo: TListItem;
  hts : THitTests;
  HitInfo: TLVHitTestInfo;
  R: TRect;
  MsgRes: Integer;
begin
  if (ssLeft in Shift) and (ssDouble in Shift) then
  begin
    hts := ListView1.GetHitTestInfoAt(X, Y);
    if htOnStateIcon in hts then Exit;
    FillChar(HitInfo, SizeOf(TLVHitTestInfo), 0);
    HitInfo.pt := Point(X ,Y); //ListView1.ScreenToClient(Mouse.Cursorpos);
    MsgRes := ListView1.Perform(LVM_SUBITEMHITTEST, 0, lparam(@HitInfo));
    if MsgRes <> -1 then
    begin
      StationIndex := HitInfo.iItem;
      RadioMOR_MainForm.Button1Click(Self);
    end;
  end;
end;

procedure TRadioMOR_MainForm.ListView1Resize(Sender: TObject);
var
  lv: TListView;
begin
  lv := ListView1;
  lv.Columns[0].Width := lv.ClientWidth - GetSystemMetrics(SM_CXEDGE);
end;

procedure TRadioMOR_MainForm.ListViewWndProc(var Msg: TMessage);
begin
  ShowScrollBar(ListView1.Handle, SB_HORZ, False);
//  ShowScrollBar(ListView1.Handle, SB_VERT, True);
  FListViewWndProc(Msg);
end;

procedure TRadioMOR_MainForm.OnRadioPlayEnd(BassObj: TObject);
begin
  Spectrum.StopDraw;
  StationNameLabel.Caption := PlayList.Sources[StationIndex].Station;
  InfoLabel.Caption := 'Радиостанция недоступна';
end;

procedure TRadioMOR_MainForm.OnRadioStreamFree(BassObj: TObject);
begin
  Spectrum.StopDraw;
end;

procedure TRadioMOR_MainForm.OnRadioPlay(BassObj: TObject);
begin
  Spectrum.StopDraw;
  case Radio.State of
    bsNone: begin
      StationNameLabel.Caption := GenerateStationName(PlayList.Sources[StationIndex]);
      InfoLabel.Caption := 'Радиостанция недоступна';
      //InfoLabel.Caption := Radio.ErrMessage;
    end;

    bsPlay: begin
      Radio.SetCustomTitle(GenerateStationName(PlayList.Sources[StationIndex]));
      Spectrum.StartDraw;
      { Важно задавать StreamBitrate после StartDraw }
      Spectrum.StreamBitrate := Radio.Bitrate;
      DM1.Timer_ElapsedTime.Enabled := True;
      if Radio.StreamTitle.IsEmpty
        then InfoLabel.Caption := Radio.URL
        else InfoLabel.Caption := Radio.StreamTitle;
    end;

    bsStop: begin
      InfoLabel.Caption := Radio.ErrMessage;
    end;
  end;
end;

procedure TRadioMOR_MainForm.OnRadioStop(BassObj: TObject);
begin
  Spectrum.StopDraw;
  DM1.Timer_ScrollStationName.Enabled := False;
  DM1.Timer_ScrollStreamTitle.Enabled := False;
  DisplayStationOfflineInfo(@StationIndex);
  Repaint;
end;

procedure TRadioMOR_MainForm.OnRadioTitleChange(BassObj: TObject);
begin
  BitrateLabel.Left := PlayTimeLabel.Left + PlayTimeLabel.Width;
  BitrateLabel.Width := StationNumLabel.Left - BitrateLabel.Left;
  BitrateLabel.Visible := {(Radio.State = bsBusy) or }(Radio.Samplerate > 0);

  DM1.Timer_ScrollStationName.Enabled := False;
  DM1.Timer_ScrollStationName.Interval := 1500;

  DM1.Timer_ScrollStreamTitle.Enabled := False;
  DM1.Timer_ScrollStreamTitle.Interval := 1500;

  if Radio.StreamTitle.IsEmpty
    then InfoLabel.Caption := Radio.URL
    else InfoLabel.Caption := Radio.StreamTitle;

  case Radio.State of
    bsBusy: begin
      StationNameLabel.Caption := Radio.ProcessInfo;
      BitrateLabel.Caption := Radio.StreamStatus;
      try
        InfoLabel.Caption := PlayList.Sources[StationIndex].URL;
      except
        InfoLabel.Caption := 'Нет данных';
      end;
      Application.ProcessMessages;
    end;

    bsNone, bsStop: try
      StationNameLabel.Caption := GenerateStationName(PlayList.Sources[StationIndex]);
      InfoLabel.Caption := PlayList.Sources[StationIndex].URL;
    except
      StationNameLabel.Caption := 'Нет данных';
      InfoLabel.Caption := 'Нет данных';
    end;

    bsRecovery: begin
      StationNameLabel.Caption := GenerateStationName(PlayList.Sources[StationIndex]);
      InfoLabel.Caption := Radio.ProcessInfo;
    end;

    else begin
      StationNameLabel.Caption := Radio.Title;
      case Radio.Bitrate > 0 of
        True: begin
          BitrateLabel.Caption := Format('%d kbps/%d KHz', [Radio.Bitrate, Round(Radio.Samplerate / 1000)]);
        end;

        False: begin
          if Radio.MetaData.Bitrate <> ''
            then BitrateLabel.Caption := Format('%s kbps/%d KHz', [Radio.MetaData.Bitrate, Round(Radio.Samplerate / 1000)])
            else BitrateLabel.Caption := Format('%d KHz', [Round(Radio.Samplerate / 1000)]);
        end;
      end;

      TextWidth_StationName := GetTextWidthInPixels(Radio.Title, StationNameLabel.Font);
      if TextWidth_StationName > StationNameLabel.Width then
      begin
        TextWidth_StationName := GetTextWidthInPixels(Radio.Title + ' :: ', StationNameLabel.Font);
        DrawPos1_StationName := 0;
        DrawPos2_StationName := TextWidth_StationName;
        DM1.Timer_ScrollStationName.Enabled := ScrollStationName;
      end;

      TextWidth_StreamTitle := GetTextWidthInPixels(Radio.StreamTitle, InfoLabel.Font);
      if TextWidth_StreamTitle > InfoLabel.Width then
      begin
        TextWidth_StreamTitle := GetTextWidthInPixels(Radio.StreamTitle + ' :: ', InfoLabel.Font);
        DrawPos1_StreamTitle := 0;
        DrawPos2_StreamTitle := TextWidth_StreamTitle;
        DM1.Timer_ScrollStreamTitle.Enabled := ScrollStreamTitle;
      end;
    end;
  end;
end;

procedure TRadioMOR_MainForm.ApplySettings;
var
  BuffLen: DWORD;
  BassInfo: BASS_INFO;
  i: Integer;
  ctrl: TControl;
begin
  SetDisplayColor(DisplayColor);
  BASS_SetConfig(BASS_CONFIG_NET_TIMEOUT, BASS_NetTimeOut * 1000);
  BASS_SetConfig(BASS_CONFIG_BUFFER, BASS_Buffer);
  for i := 0 to DisplayPanel.ControlCount - 1 do
  begin
    ctrl := DisplayPanel.Controls[i];
    if ctrl is TLabel then
    begin
      TLabel(ctrl).Font.Name := DisplayFont;
      TLabel(ctrl).Repaint;
    end;
  end;
  ctrl := nil;
  OnRadioTitleChange(Radio);
end;

procedure TRadioMOR_MainForm.Button10Click(Sender: TObject);
begin
  if PlayList.Sources.Count > 0 then
  begin
    if Radio.State = bsBusy then Exit;
    StationIndex := StationIndex + 1;
    if StationIndex > PlayList.Sources.Count - 1 then StationIndex := 0;
    Button1Click(Self);
  end;
end;

procedure TRadioMOR_MainForm.Button11Click(Sender: TObject);
var
  LowerLeft: TPoint;
begin
  LowerLeft := Button11.ClientToScreen(Point(0, Button11.Height));
  DM1.PopupMenu1.Popup(LowerLeft.X, LowerLeft.Y);
end;

procedure TRadioMOR_MainForm.Button12Click(Sender: TObject);
begin
  case FView of
    RADIO_VIEW_STANDARD: SetView(RADIO_VIEW_PLAYLIST);
    RADIO_VIEW_PLAYLIST: begin
      FWindowHeight := Height;
      SetView(RADIO_VIEW_STANDARD);
    end
    else SetView(RADIO_VIEW_STANDARD);
  end;
end;

procedure TRadioMOR_MainForm.Button1Click(Sender: TObject);
begin
  if PlayList.Sources.Count > 0 then
  begin
    if StationIndex < 0 then StationIndex := PlayList.GetItemIndexByID(StationID);
    if StationIndex < 0 then StationIndex := 0;
    if StationIndex > PlayList.Sources.Count - 1 then StationIndex := PlayList.Sources.Count - 1;
    StationID := PlayList.Sources[StationIndex].ID;
    StationNumLabel.Caption := Format('%d/%d', [StationIndex + 1, PlayList.Sources.Count]);
    try
      ListView1.Items[StationIndex].Focused := True;
      ListView1.Items[StationIndex].Selected := True;
      ScrollToActiveStation;
    except

    end;
    ListView1.Repaint;
    Radio.Play(PlayList.Sources[StationIndex].URL);
  end;
end;

procedure TRadioMOR_MainForm.Button3Click(Sender: TObject);
begin
  Radio.Stop;
end;

procedure TRadioMOR_MainForm.Button9Click(Sender: TObject);
begin
  if PlayList.Sources.Count > 0 then
  begin
    if Radio.State = bsBusy then Exit;
    StationIndex := StationIndex - 1;
    if StationIndex < 0 then StationIndex := PlayList.Sources.Count - 1;
    Button1Click(Self);
  end;
end;

procedure TRadioMOR_MainForm.CreateDisplayBackground;
var
  R: TRect;
  hCanvas: HDC;
  i: Integer;
begin
  { Создаем фон дисплея }
  if not Assigned(FDisplayBackground)
    then FDisplayBackground := TBitmap.Create;

  try
    FDisplayBackground.Width := DisplayPanel.ClientWidth;
    FDisplayBackground.Height := DisplayPanel.ClientHeight;
    hCanvas := FDisplayBackground.Canvas.Handle;

    { Верхняя часть эффекта глянца }
    R.TopLeft := Point(0, 0);
    R.BottomRight := Point(FDisplayBackground.Width, Round(FDisplayBackground.Height / 2));
    Gradient2D(
        hCanvas,
        R.TopLeft.X,
        R.TopLeft.Y,
        $00444444,
        R.BottomRight.X,
        R.BottomRight.Y,
        $002A2A2A,
        True
    );

    { Нижняя часть эффекта глянца }
    R.TopLeft := Point(0, Round(FDisplayBackground.Height / 2));
    R.BottomRight := Point(FDisplayBackground.Width, FDisplayBackground.Height);
    Gradient2D(
        hCanvas,
        R.TopLeft.X,
        R.TopLeft.Y,
        $001D1D1D,
        R.BottomRight.X,
        R.BottomRight.Y,
        clBlack,
        True
    );

//    { Свечение сверху - левая часть}
//    R.TopLeft := Point(0, 0);
//    R.BottomRight := Point(Round(FDisplayBackground.Width / 2), 1);
//    Gradient2D(
//        hCanvas,
//        R.TopLeft.X,
//        R.TopLeft.Y,
//        $00444444,
//        R.BottomRight.X,
//        R.BottomRight.Y,
//        DisplayColor,
//        False
//    );
//
//    { Свечение сверху - правая часть}
//    R.TopLeft := Point(Round(FDisplayBackground.Width / 2), 0);
//    R.BottomRight := Point(FDisplayBackground.Width, 1);
//    Gradient2D(
//        hCanvas,
//        R.TopLeft.X,
//        R.TopLeft.Y,
//        DisplayColor,
//        R.BottomRight.X,
//        R.BottomRight.Y,
//        $00444444,
//        False
//    );

    { Свечение снизу - левая часть }
    R.TopLeft := Point(0, FDisplayBackground.Height - 1);
    R.BottomRight := Point(Round(FDisplayBackground.Width / 2), FDisplayBackground.Height);
    Gradient2D(
        hCanvas,
        R.TopLeft.X,
        R.TopLeft.Y,
        clBlack,
        R.BottomRight.X,
        R.BottomRight.Y,
        DisplayColor,
        False
    );

    { Свечение снизу - правая часть }
    R.TopLeft := Point(Round(FDisplayBackground.Width / 2), FDisplayBackground.Height - 1);
    R.BottomRight := Point(FDisplayBackground.Width, FDisplayBackground.Height);
    Gradient2D(
        hCanvas,
        R.TopLeft.X,
        R.TopLeft.Y,
        DisplayColor,
        R.BottomRight.X,
        R.BottomRight.Y,
        clBlack,
        False
    );

    { Создаем фон спектрографа }
    if FSpectrumBackground = nil
      then FSpectrumBackground := TBitmap.Create;

    try
      FSpectrumBackground.Width := SpectrumPanel.ClientWidth;
      FSpectrumBackground.Height := SpectrumPanel.ClientHeight;

      R.TopLeft := Point(
          SpectrumPanel.Left,
          SpectrumPanel.Top
      );
      R.BottomRight := Point(
          SpectrumPanel.Left + SpectrumPanel.Width,
          SpectrumPanel.Top + SpectrumPanel.Height
      );
      FSpectrumBackground.Canvas.CopyRect(FSpectrumBackground.Canvas.ClipRect, FDisplayBackground.Canvas, R);
      FSpectrumBackground.Canvas.PenPos := Point(1, FSpectrumBackground.Height - 1);
      FSpectrumBackground.Canvas.Pen.Color := Spectrum.PenColor;
      FSpectrumBackground.Canvas.Pen.Width := 1;
      for i := 1 to Spectrum.LineCount do
      begin
        FSpectrumBackground.Canvas.MoveTo(FSpectrumBackground.Canvas.PenPos.X + 1, FSpectrumBackground.Canvas.PenPos.Y);
        FSpectrumBackground.Canvas.LineTo(FSpectrumBackground.Canvas.PenPos.X + Spectrum.LineWidth, FSpectrumBackground.Canvas.PenPos.Y);
      end;
      Spectrum.SetBackGround(True, FSpectrumBackground);
    except

    end;
  except

  end;
end;

procedure TRadioMOR_MainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteAppSettings;
  WritePersonalSettings;
end;

procedure TRadioMOR_MainForm.FormCreate(Sender: TObject);
var
  Res: TResourceStream;
  FontsCount: DWORD;
  LogFont: TLOGFONT;
  R: TRect;
  Bg: TBitmap;
  i: Integer;
begin
  RegisterTaskbarButtonCreatedMessage;
  Taskbar.PreviewClipRegion.Top := 0;
  Taskbar.PreviewClipRegion.Left := 0;
  Taskbar.PreviewClipRegion.Height := RADIO_HEIGHT_STANDARD;
  Taskbar.PreviewClipRegion.Width := Width;

  FTrackBarWndProc := TrackBar1.WindowProc;
  TrackBar1.WindowProc := TrackBarWndProc;
  FListViewWndProc := ListView1.WindowProc;
  ListView1.WindowProc := ListViewWndProc;
  DM1.ImageList1.GetIcon(6, Image1.Picture.Icon);

  AppWorkDir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  PersonalWorkDir := GetSpecialFolderPath(CSIDL_APPDATA);
  if PersonalWorkDir.IsEmpty
    then PersonalWorkDir := AppWorkDir
    else PersonalWorkDir := IncludeTrailingPathDelimiter(PersonalWorkDir);

  ReadAppSettings;
  ReadPersonalSettings;

  // Плейлист читается из инишника, но здесь просто вставлена заглушка
  // чтобы всегда принудительно тянуть лист из папки приложения
  // Если удалить строку ниже, то будет тянуться из инишника, но тогда нужно будет
  // допилить диалоговое окно выбора плейлиста
  PlayListFileName := ExtractFilePath(Application.ExeName) + 'stations.m3u';

  // Загружаем шрифты из ресурсов
  if not EnumResourceNames(0, RT_RCDATA, @LoadFontsCallback, 0)
    then RaiseLastOSError;

  Radio := TBassRadio.Create(Handle);
  Radio.RecoveryOnConnectionLoss := RecoveryOnConnectionLoss;
  Radio.OnPlay := OnRadioPlay;
  Radio.OnStop := OnRadioStop;
  Radio.OnTitleChange := OnRadioTitleChange;
  Radio.OnPlayEnd := OnRadioPlayEnd;
  Radio.OnStreamFree := OnRadioStreamFree;
  Radio.Volume := TrackBar1.Position;

  PlayList := TM3UPlayList.Create;
  PlayList.OnLoadingComplete := OnPlayListUpdate;
  PlayList.LoadFromFile(PlayListFileName);

  Spectrum := TSpectrum.Create(Radio, SpectrumPanel);
  Spectrum.BkgColor := clBlack;
  Spectrum.PeakColor := clGray;
  Spectrum.LineWidth := 4;
  Spectrum.mnogMatrix := 0.65;
  Spectrum.mnog := 0.8;
  Spectrum.LineFall := 2;
  Spectrum.LineCount := Round(
      (SpectrumBg.ClientWidth - 1) / (Spectrum.LineWidth + 1)
  );

  DisplayPanelResize(Self);
  DrawRect_StationName.Top := 0;
  DrawRect_StationName.Bottom := StationNameLabel.Height;
  DrawRect_StreamTitle.Top := 0;
  DrawRect_StreamTitle.Bottom := InfoLabel.Height;
  SendMessage(ListView1.Handle, LVM_SETCALLBACKMASK, LVIS_FOCUSED, 0);
  TrackBar1.Position := Volume;

  StationIndex := PlayList.GetItemIndexByID(StationID);
  DisplayStationOfflineInfo(@StationIndex);

  SetView(FView);
  ApplySettings;

  if AutoPlay then Button1Click(Self);
end;

procedure TRadioMOR_MainForm.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  FDisplayBackground.Free;
  Radio.Free;
  PlayList.Free;
  Spectrum.Free;

  for i := Low(aFonts) to High(aFonts) do
    RemoveFontMemResourceEx(aFonts[i]);
end;

procedure TRadioMOR_MainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  ctrlHandle: THandle;
begin
  ctrlHandle := WindowFromPoint(MousePos);
  if ctrlHandle <> ListView1.Handle then
  begin
    Handled := True;
    TrackBar1.DoMouseWheel(Shift, WheelDelta, MousePos);
  end;
end;

function TRadioMOR_MainForm.GenerateStationName(AStation: TRadioStation): string;
var
  TitleFormat: string;
begin
  if AStation.Title.IsEmpty
    then TitleFormat := '%s'
    else TitleFormat := '%s - %s';

  Result := Format(
      TitleFormat,
      [AStation.Station, AStation.Title]
  );
end;

procedure TRadioMOR_MainForm.OnPlayListUpdate(Sender: TObject);
var
  i: Integer;
begin
  if DM1 <> nil then
  begin
    DM1.Timer_ScrollStationName.Enabled := False;
    DM1.Timer_ScrollStreamTitle.Enabled := False;
  end;
  if PlayList.Sources.Count = 0 then
  begin
    Button3Click(Self);
    StationNameLabel.Caption := 'Нет данных';
    InfoLabel.Caption := 'Нет данных';
    StationNumLabel.Caption := '0/0'
  end else
  begin
    StationIndex := PlayList.GetItemIndexByID(StationID);
    if StationIndex < 0 then
    begin
      StationIndex := 0;
      Button3Click(Self);
    end;
    StationNameLabel.Caption := PlayList.Sources[StationIndex].Title;
    InfoLabel.Caption := PlayList.Sources[StationIndex].URL;
    StationNumLabel.Caption := Format('%d/%d', [StationIndex + 1, PlayList.Sources.Count]);
  end;

  ListView1.Items.Count := PlayList.Sources.Count;
  try
    ListView1.Items[StationIndex].Selected := True;
    ListView1.Items[StationIndex].Focused := True;
  except

  end;
  ListView1.Refresh;
  ScrollToActiveStation;
  OnRadioTitleChange(Radio);
end;

procedure TRadioMOR_MainForm.ControlPanelResize(Sender: TObject);
begin
  Button11.Left := ControlPanel.ClientWidth - Button11.Width;
  Button12.Left := Button11.Left - Button12.Width - 2;
  TrackBar1.Width := (Button12.Left - 3) - TrackBar1.Left;
end;

procedure TRadioMOR_MainForm.DisplayBgPaint(Sender: TObject);
begin
  DisplayBg.Canvas.Draw(0, 0, FDisplayBackground);
end;

procedure TRadioMOR_MainForm.DisplayPanelResize(Sender: TObject);
begin
  CreateDisplayBackground;
  StationNameLabel.Width := DisplayPanel.ClientWidth - (StationNameLabel.Left + 8);
  InfoLabel.Width := StationNameLabel.Width;
  StationNumLabel.Left := DisplayPanel.ClientWidth - (StationNumLabel.Width + 8);
  BitrateLabel.Left := PlayTimeLabel.Left + PlayTimeLabel.Width;
  BitrateLabel.Width := StationNumLabel.Left - BitrateLabel.Left;
end;

procedure TRadioMOR_MainForm.DisplayStationOfflineInfo(AIndex: PInteger);
begin
  if PlayList.Sources.Count > 0 then
  begin
    if AIndex^ < 0
      then AIndex^ := 0;
    if AIndex^ > PlayList.Sources.Count - 1
      then AIndex^ := PlayList.Sources.Count - 1;
    StationNameLabel.Caption := GenerateStationName(PlayList.Sources[AIndex^]);
    InfoLabel.Caption := PlayList.Sources[AIndex^].URL;
  end;
  BitrateLabel.Hide;
  StationNumLabel.Caption := Format('%d/%d', [AIndex^ + 1, PlayList.Sources.Count]);
end;

procedure TRadioMOR_MainForm.ReadAppSettings;
var
  Settings: TIniFile;
begin
  Settings := TIniFile.Create(AppWorkDir + RADIO_INI_FILE_APPLICATION);
  BASS_NetTimeOut := Settings.ReadInteger('SETTINGS', 'BASS_NetTimeOut', 5);
  BASS_Buffer := Settings.ReadInteger('SETTINGS', 'BASS_Buffer', 500);
  PlayListFileName := Settings.ReadString('SETTINGS', 'PlayList',
    Format('%s%s', [ExtractFilePath(Application.ExeName), 'stations.m3u']));
  RecoveryOnConnectionLoss := Settings.ReadBool('SETTINGS', 'RecoveryOnConnectionLoss', True);
  Settings.Free;
end;

procedure TRadioMOR_MainForm.ReadPersonalSettings;
var
  Settings: TIniFile;
begin
  Settings := TIniFile.Create(PersonalWorkDir + RADIO_INI_FILE_PERSONAL);

  { < ReadAppSettings }
//  BASS_NetTimeOut := Settings.ReadInteger('SETTINGS', 'BASS_NetTimeOut', 5);
//  BASS_Buffer := Settings.ReadInteger('SETTINGS', 'BASS_Buffer', 500);
//  PlayListFileName := Settings.ReadString('SETTINGS', 'PlayList',
//    Format('%s%s', [ExtractFilePath(Application.ExeName), 'stations.m3u']));
//  RecoveryOnConnectionLoss := Settings.ReadBool('SETTINGS', 'RecoveryOnConnectionLoss', True);
  { ReadAppSettings > }

  DisplayColor := Settings.ReadInteger('SETTINGS', 'DisplayColor', $000080FF{00FFBF80});
  DisplayFont := Settings.ReadString('SETTINGS', 'DisplayFont', 'a_LCDNova');
  AutoPlay := Settings.ReadBool('SETTINGS', 'AutoPlay', True);
  ScrollStationName := Settings.ReadBool('SETTINGS', 'ScrollStationName', False);
  ScrollStreamTitle := Settings.ReadBool('SETTINGS', 'ScrollStreamTitle', True);

  RadioMOR_MainForm.Top := Settings.ReadInteger('LAST_STATE', 'WindowTop',
    Round((Screen.Monitors[0].Height - RadioMOR_MainForm.Height) / 2));
  RadioMOR_MainForm.Left := Settings.ReadInteger('LAST_STATE', 'WindowLeft',
    Round((Screen.Monitors[0].Width - RadioMOR_MainForm.Width) / 2));
  StationID := Settings.ReadString('LAST_STATE', 'StationID', '');
  Volume := Settings.ReadInteger('LAST_STATE', 'Volume', 30);
  FView := Settings.ReadInteger('LAST_STATE', 'View', RADIO_VIEW_PLAYLIST);
  FWindowHeight := Settings.ReadInteger('LAST_STATE', 'WindowHeight', RADIO_HEIGHT_PLAYLIST);
  Settings.Free;
end;

procedure TRadioMOR_MainForm.RegisterTaskbarButtonCreatedMessage;
var
  cfStrust: TChangeFilterStruct;
  user32Handle: THandle;
begin
  MsgTaskbar := RegisterWindowMessage(PChar('TaskbarButtonCreated'));
  { Если закомментировать весь код ниже, то при запуске с правами администратора }
  { кнопки управления в панели задач создаваться и работать не будут. }
  { Такова политика безопасности MS }
  if MsgTaskbar <> 0 then
  if ((Win32MajorVersion = 6) and (Win32MinorVersion > 0)) or (Win32MajorVersion > 6) then
  try
    user32Handle := LoadLibrary(PChar('user32.dll'));
    if user32Handle <> 0 then
    begin
      @ChangeWindowMessageFilterEx := GetProcAddress(
          user32Handle,
          'ChangeWindowMessageFilterEx'
      );
      if Addr(ChangeWindowMessageFilterEx) <> nil then
      begin
        cfStrust.cbSize := SizeOf(TChangeFilterStruct);
        ChangeWindowMessageFilterEx(Self.Handle, MsgTaskbar, MSGFLT_ALLOW, @cfStrust);
        ChangeWindowMessageFilterEx(Self.Handle, WM_COMMAND, MSGFLT_ALLOW, @cfStrust);
      end
    end;
  finally
    FreeLibrary(user32Handle);
  end;
end;

procedure TRadioMOR_MainForm.ScrollToActiveStation;
var
  idx: Integer;
  R: TRect;
begin
  if PlayList.Sources.Count > 0 then
  begin
    idx := PlayList.GetItemIndexByID(StationID);
    if idx >= 0 then
    if ListView_IsItemVisible(ListView1.Handle, idx) = 0 then
    begin
      R := ListView1.Items[idx].DisplayRect(drBounds);
      ListView1.Scroll(0, R.Top - ListView1.ClientHeight div 2);
    end;
  end;
end;

procedure TRadioMOR_MainForm.SetDisplayColor(AColor: TColor);
var
  i: Integer;
  ctrl: TControl;
begin
  DisplayColor := AColor;
  FSelectionColor := ReduceBrightness(AColor, 60);

  Spectrum.StopDraw;
  Spectrum.PeakColor := IncreaseBrightness(AColor, 60);
  Spectrum.PenColor := DisplayColor;
  Spectrum.PenColor2 := IncreaseBrightness(AColor, 40);
  Spectrum.StartDraw;

  CreateDisplayBackground;
  DisplayBgPaint(Self);
  SpectrumBgPaint(Self);

  for i := 0 to DisplayPanel.ControlCount - 1 do
  begin
    ctrl := DisplayPanel.Controls[i];
    if ctrl is TLabel then
    begin
      TLabel(ctrl).Font.Color := DisplayColor;
      TLabel(ctrl).Repaint;
    end;
  end;


  ListView1.Refresh;
  ctrl := nil;
end;

procedure TRadioMOR_MainForm.SetView(AView: Byte);
const
  _margin: Integer = 6;
begin
  FView := AView;
  Constraints.MinHeight := 0;
  Constraints.MaxHeight := 0;

  case AView of
    RADIO_VIEW_STANDARD: begin
      ListView1.Hide;
      Height := 130;
      Constraints.MinHeight := RADIO_HEIGHT_STANDARD;
      Constraints.MaxHeight := RADIO_HEIGHT_STANDARD;
    end;

    RADIO_VIEW_PLAYLIST: begin
      ListView1.Show;
      Height := FWindowHeight;
      Constraints.MinHeight := RADIO_HEIGHT_PLAYLIST;
      try
        ListView1.Items[StationIndex].Focused := True;
        ListView1.Items[StationIndex].Selected := True;
      except

      end;
      ScrollToActiveStation;

      if Self.Top + Self.Height > Screen.WorkAreaHeight then
      case Self.Height > Screen.WorkAreaHeight of
        True: Self.Top := _margin;
        False: Self.Top := Screen.WorkAreaHeight - Self.Height - _margin;
      end;

      if Self.Left + Self.Width > Screen.DesktopWidth
        then Self.Left := Screen.DesktopWidth - Self.Width - _margin;

      if Self.Left < 0
        then Self.Left := _margin;
    end;

    else begin
      ListView1.Hide;
      Height := 130;
      Constraints.MinHeight := 130;
      Constraints.MaxHeight := 130;
    end;
  end;
end;

procedure TRadioMOR_MainForm.SpectrumBgPaint(Sender: TObject);
begin
  SpectrumBg.Canvas.Draw(0, 0, FSpectrumBackground);
end;

procedure TRadioMOR_MainForm.StationNameLabelClick(Sender: TObject);
begin
  with Form_StationStatistics do
  try
    CallingForm := Self;
    RadioStation := PlayList.Sources[StationIndex];
    Position := poMainFormCenter;
    Show;
    Self.Enabled := False;
  except

  end;
end;

procedure TRadioMOR_MainForm.WndProc(var Message: TMessage);
var
  DrawItem: TDrawItemStruct;
  CopyData: TCopyDataStruct;
  ResultInfo: array [0..MAX_PATH] of char;
  CloseAction: TCloseAction;
  StartupInfo: TStartupInfo;
begin
  case Message.Msg of
    WM_COPYDATA: begin
      CopyData := PCopyDataStruct(Message.LParam)^;
      StrLCopy(ResultInfo, CopyData.lpData, CopyData.cbData);

      case IndexText(ResultInfo,
        [
          'SHOW_WINDOW'
        ]
      ) of
        0: begin
          case Self.WindowState of
            wsMinimized: begin
              Self.Visible := True;
              ShowWindow(Self.Handle, SW_RESTORE) ;
              Application.BringToFront();
            end;
            else Application.BringToFront;
          end;

          Message.Result := 1;
          { Важно выйти в этом месте, иначе Message.Result примет значение 0 после inherited }
          Exit;
        end;
      end;
    end;
  end;

  inherited;
end;

procedure TRadioMOR_MainForm.WriteAppSettings;
var
  Settings: TIniFile;
begin
  try
    Settings := TIniFile.Create(AppWorkDir + RADIO_INI_FILE_APPLICATION);
    Settings.WriteInteger('SETTINGS', 'BASS_NetTimeOut', BASS_NetTimeOut);
    Settings.WriteInteger('SETTINGS', 'BASS_Buffer', BASS_Buffer);
    Settings.WriteString('SETTINGS', 'PlayList', PlayListFileName);
    Settings.WriteBool('SETTINGS', 'RecoveryOnConnectionLoss', RecoveryOnConnectionLoss);
  except

  end;

  Settings.Free;
end;

procedure TRadioMOR_MainForm.WritePersonalSettings;
var
  Settings: TIniFile;
begin
  Settings := TIniFile.Create(PersonalWorkDir + RADIO_INI_FILE_PERSONAL);

  { < WriteAppSettings }
//  Settings.WriteInteger('SETTINGS', 'BASS_NetTimeOut', BASS_NetTimeOut);
//  Settings.WriteInteger('SETTINGS', 'BASS_Buffer', BASS_Buffer);
//  Settings.WriteString('SETTINGS', 'PlayList', PlayListFileName);
//  Settings.WriteBool('SETTINGS', 'RecoveryOnConnectionLoss', RecoveryOnConnectionLoss);
  { WriteAppSettings > }

  Settings.WriteInteger('SETTINGS', 'DisplayColor', DisplayColor);
  Settings.WriteString('SETTINGS', 'DisplayFont', DisplayFont);
  Settings.WriteBool('SETTINGS', 'AutoPlay', AutoPlay);
  Settings.WriteBool('SETTINGS', 'ScrollStationName', ScrollStationName);
  Settings.WriteBool('SETTINGS', 'ScrollStreamTitle', ScrollStreamTitle);

  Settings.WriteInteger('LAST_STATE', 'WindowTop', RadioMOR_MainForm.Top);
  Settings.WriteInteger('LAST_STATE', 'WindowLeft',RadioMOR_MainForm.Left);
  Settings.WriteString('LAST_STATE', 'StationID', StationID);
  case TrackBar1.Position > 0 of
    True  : Settings.WriteInteger('LAST_STATE', 'Volume', TrackBar1.Position);
    False : Settings.WriteInteger('LAST_STATE', 'Volume', TrackBar1.Tag);
  end;
  Settings.WriteInteger('LAST_STATE', 'View', FView);
  case FView of
    RADIO_VIEW_PLAYLIST: Settings.WriteInteger('LAST_STATE', 'WindowHeight', RadioMOR_MainForm.Height);
    else Settings.WriteInteger('LAST_STATE', 'WindowHeight', FWindowHeight);
  end;

  Settings.Free;
end;

procedure TRadioMOR_MainForm.ToolButton2Click(Sender: TObject);
begin
  SetDisplayColor(clWhite);
end;

procedure TRadioMOR_MainForm.TrackBar1Change(Sender: TObject);
begin
  Radio.Volume := TrackBar1.Position;
  VolumeLabel.Caption := IntToStr(TrackBar1.Position) + '%';
  if TrackBar1.Position > 0 then
  begin
    DM1.ImageList1.GetIcon(6, Image1.Picture.Icon);
    with DM1.ActionManager1.Actions[4] do
    begin
      ImageIndex := 9;
      Hint := 'Выключить звук'
    end;
  end else
  begin
    DM1.ImageList1.GetIcon(7, Image1.Picture.Icon);
    with DM1.ActionManager1.Actions[4] do
    begin
      ImageIndex := 10;
      Hint := 'Включить звук'
    end;
  end;
  Taskbar.ApplyButtonsChanges;
end;

procedure TRadioMOR_MainForm.TrackBarWndProc(var Msg: TMessage);
var
  ARect: TRect;
  DC: HDC;
  BtnFaceBrush: HBRUSH;
  Handle: HWND;
begin
  FTrackBarWndProc(Msg);
  if Msg.Msg = WM_PAINT then
  begin
    Handle := TrackBar1.Handle;
    DC := GetWindowDC(Handle);
    BtnFaceBrush := CreateSolidBrush(TStyleManager.ActiveStyle.GetStyleColor(scWindow));
    try
      GetWindowRect(Handle, ARect);
      OffsetRect(ARect, -ARect.Left, -ARect.Top);
      FrameRect(DC, ARect, BtnFaceBrush);
      InflateRect(ARect, -1, -1);
      FrameRect(DC, ARect, BtnFaceBrush);
      InflateRect(ARect, -1, -1);
      FrameRect(DC, ARect, BtnFaceBrush);
      InflateRect(ARect, -1, -1);
      FrameRect(DC, ARect, BtnFaceBrush);
    finally
      DeleteObject(BtnFaceBrush);
      ReleaseDC(Handle, DC);
    end;
    FTrackBarWndProc(Msg);
  end;
end;

procedure TRadioMOR_MainForm.VolumeChange(Sender: TObject);
begin
  Radio.Volume := TrackBar1.Position;
  VolumeLabel.Caption := IntToStr(TrackBar1.Position) + '%';
  if TrackBar1.Position > 0 then DM1.ImageList1.GetIcon(6, Image1.Picture.Icon)
    else DM1.ImageList1.GetIcon(7, Image1.Picture.Icon);
end;

{ TTrackBar }

function TTrackBar.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  if WheelDelta > 0 then Position := Position + PageSize
    else Position := Position - PageSize;
  Result := True;
end;

{ TListView }

procedure TListView.CNMeasureItem(var Message: TWMMeasureItem);
begin
  inherited;
  Message.MeasureItemStruct.itemHeight := 18;
end;

end.
