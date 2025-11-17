unit TestPlayers;

interface

uses
   WEBLib.UnitTesting.Classes,
   System.SysUtils, System.Classes, JS, Web,
   Vcl.Controls, Vcl.StdCtrls,
   Data.DB,
   WEBLib.Graphics, WEBLib.Controls, WEBLib.Forms, WEBLib.Dialogs, WEBLib.ExtCtrls,
   WEBLib.DBCtrls, WEBLib.StdCtrls, WEBLib.ComCtrls, WEBLib.REST,
   WEBLib.DB, WEBLib.CDS, WebLib.JSON,
   WEBLib.WebCtrls, WEBLib.Menus, WEBLib.Grids, DB,
   senCille.Miscellaneous,
   senCille.MVCRequests;

type
{$M+}
   [TestFixture]
   TTestPlayers = class(TObject)
   private
      const LOCAL_PATH            = '/players';
      const TEST_PLAYER_CODE      = 'UT_PLAYER_0001';
      const TEST_CAMPAIGN_CODE    = 'UT_CAMPAIGN_0001';
      const TEST_WORKFLOW_CODE    = 'UT_WORKFLOW_0001';
      const TEST_ENGLISH_EXAM_ID  = 9001;
      const TEST_ACADEMIC_RECORD  = 9001;
   private
      function CreatePlayerDataSet:TWebClientDataSet;
      function CreateWorkflowDataSet:TWebClientDataSet;
      function CreateEnglishExamDataSet:TWebClientDataSet;
      function CreateAcademicRecordDataSet:TWebClientDataSet;
      procedure FillPlayerData(ADataSet :TWebClientDataSet; const AEmail :string);
      procedure FillWorkflowData(ADataSet :TWebClientDataSet);
      procedure FillEnglishExamData(ADataSet :TWebClientDataSet);
      procedure FillAcademicRecordData(ADataSet :TWebClientDataSet);
      [async] function HasTestPlayer:Boolean;
      [async] procedure EnsureTestPlayerExists;
      [async] procedure DeleteTestPlayerIfExists;
      [async] function HasTestEnglishExam:Boolean;
      [async] procedure EnsureTestEnglishExamExists;
      [async] procedure DeleteTestEnglishExamIfExists;
      [async] function HasTestAcademicRecord:Boolean;
      [async] procedure EnsureTestAcademicRecordExists;
      [async] procedure DeleteTestAcademicRecordIfExists;
   published
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestLoad;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestUpdate;
      [Test] [async] procedure TestIsReferenced;
      [Test] [async] procedure TestDelete;
      [Test] [async] procedure TestGetOrderByFields;
      [Test] [async] procedure TestLoadNotInCampaign;
      [Test] [async] procedure TestApplyToCampaign;
      [Test] [async] procedure TestLoadNotIntoATeam;
      [Test] [async] procedure TestGetFilterByProfilesPlayers;
      [Test] [async] procedure TestApplyWorkflow;
      [Test] [async] procedure TestLoadTaskList;
      [Test] [async] procedure TestInsertWorkflowStep;
      [Test] [async] procedure TestGetOneWorkflowStep;
      [Test] [async] procedure TestUpdateWorkflowStep;
      [Test] [async] procedure TestDeleteWorkflowStep;
      [Test] [async] procedure TestUpdatePlayerField;
      [Test] [async] procedure TestLoadEnglishExams;
      [Test] [async] procedure TestInsertEnglishExam;
      [Test] [async] procedure TestGetOneEnglishExam;
      [Test] [async] procedure TestUpdateEnglishExam;
      [Test] [async] procedure TestDeleteEnglishExam;
      [Test] [async] procedure TestLoadAcademicRecord;
      [Test] [async] procedure TestInsertAcademicRecord;
      [Test] [async] procedure TestGetOneAcademicRecord;
      [Test] [async] procedure TestUpdateAcademicRecord;
      [Test] [async] procedure TestDeleteAcademicRecord;
      [Test] [async] procedure TestUpdateUserEmail;
   end;
{$M-}

implementation

uses
   SysUtils,
   System.DateUtils,
   senCille.DataManagement;

{ TTestPlayers }

