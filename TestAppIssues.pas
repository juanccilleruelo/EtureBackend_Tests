unit TestAppIssues;

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
   TTestAppIssues = class(TObject)
   private
      const LOCAL_PATH     = '/appissues';
      const TEST_ISSUE_ID  = 'UT_APP_ISSUE_0001';
      const TEST_TITLE     = 'Unit Test Issue Title';
      const UPDATED_TITLE  = 'Unit Test Issue Title - Updated';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillIssueData(ADataSet :TWebClientDataSet; const ATitle :string);
      [async] function HasTestIssue:Boolean;
      [async] procedure EnsureTestIssueExists;
      [async] procedure DeleteTestIssueIfExists;
   published
      [Test] [async] procedure TestGetNextIssueId;
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestLoad;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestUpdate;
      [Test] [async] procedure TestIsReferenced;
      [Test] [async] procedure TestDelete;
      [Test] [async] procedure TestGetOrderByFields;
   end;
{$M-}

implementation

uses
   SysUtils,
   senCille.DataManagement;

{ TTestAppIssues }

function TTestAppIssues.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'ID_ISSUE';
   NewField.Size        := 32;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TDateTimeField.Create(Result);
   NewField.FieldName   := 'DT_ISSUE';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'NAV_USER_AGENT';
   NewField.Size        := 255;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'NAV_PRODUCT';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'NAV_PLATFORM';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'NAV_LANGUAGE';
   NewField.Size        := 10;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'NAV_ON_LINE_STATUS';
   NewField.Size        := 1;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'NAV_COOKIES_ENABLED';
   NewField.Size        := 1;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'STATUS';
   NewField.Size        := 1;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_USER';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'TITLE';
   NewField.Size        := 250;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'DESCRIPTION';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'SECTION';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'SEVERITY';
   NewField.Size        := 1;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'STEPS';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'IMG_ISSUE';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'RESOLUTION';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestAppIssues.FillIssueData(ADataSet :TWebClientDataSet; const ATitle :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('ID_ISSUE').AsString            := TEST_ISSUE_ID;
   ADataSet.FieldByName('DT_ISSUE').AsDateTime          := Now;
   ADataSet.FieldByName('NAV_USER_AGENT').AsString      := 'Mozilla/5.0 (Unit Test)';
   ADataSet.FieldByName('NAV_PRODUCT').AsString         := 'Chrome';
   ADataSet.FieldByName('NAV_PLATFORM').AsString        := 'Web';
   ADataSet.FieldByName('NAV_LANGUAGE').AsString        := 'en-US';
   ADataSet.FieldByName('NAV_ON_LINE_STATUS').AsString  := 'Y';
   ADataSet.FieldByName('NAV_COOKIES_ENABLED').AsString := 'Y';
   ADataSet.FieldByName('STATUS').AsString              := 'O';
   ADataSet.FieldByName('CD_USER').AsString             := 'admin';
   ADataSet.FieldByName('TITLE').AsString               := ATitle;
   ADataSet.FieldByName('DESCRIPTION').AsString         := 'Issue created for automated unit testing.';
   ADataSet.FieldByName('SECTION').AsString             := 'UNIT_TESTS';
   ADataSet.FieldByName('SEVERITY').AsString            := 'L';
   ADataSet.FieldByName('STEPS').AsString               := '1. Execute automated tests';
   ADataSet.FieldByName('IMG_ISSUE').AsString           := 'NoImage';
   ADataSet.FieldByName('RESOLUTION').AsString          := 'Pending';
   ADataSet.Post;
end;

[async] function TTestAppIssues.HasTestIssue:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['ID_ISSUE', TEST_ISSUE_ID]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestAppIssues.EnsureTestIssueExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestIssue()) then Exit;

   DataSet := CreateDataSet;
   try
      FillIssueData(DataSet, TEST_TITLE);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestIssueExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestAppIssues.DeleteTestIssueIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['ID_ISSUE', TEST_ISSUE_ID]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestAppIssues.TestGetNextIssueId;
var NextId    :string;
    jo        :TJSONObject;
    JSONArray :TJSONArray;
begin
   JSONArray := await(TJSONArray, TDB.GetJSONArray('/appissues', [], '/getissueid'));
   jo := TJSONObject(JSONArray.Items[0]);
   NextId :=  jo.GetJSONValue('ID_ISSUE');

   Assert.IsTrue(NextId <> '', 'Next issue id received');
end;

[Test] [async] procedure TTestAppIssues.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestIssueIfExists());

   DataSet := CreateDataSet;
   try
      FillIssueData(DataSet, TEST_TITLE);
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

[Test] [async] procedure TTestAppIssues.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestIssueExists());

   DataSet := CreateDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                        [['PageNumber', '1'        ],
                         ['SearchText', 'Unit Test'],
                         ['OrderField', ''         ]],
                        DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Count greater than 0');
      Assert.IsTrue(DataSet.Locate('ID_ISSUE', TEST_ISSUE_ID, []), 'Test issue located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestAppIssues.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestIssueExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['ID_ISSUE', TEST_ISSUE_ID]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('TITLE').AsString = TEST_TITLE, 'Issue title matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestAppIssues.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestIssueExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'ID_ISSUE', 'TITLE', []));
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

[Test] [async] procedure TTestAppIssues.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestIssueExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['ID_ISSUE', TEST_ISSUE_ID]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('TITLE').AsString := UPDATED_TITLE;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['ID_ISSUE', TEST_ISSUE_ID], ['OLD_ID_ISSUE', TEST_ISSUE_ID]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['ID_ISSUE', TEST_ISSUE_ID]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('TITLE').AsString = UPDATED_TITLE, 'Updated title stored in database');

      DataSet.Edit;
      DataSet.FieldByName('TITLE').AsString := TEST_TITLE;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['ID_ISSUE', TEST_ISSUE_ID], ['OLD_ID_ISSUE', TEST_ISSUE_ID]], DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestAppIssues.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   await(EnsureTestIssueExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['ID_ISSUE', TEST_ISSUE_ID]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test issue should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestAppIssues.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestIssueExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['ID_ISSUE', TEST_ISSUE_ID]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['ID_ISSUE', TEST_ISSUE_ID]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Issue successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestAppIssues.TestGetOrderByFields;
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
      Assert.IsTrue(Items.Count > 0, 'Order by fields available');
   finally
      Items.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestAppIssues);

end.
