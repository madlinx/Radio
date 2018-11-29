program radiomor;

uses
  Forms,
  fmMainForm in 'fmMainForm.pas' {RadioMOR_MainForm},
  DataModule1 in 'DataModule1.pas' {DM1: TDataModule},
  fmAbout in 'fmAbout.pas' {Form8},
  RadioMOR.PlayList in 'RadioMOR.PlayList.pas',
  BASS.Spectrum in 'BASS.Spectrum.pas',
  fmSettings in 'fmSettings.pas' {Form2},
  Vcl.Themes,
  Vcl.Styles,
  RadioMOR.GlobalVar in 'RadioMOR.GlobalVar.pas',
  RadioMOR.BassRadio in 'RadioMOR.BassRadio.pas',
  RadioMOR.Common in 'RadioMOR.Common.pas',
  BASS in 'BASS.pas',
  RadioMOR.Types in 'RadioMOR.Types.pas',
  fmStationStatistics in 'fmStationStatistics.pas' {Form_StationStatistics},
  fmServerStatistics in 'fmServerStatistics.pas' {Form_ServerStatistics};

{$R *.res}

begin
  if AppInstanceExists('TRadioMOR_MainForm')
    then Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Carbon');
  Application.CreateForm(TDM1, DM1);
  Application.CreateForm(TRadioMOR_MainForm, RadioMOR_MainForm);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm8, Form8);
  Application.CreateForm(TForm_StationStatistics, Form_StationStatistics);
  Application.CreateForm(TForm_ServerStatistics, Form_ServerStatistics);
  Application.Run;
end.
