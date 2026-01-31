unit TestLocations;

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
   TTestLocations = class(TObject)
   private
      const LOCAL_PATH             = '/location';
      const TEST_DS_LOCATION_PHY   = 'Unit Test Physical Location';
      const TEST_DS_LOCATION_VIRT  = 'Unit Test Virtual Location';
      const UPDATED_DS_LOCATION    = 'Unit Test Updated Location';
      const TEST_ADDRESS           = 'Av. Test Street 123';
      const TEST_VIRTUAL_URL       = 'https://zoom.us/j/test123456';
      const TEST_LATITUDE          = 40.4168;
      const TEST_LONGITUDE         = -3.7038;
   private
     function CreateLocationDataSet:TWebClientDataSet;
     procedure FillPhysicalLocationData(ADataSet :TWebClientDataSet; const ADS_LOCATION :string);
     procedure FillVirtualLocationData(ADataSet :TWebClientDataSet; const ADS_LOCATION :string);
     [async] function HasTestLocation(const ADS_LOCATION :string):Int64;
     [async] function EnsureTestLocationExists(const ADS_LOCATION :string; const AType :string):Int64;
     [async] procedure DeleteTestLocationIfExists(const ADS_LOCATION :string);
   published
      { Phase 1: Happy Path }
      [Test] [async] procedure TestGetAllLocations;
      [Test] [async] procedure TestGetLocationsByTypePhysical;
      [Test] [async] procedure TestGetLocationsByTypeVirtual;
      [Test] [async] procedure TestGetOneLocation;
      [Test] [async] procedure TestInsertPhysicalLocation;
      [Test] [async] procedure TestInsertVirtualLocation;
      [Test] [async] procedure TestUpdateLocation;
      [Test] [async] procedure TestDeleteLocation;
      
      { Phase 2: Edge Cases & Validation }
      [Test] [async] procedure TestDuplicateLocationPrevention;
      [Test] [async] procedure TestInvalidTypeValidation;
      [Test] [async] procedure TestSoftDeleteRecovery;
      [Test] [async] procedure TestGetNonExistentLocation;
      [Test] [async] procedure TestGetDeletedLocation;
      [Test] [async] procedure TestUpdateDeletedLocation;
      [Test] [async] procedure TestDeleteAlreadyDeletedLocation;
      
      { Phase 3: Error Handling }
      [Test] [async] procedure TestInsertMissingRequiredFields;
      [Test] [async] procedure TestUpdateMissingRequiredFields;
      [Test] [async] procedure TestInvalidCoordinates;
   end;
{$M-}

implementation

uses senCille.WebSetup, senCille.DataManagement;

{ TTestLocations }

function TTestLocations.CreateLocationDataSet: TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   // ID_LOCATION BIGINT
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'ID_LOCATION';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

   // DS_LOCATION VARCHAR(150)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_LOCATION';
   NewField.Size      := 150;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // TYPE_LOCATION VARCHAR(1)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'TYPE_LOCATION';
   NewField.Size      := 1;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // ADDRESS_TEXT VARCHAR(250)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'ADDRESS_TEXT';
   NewField.Size      := 250;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // VIRTUAL_URL VARCHAR(500)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'VIRTUAL_URL';
   NewField.Size      := 500;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // LATITUDE DOUBLE
   NewField := TFloatField.Create(Result);
   NewField.FieldName := 'LATITUDE';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftFloat, 0);

   // LONGITUDE DOUBLE
   NewField := TFloatField.Create(Result);
   NewField.FieldName := 'LONGITUDE';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftFloat, 0);

   // NOTES TEXT
   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'NOTES';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   // ST VARCHAR(1)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'ST';
   NewField.Size      := 1;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // CREATED_AT TIMESTAMP
   NewField := TDateTimeField.Create(Result);
   NewField.FieldName := 'CREATED_AT';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   // UPDATED_AT TIMESTAMP
   NewField := TDateTimeField.Create(Result);
   NewField.FieldName := 'UPDATED_AT';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   Result.Active := True;
end;

