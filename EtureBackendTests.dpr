program EtureBackendTests;

uses
  Vcl.Forms,
  WEBLib.Forms,
  TestBackendConnection in 'TestBackendConnection.pas',
  TestAcademicRecords in 'TestAcademicRecords.pas',
  TestCampaigns in 'TestCampaigns.pas',
   TestAppIssues in 'TestAppIssues.pas',
  TestPositions in 'TestPositions.pas',
  TestParents in 'TestParents.pas',
  TestInjuryAuxModels in 'TestInjuryAuxModels.pas',
  senCille.WebSetup in '..\EtureFrontend\framework\senCille.WebSetup.pas',
  senCille.Bootstrap in '..\EtureFrontend\framework\senCille.Bootstrap.pas',
  senCille.MVCRequests in '..\EtureFrontend\framework\senCille.MVCRequests.pas',
  ConfigurationConsts in '..\EtureFrontend\framework\ConfigurationConsts.pas',
  senCille.Miscellaneous in '..\EtureFrontend\framework\senCille.Miscellaneous.pas',
  Dummy in '..\EtureFrontend\Dummy\Dummy.pas' {DummyForm: TWebForm} {*.html},
  senCille.CustomWebForm in '..\EtureFrontend\framework\senCille.CustomWebForm.pas' {scCustomWebForm: TWebForm} {*.html},
  senCille.DataManagement in '..\EtureFrontend\framework\senCille.DataManagement.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
