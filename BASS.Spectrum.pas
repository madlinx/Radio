unit BASS.Spectrum;

// BassSimple v1.8
// визуализация "спектр"
// http://jqbook.narod.ru/delphi/bass_vis.htm
// alexpac26@yandex.ru Тольятти 2012

interface

uses
  Winapi.Windows, System.Math, Vcl.Dialogs, Vcl.Graphics, System.SysUtils,
  System.Classes, BASS, BASS.SimpleVis, RadioMOR.BassRadio;

 type TSpectrum = Class(TBassSimpleVis)
    protected
      FFTPeacks  : array [0..255] of Single;
      FFTFallOff : array [0..255] of Single;
      PickData1: array[0..255] of Single;
      PickData2: array[0..255] of Single;
      procedure Draw(HWND : THandle; X, Y : Integer); virtual;
      procedure OnCreate; override;
      procedure Draw_vis; override;
      procedure UpdateSize; override;
    public
      StreamBitrate: Word;
      BitmapSpectrum: TBitmap;
      mnog: single;
      mnogMatrix: single;
      LineCount: Integer;
      LineWidth : Integer;
      PeakShow : Boolean;
      PeakFall : Single;
      LineFall : Single;
      PeakColor: TColor;
      PenColor2: TColor;
      PenCenter: single;
      destructor Destroy; override;
      procedure StartDraw; override;
    end;

const // матрица спектро анализа BassSimple VIS v 1.7
spectrum_matrix: array[0..255] of single = (
  0.3887570, 0.9296451, 0.6818324, 0.5890286, 0.5175747, 0.4856205, 0.3223070, 0.3944266,
  0.3922172, 0.1862192, 0.2404768, 0.1812944, 0.2361309, 0.1526418, 0.1764436, 0.1465138,
  0.1262227, 0.1630830, 0.1289513, 0.1236878, 0.1094292, 0.2751496, 0.2909367, 0.2677711,
  0.2304773, 0.2788766, 0.2383599, 0.2920699, 0.2862922, 0.3084741, 0.3424028, 0.3266430,
  0.2651314, 0.2813882, 0.2744472, 0.2732180, 0.2717420, 0.2539919, 0.1910903, 0.2943712,
  0.3422086, 0.3053577, 0.2186195, 0.2237278, 0.2675802, 0.2510356, 0.2447454, 0.1872734,
  0.2457575, 0.1491822, 0.2015961, 0.2294250, 0.1609355, 0.1635137, 0.1152439, 0.1607668,
  0.1353835, 0.0917606, 0.0737245, 0.0953678, 0.0856792, 0.1082372, 0.1334169, 0.0895650,
  0.0809397, 0.0934055, 0.1052872, 0.0756614, 0.0757601, 0.0787047, 0.0846272, 0.0969112,
  0.1010916, 0.0962865, 0.0645690, 0.0644648, 0.0929973, 0.0942071, 0.0913096, 0.0819613,
  0.0926108, 0.1137771, 0.0896157, 0.0583732, 0.0814302, 0.1002376, 0.0658063, 0.0591318,
  0.0887872, 0.0938352, 0.0786612, 0.0907266, 0.0904946, 0.0836979, 0.0778948, 0.0473554,
  0.0521326, 0.0714429, 0.0763900, 0.0842281, 0.0672728, 0.0514371, 0.0699822, 0.0682188,
  0.0597373, 0.0873119, 0.0487065, 0.0525724, 0.0638328, 0.0506983, 0.0807146, 0.0502810,
  0.0637799, 0.0635729, 0.0492748, 0.0660175, 0.0642766, 0.0612233, 0.0506044, 0.0589489,
  0.0549454, 0.0445241, 0.0535281, 0.0576036, 0.0467815, 0.0486310, 0.0586580, 0.0538555,
  0.0615014, 0.0549888, 0.0484928, 0.0502714, 0.0572392, 0.0391223, 0.0472141, 0.0484569,
  0.0380067, 0.0412393, 0.0491522, 0.0577430, 0.0514432, 0.0437750, 0.0596669, 0.0615792,
  0.0456053, 0.0492348, 0.0542127, 0.0498144, 0.0489012, 0.0402933, 0.0522456, 0.0459986,
  0.0412331, 0.0418615, 0.0450647, 0.0359407, 0.0306501, 0.0251389, 0.0259840, 0.0351708,
  0.0381477, 0.0380282, 0.0421583, 0.0376327, 0.0256685, 0.0349484, 0.0379992, 0.0396389,
  0.0364739, 0.0293246, 0.0336921, 0.0240453, 0.0237301, 0.0264037, 0.0219793, 0.0242850,
  0.0248183, 0.0268364, 0.0294077, 0.0270079, 0.0260534, 0.0338652, 0.0246060, 0.0214867,
  0.0275492, 0.0325378, 0.0293736, 0.0241018, 0.0256128, 0.0245578, 0.0212964, 0.0254641,
  0.0239688, 0.0223880, 0.0263430, 0.0412184, 0.0341869, 0.0246067, 0.0204739, 0.0217485,
  0.0218925, 0.0185365, 0.0235025, 0.0226269, 0.0214246, 0.0238071, 0.0206002, 0.0179740,
  0.0183541, 0.0156934, 0.0183193, 0.0224145, 0.0257493, 0.0225187, 0.0184139, 0.0152407,
  0.0195499, 0.0162475, 0.0145622, 0.0213996, 0.0192790, 0.0200002, 0.0173806, 0.0131849,
  0.0117938, 0.0123681, 0.0116906, 0.0097563, 0.0083194, 0.0093707, 0.0088826, 0.0105030,
  0.0113908, 0.0113422, 0.0091066, 0.0130469, 0.0126814, 0.0087676, 0.0059537, 0.0050485,
  0.0051894, 0.0043989, 0.0040485, 0.0036095, 0.0023898, 0.0015569, 0.0008697, 0.0004868,
  0.0002562, 0.0003593, 0.0004478, 0.0002374, 0.0002346, 0.0003454, 0.0003677, 0.0002506
);