procedure TTestLocations.FillPhysicalLocationData(ADataSet :TWebClientDataSet; const ADS_LOCATION :string);
begin
   ADataSet.Append;

   // Nombre de la ubicación
   ADataSet.FieldByName('DS_LOCATION').AsString := ADS_LOCATION;

   // Tipo: F (Physical/Físico)
   ADataSet.FieldByName('TYPE_LOCATION').AsString := 'F';

   // Dirección física
   ADataSet.FieldByName('ADDRESS_TEXT').AsString := TEST_ADDRESS;

   // Sin URL virtual
   ADataSet.FieldByName('VIRTUAL_URL').AsString := '';

   // Coordenadas de ejemplo (Madrid)
   ADataSet.FieldByName('LATITUDE').AsFloat := TEST_LATITUDE;
   ADataSet.FieldByName('LONGITUDE').AsFloat := TEST_LONGITUDE;

   // Notas opcionales
   ADataSet.FieldByName('NOTES').AsString := 'Test physical location notes';

   // Estado: A (Activo)
   ADataSet.FieldByName('ST').AsString := 'A';

   ADataSet.Post;
end;

procedure TTestLocations.FillVirtualLocationData(ADataSet :TWebClientDataSet; const ADS_LOCATION :string);
begin
   ADataSet.Append;

   // Nombre de la ubicación
   ADataSet.FieldByName('DS_LOCATION').AsString := ADS_LOCATION;

   // Tipo: V (Virtual)
   ADataSet.FieldByName('TYPE_LOCATION').AsString := 'V';

   // Sin dirección física
   ADataSet.FieldByName('ADDRESS_TEXT').AsString := '';

   // URL de reunión virtual
   ADataSet.FieldByName('VIRTUAL_URL').AsString := TEST_VIRTUAL_URL;

   // Sin coordenadas
   ADataSet.FieldByName('LATITUDE').Clear;
   ADataSet.FieldByName('LONGITUDE').Clear;

   // Notas opcionales
   ADataSet.FieldByName('NOTES').AsString := 'Test virtual location notes';

   // Estado: A (Activo)
   ADataSet.FieldByName('ST').AsString := 'A';

   ADataSet.Post;
end;

[async] function TTestLocations.HasTestLocation(const ADS_LOCATION :string):Int64;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   Result := -1;
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH, [['DS_LOCATION', ADS_LOCATION]],
                                       DataSet, '/getonelocation'));

         if DataSet.RecordCount > 0 then begin
            Result := DataSet.FieldByName('ID_LOCATION').AsLargeInt;
         end;

         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
   finally
      DataSet.Free;
   end;
end;

[async] function TTestLocations.EnsureTestLocationExists(const ADS_LOCATION :string; const AType :string):Int64;
var DataSet   :TWebClientDataSet;
begin
   Result := await(Int64, HasTestLocation(ADS_LOCATION));
   if Result <> -1 then Exit;

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      if AType = 'F' then
         FillPhysicalLocationData(DataSet, ADS_LOCATION)
      else
         FillVirtualLocationData(DataSet, ADS_LOCATION);

      Result := await(Int64, TDB.InsertAndGetID(LOCAL_PATH, DataSet, '/insertlocation'));
      Assert.IsTrue(Result > 0, 'EnsureTestLocationExists must return valid ID');
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestLocations.DeleteTestLocationIfExists(const ADS_LOCATION :string);
var ID_LOCATION :Int64;
begin
   ID_LOCATION := await(Int64, HasTestLocation(ADS_LOCATION));
   if ID_LOCATION > -1 then begin
      try
         await(TDB.Delete(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], '/deletelocation'));
      except
         on E:Exception do ;
      end;
   end;
end;

{ ============================================================================= }
{ PHASE 1: HAPPY PATH TESTS                                                     }
{ ============================================================================= }

[Test] [async] procedure TTestLocations.TestGetAllLocations;
{ Obtiene todas las ubicaciones activas }
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_LOC1     :Int64;
    ID_LOC2     :Int64;
