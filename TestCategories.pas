unit TestCategories;

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
   TTestCategories = class(TObject)
   private
      const LOCAL_PATH            = '/categories';
      const TEST_CATEGORY_CODE    = 'UT_CATEGORY_0001';
      const TEST_DESCRIPTION      = 'Unit Test Category';
      const UPDATED_DESCRIPTION   = 'Unit Test Category - Updated';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillCategoryData(ADataSet :TWebClientDataSet; const ADescription :string);
      [async] function HasTestCategory:Boolean;
      [async] procedure EnsureTestCategoryExists;
      [async] procedure DeleteTestCategoryIfExists;
   published
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

{ TTestCategories }

function TTestCategories.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_CATEGORY';
   NewField.Size := 14;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_CATEGORY';
   NewField.Size := 50;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'NOTES';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'IMG_LOGO';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestCategories.FillCategoryData(ADataSet :TWebClientDataSet; const ADescription :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_CATEGORY').AsString := TEST_CATEGORY_CODE;
   ADataSet.FieldByName('DS_CATEGORY').AsString := ADescription;
   ADataSet.FieldByName('NOTES').AsString := 'Category created for automated unit testing.';
   ADataSet.FieldByName('IMG_LOGO').AsString := 'NoImage';
   ADataSet.Post;
end;

[async] function TTestCategories.HasTestCategory:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_CATEGORY', TEST_CATEGORY_CODE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestCategories.EnsureTestCategoryExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestCategory()) then begin
      Exit;
   end;

   DataSet := CreateDataSet;
   try
      FillCategoryData(DataSet, TEST_DESCRIPTION);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestCategoryExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestCategories.DeleteTestCategoryIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_CATEGORY', TEST_CATEGORY_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestCategories.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestCategoryIfExists());

   DataSet := CreateDataSet;
   try
      FillCategoryData(DataSet, TEST_DESCRIPTION);
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

[Test] [async] procedure TTestCategories.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestCategoryExists());

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
      Assert.IsTrue(DataSet.Locate('CD_CATEGORY', TEST_CATEGORY_CODE, []), 'Test category located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCategories.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCategoryExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_CATEGORY', TEST_CATEGORY_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_CATEGORY').AsString = TEST_DESCRIPTION, 'Category description matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCategories.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestCategoryExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_CATEGORY', 'DS_CATEGORY', []));
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

[Test] [async] procedure TTestCategories.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCategoryExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_CATEGORY', TEST_CATEGORY_CODE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_CATEGORY').AsString := UPDATED_DESCRIPTION;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['CD_CATEGORY', TEST_CATEGORY_CODE], ['OLD_CD_CATEGORY', TEST_CATEGORY_CODE]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_CATEGORY', TEST_CATEGORY_CODE]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('DS_CATEGORY').AsString = UPDATED_DESCRIPTION, 'Updated description stored in database');

      DataSet.Edit;
      DataSet.FieldByName('DS_CATEGORY').AsString := TEST_DESCRIPTION;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['CD_CATEGORY', TEST_CATEGORY_CODE], ['OLD_CD_CATEGORY', TEST_CATEGORY_CODE]], DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCategories.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   await(EnsureTestCategoryExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_CATEGORY', TEST_CATEGORY_CODE]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test category should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCategories.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCategoryExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['CD_CATEGORY', TEST_CATEGORY_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_CATEGORY', TEST_CATEGORY_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Category successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCategories.TestGetOrderByFields;
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
   TTMSWEBUnitTestingRunner.RegisterClass(TTestCategories);

end.
