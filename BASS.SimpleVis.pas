unit BASS.SimpleVis;

// BassSimple v1.8
// модуль визуализациий
// http://jqbook.narod.ru/delphi/bass_vis.htm
// alexpac26@yandex.ru Тольятти 2012

interface

uses Windows, Dialogs, Graphics, SysUtils, Classes, RadioMOR.BassRadio, ExtCtrls;

Type

TPanel = class(ExtCtrls.TPanel)
  public
    property Canvas;
end;

TBassSimpleVis = class(TObject)
  private
    function RHeight: integer;
    function RWidth: integer;
    procedure WHeight(const Value: integer);
    procedure WWidth(const Value: integer);
  protected
      BackBmp : TBitmap;
      paintBox: TPanel;
      procedure TimerTimer(Sender: TObject);
      procedure Draw_vis; virtual;
      procedure OnCreate; virtual;
      procedure UpdateSize; virtual;
  public
    VisBuff : TBitmap;
    DrawX:integer;
    DrawY:integer;
    bassObj: TBassRadio;
    Timer: TTimer;
    BkgColor : TColor;
    PenColor : TColor;
    FrmClear : Boolean;
    UseBkg   : Boolean;
    DrawType: integer;
    procedure Clear; virtual;
    constructor Create (bassObj:TObject; PaintBox: ExtCtrls.TPanel; milisecond: cardinal = 30); virtual;
    destructor Destroy; override;
    procedure SetBackGround (Active : Boolean; BkgCanvas : TGraphic);
    procedure StartDraw; virtual;
    procedure StopDraw;  virtual;
    property Height: integer read RHeight write WHeight;
    property Width: integer read RWidth write WWidth;
end;

implementation

{ TBaseVisualization }

procedure TBassSimpleVis.Clear;
begin
  VisBuff.Canvas.Pen.Color := BkgColor;
  VisBuff.Canvas.Brush.Color := BkgColor;
  VisBuff.Canvas.Rectangle(0, 0, VisBuff.Width, VisBuff.Height);
  if UseBkg then VisBuff.Canvas.CopyRect(Rect(0, 0, BackBmp.Width, BackBmp.Height), BackBmp.Canvas, Rect(0, 0, BackBmp.Width, BackBmp.Height));
  BitBlt(self.paintBox.Canvas.Handle, 0, 0, VisBuff.Width, VisBuff.Height, VisBuff.Canvas.Handle, 0, 0, srccopy);
end;

constructor TBassSimpleVis.Create(bassObj: TObject; PaintBox: ExtCtrls.TPanel;
  milisecond: cardinal);
begin
  VisBuff := TBitmap.Create;
  BackBmp := TBitmap.Create;

  Timer:=TTimer.Create(PaintBox);
  Timer.Enabled:=false;
  Timer.Interval:=milisecond;
  Timer.OnTimer:=self.TimerTimer;
  self.bassObj:=TBassRadio(bassObj);
  self.paintBox:=TPanel(PaintBox);

  VisBuff.Width := self.PaintBox.Width;
  VisBuff.Height := self.PaintBox.Height;
  BackBmp.Width := self.PaintBox.Width;
  BackBmp.Height := self.PaintBox.Height;

  BkgColor := clBlack;
  PenColor := 14184595;
  FrmClear := True;
  UseBkg := False;
  DrawX:=0;
  DrawY:=0;
  DrawType:=0;

  OnCreate;
end;

destructor TBassSimpleVis.Destroy;
begin
  Timer.Destroy;
  VisBuff.free;
  BackBmp.free;
  inherited;
end;

procedure TBassSimpleVis.Draw_vis;
begin
  // n/a
end;

procedure TBassSimpleVis.OnCreate;
begin
  // n/a
end;

function TBassSimpleVis.RHeight: integer;
begin
  result:=VisBuff.Height;
end;

function TBassSimpleVis.RWidth: integer;
begin
  result:=VisBuff.Width;
end;

procedure TBassSimpleVis.SetBackGround(Active: Boolean;
  BkgCanvas: TGraphic);
begin
  UseBkg := Active;
  BackBmp.Canvas.Draw(0, 0, BkgCanvas);
end;

procedure TBassSimpleVis.StartDraw;
begin
  Timer.Enabled:=true;
end;

procedure TBassSimpleVis.StopDraw;
begin
  Timer.Enabled:=false;
  Clear;
end;

procedure TBassSimpleVis.TimerTimer(Sender: TObject);
begin
   if bassObj.State = bsPlay then Draw_vis else if bassObj.State = bsPause then Exit else Clear;
end;

procedure TBassSimpleVis.UpdateSize;
begin
  //
end;

procedure TBassSimpleVis.WHeight(const Value: integer);
begin
  VisBuff.Height:=value;
  paintBox.Height:=value;
  UpdateSize;
end;

procedure TBassSimpleVis.WWidth(const Value: integer);
begin
 VisBuff.Width:=value;
 paintBox.Width:=value;
 UpdateSize;
end;

end.