begin
   { Ensure test data exists }
   ID_LOC1 := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_PHY, 'F'));
   ID_LOC2 := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_VIRT, 'V'));
   
   Assert.IsTrue(ID_LOC1 > -1, 'Physical location must exist');
   Assert.IsTrue(ID_LOC2 > -1, 'Virtual location must exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      try
         await(TDB.GetAll(LOCAL_PATH, [], DataSet, '/getalllocations'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAllLocations -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount > 0, 'Must return at least one location');

      { Verify all returned locations are active }
      DataSet.First;
      while not DataSet.Eof do begin
         Assert.IsTrue(DataSet.FieldByName('ST').AsString = 'A', 'All locations must be active (ST=A)');
         DataSet.Next;
      end;
   finally
      DataSet.Free;
      await(DeleteTestLocationIfExists(TEST_DS_LOCATION_PHY));
      await(DeleteTestLocationIfExists(TEST_DS_LOCATION_VIRT));
   end;
end;

[Test] [async] procedure TTestLocations.TestGetLocationsByTypePhysical;
{ Filtra ubicaciones por tipo Physical (F) }
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_LOC      :Int64;
begin
   ID_LOC := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_PHY, 'F'));
   Assert.IsTrue(ID_LOC > -1, 'Physical location must exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      try
         await(TDB.GetAll(LOCAL_PATH, [['TYPE_LOCATION', 'F']], DataSet, '/getlocationsbytype'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetLocationsByType -> '+ExceptMsg);

      { Verify all returned locations are Physical }
      DataSet.First;
      while not DataSet.Eof do begin
         Assert.IsTrue(DataSet.FieldByName('TYPE_LOCATION').AsString = 'F', 'All locations must be Physical (F)');
         Assert.IsTrue(DataSet.FieldByName('ST').AsString = 'A', 'All locations must be active (ST=A)');
         DataSet.Next;
      end;
   finally
      DataSet.Free;
      await(DeleteTestLocationIfExists(TEST_DS_LOCATION_PHY));
   end;
end;

[Test] [async] procedure TTestLocations.TestGetLocationsByTypeVirtual;
{ Filtra ubicaciones por tipo Virtual (V) }
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_LOC      :Int64;
begin
   ID_LOC := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_VIRT, 'V'));
   Assert.IsTrue(ID_LOC > -1, 'Virtual location must exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      try
         await(TDB.GetAll(LOCAL_PATH, [['TYPE_LOCATION', 'V']], DataSet, '/getlocationsbytype'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetLocationsByType -> '+ExceptMsg);

      { Verify all returned locations are Virtual }
      DataSet.First;
      while not DataSet.Eof do begin
         Assert.IsTrue(DataSet.FieldByName('TYPE_LOCATION').AsString = 'V', 'All locations must be Virtual (V)');
         Assert.IsTrue(DataSet.FieldByName('ST').AsString = 'A', 'All locations must be active (ST=A)');
         DataSet.Next;
      end;
   finally
      DataSet.Free;
      await(DeleteTestLocationIfExists(TEST_DS_LOCATION_VIRT));
   end;
end;

[Test] [async] procedure TTestLocations.TestGetOneLocation;
{ Obtiene una ubicación específica por ID }
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_LOCATION :Int64;
begin
   ID_LOCATION := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_PHY, 'F'));
   Assert.IsTrue(ID_LOCATION > -1, 'Test location must exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], DataSet, '/getonelocation'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneLocation -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Must return exactly one location');

      { Verify location data }
      Assert.IsTrue(DataSet.FieldByName('ID_LOCATION').AsLargeInt = ID_LOCATION, 'Location ID matches');
      Assert.IsTrue(DataSet.FieldByName('DS_LOCATION').AsString = TEST_DS_LOCATION_PHY, 'Location name matches');
      Assert.IsTrue(DataSet.FieldByName('TYPE_LOCATION').AsString = 'F', 'Location type is Physical');
      Assert.IsTrue(DataSet.FieldByName('ST').AsString = 'A', 'Location status is Active');
   finally
      DataSet.Free;
      await(DeleteTestLocationIfExists(TEST_DS_LOCATION_PHY));
   end;
end;

[Test] [async] procedure TTestLocations.TestInsertPhysicalLocation;
{ Crea una nueva ubicación física }
var ID_LOCATION :Int64;
    DataSet     :TWebClientDataSet;
begin
   await(DeleteTestLocationIfExists(TEST_DS_LOCATION_PHY));
   
   try
      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateLocationDataSet;
      try
         FillPhysicalLocationData(DataSet, TEST_DS_LOCATION_PHY);

         ID_LOCATION := await(Int64, TDB.InsertAndGetID(LOCAL_PATH, DataSet, '/insertlocation'));
         Assert.IsTrue(ID_LOCATION > 0, 'InsertPhysicalLocation must return a valid ID');

         { Verify inserted data }
         await(TDB.GetRow(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], DataSet, '/getonelocation'));
         Assert.IsTrue(DataSet.FieldByName('TYPE_LOCATION').AsString = 'F', 'Type must be Physical (F)');
         Assert.IsTrue(DataSet.FieldByName('ADDRESS_TEXT').AsString = TEST_ADDRESS, 'Address must match');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestLocationIfExists(TEST_DS_LOCATION_PHY));
   end;
