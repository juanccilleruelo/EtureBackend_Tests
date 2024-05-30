program EtureBackendTests;

uses
  Vcl.Forms,
  WEBLib.Forms,
  senCille.Miscellaneous in 'framework\senCille.Miscellaneous.pas',
  senCille.MVCRequests in 'framework\senCille.MVCRequests.pas',
  ConfigurationConsts in 'framework\ConfigurationConsts.pas',
  TestBackendConnection in 'TestBackendConnection.pas',
  TestAcademicRecords in 'TestAcademicRecords.pas',
  TestCampaigns in 'TestCampaigns.pas',
  TestPositions in 'TestPositions.pas',
  TestTutors in 'TestTutors.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