function TTestPlayers.CreatePlayerDataSet:TWebClientDataSet;
   procedure AddStringField(const AName :string; ASize :Integer);
   var Field :TStringField;
   begin
      Field := TStringField.Create(Result);
      Field.FieldName := AName;
      Field.Size := ASize;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftString, Field.Size);
   end;
   procedure AddMemoField(const AName :string);
   var Field :TMemoField;
   begin
      Field := TMemoField.Create(Result);
      Field.FieldName := AName;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftMemo, 0);
   end;
   procedure AddFloatField(const AName :string);
   var Field :TFloatField;
   begin
      Field := TFloatField.Create(Result);
      Field.FieldName := AName;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftFloat, 0);
   end;
   procedure AddIntegerField(const AName :string);
   var Field :TIntegerField;
   begin
      Field := TIntegerField.Create(Result);
      Field.FieldName := AName;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftInteger, 0);
   end;
   procedure AddDateField(const AName :string);
   var Field :TDateTimeField;
   begin
      Field := TDateTimeField.Create(Result);
      Field.FieldName := AName;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftDateTime, 0);
   end;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   AddStringField('CD_USER', 50);
   AddStringField('EMAIL', 100);
   AddDateField('CREATED');
   AddStringField('TITLE', 4);
   AddStringField('FIRST_NAME', 30);
   AddStringField('LAST_NAME', 40);
   AddStringField('DS_USER', 70);
   AddStringField('ADDRESS_LN_1', 50);
   AddStringField('ADDRESS_LN_2', 50);
   AddStringField('CITY', 50);
   AddStringField('POSTAL_CODE', 15);
   AddStringField('PROVINCE', 50);
   AddStringField('CD_STATE', 3);
   AddStringField('DS_STATE', 40);
   AddStringField('CD_COUNTRY', 3);
   AddStringField('DS_COUNTRY', 40);
   AddStringField('PHONE_NUMBER', 20);
   AddStringField('PREFERRED_LANGUAGE', 2);
   AddMemoField('NOTES');
   AddMemoField('IMG_PROFILE');
   AddStringField('NATIONALITY', 50);
   AddDateField('BIRTH_DATE');
   AddStringField('ACTIVE', 1);
   AddStringField('FINALIZED', 1);
   AddStringField('TYPE', 1);
   AddStringField('CD_CAMPAIGN', 14);
   AddStringField('DS_CAMPAIGN', 50);
   AddStringField('CD_METRICS', 1);
   AddStringField('DNI', 18);
   AddStringField('PASSPORT_NUMBER', 25);
   AddDateField('PASSPORT_EXPIRATION');
   AddStringField('FATHER_FIRST_NAME', 30);
   AddStringField('FATHER_LAST_NAME', 40);
   AddStringField('FATHER_PASSPORT', 25);
   AddStringField('FATHER_EMAIL', 100);
   AddStringField('MOTHER_FIRST_NAME', 30);
   AddStringField('MOTHER_LAST_NAME', 40);
   AddStringField('MOTHER_PASSPORT', 25);
   AddStringField('MOTHER_EMAIL', 100);
   AddStringField('PARENTS_PHONE_NUMBER', 20);
   AddStringField('PARENTS_EMAIL', 100);
   AddStringField('PARENTS_CITY', 50);
   AddStringField('PARENTS_POSTAL_CODE', 15);
   AddStringField('PARENTS_ADDRESS_LN_1', 50);
   AddStringField('PARENTS_ADDRESS_LN_2', 50);
   AddStringField('PARENTS_CD_STATE', 40);
   AddStringField('PARENTS_CD_COUNTRY', 40);
   AddStringField('CD_AGENT_1', 50);
   AddStringField('CD_AGENT_2', 50);
   AddStringField('CD_PARENT_1', 50);
   AddStringField('CD_PARENT_2', 50);
   AddMemoField('NOTES_PARENT_1');
   AddMemoField('NOTES_PARENT_2');
   AddStringField('JND_PARENT_1_PHONE_NUMBER', 20);
   AddStringField('JND_PARENT_1_EMAIL', 100);
   AddStringField('JND_PARENT_2_PHONE_NUMBER', 20);
   AddStringField('JND_PARENT_2_EMAIL', 100);
   AddMemoField('OBJS_MOTIVATION');
   AddIntegerField('OBJS_INVESTMENT');
   AddStringField('OBJS_CD_SCHOLARSHIP_TYPE', 2);
   AddMemoField('OBJS_PREFERENCES');
   AddIntegerField('OBJS_UNIV_SOCCER_LVL');
   AddIntegerField('OBJS_UNIV_ACADEMIC_LVL');
   AddIntegerField('OBJS_UNIV_SCHOLARSHIP_LVL');
   AddIntegerField('OBJS_UNIV_LOCATION_LVL');
   AddFloatField('GPA');
   AddStringField('CURRENTLY_STUDYING', 50);
   AddStringField('LEVEL_OF_SPANISH', 50);
   AddStringField('HS_GRAD_YEAR', 4);
   AddFloatField('HS_GPA');
   AddFloatField('SAT_ACT_SCORE');
   AddStringField('INTENTED_MAJOR', 100);
   AddMemoField('TOP_10_UNIVERSITIES');
   AddFloatField('UNIVERSITY_GPA');
   AddMemoField('UNIVERSITY_TRANSCRIPT');
   AddMemoField('HIGH_SCHOOL_TRANSCRIPT');
   AddMemoField('WHY_ETURE');
   AddMemoField('WHAT_HOBBIES');
   AddMemoField('WHY_SOCCER');
   AddMemoField('WHAT_FROM_SOCCER');
   AddMemoField('WHAT_TO_TEAM');
   AddMemoField('AREAS_TO_IMPROVE');
   AddMemoField('WOULD_ETURE_KNOW');
   AddFloatField('HEIGHT');
   AddFloatField('HEIGHT_FEET');
   AddFloatField('HEIGHT_INCHES');
   AddFloatField('WEIGHT');
   AddFloatField('WEIGHT_POUNDS');
   AddStringField('CD_POSITION', 10);
   AddStringField('DOMINANT_FOOT', 10);
   AddMemoField('URL');
   AddStringField('WANTED_STUDIES', 200);
   AddStringField('ENGLISH_LEVEL', 2);
   AddStringField('ENGLISH_TEST', 1);
   AddStringField('ENGLISH_CERTIFICATION', 10);
   AddStringField('SAT_ACT_EXAM', 4);
   AddFloatField('SAT_ACT_MATH_SCORE');
   AddFloatField('SAT_ACT_COMPOSITE_SCORE');
   AddStringField('CURRENT_TEAM', 100);
   AddStringField('CD_CATEGORY', 14);
   AddStringField('LINK_HIGHLIGHTS_VIDEO', 255);
   AddStringField('CD_TEAM', 14);
   AddMemoField('STRENGTHS');
   AddMemoField('WEAKNESSES');
   AddMemoField('CURRENT_STATUS');
   AddMemoField('CAREER_HISTORY');
   AddIntegerField('STATS_MATCHES_PLAYED');
   AddIntegerField('STATS_STARTING_PLAYER');
   AddIntegerField('STATS_WINS');
   AddIntegerField('STATS_LOSSES');
   AddIntegerField('STATS_MINUTES');
   AddIntegerField('STATS_GOALS');
   AddIntegerField('STATS_ASSISTS');
   AddIntegerField('STATS_SAVES');
   AddIntegerField('STATS_PENALTIES_SAVED');
   AddIntegerField('STATS_CLEAN_SHEET');
   AddIntegerField('STATS_INJURED');
   AddIntegerField('STATS_FOULS');
   AddIntegerField('STATS_YELLOW_CARDS');
   AddIntegerField('STATS_RED_CARDS');
   AddIntegerField('STATS_GOALS_CONCEDED');
   AddIntegerField('STATS_BENCH_APPEARANCES');
   AddFloatField('OP_SPEED');
   AddFloatField('OP_SHOOTING');
   AddFloatField('OP_PASSING');
   AddFloatField('OP_DRIBBLING');
   AddFloatField('OP_DEFENSE');
   AddFloatField('OP_PHYSICAL');
   AddFloatField('GK_AGILITY');
   AddFloatField('GK_REFLEXES');
   AddFloatField('GK_COORDINATION');
   AddFloatField('GK_JUMPING');
   AddFloatField('GK_STRENGTH');
   AddFloatField('GK_COMMUNICATION');
   AddFloatField('GK_CONCENTRATION');
   AddFloatField('GK_BRAVERY');
   AddFloatField('GK_BALL_HANDLING');
   AddDateField('APPOINTMENT_DATE');

   Result.Active := True;