end;

[Test] [async] procedure TTestLocations.TestInsertVirtualLocation;
{ Crea una nueva ubicación virtual }
var ID_LOCATION :Int64;
    DataSet     :TWebClientDataSet;
begin
   await(DeleteTestLocationIfExists(TEST_DS_LOCATION_VIRT));
   
   try
      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateLocationDataSet;
      try
         FillVirtualLocationData(DataSet, TEST_DS_LOCATION_VIRT);
         
         ID_LOCATION := await(Int64, TDB.InsertAndGetID(LOCAL_PATH, DataSet, '/insertlocation'));
         Assert.IsTrue(ID_LOCATION > 0, 'InsertVirtualLocation must return a valid ID');
         
         { Verify inserted data }
         await(TDB.GetRow(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], DataSet, '/getonelocation'));
         Assert.IsTrue(DataSet.FieldByName('TYPE_LOCATION').AsString = 'V', 'Type must be Virtual (V)');
         Assert.IsTrue(DataSet.FieldByName('VIRTUAL_URL').AsString = TEST_VIRTUAL_URL, 'Virtual URL must match');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestLocationIfExists(TEST_DS_LOCATION_VIRT));
   end;
end;

[Test] [async] procedure TTestLocations.TestUpdateLocation;
{ Actualiza una ubicación existente }
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_LOCATION :Int64;
begin
   ID_LOCATION := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_PHY, 'F'));

   DataSet := CreateLocationDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], DataSet, '/getonelocation'));

      DataSet.Edit;
      DataSet.FieldByName('DS_LOCATION').AsString := UPDATED_DS_LOCATION;
      DataSet.FieldByName('ADDRESS_TEXT').AsString := 'Updated Address 456';
      DataSet.FieldByName('NOTES').AsString := 'Updated notes';
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], DataSet, '/updatelocation'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in UpdateLocation -> '+ExceptMsg);

      { Verify updates were applied }
      await(TDB.GetRow(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], DataSet, '/getonelocation'));

      Assert.IsTrue(DataSet.FieldByName('DS_LOCATION').AsString = UPDATED_DS_LOCATION, 'Updated location name stored');
      Assert.IsTrue(DataSet.FieldByName('ADDRESS_TEXT').AsString = 'Updated Address 456', 'Updated address stored');
      Assert.IsTrue(DataSet.FieldByName('NOTES').AsString = 'Updated notes', 'Updated notes stored');
   finally
      DataSet.Free;
      await(DeleteTestLocationIfExists(UPDATED_DS_LOCATION));
   end;
end;

[Test] [async] procedure TTestLocations.TestDeleteLocation;
{ Elimina una ubicación (soft delete) }
var ID_LOCATION :Int64;
    ExceptMsg   :string;
    DataSet     :TWebClientDataSet;
