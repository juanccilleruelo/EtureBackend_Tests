unit TestStates;

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
   TTestStates = class(TObject)
   private
      const LOCAL_PATH             = '/states';
      const TEST_STATE_CODE        = 'UTS';
      const TEST_STATE_NAME_EN     = 'Unit Test State';
      const TEST_STATE_NAME_ES     = 'Estado de Prueba';
      const UPDATED_STATE_NAME_EN  = 'Updated State';
      const UPDATED_STATE_NAME_ES  = 'Estado Actualizado';

      const COUNTRIES_PATH         = '/countries';
      const TEST_COUNTRY_CODE      = 'UTC';
      const TEST_COUNTRY_NAME_EN   = 'Unit Test Country';
      const TEST_COUNTRY_NAME_ES   = 'País de Prueba';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillStateData(ADataSet :TWebClientDataSet; const ACountryCode, AStateCode, ANameEn, ANameEs :string);
      [async] procedure EnsureTestCountryExists;
      [async] function HasTestState:Boolean;
      [async] procedure EnsureTestStateExists;
      [async] procedure DeleteTestStateIfExists;
   published
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestLoad;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestGetCountryStates;
      [Test] [async] procedure TestUpdate;
      [Test] [async] procedure TestIsReferenced;
      [Test] [async] procedure TestDelete;
      [Test] [async] procedure TestGetOrderByFields;
   end;
{$M-}

implementation

uses
   senCille.DataManagement;

{ TTestStates }

function TTestStates.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_COUNTRY';
   NewField.Size        := 5;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_STATE';
   NewField.Size        := 3;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_STATE_EN';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_STATE_ES';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

