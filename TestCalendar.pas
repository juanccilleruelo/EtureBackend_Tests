unit TestCalendar;

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
   TTestCalendar = class(TObject)
   private
      const LOCAL_PATH          = '/calendar';
      const TEST_CD_USER        = 'playerus';
      const TEST_DS_CALENDAR    = 'Unit Test Calendar';
      const UPDATED_DS_CALENDAR = 'Unit Test Updated Calendar';
      const TEST_COLOR          = '#FF5733';
   private
     function CreateCalendarDataSet:TWebClientDataSet;
     procedure FillCalendarData(ADataSet :TWebClientDataSet; const ADS_CALENDAR :string; const AColor: string = '#FF5733');
     [async] function HasTestCalendar(const ADS_CALENDAR :string):Int64;
     [async] function EnsureTestCalendarExists(const ADS_CALENDAR :string):Int64;
     [async] procedure DeleteTestCalendarIfExists(const ADS_CALENDAR :string);
   published
      [Test] [async] procedure TestCalendarExists;
      [Test] [async] procedure TestCreateNewCalendar;
      [Test] [async] procedure TestUpdateCalendar;
      [Test] [async] procedure TestDeleteCalendar;
      [Test] [async] procedure TestAllCalendarsCalendar;
      [Test] [async] procedure TestOneCalendar;
   end;
{$M-}

implementation

uses senCille.WebSetup, senCille.DataManagement;

{ TTestCalendar }

function TTestCalendar.CreateCalendarDataSet: TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   // ID_CALENDAR BIGINT
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'ID_CALENDAR';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

   // CD_USER VARCHAR(50)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_USER';
   NewField.Size      := 50;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // DS_CALENDAR VARCHAR(100)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_CALENDAR';
   NewField.Size      := 100;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // COLOR VARCHAR(20)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'COLOR';
   NewField.Size      := 20;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

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

procedure TTestCalendar.FillCalendarData(ADataSet :TWebClientDataSet; const ADS_CALENDAR :string; const AColor: string = '#FF5733');
begin
   ADataSet.Append;

   // No se asigna ID_CALENDAR: lo genera el servidor / base de datos
   // ADataSet.FieldByName('ID_CALENDAR').Clear;

   // Usuario propietario del calendario
   ADataSet.FieldByName('CD_USER').AsString := TEST_CD_USER;

   // Nombre del calendario
   ADataSet.FieldByName('DS_CALENDAR').AsString := ADS_CALENDAR;

   // Color del calendario (opcional)
   ADataSet.FieldByName('COLOR').AsString := AColor;

   // Estado: A (Activo), C (Cerrado), B (Bloqueado)
   ADataSet.FieldByName('ST').AsString := 'A';

   // Las fechas CREATED_AT y UPDATED_AT las maneja el servidor
   // ADataSet.FieldByName('CREATED_AT').AsDateTime := Now;
   // ADataSet.FieldByName('UPDATED_AT').AsDateTime := Now;

   ADataSet.Post;
end;

[async] function TTestCalendar.HasTestCalendar(const ADS_CALENDAR :string):Int64;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   Result := -1;
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateCalendarDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH, [['CD_USER'    , TEST_CD_USER],
                                       ['DS_CALENDAR', ADS_CALENDAR]],
                                       DataSet, '/getonecalendar'));

         if DataSet.RecordCount > 0 then begin
            Result := DataSet.FieldByName('ID_CALENDAR').AsLargeInt;
         end;

         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
   finally
      DataSet.Free;
   end;
end;

[async] function TTestCalendar.EnsureTestCalendarExists(const ADS_CALENDAR :string):Int64;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   Result := await(Int64, HasTestCalendar(ADS_CALENDAR));
   if Result <> -1 then Exit;

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateCalendarDataSet;
   try
      FillCalendarData(DataSet, ADS_CALENDAR);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertcalendar'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestCalendarExists -> '+ExceptMsg);
      
      Result := await(Int64, HasTestCalendar(ADS_CALENDAR));
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestCalendar.DeleteTestCalendarIfExists(const ADS_CALENDAR :string);
var ID_CALENDAR :Int64;
begin
   ID_CALENDAR := await(Int64, HasTestCalendar(ADS_CALENDAR));
   if ID_CALENDAR > -1 then begin
      try
         await(TDB.Delete(LOCAL_PATH, [['ID_CALENDAR', IntToStr(ID_CALENDAR)],
                                       ['CD_USER'    , TEST_CD_USER         ]], '/deletecalendar'));
      except
         on E:Exception do ;
      end;
   end;
end;