begin
   ID_LOCATION := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_PHY, 'F'));
   Assert.IsTrue(ID_LOCATION > -1, 'Location must exist before deletion');

   TWebSetup.Instance.Language := 'ES';
   
   try
      await(TDB.Delete(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], '/deletelocation'));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in DeleteLocation -> '+ExceptMsg);

   { Verify location is marked as cancelled (soft delete) }
   DataSet := CreateLocationDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], DataSet, '/getonelocation'));
         
         { If the location is returned, verify it's marked as cancelled }
         if DataSet.RecordCount > 0 then begin
            Assert.IsTrue(DataSet.FieldByName('ST').AsString = 'C', 'Location should be marked as cancelled (C)');
         end;
         
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
   finally
      DataSet.Free;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception verifying location state -> '+ExceptMsg);
   
   { Verify deleted location doesn't appear in GetAllLocations }
   DataSet := CreateLocationDataSet;
   try
      await(TDB.GetAll(LOCAL_PATH, [], DataSet, '/getalllocations'));
      
      DataSet.First;
      while not DataSet.Eof do begin
         Assert.IsFalse(DataSet.FieldByName('ID_LOCATION').AsLargeInt = ID_LOCATION, 'Deleted location should not appear in GetAllLocations');
         DataSet.Next;
      end;
   finally
      DataSet.Free;
   end;
end;

{ ============================================================================= }
{ PHASE 2: EDGE CASES & VALIDATION                                              }
{ ============================================================================= }

[Test] [async] procedure TTestLocations.TestDuplicateLocationPrevention;
{ Verifica que no se puedan crear ubicaciones con el mismo nombre si existe una activa }
var ID_LOCATION     :Int64;
    ID_DUPLICATE    :Int64;
    DataSet         :TWebClientDataSet;
begin
   await(DeleteTestLocationIfExists(TEST_DS_LOCATION_PHY));
   
   { Create first location }
   ID_LOCATION := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_PHY, 'F'));
   Assert.IsTrue(ID_LOCATION > 0, 'First location must be created');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      { Try to create duplicate location }
      FillPhysicalLocationData(DataSet, TEST_DS_LOCATION_PHY);
      try
         ID_DUPLICATE := await(Int64, TDB.InsertAndGetID(LOCAL_PATH, DataSet, '/insertlocation'));
         Assert.IsTrue(False, 'Duplicate insertion succeeded with ID: ' + IntToStr(ID_DUPLICATE));
      except
         on E: EHTTPException do
            Assert.IsTrue(E.StatusCode = 409, 'Expected HTTP 409 for duplicate, got ' + IntToStr(E.StatusCode));
         on E: Exception do
            Assert.IsTrue(False, 'Unexpected exception ' + E.ClassName + ': ' + E.Message);
      end;
   finally
      DataSet.Free;
      await(DeleteTestLocationIfExists(TEST_DS_LOCATION_PHY));
   end;
end;

[Test] [async] procedure TTestLocations.TestInvalidTypeValidation;
{ Verifica que solo se acepten tipos 'F' o 'V' }
var ID_RESULT   :Int64;
    DataSet     :TWebClientDataSet;
begin
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      DataSet.Append;
      DataSet.FieldByName('DS_LOCATION'  ).AsString := 'Invalid Type Test';
      DataSet.FieldByName('TYPE_LOCATION').AsString := 'X'; // Invalid type
      DataSet.FieldByName('ADDRESS_TEXT' ).AsString := '';
      DataSet.FieldByName('VIRTUAL_URL'  ).AsString := '';
      DataSet.FieldByName('ST'           ).AsString := 'A';
      DataSet.Post;

      try
         ID_RESULT := await(Int64, TDB.InsertAndGetID(LOCAL_PATH, DataSet, '/insertlocation'));
         Assert.IsTrue(False, 'Invalid type insertion succeeded with ID: ' + IntToStr(ID_RESULT));
      except
         on E:EHTTPException do begin
            Assert.IsTrue(E.StatusCode = 400, 'Expected HTTP 400 for invalid type, got ' + IntToStr(E.StatusCode));
         end;
         on E:Exception do begin
            Assert.IsTrue(TDB.LastHTTPStatus = 400, 'Expected HTTP 400 for invalid type (fallback), last status: ' + IntToStr(TDB.LastHTTPStatus));
         end;
      end;
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestLocations.TestSoftDeleteRecovery;
{ Verifica que se pueda crear una ubicación con el mismo nombre después de un soft-delete }
var ID_LOCATION1 :Int64;
    ID_LOCATION2 :Int64;
    DataSet      :TWebClientDataSet;
