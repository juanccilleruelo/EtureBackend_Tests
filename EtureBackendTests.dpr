program EtureBackendTests;

uses
  Vcl.Forms,
  WEBLib.Forms,
  TestBackendConnection in 'TestBackendConnection.pas',
  TestAppIssues in 'TestAppIssues.pas',
  TestCategories in 'TestCategories.pas',
   TestClubs in 'TestClubs.pas',
  TestAssays in 'TestAssays.pas',
  TestPublicResources in 'TestPublicResources.pas',
  TestCampaigns in 'TestCampaigns.pas',
  TestCallUps in 'TestCallUps.pas',
  TestPositions in 'TestPositions.pas',
  TestParents in 'TestParents.pas',
  TestCareerHistory in 'TestCareerHistory.pas',
  TestInjuryAuxModels in 'TestInjuryAuxModels.pas',
  TestAcademicRecords in 'TestAcademicRecords.pas',
  TestClinicalRecords in 'TestClinicalRecords.pas',
  senCille.WebSetup in '..\EtureFrontend\framework\senCille.WebSetup.pas',
  senCille.Bootstrap in '..\EtureFrontend\framework\senCille.Bootstrap.pas',
  senCille.MVCRequests in '..\EtureFrontend\framework\senCille.MVCRequests.pas',
  ConfigurationConsts in '..\EtureFrontend\framework\ConfigurationConsts.pas',
  senCille.Miscellaneous in '..\EtureFrontend\framework\senCille.Miscellaneous.pas',
  Dummy in '..\EtureFrontend\Dummy\Dummy.pas' {DummyForm: TWebForm} {*.html},
  senCille.CustomWebForm in '..\EtureFrontend\framework\senCille.CustomWebForm.pas' {scCustomWebForm: TWebForm} {*.html},
  senCille.DataManagement in '..\EtureFrontend\framework\senCille.DataManagement.pas',
  TestAuxData in 'TestAuxData.pas',
   TestCalendarEvents in 'TestCalendarEvents.pas',
   TestConferences in 'TestConferences.pas';

{$R *.res}

begin
   Application.Initialize;
   Application.MainFormOnTaskbar := True;
   Application.Run;
end.
