program EtureBackendTests;

uses
  Vcl.Forms,
  WEBLib.Forms,
  TestAcademicRecords in 'TestAcademicRecords.pas',
  senCille.Miscellaneous in 'framework\senCille.Miscellaneous.pas',
  senCille.MVCRequests in 'framework\senCille.MVCRequests.pas',
  ConfigurationConsts in 'framework\ConfigurationConsts.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