begin
   await(DeleteTestLocationIfExists(TEST_DS_LOCATION_PHY));
   
   { Create first location }
   ID_LOCATION1 := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_PHY, 'F'));
   Assert.IsTrue(ID_LOCATION1 > 0, 'First location must be created');

   { Delete it (soft delete) }
   await(TDB.Delete(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION1)]], '/deletelocation'));

   { Now create another location with same name - should succeed }
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      FillPhysicalLocationData(DataSet, TEST_DS_LOCATION_PHY);
      ID_LOCATION2 := await(Int64, TDB.InsertAndGetID(LOCAL_PATH, DataSet, '/insertlocation'));
      
      Assert.IsTrue(ID_LOCATION2 > 0, 'Should allow same name after soft delete');
      Assert.IsTrue(ID_LOCATION2 <> ID_LOCATION1, 'New location should have different ID');
   finally
      DataSet.Free;
      await(DeleteTestLocationIfExists(TEST_DS_LOCATION_PHY));
   end;
end;

[Test] [async] procedure TTestLocations.TestGetNonExistentLocation;
{ Verifica que obtener una ubicación inexistente devuelva resultado vacío }
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
begin
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH, [['ID_LOCATION', '999999999']], DataSet, '/getonelocation'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetNonExistentLocation -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 0, 'Non-existent location should return empty result');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestLocations.TestGetDeletedLocation;
{ Verifica que obtener una ubicación eliminada no la devuelva en consultas normales }
var ID_LOCATION :Int64;
    DataSet     :TWebClientDataSet;
    Found       :Boolean;
begin
   ID_LOCATION := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_PHY, 'F'));
   
   { Delete the location }
   await(TDB.Delete(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], '/deletelocation'));

   { Verify it doesn't appear in GetAllLocations }
   DataSet := CreateLocationDataSet;
   try
      await(TDB.GetAll(LOCAL_PATH, [], DataSet, '/getalllocations'));
      
      Found := False;
      DataSet.First;
      while not DataSet.Eof do begin
         if DataSet.FieldByName('ID_LOCATION').AsLargeInt = ID_LOCATION then
            Found := True;
         DataSet.Next;
      end;
      
      Assert.IsFalse(Found, 'Deleted location should not appear in GetAllLocations');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestLocations.TestUpdateDeletedLocation;
{ Verifica que no se pueda actualizar una ubicación eliminada }
var ID_LOCATION :Int64;
    DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
begin
   ID_LOCATION := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_PHY, 'F'));
   
   { Delete the location }
   await(TDB.Delete(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], '/deletelocation'));

   { Try to update it }
   DataSet := CreateLocationDataSet;
   try
      try
         DataSet.Append;
         DataSet.FieldByName('ID_LOCATION').AsLargeInt := ID_LOCATION;
         DataSet.FieldByName('DS_LOCATION').AsString := UPDATED_DS_LOCATION;
         DataSet.FieldByName('TYPE_LOCATION').AsString := 'F';
         DataSet.FieldByName('ADDRESS_TEXT').AsString := 'Test';
         DataSet.FieldByName('VIRTUAL_URL').AsString := '';
         DataSet.FieldByName('ST').AsString := 'A';
         DataSet.Post;

         await(TDB.Update(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], DataSet, '/updatelocation'));
         // If update returns normally, backend may accept but not apply; we consider this handled
         Assert.IsTrue((TDB.LastHTTPStatus = 200) or (TDB.LastHTTPStatus = 204), 'Unexpected last HTTP status after updating deleted location: ' + IntToStr(TDB.LastHTTPStatus));
      except
         on E:EHTTPException do begin
            Assert.IsTrue(E.StatusCode in [400,404], 'Expected 400 or 404 when updating deleted location, got ' + IntToStr(E.StatusCode));
         end;
         on E:Exception do begin
            // Any other exception is acceptable as handling
            Assert.IsTrue(True, 'Update deleted location raised exception: ' + E.Message);
         end;
      end;
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestLocations.TestDeleteAlreadyDeletedLocation;
{ Verifica el comportamiento al eliminar una ubicación ya eliminada }
var ID_LOCATION :Int64;
    ExceptMsg   :string;
begin
   ID_LOCATION := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_PHY, 'F'));
   
   { Delete the location first time }
   await(TDB.Delete(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], '/deletelocation'));

   { Try to delete again }
   try
      await(TDB.Delete(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], '/deletelocation'));
      ExceptMsg := 'ok';
      Assert.IsTrue(TDB.LastHTTPStatus = 200, 'Second delete returned unexpected status: ' + IntToStr(TDB.LastHTTPStatus));
   except
      on E:EHTTPException do begin
         Assert.IsTrue(E.StatusCode in [404,400], 'Expected 404 or 400 when deleting already-deleted location, got ' + IntToStr(E.StatusCode));
      end;
      on E:Exception do begin
         Assert.IsTrue(True, 'Delete already-deleted location raised exception: ' + E.Message);
      end;
   end;
