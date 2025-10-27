unit TestCountries;

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
   TTestCountries = class(TObject)
   private
      const LOCAL_PATH                = '/countries';
      const TEST_COUNTRY_CODE         = 'UTC';
      const TEST_COUNTRY_NAME_EN      = 'Unit Test Country';
      const TEST_COUNTRY_NAME_ES      = 'País de Prueba';
      const UPDATED_COUNTRY_NAME_EN   = 'Updated Unit Test Country';
      const UPDATED_COUNTRY_NAME_ES   = 'País de Prueba Actualizado';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillCountryData(ADataSet :TWebClientDataSet; const ACode, ANameEn, ANameEs :string);
      [async] function HasTestCountry:Boolean;
      [async] procedure EnsureTestCountryExists;
      [async] procedure DeleteTestCountryIfExists;
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

{ TTestCountries }

function TTestCountries.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_COUNTRY';
   NewField.Size        := 3;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_COUNTRY_EN';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_COUNTRY_ES';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

procedure TTestCountries.FillCountryData(ADataSet :TWebClientDataSet; const ACode, ANameEn, ANameEs :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_COUNTRY').AsString    := ACode;
   ADataSet.FieldByName('DS_COUNTRY_EN').AsString := ANameEn;
   ADataSet.FieldByName('DS_COUNTRY_ES').AsString := ANameEs;
   ADataSet.Post;
end;

[async] function TTestCountries.HasTestCountry:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_COUNTRY', TEST_COUNTRY_CODE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestCountries.EnsureTestCountryExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestCountry()) then Exit;

   DataSet := CreateDataSet;
   try
      FillCountryData(DataSet,
                      TEST_COUNTRY_CODE,
                      TEST_COUNTRY_NAME_EN,
                      TEST_COUNTRY_NAME_ES);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestCountryExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestCountries.DeleteTestCountryIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_COUNTRY', TEST_COUNTRY_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestCountries.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestCountryIfExists());

   DataSet := CreateDataSet;
   try
      FillCountryData(DataSet,
                      TEST_COUNTRY_CODE,
                      TEST_COUNTRY_NAME_EN,
                      TEST_COUNTRY_NAME_ES);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Insert -> '+ExceptMsg);
      Assert.IsTrue(await(Boolean, HasTestCountry()), 'Inserted country not found afterwards');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCountries.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestCountryExists());

   DataSet := CreateDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                        [['PageNumber', IntToStr(1)],
                         ['SearchText', TEST_COUNTRY_CODE],
                         ['OrderField', '']],
                        DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Select returned at least one row');
      Assert.IsTrue(DataSet.FieldByName('CD_COUNTRY').AsString = TEST_COUNTRY_CODE, 'Country code matches in load');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCountries.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCountryExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_COUNTRY', TEST_COUNTRY_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_COUNTRY_EN').AsString = TEST_COUNTRY_NAME_EN, 'English name matches');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCountries.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestCountryExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_COUNTRY', 'DS_COUNTRY_EN', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll -> '+ExceptMsg);
      Assert.IsTrue(Items.IndexOfName(TEST_COUNTRY_CODE) >= 0, 'Test country present in GetAll list');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestCountries.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCountryExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_COUNTRY', TEST_COUNTRY_CODE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_COUNTRY_EN').AsString := UPDATED_COUNTRY_NAME_EN;
      DataSet.FieldByName('DS_COUNTRY_ES').AsString := UPDATED_COUNTRY_NAME_ES;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_COUNTRY', TEST_COUNTRY_CODE],
                           ['OLD_CD_COUNTRY', TEST_COUNTRY_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_COUNTRY', TEST_COUNTRY_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.FieldByName('DS_COUNTRY_EN').AsString = UPDATED_COUNTRY_NAME_EN, 'Updated English name stored');
      Assert.IsTrue(DataSet.FieldByName('DS_COUNTRY_ES').AsString = UPDATED_COUNTRY_NAME_ES, 'Updated Spanish name stored');

      DataSet.Edit;
      DataSet.FieldByName('DS_COUNTRY_EN').AsString := TEST_COUNTRY_NAME_EN;
      DataSet.FieldByName('DS_COUNTRY_ES').AsString := TEST_COUNTRY_NAME_ES;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_COUNTRY', TEST_COUNTRY_CODE],
                        ['OLD_CD_COUNTRY', TEST_COUNTRY_CODE]],
                       DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCountries.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   await(EnsureTestCountryExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_COUNTRY', TEST_COUNTRY_CODE]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test country should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCountries.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCountryExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['CD_COUNTRY', TEST_COUNTRY_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_COUNTRY', TEST_COUNTRY_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Country successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCountries.TestGetOrderByFields;
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
   TTMSWEBUnitTestingRunner.RegisterClass(TTestCountries);

end.