procedure TTestStates.FillStateData(ADataSet :TWebClientDataSet; const ACountryCode, AStateCode, ANameEn, ANameEs :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_COUNTRY' ).AsString := ACountryCode;
   ADataSet.FieldByName('CD_STATE'   ).AsString := AStateCode;
   ADataSet.FieldByName('DS_STATE_EN').AsString := ANameEn;
   ADataSet.FieldByName('DS_STATE_ES').AsString := ANameEs;
   ADataSet.Post;
end;

[async] procedure TTestStates.EnsureTestCountryExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   DataSet := TWebClientDataSet.Create(nil);
   try
      try
         await(TDB.GetRow(COUNTRIES_PATH,
                          [['CD_COUNTRY', TEST_COUNTRY_CODE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;

      if not DataSet.IsEmpty then Exit;

      DataSet.Close;
      DataSet.FieldDefs.Clear;

      DataSet.FieldDefs.Add('CD_COUNTRY'   , ftString,  3);
      DataSet.FieldDefs.Add('DS_COUNTRY_EN', ftString, 50);
      DataSet.FieldDefs.Add('DS_COUNTRY_ES', ftString, 50);
      DataSet.CreateDataSet;
      DataSet.Active := True;

      DataSet.Append;
      DataSet.FieldByName('CD_COUNTRY'   ).AsString := TEST_COUNTRY_CODE;
      DataSet.FieldByName('DS_COUNTRY_EN').AsString := TEST_COUNTRY_NAME_EN;
      DataSet.FieldByName('DS_COUNTRY_ES').AsString := TEST_COUNTRY_NAME_ES;
      DataSet.Post;

      try
         await(TDB.Insert(COUNTRIES_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do
            if Pos('"PK_COUNTRIES"', UpperCase(E.Message)) > 0 then
               ExceptMsg := 'ok'
            else
               ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestCountryExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] function TTestStates.HasTestState:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_COUNTRY', TEST_COUNTRY_CODE],
                           ['CD_STATE'  , TEST_STATE_CODE  ]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestStates.EnsureTestStateExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestCountryExists());

   if await(Boolean, HasTestState()) then Exit;

   DataSet := CreateDataSet;
   try
      FillStateData(DataSet,
                    TEST_COUNTRY_CODE,
                    TEST_STATE_CODE,
                    TEST_STATE_NAME_EN,
                    TEST_STATE_NAME_ES);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestStateExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestStates.DeleteTestStateIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_COUNTRY', TEST_COUNTRY_CODE],
                        ['CD_STATE'  , TEST_STATE_CODE  ]]));
   except
      on E:Exception do ;
   end;

   try
      await(TDB.Delete(COUNTRIES_PATH,
                       [['CD_COUNTRY', TEST_COUNTRY_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestStates.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestStateIfExists());
   await(EnsureTestCountryExists());

   DataSet := CreateDataSet;
   try
      FillStateData(DataSet,
                    TEST_COUNTRY_CODE,
                    TEST_STATE_CODE,
                    TEST_STATE_NAME_EN,
                    TEST_STATE_NAME_ES);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Insert -> '+ExceptMsg);
      Assert.IsTrue(await(Boolean, HasTestState()), 'Inserted state not found afterwards');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestStates.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestStateExists());

   DataSet := CreateDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                        [['PageNumber', IntToStr(1)    ],
                         ['SearchText', TEST_STATE_CODE],
                         ['OrderField', ''             ]],
                        DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Select returned at least one row');
      Assert.IsTrue(DataSet.FieldByName('CD_STATE').AsString = TEST_STATE_CODE, 'State code matches in load');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestStates.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestStateExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_COUNTRY', TEST_COUNTRY_CODE],
                           ['CD_STATE', TEST_STATE_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_STATE_EN').AsString = TEST_STATE_NAME_EN, 'State name matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestStates.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestStateExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_STATE', 'DS_STATE_EN', []));
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

[Test] [async] procedure TTestStates.TestGetCountryStates;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestStateExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items,
                                 LOCAL_PATH+'/getcountrystates',
                                 'CD_STATE',
                                 'DS_STATE_EN',
                                 [['CD_COUNTRY', TEST_COUNTRY_CODE]]));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetCountryStates -> '+ExceptMsg);
      Assert.IsTrue(Pos(TEST_STATE_CODE, Items.Text) > 0,
                    'Country states list contains the test state');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestStates.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestStateExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_COUNTRY', TEST_COUNTRY_CODE],
                        ['CD_STATE'  , TEST_STATE_CODE  ]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_STATE_EN').AsString := UPDATED_STATE_NAME_EN;
      DataSet.FieldByName('DS_STATE_ES').AsString := UPDATED_STATE_NAME_ES;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_COUNTRY'    , TEST_COUNTRY_CODE],
                           ['CD_STATE'      , TEST_STATE_CODE  ],
                           ['OLD_CD_COUNTRY', TEST_COUNTRY_CODE],
                           ['OLD_CD_STATE'  , TEST_STATE_CODE  ]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_COUNTRY', TEST_COUNTRY_CODE],
                        ['CD_STATE'  , TEST_STATE_CODE]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('DS_STATE_EN').AsString = UPDATED_STATE_NAME_EN, 'Updated English name stored in database');
      Assert.IsTrue(DataSet.FieldByName('DS_STATE_ES').AsString = UPDATED_STATE_NAME_ES, 'Updated Spanish name stored in database');

      DataSet.Edit;
      DataSet.FieldByName('DS_STATE_EN').AsString := TEST_STATE_NAME_EN;
      DataSet.FieldByName('DS_STATE_ES').AsString := TEST_STATE_NAME_ES;
      DataSet.Post;

      await(TDB.Update(LOCAL_PATH,
                       [['CD_COUNTRY'    , TEST_COUNTRY_CODE],
                        ['CD_STATE'      , TEST_STATE_CODE  ],
                        ['OLD_CD_COUNTRY', TEST_COUNTRY_CODE],
                        ['OLD_CD_STATE'  , TEST_STATE_CODE  ]],
                       DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestStates.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   await(EnsureTestStateExists());

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_COUNTRY', TEST_COUNTRY_CODE],
                        ['CD_STATE', TEST_STATE_CODE]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test state should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestStates.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestStateExists());

   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_COUNTRY', TEST_COUNTRY_CODE],
                        ['CD_STATE', TEST_STATE_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_COUNTRY', TEST_COUNTRY_CODE],
                        ['CD_STATE', TEST_STATE_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'State successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestStates.TestGetOrderByFields;
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
   TTMSWEBUnitTestingRunner.RegisterClass(TTestStates);

end.
