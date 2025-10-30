program EtureBackendTests;

uses
  Vcl.Forms,
  WEBLib.Forms,
  senCille.WebSetup in '..\EtureFrontend\framework\senCille.WebSetup.pas',
  senCille.Bootstrap in '..\EtureFrontend\framework\senCille.Bootstrap.pas',
  senCille.MVCRequests in '..\EtureFrontend\framework\senCille.MVCRequests.pas',
  ConfigurationConsts in '..\EtureFrontend\framework\ConfigurationConsts.pas',
  senCille.Miscellaneous in '..\EtureFrontend\framework\senCille.Miscellaneous.pas',
  Dummy in '..\EtureFrontend\Dummy\Dummy.pas' {DummyForm: TWebForm} {*.html},
  senCille.CustomWebForm in '..\EtureFrontend\framework\senCille.CustomWebForm.pas' {scCustomWebForm: TWebForm} {*.html},
  senCille.DataManagement in '..\EtureFrontend\framework\senCille.DataManagement.pas' {$R *.res},
  TestCallUps in 'TestCallUps.pas',
  senCille.TypeConverter in '..\EtureFrontend\framework\senCille.TypeConverter.pas';

(*
   TestProperties in 'TestProperties.pas',
   TestCalendarEvents in 'TestCalendarEvents.pas',
   TestUniversities in 'TestUniversities.pas',
   TestTeams in 'TestTeams.pas',
   //TestMyVisaTemplates in 'TestMyVisaTemplates.pas',
   TestSocialMedia in 'TestSocialMedia.pas',
   TestStates in 'TestStates.pas',
   //TestMyVisaExamples in 'TestMyVisaExamples.pas',
   TestMyVisaOverview in 'TestMyVisaOverview.pas',
   TestMailTemplates in 'TestMailTemplates.pas',
   TestBackendConnection in 'TestBackendConnection.pas',
   TestAppIssues in 'TestAppIssues.pas',
   TestCategories in 'TestCategories.pas',
   TestClubs in 'TestClubs.pas',
   TestAssays in 'TestAssays.pas',
   TestPublicResources in 'TestPublicResources.pas',
   TestCountries in 'TestCountries.pas',
   TestCampaigns in 'TestCampaigns.pas',

   TestPositions in 'TestPositions.pas',
   TestParents in 'TestParents.pas',
   TestAuxData in 'TestAuxData.pas',
   TestConferences in 'TestConferences.pas';
   TestCareerHistory in 'TestCareerHistory.pas',
   TestInjuryAuxModels in 'TestInjuryAuxModels.pas',
   TestAcademicRecords in 'TestAcademicRecords.pas',
   TestClinicalRecords in 'TestClinicalRecords.pas';
   *)
  {... ...}




{$R *.res}

begin
   Application.Initialize;
   Application.MainFormOnTaskbar := True;
   Application.Run;
end.