end;

function TTestPlayers.CreateWorkflowDataSet:TWebClientDataSet;
   procedure AddStringField(const AName :string; ASize :Integer);
   var Field :TStringField;
   begin
      Field := TStringField.Create(Result);
      Field.FieldName := AName;
      Field.Size := ASize;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftString, Field.Size);
   end;
   procedure AddIntegerField(const AName :string);
   var Field :TIntegerField;
   begin
      Field := TIntegerField.Create(Result);
      Field.FieldName := AName;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftInteger, 0);
   end;
   procedure AddMemoField(const AName :string);
   var Field :TMemoField;
   begin
      Field := TMemoField.Create(Result);
      Field.FieldName := AName;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftMemo, 0);
   end;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   AddStringField('CD_WORKFLOW', 12);
   AddStringField('DS_WORKFLOW', 50);
   AddMemoField('NOTES');
   AddIntegerField('NM_STEPS');

   Result.Active := True;
end;

function TTestPlayers.CreateEnglishExamDataSet:TWebClientDataSet;
   procedure AddStringField(const AName :string; ASize :Integer);
   var Field :TStringField;
   begin
      Field := TStringField.Create(Result);
      Field.FieldName := AName;
      Field.Size := ASize;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftString, Field.Size);
   end;
   procedure AddIntegerField(const AName :string);
   var Field :TIntegerField;
   begin
      Field := TIntegerField.Create(Result);
      Field.FieldName := AName;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftInteger, 0);
   end;
   procedure AddFloatField(const AName :string);
   var Field :TFloatField;
   begin
      Field := TFloatField.Create(Result);
      Field.FieldName := AName;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftFloat, 0);
   end;
   procedure AddDateField(const AName :string);
   var Field :TDateTimeField;
   begin
      Field := TDateTimeField.Create(Result);
      Field.FieldName := AName;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftDateTime, 0);
   end;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   AddStringField('CD_USER', 50);
   AddIntegerField('NM_EXAM');
   AddStringField('DS_EXAM', 50);
   AddDateField('DT_EXAM');
   AddFloatField('SCORE');

   Result.Active := True;
