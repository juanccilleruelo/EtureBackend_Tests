program EtureBackendTests;

uses
  Vcl.Forms,
  WEBLib.Forms,
  ConfigurationConsts in '..\EtureFrontend\framework\ConfigurationConsts.pas',
  senCille.WebSetup in '..\EtureFrontend\framework\senCille.WebSetup.pas',
  senCille.Bootstrap in '..\EtureFrontend\framework\senCille.Bootstrap.pas',
  senCille.MVCRequests in '..\EtureFrontend\framework\senCille.MVCRequests.pas',
  senCille.Miscellaneous in '..\EtureFrontend\framework\senCille.Miscellaneous.pas',
  senCille.CustomWebForm in '..\EtureFrontend\framework\senCille.CustomWebForm.pas' {scCustomWebForm: TWebForm} {*.html},
  senCille.DataManagement in '..\EtureFrontend\framework\senCille.DataManagement.pas' {$R *.res},
  senCille.TypeConverter in '..\EtureFrontend\framework\senCille.TypeConverter.pas',
  Dummy in '..\EtureFrontend\Dummy\Dummy.pas' {DummyForm: TWebForm} {*.html},
  {... ...}
  (*
  TestAppIssues in 'TestAppIssues.pas',
  TestCallUps in 'TestCallUps.pas',
  TestProperties in 'TestProperties.pas',
  TestUniversities in 'TestUniversities.pas',
  TestTeams in 'TestTeams.pas',

  *)
  //TestSocialMedia in 'TestSocialMedia.pas',
  TestStates in 'TestStates.pas';
(*
   TestCalendarEvents in 'TestCalendarEvents.pas';
   //TestMyVisaTemplates in 'TestMyVisaTemplates.pas',
   //TestMyVisaExamples in 'TestMyVisaExamples.pas',
   TestMyVisaOverview in 'TestMyVisaOverview.pas',
   TestMailTemplates in 'TestMailTemplates.pas',
   TestBackendConnection in 'TestBackendConnection.pas',
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
