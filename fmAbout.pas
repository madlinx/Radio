unit fmAbout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvExControls, JvGradient, Vcl.StdCtrls,
  Vcl.ExtCtrls, JvScrollText, JvComponentBase, JvComputerInfoEx,
  Vcl.Imaging.pngimage;

type
  TForm8 = class(TForm)
    Image1: TImage;
    Label3: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    JvComputerInfoEx1: TJvComputerInfoEx;
    UserInfoLabel: TLabel;
    ComputerInfoLabel: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    OSInfoLabel: TLabel;
    JvScrollText1: TJvScrollText;
    BassDllVersionLabel: TLabel;
    Label6: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form8: TForm8;

implementation

{$R *.dfm}

uses fmMainForm;

procedure TForm8.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RadioMOR_MainForm.Enabled := True;
  RadioMOR_MainForm.Show;
end;

procedure TForm8.FormCreate(Sender: TObject);
var
  FBVersion, InfoString: string;
begin
  InfoString := TOSVersion.ToString;
//  InfoString := JvComputerInfoEx1.OS.ProductName;
//  if InfoString = '' then InfoString := 'Microsoft Windows';
//  InfoString := InfoString + ', Версия '
//    + IntToStr(JvComputerInfoEx1.OS.VersionMajor) + '.'
//    + IntToStr(JvComputerInfoEx1.OS.VersionMinor) + ' '
//    + '(Сборка ' + IntToStr(JvComputerInfoEx1.OS.VersionBuild);
//  if JvComputerInfoEx1.OS.VersionCSDString <> ''
//    then InfoString := InfoString + ': ' + JvComputerInfoEx1.OS.VersionCSDString;
//  InfoString := InfoString + ')';
  OSInfoLabel.Caption := InfoString;
  //MemoryInfoLabel.Caption := FormatFloat('#,##0 КБ', JvComputerInfoEx1.Memory.TotalPhysicalMemory/1024);
  ComputerInfoLabel.Caption := JvComputerInfoEx1.Identification.LocalComputerName
    + ' / ' + JvComputerInfoEx1.Identification.IPAddress;
  UserInfoLabel.Caption := JvComputerInfoEx1.Identification.LocalUserName;

  Label2.Caption := Format('Copyright © 2013-%d, JSC Mozyr Oil Refinery', [CurrentYear]);
  JvScrollText1.Items[JvScrollText1.Items.Count - 2] := Format('Copyright © 2013-%d:', [CurrentYear]);
end;

procedure TForm8.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
end;

end.