end;

function TTestPlayers.CreateAcademicRecordDataSet:TWebClientDataSet;
   procedure AddStringField(const AName :string; ASize :Integer);
   var Field :TStringField;
   begin
      Field := TStringField.Create(Result);
      Field.FieldName := AName;
      Field.Size := ASize;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftString, Field.Size);
   end;
   procedure AddIntegerField(const AName :string);
   var Field :TIntegerField;
   begin
      Field := TIntegerField.Create(Result);
      Field.FieldName := AName;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftInteger, 0);
   end;
   procedure AddFloatField(const AName :string);
   var Field :TFloatField;
   begin
      Field := TFloatField.Create(Result);
      Field.FieldName := AName;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftFloat, 0);
   end;
   procedure AddMemoField(const AName :string);
   var Field :TMemoField;
   begin
      Field := TMemoField.Create(Result);
      Field.FieldName := AName;
      Field.DataSet := Result;
      Result.FieldDefs.Add(Field.FieldName, ftMemo, 0);
   end;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   AddStringField('CD_USER', 50);
   AddIntegerField('NM_RECORD');
   AddStringField('CD_SCHOOL_COURSE', 5);
   AddStringField('DS_SCHOOL', 50);
   AddStringField('CD_SCHOOL_TYPE', 3);
   AddStringField('CITY', 50);
   AddStringField('CD_STATE', 3);
   AddStringField('CD_COUNTRY', 3);
   AddStringField('CD_GRADE', 2);
   AddFloatField('GPA');
   AddMemoField('GPA_DOCUM');
   AddStringField('DS_SCHOOL_COURSE', 50);
   AddStringField('DS_SCHOOL_TYPE', 50);
   AddStringField('DS_STATE', 40);
   AddStringField('DS_COUNTRY', 40);

   Result.Active := True;
end;