procedure Gradient2D(h: HWND; x1,y1:integer; color1: TColor; x2,y2:integer; color2:TColor; Vertical: boolean = false);

implementation

// совмеcтимо с Delphi 7 - XE

function GradientFill(DC: HDC; Vertex: Pointer; //PMyTriVertex
  dwNumVertex: ULONG; pMesh: Pointer;
  dwNumMesh, dwMode: ULONG): BOOL; stdcall; external 'Msimg32.dll';

procedure Gradient2D(h: HWND; x1,y1:integer; color1: TColor; x2,y2:integer; color2:TColor; Vertical: boolean = false);
type
  MyCOLOR16 = Word;
  PMyTriVertex = ^TMyTriVertex;
  TMyTriVertex = packed record
    x: Longint;
    y: Longint;
    Red: MyCOLOR16;
    Green: MyCOLOR16;
    Blue: MyCOLOR16;
    Alpha: MyCOLOR16;
  end;
var
  t:array[0..1] of TMyTriVertex;
  tt: PMyTriVertex;
  g:TGradientRect;
  mode: Cardinal;
begin
  t[0].x:=x1;
  t[0].y:=y1;
  t[0].Red:=round((GetRValue(color1)/255)*65535);
  t[0].Green:=round((GetGValue(color1)/255)*65535);
  t[0].Blue:=round((GetBValue(color1)/255)*65535);
  t[0].Alpha:=0;
  t[1].x:=x2;
  t[1].y:=y2;
  t[1].Red:=round((GetRValue(color2)/255)*65535);
  t[1].Green:=round((GetGValue(color2)/255)*65535);
  t[1].Blue:=round((GetBValue(color2)/255)*65535);
  t[1].Alpha:=0;
  g.UpperLeft:=0;
  g.LowerRight:=1;
  tt:=@t[0];
  if Vertical then mode := GRADIENT_FILL_RECT_V else mode := GRADIENT_FILL_RECT_H;
  GradientFill(h,tt,2,@g,1,mode);
end;

procedure CopyRectXY(source,dest: TCanvas; x1,y1,x2,y2:integer);
begin
  dest.CopyRect(
    Rect(Point(x1,y1),Point(x2,y2)),
    source,
    Rect(Point(x1,y1),Point(x2,y2))
  );
end;


destructor TSpectrum.Destroy;
begin
  BitmapSpectrum.Free;
  inherited;
end;

procedure TSpectrum.Draw(HWND : THandle; X, Y : Integer);
var
  i, j, YPos, k: LongInt;
  Sum : Single;