[Test] [async] procedure TTestCalendar.TestCalendarExists;
{ Verifica si existe un calendario con un nombre específico }
var ID_CALENDAR :Int64;
    ExceptMsg   :string;
begin
   await(DeleteTestCalendarIfExists(TEST_DS_CALENDAR));
   
   TWebSetup.Instance.Language := 'ES';
   try
      ID_CALENDAR := await(Int64, HasTestCalendar(TEST_DS_CALENDAR));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in CalendarExists -> '+ExceptMsg);
   Assert.IsTrue(ID_CALENDAR = -1, 'TestCalendarExists must say it does not exist.');
end;

[Test] [async] procedure TTestCalendar.TestCreateNewCalendar;
{ Crea un nuevo calendario y verifica que se devuelva un ID válido }
var ID_CALENDAR :Int64;
    ExceptMsg   :string;
    DataSet     :TWebClientDataSet;
begin
   await(DeleteTestCalendarIfExists(TEST_DS_CALENDAR));
   
   try
      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateCalendarDataSet;
      try
         FillCalendarData(DataSet, TEST_DS_CALENDAR);
         try
            await(TDB.Insert(LOCAL_PATH, DataSet, '/insertcalendar'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in CreateNewCalendar -> '+ExceptMsg);

         ID_CALENDAR := await(Int64, HasTestCalendar(TEST_DS_CALENDAR));
         Assert.IsTrue(ID_CALENDAR > -1, 'CreateNewCalendar must return a valid ID.');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestCalendarIfExists(TEST_DS_CALENDAR));
   end;
end;

[Test] [async] procedure TTestCalendar.TestUpdateCalendar;
{ Actualiza un calendario existente y verifica que los cambios se apliquen correctamente }
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
begin
   ID_CALENDAR := await(Int64, EnsureTestCalendarExists(TEST_DS_CALENDAR));

   DataSet := CreateCalendarDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['ID_CALENDAR', IntToStr(ID_CALENDAR)]],
                       DataSet, '/getonecalendar'));

      DataSet.Edit;
      DataSet.FieldByName('DS_CALENDAR').AsString := UPDATED_DS_CALENDAR;
      DataSet.FieldByName('COLOR'      ).AsString := '#00FF00';
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['ID_CALENDAR', IntToStr(ID_CALENDAR)],
                                       ['CD_USER'    , TEST_CD_USER        ]], DataSet, '/updatecalendar'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in UpdateCalendar -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['ID_CALENDAR', IntToStr(ID_CALENDAR)]],
                       DataSet, '/getonecalendar'));

      Assert.IsTrue(DataSet.FieldByName('DS_CALENDAR').AsString = UPDATED_DS_CALENDAR, 'Updated calendar name stored');
      Assert.IsTrue(DataSet.FieldByName('COLOR'      ).AsString = '#00FF00', 'Updated color stored');

      DataSet.Edit;
      DataSet.FieldByName('DS_CALENDAR').AsString := TEST_DS_CALENDAR;
      DataSet.FieldByName('COLOR'      ).AsString := TEST_COLOR;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['ID_CALENDAR', IntToStr(ID_CALENDAR)],
                                    ['CD_USER'    , TEST_CD_USER        ]], DataSet, '/updatecalendar'));
   finally
      DataSet.Free;
      await(DeleteTestCalendarIfExists(TEST_DS_CALENDAR));
   end;
end;

[Test] [async] procedure TTestCalendar.TestDeleteCalendar;
{ Elimina un calendario existente y verifica que ya no exista }
var ID_CALENDAR :Int64;
    ExceptMsg   :string;
    DataSet     :TWebClientDataSet;