procedure TTestPlayers.FillPlayerData(ADataSet :TWebClientDataSet; const AEmail :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_USER').AsString := TEST_PLAYER_CODE;
   ADataSet.FieldByName('EMAIL').AsString := AEmail;
   ADataSet.FieldByName('CREATED').AsDateTime := Now;
   ADataSet.FieldByName('TITLE').AsString := 'MR';
   ADataSet.FieldByName('FIRST_NAME').AsString := 'Unit';
   ADataSet.FieldByName('LAST_NAME').AsString := 'TestPlayer';
   ADataSet.FieldByName('DS_USER').AsString := 'Unit Test Player';
   ADataSet.FieldByName('CITY').AsString := 'Test City';
   ADataSet.FieldByName('CD_COUNTRY').AsString := 'US';
   ADataSet.FieldByName('DS_COUNTRY').AsString := 'United States';
   ADataSet.FieldByName('PREFERRED_LANGUAGE').AsString := 'EN';
   ADataSet.FieldByName('ACTIVE').AsString := 'Y';
   ADataSet.FieldByName('FINALIZED').AsString := 'N';
   ADataSet.FieldByName('TYPE').AsString := 'P';
   ADataSet.FieldByName('CD_CAMPAIGN').AsString := TEST_CAMPAIGN_CODE;
   ADataSet.FieldByName('DNI').AsString := 'UTP-0001';
   ADataSet.FieldByName('PASSPORT_NUMBER').AsString := 'UTP123456';
   ADataSet.FieldByName('PASSPORT_EXPIRATION').AsDateTime := IncYear(Now, 3);
   ADataSet.FieldByName('FATHER_FIRST_NAME').AsString := 'John';
   ADataSet.FieldByName('FATHER_LAST_NAME').AsString := 'Doe';
   ADataSet.FieldByName('FATHER_EMAIL').AsString := 'john.doe@example.com';
   ADataSet.FieldByName('MOTHER_FIRST_NAME').AsString := 'Jane';
   ADataSet.FieldByName('MOTHER_LAST_NAME').AsString := 'Doe';
   ADataSet.FieldByName('MOTHER_EMAIL').AsString := 'jane.doe@example.com';
   ADataSet.FieldByName('PARENTS_EMAIL').AsString := 'parents.doe@example.com';
   ADataSet.FieldByName('OBJS_INVESTMENT').AsInteger := 1;
   ADataSet.FieldByName('OBJS_CD_SCHOLARSHIP_TYPE').AsString := 'A1';
   ADataSet.FieldByName('GPA').AsFloat := 3.5;
   ADataSet.FieldByName('HS_GRAD_YEAR').AsString := '2024';
   ADataSet.FieldByName('HS_GPA').AsFloat := 3.7;
   ADataSet.FieldByName('SAT_ACT_SCORE').AsFloat := 1450;
   ADataSet.FieldByName('INTENTED_MAJOR').AsString := 'Computer Science';
   ADataSet.FieldByName('ENGLISH_LEVEL').AsString := 'C1';
   ADataSet.FieldByName('ENGLISH_TEST').AsString := 'Y';
   ADataSet.FieldByName('ENGLISH_CERTIFICATION').AsString := 'TOEFL';
   ADataSet.FieldByName('CURRENT_TEAM').AsString := 'Unit Test FC';
   ADataSet.FieldByName('CD_CATEGORY').AsString := 'UTCAT01';
   ADataSet.FieldByName('CD_TEAM').AsString := 'UTTEAM01';
   ADataSet.FieldByName('STATS_MATCHES_PLAYED').AsInteger := 10;
   ADataSet.FieldByName('STATS_GOALS').AsInteger := 5;
   ADataSet.FieldByName('STATS_ASSISTS').AsInteger := 3;
   ADataSet.FieldByName('OP_SPEED').AsFloat := 80;
   ADataSet.FieldByName('OP_SHOOTING').AsFloat := 75;
   ADataSet.FieldByName('OP_PASSING').AsFloat := 82;
   ADataSet.FieldByName('HEIGHT').AsFloat := 1.8;
   ADataSet.FieldByName('WEIGHT').AsFloat := 75;
   ADataSet.FieldByName('APPOINTMENT_DATE').AsDateTime := Now;
   ADataSet.Post;
end;

procedure TTestPlayers.FillWorkflowData(ADataSet :TWebClientDataSet);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_WORKFLOW').AsString := TEST_WORKFLOW_CODE;
   ADataSet.FieldByName('DS_WORKFLOW').AsString := 'Unit Test Workflow';
   ADataSet.FieldByName('NOTES').AsString := 'Workflow generated by automated tests.';
   ADataSet.FieldByName('NM_STEPS').AsInteger := 1;
   ADataSet.Post;
end;

procedure TTestPlayers.FillEnglishExamData(ADataSet :TWebClientDataSet);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_USER').AsString := TEST_PLAYER_CODE;
   ADataSet.FieldByName('NM_EXAM').AsInteger := TEST_ENGLISH_EXAM_ID;
   ADataSet.FieldByName('DS_EXAM').AsString := 'TOEFL';
   ADataSet.FieldByName('DT_EXAM').AsDateTime := EncodeDate(2023, 12, 1);
   ADataSet.FieldByName('SCORE').AsFloat := 110;
   ADataSet.Post;
end;

procedure TTestPlayers.FillAcademicRecordData(ADataSet :TWebClientDataSet);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_USER').AsString := TEST_PLAYER_CODE;
   ADataSet.FieldByName('NM_RECORD').AsInteger := TEST_ACADEMIC_RECORD;
   ADataSet.FieldByName('CD_SCHOOL_COURSE').AsString := 'CS101';
   ADataSet.FieldByName('DS_SCHOOL').AsString := 'Unit Test High School';
   ADataSet.FieldByName('CD_SCHOOL_TYPE').AsString := 'HS';
   ADataSet.FieldByName('CITY').AsString := 'Test City';
   ADataSet.FieldByName('CD_STATE').AsString := 'CA';
   ADataSet.FieldByName('CD_COUNTRY').AsString := 'US';
   ADataSet.FieldByName('CD_GRADE').AsString := '12';
   ADataSet.FieldByName('GPA').AsFloat := 3.6;
   ADataSet.FieldByName('GPA_DOCUM').AsString := 'Test GPA Document';
   ADataSet.FieldByName('DS_SCHOOL_COURSE').AsString := 'Computer Science';
   ADataSet.FieldByName('DS_SCHOOL_TYPE').AsString := 'High School';
   ADataSet.FieldByName('DS_STATE').AsString := 'California';
   ADataSet.FieldByName('DS_COUNTRY').AsString := 'United States';
   ADataSet.Post;
end;

[async] function TTestPlayers.HasTestPlayer:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreatePlayerDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_USER', TEST_PLAYER_CODE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestPlayers.EnsureTestPlayerExists;
var DataSet :TWebClientDataSet;
begin
   if await(Boolean, HasTestPlayer()) then Exit;

   DataSet := CreatePlayerDataSet;
   try
      FillPlayerData(DataSet, 'player.test@eture.com');
      await(TDB.Insert(LOCAL_PATH, DataSet));
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestPlayers.DeleteTestPlayerIfExists;
begin
   if not await(Boolean, HasTestPlayer()) then Exit;

   await(TDB.Delete(LOCAL_PATH,
                    [['CD_USER', TEST_PLAYER_CODE]]));
end;

[async] function TTestPlayers.HasTestEnglishExam:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateEnglishExamDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_USER', TEST_PLAYER_CODE],
                           ['NM_EXAM', IntToStr(TEST_ENGLISH_EXAM_ID)]],
                          DataSet, '/getoneenglishexam'));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestPlayers.EnsureTestEnglishExamExists;