begin
  if FrmClear then
  begin
     VisBuff.Canvas.Pen.Color := BkgColor;
     VisBuff.Canvas.Brush.Color := BkgColor;
     VisBuff.Canvas.Rectangle(0, 0, VisBuff.Width, VisBuff.Height);
     if UseBkg then VisBuff.Canvas.CopyRect(Rect(0, 0, BackBmp.Width, BackBmp.Height),
       BackBmp.Canvas, Rect(0, 0, BackBmp.Width, BackBmp.Height));
  end;

  BASS_ChannelGetData(bassObj.Stream, @PickData1, BASS_DATA_FFT512);

  // Нормализация
  for i := 0 to High(PickData1) do
  begin
    { Если раскомментировать строку ниже, то будет происходить постоянное    }
    { затухание спектра, пока он вообще не перестанет отображаться. В чем    }
    { причина я не вникал, а просто закомметировал. / 13.10.2016 / azhigadlo }
    //if PickData2[i] < Abs(PickData1[i]) then PickData2[i] := Abs(PickData1[i]) * 1.05;
    PickData1[i] := (Abs(PickData1[i]) / PickData2[i]) * mnog;
    if PickData1[i] > 1 then PickData1[i] := 1;
  end;

  if LineCount > Length(PickData1) then LineCount := Length(PickData1);
  if LineCount < 3 then LineCount := 3;

  // Горизонтальное сжатие
  case StreamBitrate of
    0..63    : k := Trunc(125 / LineCount);
    64..127  : k := Trunc(150 / LineCount);
    128..191 : k := Trunc(175 / LineCount);
    192..255 : k := Trunc(200 / LineCount);
    256..320 : k := Trunc(225 / LineCount);
    else       k := Trunc(Length(PickData1) / LineCount);
  end;

  for i := 0 to LineCount - 1 do
  begin
    Sum := 0;
    for j := (i * k) to ((i + 1) * k) do
      if Sum < PickData1[j] then Sum := PickData1[j];
    PickData1[i] := Sum;
  end;

  // отрисовка
  VisBuff.Canvas.Pen.Color := PenColor;
  for k := 0 to LineCount - 1 do
  begin
    YPos:=round(VisBuff.Height*PickData1[k]);
    // высота рассчитана
    //FFTFallOff[k] := YPos;
    if YPos >= FFTPeacks[k] then FFTPeacks[k] := YPos else FFTPeacks[k] := FFTPeacks[k] - PeakFall;
    if YPos >= FFTFallOff[k] then FFTFallOff[k] := YPos else FFTFallOff[k] := FFTFallOff[k] - LineFall;
    // высоты записаны
    if (VisBuff.Height - FFTPeacks[k]) > VisBuff.Height then FFTPeacks[k] := 0;
    if (VisBuff.Height - FFTFallOff[k]) > VisBuff.Height then FFTFallOff[k] := 0;
    // коррекция
    case DrawType of
      0 : begin
        //VisBuff.Canvas.Pen.Color:=self.PenColor;
        CopyRectXY(BitmapSpectrum.Canvas,VisBuff.Canvas,
          X + k,
          Y + VisBuff.Height,
          X + k+1,
          Y + VisBuff.Height - round(FFTFallOff[k])
        );
        if PeakShow then VisBuff.Canvas.Pixels[X + k, Y + VisBuff.Height - round(FFTPeacks[k])] := self.PeakColor;
      end;
      1 : begin
        if PeakShow then
        begin
           VisBuff.Canvas.Pen.Color := PeakColor;
           VisBuff.Canvas.MoveTo(X + k * (LineWidth + 1), Y + VisBuff.Height - round(FFTPeacks[k]));
           VisBuff.Canvas.LineTo(X + k * (LineWidth + 1) + LineWidth, Y + VisBuff.Height - round(FFTPeacks[k]));
        end;
        // VisBuff.Canvas.Pen.Color := PenColor;
        //VisBuff.Canvas.Brush.Color := PenColor;
        CopyRectXY(BitmapSpectrum.Canvas,VisBuff.Canvas,
          X + k * (LineWidth + 1),
          Y + VisBuff.Height - round(FFTFallOff[k]),
          X + k * (LineWidth + 1) + LineWidth,
          Y + VisBuff.Height
        );
      end;
    end; // end case
  end;// end if
  // отрисовка
  BitBlt(HWND, 0, 0, VisBuff.Width, VisBuff.Height, VisBuff.Canvas.Handle, 0, 0, srccopy)
end; // end procedure

procedure TSpectrum.Draw_vis;
begin
  inherited;
  Draw(paintBox.Canvas.Handle, DrawX, DrawY);
end;

procedure TSpectrum.OnCreate;
var i:integer;
begin
  inherited;
  PeakColor := 9868950;
  PenColor := 558104;
  PenColor2 := clRed;
  PenCenter := 0.8;
  DrawType := 1;
  LineCount  := 50;
  PeakFall := 0.7;
  LineFall := 3;
  LineWidth := 3;
  PeakShow := True;
  mnog:=1; // множитель
  mnogMatrix:=0.8;
  DrawX:=2;
  DrawY:=0;
  BitmapSpectrum:=TBitmap.Create;
  UpdateSize;
  for i := 0 to high(FFTPeacks) do begin
    FFTPeacks[i]:=0;
    FFTFallOff[i]:=0;
  end;
  for i := 0 to high(PickData2) do PickData2[i]:=spectrum_matrix[i];
end;

procedure TSpectrum.StartDraw;
var i:integer;
begin
  // инициализация матрицы нормализации
  StreamBitrate := 0;
  UpdateSize;
  for i := 0 to high(PickData2) do PickData2[i]:=spectrum_matrix[i] * mnogMatrix;
  inherited;
end;

procedure TSpectrum.UpdateSize;
begin
  inherited;
  BitmapSpectrum.Width:=paintBox.Width;
  BitmapSpectrum.Height:=paintBox.Height;
  BitmapSpectrum.Canvas.Pen.color:=PenColor;
  BitmapSpectrum.Canvas.Brush.Color:=PenColor;
  BitmapSpectrum.Canvas.FillRect(BitmapSpectrum.Canvas.ClipRect);
  Gradient2D(BitmapSpectrum.Canvas.Handle,0,0,PenColor2,BitmapSpectrum.Width,round(PenCenter*paintBox.Height),PenColor,true);
end;

end.


