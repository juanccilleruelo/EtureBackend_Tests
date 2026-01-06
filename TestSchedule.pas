unit TestSchedule;

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
   TTestSchedule = class(TObject)
   private
      const LOCAL_PATH          = '/schedule';
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
   end;
{$M-}

implementation

uses senCille.WebSetup, senCille.DataManagement;

{ TTestSchedule }

function TTestSchedule.CreateCalendarDataSet: TWebClientDataSet;
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

procedure TTestSchedule.FillCalendarData(ADataSet :TWebClientDataSet; const ADS_CALENDAR :string; const AColor: string = '#FF5733');
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

[async] function TTestSchedule.HasTestCalendar(const ADS_CALENDAR :string):Int64;
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

[async] function TTestSchedule.EnsureTestCalendarExists(const ADS_CALENDAR :string):Int64;
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

[async] procedure TTestSchedule.DeleteTestCalendarIfExists(const ADS_CALENDAR :string);
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

[Test] [async] procedure TTestSchedule.TestCalendarExists;
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

[Test] [async] procedure TTestSchedule.TestCreateNewCalendar;
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

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestSchedule);
end.
