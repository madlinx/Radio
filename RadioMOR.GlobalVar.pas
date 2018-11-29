unit RadioMOR.GlobalVar;

interface

uses
  Winapi.Windows, System.Generics.Collections, Vcl.Graphics, Vcl.Taskbar,
  RadioMOR.Types, RadioMOR.PlayList;

var
  MsgTaskbar: Cardinal;
  AppWorkDir: string;
  PersonalWorkDir: string;
  StationID: string;
  StationIndex: Integer = -1;
  aFonts: TCustomFontArray;
  DisplayFont: string;
  DisplayColor: TColor;
  PlayListFileName: string;
  Volume: Byte;
  BASS_Buffer: Integer;
  BASS_NetTimeOut: Integer;
  InvertSelector: Boolean = True;
  RecoveryOnConnectionLoss: Boolean;
  AutoPlay: Boolean;
  ScrollStationName: Boolean;
  ScrollStreamTitle: Boolean;
  PlayList: TM3UPlayList;

  ChangeWindowMessageFilterEx: function(Wnd: HWND; Msg: UINT; Action: DWORD;
    ChangeFilterStruct: Pointer): Boolean; stdcall;

implementation

end.
