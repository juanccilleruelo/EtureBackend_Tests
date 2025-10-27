unit TestMyVisaOverview;

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
   TTestMyVisaOverview = class(TObject)
   private
      const LOCAL_PATH             = '/myvisaoverview';
      const TEST_DOC_NUMBER        = 99887766;
      const TEST_IMG_HTML          = '<img src="unit-test.png" alt="Unit Test Visa">';
      const UPDATED_TEST_IMG_HTML  = '<img src="unit-test-updated.png" alt="Unit Test Visa Updated">';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillVisaOverviewData(ADataSet :TWebClientDataSet; const ADocNumber :Integer; const AImageHtml :string);
      [async] function HasTestVisaOverview:Boolean;
      [async] procedure EnsureTestVisaOverviewExists;
      [async] procedure DeleteTestVisaOverviewIfExists;
   published
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestUpdate;
      [Test] [async] procedure TestDelete;
   end;
{$M-}

implementation

uses
   senCille.DataManagement;

{ TTestMyVisaOverview }

function TTestMyVisaOverview.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TIntegerField.Create(Result);
   NewField.FieldName := 'DOC_NUMBER';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftInteger, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'IMG_HTML';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestMyVisaOverview.FillVisaOverviewData(ADataSet :TWebClientDataSet; const ADocNumber :Integer; const AImageHtml :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('DOC_NUMBER').AsInteger := ADocNumber;
   ADataSet.FieldByName('IMG_HTML').AsString := AImageHtml;
   ADataSet.Post;
end;

[async] function TTestMyVisaOverview.HasTestVisaOverview:Boolean;
var
   DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH, [['DOC_NUMBER', IntToStr(TEST_DOC_NUMBER)]], DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestMyVisaOverview.EnsureTestVisaOverviewExists;
var
   DataSet   :TWebClientDataSet;
   ExceptMsg :string;
begin
   if await(Boolean, HasTestVisaOverview()) then begin
      Exit;
   end;

   DataSet := CreateDataSet;
   try
      FillVisaOverviewData(DataSet, TEST_DOC_NUMBER, TEST_IMG_HTML);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestVisaOverviewExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestMyVisaOverview.DeleteTestVisaOverviewIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['DOC_NUMBER', IntToStr(TEST_DOC_NUMBER)]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestMyVisaOverview.TestInsert;
var
   DataSet   :TWebClientDataSet;
   ExceptMsg :string;
begin
   await(DeleteTestVisaOverviewIfExists());

   DataSet := CreateDataSet;
   try
      FillVisaOverviewData(DataSet, TEST_DOC_NUMBER, TEST_IMG_HTML);
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

[Test] [async] procedure TTestMyVisaOverview.TestGetOne;
var
   DataSet   :TWebClientDataSet;
   ExceptMsg :string;
begin
   await(EnsureTestVisaOverviewExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH, [['DOC_NUMBER', IntToStr(TEST_DOC_NUMBER)]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('IMG_HTML').AsString = TEST_IMG_HTML, 'Image HTML matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaOverview.TestGetAll;
var
   Items     :TStrings;
   ExceptMsg :string;
begin
   await(EnsureTestVisaOverviewExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'DOC_NUMBER', 'DOC_NUMBER', []));
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

[Test] [async] procedure TTestMyVisaOverview.TestUpdate;
var
   DataSet   :TWebClientDataSet;
   ExceptMsg :string;
begin
   await(EnsureTestVisaOverviewExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH, [['DOC_NUMBER', IntToStr(TEST_DOC_NUMBER)]], DataSet));

      DataSet.Edit;
      DataSet.FieldByName('IMG_HTML').AsString := UPDATED_TEST_IMG_HTML;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['DOC_NUMBER', IntToStr(TEST_DOC_NUMBER)], ['OLD_DOC_NUMBER', IntToStr(TEST_DOC_NUMBER)]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH, [['DOC_NUMBER', IntToStr(TEST_DOC_NUMBER)]], DataSet));

      Assert.IsTrue(DataSet.FieldByName('IMG_HTML').AsString = UPDATED_TEST_IMG_HTML, 'Updated HTML stored in database');

      DataSet.Edit;
      DataSet.FieldByName('IMG_HTML').AsString := TEST_IMG_HTML;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['DOC_NUMBER', IntToStr(TEST_DOC_NUMBER)], ['OLD_DOC_NUMBER', IntToStr(TEST_DOC_NUMBER)]], DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestMyVisaOverview.TestDelete;
var
   DataSet   :TWebClientDataSet;
   ExceptMsg :string;
begin
   await(EnsureTestVisaOverviewExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['DOC_NUMBER', IntToStr(TEST_DOC_NUMBER)]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH, [['DOC_NUMBER', IntToStr(TEST_DOC_NUMBER)]], DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Visa overview successfully removed');
   finally
      DataSet.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestMyVisaOverview);

end.