var DataSet :TWebClientDataSet;
begin
   await(EnsureTestPlayerExists());
   if await(Boolean, HasTestEnglishExam()) then Exit;

   DataSet := CreateEnglishExamDataSet;
   try
      FillEnglishExamData(DataSet);
      await(TDB.Insert(LOCAL_PATH, DataSet, '/insertenglishexam'));
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestPlayers.DeleteTestEnglishExamIfExists;
begin
   if not await(Boolean, HasTestEnglishExam()) then Exit;

   await(TDB.Delete(LOCAL_PATH,
                    [['CD_USER', TEST_PLAYER_CODE],
                     ['NM_EXAM', IntToStr(TEST_ENGLISH_EXAM_ID)]],
                    '/deleteenglishexam'));
end;

[async] function TTestPlayers.HasTestAcademicRecord:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateAcademicRecordDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_USER', TEST_PLAYER_CODE],
                           ['NM_RECORD', IntToStr(TEST_ACADEMIC_RECORD)]],
                          DataSet, '/getoneacademicrecord'));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestPlayers.EnsureTestAcademicRecordExists;
var DataSet :TWebClientDataSet;
begin
   await(EnsureTestPlayerExists());
   if await(Boolean, HasTestAcademicRecord()) then Exit;

   DataSet := CreateAcademicRecordDataSet;
   try
      FillAcademicRecordData(DataSet);
      await(TDB.Insert(LOCAL_PATH, DataSet, '/insertacademicrecord'));
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestPlayers.DeleteTestAcademicRecordIfExists;
begin
   if not await(Boolean, HasTestAcademicRecord()) then Exit;

   await(TDB.Delete(LOCAL_PATH,
                    [['CD_USER', TEST_PLAYER_CODE],
                     ['NM_RECORD', IntToStr(TEST_ACADEMIC_RECORD)]],
                    '/deleteacademicrecord'));
end;

[Test] [async] procedure TTestPlayers.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestPlayerIfExists());

   DataSet := CreatePlayerDataSet;
   try
      FillPlayerData(DataSet, 'insert.player@eture.com');
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Insert -> '+ExceptMsg);
      Assert.IsTrue(await(Boolean, HasTestPlayer()), 'Player inserted successfully');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreatePlayerDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [['PageNumber', '1'],
                                    ['SearchText', 'Unit'],
                                    ['OrderField', 'FIRST_NAME']],
                                   DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Recovered at least one player');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreatePlayerDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_USER', TEST_PLAYER_CODE]],
                          DataSet, '/getone'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.FieldByName('CD_USER').AsString = TEST_PLAYER_CODE, 'Retrieved expected player');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestGetAll;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreatePlayerDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [],
                                   DataSet, '/getall'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Recovered at least one player in GetAll');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestUpdate;