begin
   ID_CALENDAR := await(Int64, EnsureTestCalendarExists(TEST_DS_CALENDAR));
   Assert.IsTrue(ID_CALENDAR > -1, 'Calendar must exist before deletion');

   TWebSetup.Instance.Language := 'ES';
   
   try
      { Attempt to delete the calendar }
      await(TDB.Delete(LOCAL_PATH, [['ID_CALENDAR', IntToStr(ID_CALENDAR)],
                                    ['CD_USER'    , TEST_CD_USER        ]], '/deletecalendar'));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in DeleteCalendar -> '+ExceptMsg);

   { Verify calendar is marked as cancelled (soft delete) }
   DataSet := CreateCalendarDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH, [['ID_CALENDAR', IntToStr(ID_CALENDAR)]],
                                       DataSet, '/getonecalendar'));
         
         { If the calendar is returned, verify it's marked as cancelled }
         if DataSet.RecordCount > 0 then begin
            Assert.IsTrue(DataSet.FieldByName('ST').AsString = 'C', 'Calendar should be marked as cancelled (C)');
         end;
         
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
   finally
      DataSet.Free;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception verifying calendar state -> '+ExceptMsg);
end;

[Test] [async] procedure TTestCalendar.TestAllCalendarsCalendar;
{ Obtiene todos los calendarios de un usuario y verifica que se devuelvan correctamente }
var DataSet         :TWebClientDataSet;
    ExceptMsg       :string;
    ID_CALENDAR1    :Int64;
    ID_CALENDAR2    :Int64;
    InitialCount    :Integer;
    FinalCount      :Integer;
    FoundCalendar1  :Boolean;
    FoundCalendar2  :Boolean;
begin
   { Create two test calendars }
   ID_CALENDAR1 := await(Int64, EnsureTestCalendarExists(TEST_DS_CALENDAR));
   ID_CALENDAR2 := await(Int64, EnsureTestCalendarExists(TEST_DS_CALENDAR + ' 2'));
   
   Assert.IsTrue(ID_CALENDAR1 > -1, 'First test calendar must exist');
   Assert.IsTrue(ID_CALENDAR2 > -1, 'Second test calendar must exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateCalendarDataSet;
   try
      try
         { Get all calendars for the test user }
         await(TDB.GetAll(LOCAL_PATH, [['CD_USER', TEST_CD_USER]], DataSet, '/getallcalendars'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAllCalendars -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount > 0, 'User must have at least one calendar');

      { Verify that our test calendars are in the result }
      FoundCalendar1 := False;
      FoundCalendar2 := False;
      
      DataSet.First;
      while not DataSet.Eof do begin
         if DataSet.FieldByName('ID_CALENDAR').AsLargeInt = ID_CALENDAR1 then begin
            FoundCalendar1 := True;
            Assert.IsTrue(DataSet.FieldByName('DS_CALENDAR').AsString = TEST_DS_CALENDAR, 'Calendar 1 name matches');
            Assert.IsTrue(DataSet.FieldByName('CD_USER').AsString = TEST_CD_USER, 'Calendar 1 user matches');
         end;
         
         if DataSet.FieldByName('ID_CALENDAR').AsLargeInt = ID_CALENDAR2 then begin
            FoundCalendar2 := True;
            Assert.IsTrue(DataSet.FieldByName('DS_CALENDAR').AsString = TEST_DS_CALENDAR + ' 2', 'Calendar 2 name matches');
            Assert.IsTrue(DataSet.FieldByName('CD_USER').AsString = TEST_CD_USER, 'Calendar 2 user matches');
         end;
         
         DataSet.Next;
      end;

      Assert.IsTrue(FoundCalendar1, 'Test calendar 1 found in results');
      Assert.IsTrue(FoundCalendar2, 'Test calendar 2 found in results');
   finally
      DataSet.Free;
      await(DeleteTestCalendarIfExists(TEST_DS_CALENDAR));
      await(DeleteTestCalendarIfExists(TEST_DS_CALENDAR + ' 2'));
   end;
end;

[Test] [async] procedure TTestCalendar.TestOneCalendar;
{ Obtiene un calendario específico por su ID y verifica que los datos sean correctos }
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
begin
   { Create a test calendar }
   ID_CALENDAR := await(Int64, EnsureTestCalendarExists(TEST_DS_CALENDAR));
   Assert.IsTrue(ID_CALENDAR > -1, 'Test calendar must exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateCalendarDataSet;
   try
      try
         { Get specific calendar by ID }
         await(TDB.GetRow(LOCAL_PATH, [['ID_CALENDAR', IntToStr(ID_CALENDAR)]], DataSet, '/getonecalendar'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneCalendar -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Must return exactly one calendar');

      { Verify calendar data }
      Assert.IsTrue(DataSet.FieldByName('ID_CALENDAR').AsLargeInt = ID_CALENDAR, 'Calendar ID matches');
      Assert.IsTrue(DataSet.FieldByName('DS_CALENDAR').AsString = TEST_DS_CALENDAR, 'Calendar name matches');
      Assert.IsTrue(DataSet.FieldByName('CD_USER').AsString = TEST_CD_USER, 'Calendar user matches');
      Assert.IsTrue(DataSet.FieldByName('COLOR').AsString = TEST_COLOR, 'Calendar color matches');
      Assert.IsTrue(DataSet.FieldByName('ST').AsString = 'A', 'Calendar status is Active');
   finally
      DataSet.Free;
      await(DeleteTestCalendarIfExists(TEST_DS_CALENDAR));
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestCalendar);
end.
