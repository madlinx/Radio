unit fmSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls, System.Win.Registry, System.RegularExpressions,
  BASS, RadioMOR.Common, RadioMOR.GlobalVar;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    PageControl_Settings: TPageControl;
    TabSheet_General: TTabSheet;
    TabSheet_Playback: TTabSheet;
    TabSheet_View: TTabSheet;
    CheckBox_Autoplay: TCheckBox;
    ComboBox_Device: TComboBox;
    Edit_Timeout: TEdit;
    UpDown_Timeout: TUpDown;
    Edit_BufferSize: TEdit;
    UpDown_BufferSize: TUpDown;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Button10: TButton;
    CheckBox_ScrollStreamTitle: TCheckBox;
    CheckBox_ScrollStationName: TCheckBox;
    ComboBox_Font: TComboBox;
    ColorPanel: TPanel;
    Label_Font: TLabel;
    Label6: TLabel;
    CheckBox_Autorun: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Edit_TimeoutChange(Sender: TObject);
    procedure Edit_BufferSizeChange(Sender: TObject);
    procedure ComboBox_FontDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    function GetAutorun: Boolean;
    procedure SetAutorun(AValue: Boolean);
  public
    procedure UpdateParameterControls;
  end;

var
  Form2: TForm2;

implementation

uses fmMainForm, DataModule1;

{$R *.dfm}

procedure TForm2.Button10Click(Sender: TObject);
begin
  with DM1.ColorDialog1 do
  begin
    Color := ColorPanel.Color;
    if Execute
      then ColorPanel.Color := Color;
  end;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  { Общие }
  SetAutorun(CheckBox_Autorun.Checked);
  AutoPlay := CheckBox_Autoplay.Checked;

  { Воспроизведение }
  BASS_Buffer := UpDown_BufferSize.Position;
  BASS_NetTimeOut := UpDown_Timeout.Position;

  { Вид }
  DisplayColor := ColorPanel.Color;
  RadioMOR_MainForm.SetDisplayColor(DisplayColor);
  DisplayFont := ComboBox_Font.Text;
  ScrollStationName := CheckBox_ScrollStationName.Checked;
  ScrollStreamTitle := CheckBox_ScrollStreamTitle.Checked;

  RadioMOR_MainForm.ApplySettings;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  Button2Click(Self);
  Close;
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
  CheckBox_Autorun.Checked := False;
  CheckBox_Autoplay.Checked := True;
  UpDown_Timeout.Position := 10;
  UpDown_BufferSize.Position := 500;
  ColorPanel.Color := $000080FF{00FFBF80};
  ComboBox_Font.ItemIndex := 0;
  CheckBox_ScrollStationName.Checked := False;
  CheckBox_ScrollStreamTitle.Checked := True;
end;

procedure TForm2.ComboBox_FontDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
const
  _margin: Integer = 6;
var
  ItemText: string;
  C: TCanvas;
//  DC: HDC;
  DrawRect: TRect;
  DeviderPos: Integer;
  TextWidth: Integer;
begin
//  DeviderPos := 0;
//  { Вычисляем положение отрисовки разделителя }
//  if odComboBoxEdit in State then
//  begin
//    DeviderPos := GetTextWidthInPixels(ComboBox_Font.Items[Index], ComboBox_Font.Font) + 6;
//  end
//  else for ItemText in ComboBox_Font.Items do
//  begin
//    TextWidth := GetTextWidthInPixels(ItemText, ComboBox_Font.Font);
//    if DeviderPos < TextWidth
//      then DeviderPos := TextWidth;
//  end;
//  DeviderPos := DeviderPos + _margin * 2;
//
//  ItemText := ComboBox_Font.Items[Index];
////  DC := ComboBox_DC.Canvas.Handle;
//  C := ComboBox_Font.Canvas;
//  if ( odSelected in State ) or ( odFocused in State ) then
//  begin
//     C.Brush.Color := clHighlight;
//     C.Pen.Color := clHighlightText;
//  end else
//  begin
//    C.Pen.Color := clWhite;
//  end;
//  C.FillRect(Rect);
//
//  { Рисуем разделитель }
//  C.Pen.Width := 1;
//  C.MoveTo(DeviderPos, Rect.Top);
//  C.LineTo(DeviderPos, Rect.Bottom);
//
//  { Выводим имя шрифта }
//  DrawRect := Rect;
//  OffsetRect(DrawRect, _margin, 1);
//  if DeviderPos - _margin < Rect.Right
//    then DrawRect.Right := DeviderPos - _margin
//    else DrawRect.Right := Rect.Right;
//  with C.Font do
//  begin
//    if ( odSelected in State ) or ( odFocused in State )
//      then Color := clHighlightText
//      else Color := clWhite;
//  end;
//  C.TextRect(DrawRect, ItemText, [tfLeft, tfEndEllipsis, tfVerticalCenter]);
//
//  { Выводим предварительный просмотр шрифта }
//  DrawRect := Rect;
//  OffsetRect(DrawRect, DeviderPos + _margin, 1);
//  DrawRect.Right := Rect.Right;
//  with C.Font do
//  begin
//    Name := ItemText;
//    if ( odSelected in State ) or ( odFocused in State )
//      then Color := clHighlightText
//      else Color := clWhite;
//  end;
//  ItemText := 'Исплнитель - Название трека';
//  C.TextRect(DrawRect, ItemText, [tfLeft, tfEndEllipsis, tfVerticalCenter]);
end;