var DataSet           :TWebClientDataSet;
    ExceptMsg         :string;
    OriginalFirstName :string;
    OriginalLastName  :string;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreatePlayerDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE]],
                       DataSet));

      OriginalFirstName := DataSet.FieldByName('FIRST_NAME').AsString;
      OriginalLastName  := DataSet.FieldByName('LAST_NAME').AsString;

      DataSet.Edit;
      DataSet.FieldByName('FIRST_NAME').AsString := 'Updated';
      DataSet.FieldByName('LAST_NAME').AsString  := 'Player';
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_USER', TEST_PLAYER_CODE],
                           ['OLD_CD_USER', TEST_PLAYER_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.FieldByName('FIRST_NAME').AsString = 'Updated', 'Player first name updated');
      Assert.IsTrue(DataSet.FieldByName('LAST_NAME').AsString = 'Player', 'Player last name updated');

      DataSet.Edit;
      DataSet.FieldByName('FIRST_NAME').AsString := OriginalFirstName;
      DataSet.FieldByName('LAST_NAME').AsString  := OriginalLastName;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE],
                        ['OLD_CD_USER', TEST_PLAYER_CODE]],
                       DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestIsReferenced;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    IsReferenced:Boolean;
    TextMessage :string;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreatePlayerDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE]],
                       DataSet));
      IsReferenced := False;
      try
         TextMessage := '';
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(not IsReferenced, 'Test player should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestPlayerExists());

   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   Assert.IsFalse(await(Boolean, HasTestPlayer()), 'Player deleted successfully');

   DataSet := CreatePlayerDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Player successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestGetOrderByFields;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getorderbyfields', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOrderByFields -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Order by fields available for players');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestLoadNotInCampaign;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreatePlayerDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [['CD_CAMPAIGN', TEST_CAMPAIGN_CODE]],
                                   DataSet, '/loadnotincampaign'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in LoadNotInCampaign -> '+ExceptMsg);
      Assert.IsTrue(Count >= 0, 'LoadNotInCampaign executed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestApplyToCampaign;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreatePlayerDataSet;
   try
      FillPlayerData(DataSet, 'apply.campaign@eture.com');
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/applytocampaign'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in ApplyToCampaign -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestLoadNotIntoATeam;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreatePlayerDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [['CD_TEAM', '']],
                                   DataSet, '/loadnotintoateam'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in LoadNotIntoATeam -> '+ExceptMsg);
      Assert.IsTrue(Count >= 0, 'LoadNotIntoATeam executed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestGetFilterByProfilesPlayers;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreatePlayerDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [['Filter', 'ALL']],
                                   DataSet, '/getfilterbyprofilesplayers'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetFilterByProfilesPlayers -> '+ExceptMsg);
      Assert.IsTrue(Count >= 0, 'GetFilterByProfilesPlayers executed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestApplyWorkflow;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreateWorkflowDataSet;
   try
      FillWorkflowData(DataSet);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/applyworkflow'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in ApplyWorkflow -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestLoadTaskList;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreateWorkflowDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [['CD_USER', TEST_PLAYER_CODE]],
                                   DataSet, '/loadtasklist'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in LoadTaskList -> '+ExceptMsg);
      Assert.IsTrue(Count >= 0, 'LoadTaskList executed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestInsertWorkflowStep;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreateWorkflowDataSet;
   try
      FillWorkflowData(DataSet);
      DataSet.FieldByName('NM_STEPS').AsInteger := 2;
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertwfstep'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in InsertWFStep -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestGetOneWorkflowStep;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   DataSet := CreateWorkflowDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_WORKFLOW', TEST_WORKFLOW_CODE],
                           ['NM_STEPS', '1']],
                          DataSet, '/getonestep'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneStep -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestUpdateWorkflowStep;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   DataSet := CreateWorkflowDataSet;
   try
      FillWorkflowData(DataSet);
      DataSet.FieldByName('NM_STEPS').AsInteger := 3;
      try
         await(TDB.Update(LOCAL_PATH, [], DataSet, '/updatestep'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in UpdateStep -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestDeleteWorkflowStep;
var ExceptMsg :string;
begin
   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_WORKFLOW', TEST_WORKFLOW_CODE],
                        ['NM_STEPS', '1']],
                       '/deletestep'));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in DeleteStep -> '+ExceptMsg);
end;

[Test] [async] procedure TTestPlayers.TestUpdatePlayerField;
var DataSet           :TWebClientDataSet;
    ExceptMsg         :string;
    OriginalFirstName :string;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreatePlayerDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE]],
                       DataSet));

      OriginalFirstName := DataSet.FieldByName('FIRST_NAME').AsString;

      DataSet.Edit;
      DataSet.FieldByName('FIRST_NAME').AsString := 'FieldUpdated';
      DataSet.Post;
      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_USER', TEST_PLAYER_CODE]],
                          DataSet, '/updateplayerfield'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in UpdatePlayerField -> '+ExceptMsg);

      DataSet.Edit;
      DataSet.FieldByName('FIRST_NAME').AsString := OriginalFirstName;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE]],
                       DataSet, '/updateplayerfield'));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestLoadEnglishExams;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestEnglishExamExists());

   DataSet := CreateEnglishExamDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [['CD_USER', TEST_PLAYER_CODE]],
                                   DataSet, '/loadenglishexams'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in LoadEnglishExams -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'English exams retrieved');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestInsertEnglishExam;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestPlayerExists());
   await(DeleteTestEnglishExamIfExists());

   DataSet := CreateEnglishExamDataSet;
   try
      FillEnglishExamData(DataSet);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertenglishexam'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in InsertEnglishExam -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestGetOneEnglishExam;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestEnglishExamExists());

   DataSet := CreateEnglishExamDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_USER', TEST_PLAYER_CODE],
                           ['NM_EXAM', IntToStr(TEST_ENGLISH_EXAM_ID)]],
                          DataSet, '/getoneenglishexam'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneEnglishExam -> '+ExceptMsg);
      Assert.IsTrue(DataSet.FieldByName('NM_EXAM').AsInteger = TEST_ENGLISH_EXAM_ID, 'Retrieved expected exam');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestUpdateEnglishExam;
var DataSet       :TWebClientDataSet;
    ExceptMsg     :string;
    OriginalScore :Double;