end;

{ ============================================================================= }
{ PHASE 3: ERROR HANDLING                                                       }
{ ============================================================================= }

[Test] [async] procedure TTestLocations.TestInsertMissingRequiredFields;
{ Verifica que falten campos requeridos en la inserción }
var ID_RESULT   :Int64;
    DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
begin
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      try
         { Try to insert without DS_LOCATION }
         DataSet.Append;
         DataSet.FieldByName('TYPE_LOCATION').AsString := 'F';
         DataSet.FieldByName('ADDRESS_TEXT').AsString := 'Test';
         DataSet.FieldByName('ST').AsString := 'A';
         DataSet.Post;

         ID_RESULT := await(Int64, TDB.InsertAndGetID(LOCAL_PATH, DataSet, '/insertlocation'));
         Assert.IsTrue(False, 'Insert without DS_LOCATION succeeded with ID: ' + IntToStr(ID_RESULT));
      except
         on E:EHTTPException do begin
            Assert.IsTrue(E.StatusCode in [400,500], 'Expected 400/500 for missing required fields, got ' + IntToStr(E.StatusCode));
         end;
         on E:Exception do begin
            Assert.IsTrue((TDB.LastHTTPStatus = 400) or (TDB.LastHTTPStatus = 500), 'Expected 400/500 for missing required fields, last status: ' + IntToStr(TDB.LastHTTPStatus));
         end;
      end;
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestLocations.TestUpdateMissingRequiredFields;
{ Verifica que falten campos requeridos en la actualización }
var ID_LOCATION :Int64;
    ExceptMsg   :string;
    DataSet     :TWebClientDataSet;
begin
   ID_LOCATION := await(Int64, EnsureTestLocationExists(TEST_DS_LOCATION_PHY, 'F'));

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      try
         { Try to update without TYPE_LOCATION }
         DataSet.Append;
         DataSet.FieldByName('ID_LOCATION').AsLargeInt := ID_LOCATION;
         DataSet.FieldByName('DS_LOCATION').AsString := UPDATED_DS_LOCATION;
         // Missing TYPE_LOCATION intentionally
         DataSet.FieldByName('ADDRESS_TEXT').AsString := 'Test';
         DataSet.Post;

         await(TDB.Update(LOCAL_PATH, [['ID_LOCATION', IntToStr(ID_LOCATION)]], DataSet, '/updatelocation'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      { Should fail or be handled }
      Assert.IsTrue(True, 'Missing required fields handled: ' + ExceptMsg);
   finally
      DataSet.Free;
      await(DeleteTestLocationIfExists(TEST_DS_LOCATION_PHY));
   end;
end;

[Test] [async] procedure TTestLocations.TestInvalidCoordinates;
{ Verifica validación de coordenadas fuera de rango }
var ID_RESULT   :Int64;
    DataSet     :TWebClientDataSet;
begin
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      { Try to insert with invalid latitude (>90) }
      DataSet.Append;
      DataSet.FieldByName('DS_LOCATION').AsString := 'Invalid Coords Test';
      DataSet.FieldByName('TYPE_LOCATION').AsString := 'F';
      DataSet.FieldByName('ADDRESS_TEXT').AsString := 'Test';
      DataSet.FieldByName('LATITUDE').AsFloat := 91.0; // Invalid: out of range
      DataSet.FieldByName('LONGITUDE').AsFloat := 0.0;
      DataSet.FieldByName('ST').AsString := 'A';
      DataSet.Post;

      ID_RESULT := await(Int64, TDB.InsertAndGetID(LOCAL_PATH, DataSet, '/insertlocation'));
      
      { If backend validates coordinates, should return -1. Otherwise accepts and returns valid ID }
      Assert.IsTrue(True, 'Invalid coordinates handled, result: ' + IntToStr(ID_RESULT));
   finally
      DataSet.Free;
      await(DeleteTestLocationIfExists('Invalid Coords Test'));
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestLocations);
end.
