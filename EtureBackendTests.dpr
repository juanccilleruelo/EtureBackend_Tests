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
  TestStates in 'TestStates.pas',
  TestAuxData in 'TestAuxData.pas',
  TestCategories in 'TestCategories.pas',
  TestConferences in 'TestConferences.pas',
  TestCampaigns in 'TestCampaigns.pas',
  TestAssays in 'TestAssays.pas',
  TestMyVisaTemplates in 'TestMyVisaTemplates.pas',
  TestBackendConnection in 'TestBackendConnection.pas',
  *)

  TestMyVisaExamples in 'TestMyVisaExamples.pas',
  TestSocialMedia in 'TestSocialMedia.pas';
  //TestCalendarEvents in 'TestCalendarEvents.pas';
(*

    TestClubs in 'TestClubs.pas', {This need to be reconstructed completly}
    TestPositions in 'TestPositions.pas', {Reconstruct it}
    TestParents in 'TestParents.pas',     {Reconstruct it}
    TestPublicResources in 'TestPublicResources.pas', {Reconstruct it}
    TestCareerHistory in 'TestCareerHistory.pas', {Model needs to be completed}

    TestInjuryAuxModels in 'TestInjuryAuxModels.pas', {The tests are empty}
    TestAcademicRecords in 'TestAcademicRecords.pas', {this module don't have tests inside}
    TestClinicalRecords in 'TestClinicalRecords.pas', {Needs a revision}
    TestCountries in 'TestCountries.pas', {Needs revision}

   //
   //
   //TestMyVisaOverview in 'TestMyVisaOverview.pas',
   //TestMailTemplates in 'TestMailTemplates.pas',
   *)
  {... ...}




{$R *.res}

begin
   Application.Initialize;
   Application.MainFormOnTaskbar := True;
   Application.Run;
end.