begin
   await(EnsureTestEnglishExamExists());

   DataSet := CreateEnglishExamDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE],
                        ['NM_EXAM', IntToStr(TEST_ENGLISH_EXAM_ID)]],
                       DataSet, '/getoneenglishexam'));

      OriginalScore := DataSet.FieldByName('SCORE').AsFloat;

      DataSet.Edit;
      DataSet.FieldByName('SCORE').AsFloat := 115;
      DataSet.Post;
      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_USER', TEST_PLAYER_CODE],
                           ['NM_EXAM', IntToStr(TEST_ENGLISH_EXAM_ID)]],
                          DataSet, '/updateenglishexam'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in UpdateEnglishExam -> '+ExceptMsg);

      DataSet.Edit;
      DataSet.FieldByName('SCORE').AsFloat := OriginalScore;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE],
                        ['NM_EXAM', IntToStr(TEST_ENGLISH_EXAM_ID)]],
                       DataSet, '/updateenglishexam'));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestDeleteEnglishExam;
var ExceptMsg :string;
begin
   await(EnsureTestEnglishExamExists());

   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE],
                        ['NM_EXAM', IntToStr(TEST_ENGLISH_EXAM_ID)]],
                       '/deleteenglishexam'));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in DeleteEnglishExam -> '+ExceptMsg);
end;

[Test] [async] procedure TTestPlayers.TestLoadAcademicRecord;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestAcademicRecordExists());

   DataSet := CreateAcademicRecordDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [['CD_USER', TEST_PLAYER_CODE]],
                                   DataSet, '/loadacademicrecord'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in LoadAcademicRecord -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Academic records retrieved');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestInsertAcademicRecord;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestPlayerExists());
   await(DeleteTestAcademicRecordIfExists());

   DataSet := CreateAcademicRecordDataSet;
   try
      FillAcademicRecordData(DataSet);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertacademicrecord'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in InsertAcademicRecord -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestGetOneAcademicRecord;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestAcademicRecordExists());

   DataSet := CreateAcademicRecordDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_USER', TEST_PLAYER_CODE],
                           ['NM_RECORD', IntToStr(TEST_ACADEMIC_RECORD)]],
                          DataSet, '/getoneacademicrecord'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneAcademicRecord -> '+ExceptMsg);
      Assert.IsTrue(DataSet.FieldByName('NM_RECORD').AsInteger = TEST_ACADEMIC_RECORD, 'Retrieved expected academic record');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestUpdateAcademicRecord;
var DataSet      :TWebClientDataSet;
    ExceptMsg    :string;
    OriginalGPA  :Double;
begin
   await(EnsureTestAcademicRecordExists());

   DataSet := CreateAcademicRecordDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE],
                        ['NM_RECORD', IntToStr(TEST_ACADEMIC_RECORD)]],
                       DataSet, '/getoneacademicrecord'));

      OriginalGPA := DataSet.FieldByName('GPA').AsFloat;

      DataSet.Edit;
      DataSet.FieldByName('GPA').AsFloat := 3.8;
      DataSet.Post;
      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_USER', TEST_PLAYER_CODE],
                           ['NM_RECORD', IntToStr(TEST_ACADEMIC_RECORD)]],
                          DataSet, '/updateacademicrecord'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in UpdateAcademicRecord -> '+ExceptMsg);

      DataSet.Edit;
      DataSet.FieldByName('GPA').AsFloat := OriginalGPA;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE],
                        ['NM_RECORD', IntToStr(TEST_ACADEMIC_RECORD)]],
                       DataSet, '/updateacademicrecord'));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestPlayers.TestDeleteAcademicRecord;
var ExceptMsg :string;
begin
   await(EnsureTestAcademicRecordExists());

   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE],
                        ['NM_RECORD', IntToStr(TEST_ACADEMIC_RECORD)]],
                       '/deleteacademicrecord'));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in DeleteAcademicRecord -> '+ExceptMsg);
end;

[Test] [async] procedure TTestPlayers.TestUpdateUserEmail;
var DataSet        :TWebClientDataSet;
    ExceptMsg      :string;
    OriginalEmail  :string;
begin
   await(EnsureTestPlayerExists());

   DataSet := CreatePlayerDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE]],
                       DataSet));

      OriginalEmail := DataSet.FieldByName('EMAIL').AsString;

      DataSet.Edit;
      DataSet.FieldByName('EMAIL').AsString := 'update.email@eture.com';
      DataSet.Post;
      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_USER', TEST_PLAYER_CODE]],
                          DataSet, '/updateuseremail'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in UpdateUserEmail -> '+ExceptMsg);

      DataSet.Edit;
      DataSet.FieldByName('EMAIL').AsString := OriginalEmail;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_USER', TEST_PLAYER_CODE]],
                       DataSet, '/updateuseremail'));
   finally
      DataSet.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestPlayers);

end.
