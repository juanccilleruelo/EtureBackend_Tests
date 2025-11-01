unit TestSocialMedia;

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
   TTestSocialMedia = class(TObject)
   private
      const LOCAL_PATH                = '/socialmedia';
      const TEST_SOCIAL_MEDIA_CODE    = 'UTSM';
      const TEST_SOCIAL_MEDIA_NAME    = 'Unit Test Social Medium';
      const UPDATED_SOCIAL_MEDIA_NAME = 'Test - Updated';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillSocialMediaData(ADataSet :TWebClientDataSet; const ADescription :string);
      [async] function HasTestSocialMedia:Boolean;
      [async] procedure EnsureTestSocialMediaExists;
      [async] procedure DeleteTestSocialMediaIfExists;
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

{ TTestSocialMedia }

function TTestSocialMedia.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_SOCIAL_MEDIUM';
   NewField.Size := 4;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_SOCIAL_MEDIUM';
   NewField.Size := 25;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'IMG_LOGO';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestSocialMedia.FillSocialMediaData(ADataSet :TWebClientDataSet; const ADescription :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_SOCIAL_MEDIUM').AsString := TEST_SOCIAL_MEDIA_CODE;
   ADataSet.FieldByName('DS_SOCIAL_MEDIUM').AsString := ADescription;
   ADataSet.FieldByName('IMG_LOGO').AsString := 'NoImage';
   ADataSet.Post;
end;

[async] function TTestSocialMedia.HasTestSocialMedia:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestSocialMedia.EnsureTestSocialMediaExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestSocialMedia()) then begin
      Exit;
   end;

   DataSet := CreateDataSet;
   try
      FillSocialMediaData(DataSet, TEST_SOCIAL_MEDIA_NAME);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestSocialMediaExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestSocialMedia.DeleteTestSocialMediaIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestSocialMedia.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestSocialMediaIfExists());

   DataSet := CreateDataSet;
   try
      FillSocialMediaData(DataSet, TEST_SOCIAL_MEDIA_NAME);
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

[Test] [async] procedure TTestSocialMedia.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestSocialMediaExists());

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
      Assert.IsTrue(DataSet.Locate('CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE, []), 'Test social media located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestSocialMedia.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestSocialMediaExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_SOCIAL_MEDIUM').AsString = TEST_SOCIAL_MEDIA_NAME, 'Social media description matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestSocialMedia.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestSocialMediaExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_SOCIAL_MEDIUM', 'DS_SOCIAL_MEDIUM', []));
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

[Test] [async] procedure TTestSocialMedia.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestSocialMediaExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_SOCIAL_MEDIUM').AsString := UPDATED_SOCIAL_MEDIA_NAME;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE], ['OLD_CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('DS_SOCIAL_MEDIUM').AsString = UPDATED_SOCIAL_MEDIA_NAME, 'Updated description stored in database');

      DataSet.Edit;
      DataSet.FieldByName('DS_SOCIAL_MEDIUM').AsString := TEST_SOCIAL_MEDIA_NAME;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE], ['OLD_CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE]], DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestSocialMedia.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   await(EnsureTestSocialMediaExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test social media should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestSocialMedia.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestSocialMediaExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_SOCIAL_MEDIUM', TEST_SOCIAL_MEDIA_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Social media successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestSocialMedia.TestGetOrderByFields;
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
   TTMSWEBUnitTestingRunner.RegisterClass(TTestSocialMedia);

end.
