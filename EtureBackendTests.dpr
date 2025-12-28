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
  {$R}
  {$R}
  {$R}
  senCille.DataManagement in '..\EtureFrontend\framework\senCille.DataManagement.pas' {$R *.res},
  senCille.TypeConverter in '..\EtureFrontend\framework\senCille.TypeConverter.pas',
  Dummy in '..\EtureFrontend\Dummy\Dummy.pas' {DummyForm: TWebForm} {*.html},
  TestChats in 'TestChats.pas';

//C:\Views\EtureServer\ScholarshipTypes\ScholarshipTypesController.pas

{$R}

(*
  TestBackendConnection in 'TestBackendConnection.pas',
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
  TestMyVisaExamples in 'TestMyVisaExamples.pas',
  TestSocialMedia in 'TestSocialMedia.pas',
  TestPositions in 'TestPositions.pas',
  TestClubs in 'TestClubs.pas',
  TestInjuryAuxModels in 'TestInjuryAuxModels.pas',
  TestDataTypes in 'TestDataTypes.pas',
  TestDominantFoot in 'TestDominantFoot.pas';
  *)

  //TestCalendarEvents in 'TestCalendarEvents.pas',
  //TestUsers in 'TestUsers.pas',
  //TestPlayers in 'TestPlayers.pas';

  //TestMyVisaOverview in 'TestMyVisaOverview.pas',
  //TestMailTemplates in 'TestMailTemplates.pas',

(*
C:\Views\EtureServer\Users\UsersController.pas

C:\Views\EtureServer\MailTemplates\MailTemplatesController.pas
C:\Views\EtureServer\MyVisaOverview\MyVisaOverviewController.pas
C:\Views\EtureServer\Notices\NoticesController.pas
C:\Views\EtureServer\PlayerDocuments\PlayerDocumentsController.pas
C:\Views\EtureServer\PlayerInjuries\PlayerInjuriesController.pas
C:\Views\EtureServer\PlayerSanctions\PlayerSanctionsController.pas
C:\Views\EtureServer\Players\PlayersController.pas
C:\Views\EtureServer\Reminders\RemindersController.pas

C:\Views\EtureServer\SchoolCourses\SchoolCoursesController.pas
C:\Views\EtureServer\SchoolTypes\SchoolTypesController.pas
C:\Views\EtureServer\SocialMedia\SocialMediaController.pas
C:\Views\EtureServer\Universities\UniversityOfferedController.pas
C:\Views\EtureServer\Universities\UniversityTeamController.pas
C:\Views\EtureServer\Vehicles\VehiclesController.pas
C:\Views\EtureServer\WFStepTypes\WFStepTypesController.pas

C:\Views\EtureServer\Workflows\WorkflowsController.pas  *)


(*
    TestParents in 'TestParents.pas',     {Reconstruct it}
    TestCareerHistory in 'TestCareerHistory.pas', {Model needs to be completed}

    TestAcademicRecords in 'TestAcademicRecords.pas', {this module don't have tests inside}
    TestClinicalRecords in 'TestClinicalRecords.pas', {Needs a revision}
    TestCountries in 'TestCountries.pas', {Needs revision}

    TestPublicResources in 'TestPublicResources.pas';
   //
   //

   *)
  {... ...}

{$R *.res}

begin
   Application.Initialize;
   Application.MainFormOnTaskbar := True;
   Application.Run;
end.
