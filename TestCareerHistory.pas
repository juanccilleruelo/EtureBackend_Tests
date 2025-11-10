unit TestCareerHistory;

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
   TTestCareerHistory = class(TObject)
   private
      const LOCAL_PATH            = '/careerhistory';
      const TEST_USER             = 'UT_CAREER_HISTORY';
      const TEST_HISTORY_ID       = 999999;
      const TEST_TEAM_NAME        = 'Unit Test Team';
      const UPDATED_TEAM_NAME     = 'Unit Test Team Updated';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillCareerHistoryData(ADataSet :TWebClientDataSet; const ATeamName :string);
      [async] function HasTestCareerHistory:Boolean;
      [async] procedure EnsureTestCareerHistoryExists;
      [async] procedure DeleteTestCareerHistoryIfExists;
   published
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestLoad;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestUpdate;
      [Test] [async] procedure TestDelete;
   end;
{$M-}

implementation

uses
   SysUtils,
   senCille.DataManagement;

{ TTestCareerHistory }

function TTestCareerHistory.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_USER';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TIntegerField.Create(Result);
   NewField.FieldName   := 'ID_CAREER_HISTORY';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftInteger, 0);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'SEASON';
   NewField.Size        := 10;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'TEAM_NAME';
   NewField.Size        := 100;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'TEAM_LOCATION';
   NewField.Size        := 100;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_CATEGORY';
   NewField.Size        := 14;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_CATEGORY';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'LINK_HIGHLIGHTS';
   NewField.Size        := 255;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

procedure TTestCareerHistory.FillCareerHistoryData(ADataSet :TWebClientDataSet; const ATeamName :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_USER').AsString             := TEST_USER;
   ADataSet.FieldByName('ID_CAREER_HISTORY').AsInteger  := TEST_HISTORY_ID;
   ADataSet.FieldByName('SEASON').AsString              := '2024-2025';
   ADataSet.FieldByName('TEAM_NAME').AsString           := ATeamName;
   ADataSet.FieldByName('TEAM_LOCATION').AsString       := 'Unit Test City';
   ADataSet.FieldByName('CD_CATEGORY').AsString         := 'UT_CATEGORY';
   ADataSet.FieldByName('DS_CATEGORY').AsString         := 'Unit Test Category';
   ADataSet.FieldByName('LINK_HIGHLIGHTS').AsString     := 'https://example.com/highlights';
   ADataSet.Post;
end;

[async] function TTestCareerHistory.HasTestCareerHistory:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_USER', TEST_USER],
                           ['ID_CAREER_HISTORY', IntToStr(TEST_HISTORY_ID)]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestCareerHistory.EnsureTestCareerHistoryExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestCareerHistory()) then Exit;

   DataSet := CreateDataSet;
   try
      FillCareerHistoryData(DataSet, TEST_TEAM_NAME);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestCareerHistoryExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestCareerHistory.DeleteTestCareerHistoryIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_USER', TEST_USER],
                        ['ID_CAREER_HISTORY', IntToStr(TEST_HISTORY_ID)]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestCareerHistory.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestCareerHistoryIfExists());

   DataSet := CreateDataSet;
   try
      FillCareerHistoryData(DataSet, TEST_TEAM_NAME);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Insert -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCareerHistory.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestCareerHistoryExists());

   DataSet := CreateDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                        [['PageNumber', '1'     ],
                         ['CD_USER', TEST_USER  ],
                         ['OrderField', ''      ]],
                        DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Count greater than 0');
      Assert.IsTrue(DataSet.Locate('ID_CAREER_HISTORY', TEST_HISTORY_ID, []), 'Test career history located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCareerHistory.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCareerHistoryExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_USER', TEST_USER],
                           ['ID_CAREER_HISTORY', IntToStr(TEST_HISTORY_ID)]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('TEAM_NAME').AsString = TEST_TEAM_NAME, 'Team name matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCareerHistory.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestCareerHistoryExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items,
                                LOCAL_PATH+'/getall',
                                'ID_CAREER_HISTORY',
                                'TEAM_NAME',
                                [['CD_USER', TEST_USER]]));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestCareerHistory.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCareerHistoryExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER],
                        ['ID_CAREER_HISTORY', IntToStr(TEST_HISTORY_ID)]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('TEAM_NAME').AsString := UPDATED_TEAM_NAME;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_USER', TEST_USER],
                           ['ID_CAREER_HISTORY', IntToStr(TEST_HISTORY_ID)],
                           ['OLD_CD_USER', TEST_USER],
                           ['OLD_ID_CAREER_HISTORY', IntToStr(TEST_HISTORY_ID)]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER],
                        ['ID_CAREER_HISTORY', IntToStr(TEST_HISTORY_ID)]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('TEAM_NAME').AsString = UPDATED_TEAM_NAME, 'Updated team name stored in database');

      DataSet.Edit;
      DataSet.FieldByName('TEAM_NAME').AsString := TEST_TEAM_NAME;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_USER', TEST_USER],
                        ['ID_CAREER_HISTORY', IntToStr(TEST_HISTORY_ID)],
                        ['OLD_CD_USER', TEST_USER],
                        ['OLD_ID_CAREER_HISTORY', IntToStr(TEST_HISTORY_ID)]],
                       DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCareerHistory.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCareerHistoryExists());

   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_USER', TEST_USER],
                        ['ID_CAREER_HISTORY', IntToStr(TEST_HISTORY_ID)]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_USER', TEST_USER],
                        ['ID_CAREER_HISTORY', IntToStr(TEST_HISTORY_ID)]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Career history successfully removed');
   finally
      DataSet.Free;
   end;

   await(EnsureTestCareerHistoryExists());
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestCareerHistory);

end.