procedure TForm2.Edit_TimeoutChange(Sender: TObject);
var
  res: string;
begin
  res := StringReplace(Edit_Timeout.Text, FormatSettings.ThousandSeparator, '', [rfReplaceAll]);
  if StrToIntDef(res, 0) > UpDown_Timeout.Max then
  begin
    Edit_Timeout.Text := FormatFloat('#' + FormatSettings.ThousandSeparator + '##0', UpDown_Timeout.Max);
    Edit_Timeout.SelStart := Length(Edit_Timeout.Text);
    Edit_Timeout.SelLength := 0;
  end;
end;

procedure TForm2.Edit_BufferSizeChange(Sender: TObject);
var
  res: string;
begin
  res := StringReplace(Edit_BufferSize.Text, FormatSettings.ThousandSeparator, '', [rfReplaceAll]);
  if StrToIntDef(res, 0) > UpDown_BufferSize.Max then
  begin
    Edit_BufferSize.Text := FormatFloat('#' + FormatSettings.ThousandSeparator + '##0', UpDown_BufferSize.Max);
    Edit_BufferSize.SelStart := Length(Edit_BufferSize.Text);
    Edit_BufferSize.SelLength := 0;
  end;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RadioMOR_MainForm.Enabled := True;
  RadioMOR_MainForm.Show;
end;

function TForm2.GetAutorun: Boolean;
var
  Reg: TRegistry;
  Res: Boolean;
  s: string;
  regEx: TRegEx;
begin
  Reg := TRegistry.Create(KEY_ALL_ACCESS);
  Reg.RootKey := HKEY_CURRENT_USER;
  Res := Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False);
  if not Res then Result := False else
  begin
    Res := Reg.ValueExists('RadioMOR');
    if not Res then Result := False else
    begin
      s := Reg.ReadString('RadioMOR');
      regEx := TRegEx.Create('(?:[A-z]\:|\\)(\\[\w\-\s\.]+)+\.\w+');
      Result := CompareText(regEx.Match(s).Value, Application.ExeName) = 0;
    end;
  end;
  Reg.CloseKey;
  Reg.Free;
end;

procedure TForm2.SetAutorun(AValue: Boolean);
var
  Reg: TRegistry;
  Res: Boolean;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  Reg.RootKey := HKEY_CURRENT_USER;
  Res := Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False);
  if Res then
  case AValue of
    True : Reg.WriteString('RadioMOR', '"' + Application.ExeName +'" -autorun');
    False: Reg.DeleteValue('RadioMOR');
  end;
  Reg.CloseKey;
  Reg.Free;
end;

procedure TForm2.UpdateParameterControls;
var
  DevNumber: Integer;
  DevInfo: BASS_DEVICEINFO;
  i: Integer;
  res: Integer;
  lFont: TLogFont;
  sFontName: string;
begin
  PageControl_Settings.ActivePageIndex := 0;
  DevNumber := 0;

  { Общие }
  CheckBox_Autorun.Checked := GetAutorun;
  CheckBox_Autoplay.Checked := AutoPlay;

  { Воспроизведение }
  ComboBox_Device.Clear;
  while BASS_GetDeviceInfo(DevNumber, DevInfo) do
  begin
    ComboBox_Device.Items.Add(DevInfo.name);
    DevNumber := DevNumber + 1;
  end;
  ComboBox_Device.ItemIndex := BASS_GetDevice;

  UpDown_Timeout.Position := Round(BASS_GetConfig(BASS_CONFIG_NET_TIMEOUT) / 1000);
  UpDown_BufferSize.Position := BASS_GetConfig(BASS_CONFIG_BUFFER);

  { Вид }
  Form2.ColorPanel.Color := DisplayColor;
//  ComboBox_Font.Clear;
//  for i := Low(aFonts) to High(aFonts) do
//  begin
//    FillChar(lFont, SizeOf(TLogFont), 0);
//    res := GetObject(aFonts[i], SizeOf(TLogFont), @lFont);
//    if res <> 0 then
//    begin
//      sFontName := PChar(@lFont.lfFaceName[0]);
//      ComboBox_Font.AddItem(sFontName, nil);
//    end;
//  end;

  ComboBox_Font.ItemIndex := ComboBox_Font.Items.IndexOf(DisplayFont);
  CheckBox_ScrollStationName.Checked := ScrollStationName;
  CheckBox_ScrollStreamTitle.Checked := ScrollStreamTitle;
end;

end.
