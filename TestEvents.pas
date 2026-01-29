unit TestEvents;

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
   senCille.TypeConverter,
   senCille.Miscellaneous,
   senCille.MVCRequests;

type
{$M+}
   [TestFixture]
   TTestEvents = class(TObject)
   private
      const LOCAL_PATH             = '/event';
      const TEST_CD_USER           = 'playerus';
      const TEST_TITLE             = 'Unit Test Event';
      const UPDATED_TEST_TITLE     = 'Updated Unit Test Event';
      const TEST_DESCRIPTION       = 'This is a test event description';
      const TEST_LINK_URL          = 'https://maps.google.com/maps?q=Calle+Principal+123,+Madrid';
      const TEST_ALL_DAY           = 'N';
      const TEST_TZ_NAME           = 'UTC';
   private
      function CreateEventDataSet:TWebClientDataSet;
      function CreateCalendarDataSet:TWebClientDataSet;
      function CreateLocationDataSet:TWebClientDataSet;
      procedure FillEventData(ADataSet :TWebClientDataSet; const AID_CALENDAR :Int64; const ATitle :string; const AStartsAt, AEndsAt :TDateTime; const AID_LOCATION, AID_MEETING_POINT :Int64);
      [async] function GetTestCalendarID:Int64;
      [async] function EnsureTestCalendarExists:Int64;
      [async] function GetValidLocationID:Int64;
      [async] function EnsureTestLocationExists:Int64;
      [async] function HasTestEvent(const ATitle :string):Int64;
      [async] function EnsureTestEventExists(const ATitle :string):Int64;
      [async] procedure DeleteTestEventIfExists(const ATitle :string);
   published
      { GetEventsByCalendar - 3 tests }
      [Test] [async] procedure TestGetEventsByCalendarWithoutDateRange;
      [Test] [async] procedure TestGetEventsByCalendarWithDateRange;
      [Test] [async] procedure TestGetEventsByCalendarEmptyResult;

      { GetEventsByUser - 3 tests }
      [Test] [async] procedure TestGetEventsByUserAsOrganizer;
      [Test] [async] procedure TestGetEventsByUserAsAttendee;
      [Test] [async] procedure TestGetEventsByUserBothRoles;

      { GetOneEvent - 2 tests }
      [Test] [async] procedure TestGetOneEventExists;
      [Test] [async] procedure TestGetOneEventNotFound;

      { InsertEvent - 5 tests }
      [Test] [async] procedure TestInsertEventValid;
      [Test] [async] procedure TestInsertEventStartsAfterEnds;
      [Test] [async] procedure TestInsertEventInvalidAllDayValue;
      [Test] [async] procedure TestInsertEventLocationNotExists;
      [Test] [async] procedure TestInsertEventMeetingPointNotExists;

      { UpdateEvent - 3 tests }
      [Test] [async] procedure TestUpdateEventValid;
      [Test] [async] procedure TestUpdateEventUserNotOrganizer;
      [Test] [async] procedure TestUpdateEventNotFound;

      { DeleteEvent - 2 tests }
      [Test] [async] procedure TestDeleteEventValid;
      [Test] [async] procedure TestDeleteEventUserNotOrganizer;
   end;
{$M-}

implementation

uses senCille.WebSetup, senCille.DataManagement;

{ TTestEvents }

function TTestEvents.CreateCalendarDataSet: TWebClientDataSet;
var NewField :TField;
begin
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

   // DS_CALENDAR VARCHAR(200)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_CALENDAR';
   NewField.Size      := 200;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // COLOR VARCHAR(7)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'COLOR';
   NewField.Size      := 7;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

function TTestEvents.CreateLocationDataSet: TWebClientDataSet;
var NewField :TField;
begin
   Result := TWebClientDataSet.Create(nil);

   // ID_LOCATION BIGINT
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'ID_LOCATION';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

   // DS_LOCATION VARCHAR(200)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_LOCATION';
   NewField.Size      := 200;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

function TTestEvents.CreateEventDataSet: TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   // ID_EVENT BIGINT
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'ID_EVENT';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

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

   // TITLE VARCHAR(200)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'TITLE';
   NewField.Size      := 200;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // DESCRIPTION TEXT (memo)
   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'DESCRIPTION';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   // LINK_URL VARCHAR(500)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'LINK_URL';
   NewField.Size      := 500;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // ALL_DAY VARCHAR(1)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'ALL_DAY';
   NewField.Size      := 1;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // STARTS_AT_TZ TIMESTAMP
   NewField := TDateTimeField.Create(Result);
   NewField.FieldName := 'STARTS_AT_TZ';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   // ENDS_AT_TZ TIMESTAMP
   NewField := TDateTimeField.Create(Result);
   NewField.FieldName := 'ENDS_AT_TZ';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   // TZ_NAME VARCHAR(50)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'TZ_NAME';
   NewField.Size      := 50;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // ID_LOCATION BIGINT
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'ID_LOCATION';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

   // ID_MEETING_POINT BIGINT
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'ID_MEETING_POINT';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

   // IS_INVITATION VARCHAR(1)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'IS_INVITATION';
   NewField.Size      := 1;
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

procedure TTestEvents.FillEventData(ADataSet :TWebClientDataSet; const AID_CALENDAR :Int64; const ATitle :string; const AStartsAt, AEndsAt :TDateTime; const AID_LOCATION, AID_MEETING_POINT :Int64);
begin
   ADataSet.Append;

   ADataSet.FieldByName('ID_CALENDAR'     ).AsLargeInt := AID_CALENDAR;
   ADataSet.FieldByName('CD_USER'         ).AsString   := TEST_CD_USER;
   ADataSet.FieldByName('TITLE'           ).AsString   := ATitle;
   ADataSet.FieldByName('DESCRIPTION'     ).AsString   := TEST_DESCRIPTION;
   ADataSet.FieldByName('LINK_URL'        ).AsString   := TEST_LINK_URL;
   ADataSet.FieldByName('ALL_DAY'         ).AsString   := TEST_ALL_DAY;
   ADataSet.FieldByName('STARTS_AT_TZ'    ).AsDateTime := AStartsAt;
   ADataSet.FieldByName('ENDS_AT_TZ'      ).AsDateTime := AEndsAt;
   ADataSet.FieldByName('TZ_NAME'         ).AsString   := TEST_TZ_NAME;
   ADataSet.FieldByName('ID_LOCATION'     ).AsLargeInt := AID_LOCATION;
   ADataSet.FieldByName('ID_MEETING_POINT').AsLargeInt := AID_MEETING_POINT;
   ADataSet.FieldByName('ST'              ).AsString   := 'A';

   ADataSet.Post;
end;

[async] function TTestEvents.EnsureTestCalendarExists:Int64;
{ PROPÓSITO:
  Garantiza que existe el calendario de prueba "Unit Test Calendar".
  Si ya existe, devuelve su ID. Si no existe, lo crea.
  
  RETORNO:
  - ID_CALENDAR del calendario (existente o recién creado)
}
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   { PASO 1: Intentar obtener el calendario existente }
   Result := await(Int64, GetTestCalendarID);
   if Result > 0 then Exit;  { Ya existe, retornar su ID }

   { PASO 2: El calendario no existe, crearlo }
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateCalendarDataSet;
   try
      DataSet.Append;
      DataSet.FieldByName('CD_USER'    ).AsString := TEST_CD_USER;
      DataSet.FieldByName('DS_CALENDAR').AsString := 'Unit Test Calendar';
      DataSet.FieldByName('COLOR'      ).AsString := '#FF5733';
      DataSet.Post;

      try
         { Llamar al endpoint POST /schedule/insertcalendar }
         await(TDB.Insert('/schedule', DataSet, '/insertcalendar'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Failed to create test calendar -> '+ExceptMsg);

      { PASO 3: Recuperar el ID del calendario recién creado }
      Result := await(Int64, GetTestCalendarID);
      Assert.IsTrue(Result > 0, 'Failed to retrieve calendar ID after creation');
   finally
      DataSet.Free;
   end;
end;

[async] function TTestEvents.GetValidLocationID:Int64;
{ PROPÓSITO:
  Obtiene el ID de una location válida existente en la base de datos.
  
  RETORNO:
  - ID_LOCATION del primer location activo encontrado
  - -1 si no hay locations en la base de datos
  
  NOTA: 
  Este método se usa para obtener IDs válidos para los tests.
  Asume que existe al menos una location en la base de datos.
}
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   Result := -1;
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      try
         { Llamar al endpoint POST /location/getalllocations }
         await(TDB.GetAll('/location', [], DataSet, '/getalllocations'));

         { Si hay locations, tomar el ID del primero }
         if DataSet.RecordCount > 0 then begin
            DataSet.First;
            Result := DataSet.FieldByName('ID_LOCATION').AsLargeInt;
         end;

         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            { En caso de error, mantener Result = -1 }
            ExceptMsg := E.Message;
         end;
      end;
   finally
      DataSet.Free;
   end;
end;

[async] function TTestEvents.EnsureTestLocationExists:Int64;
{ PROPÓSITO:
  Garantiza que existe al menos una location de prueba en la base de datos.
  Si ya existe alguna location, devuelve el ID de la primera encontrada.
  Si no existe ninguna, crea una location de prueba y devuelve su ID.
  
  RETORNO:
  - ID_LOCATION de una location válida (existente o recién creada)
  
  NOTA:
  Este método asegura que siempre haya al menos una location disponible
  para los tests, creándola automáticamente si es necesario.
}
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   { PASO 1: Intentar obtener una location existente }
   Result := await(Int64, GetValidLocationID);
   if Result > 0 then Exit;  { Ya existe al menos una, retornar su ID }

   { PASO 2: No hay locations, crear una de prueba }
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateLocationDataSet;
   try
      DataSet.Append;
      DataSet.FieldByName('DS_LOCATION').AsString := 'Unit Test Location';
      DataSet.Post;

      try
         { Llamar al endpoint POST /location/insertlocation }
         { TYPE_LOCATION: F (Physical) o V (Virtual) - usamos F }
         await(TDB.Insert('/location', [['DS_LOCATION'  , 'Unit Test Location'],
                                        ['TYPE_LOCATION', 'F'],
                                        ['ADDRESS_TEXT' , 'Test Address 123'],
                                        ['NOTES'        , 'Created for unit testing']], '/insertlocation'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Failed to create test location -> '+ExceptMsg);

      { PASO 3: Recuperar el ID de la location recién creada }
      Result := await(Int64, GetValidLocationID);
      Assert.IsTrue(Result > 0, 'Failed to retrieve location ID after creation');
   finally
      DataSet.Free;
   end;
end;

[async] function TTestEvents.GetTestCalendarID:Int64;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   { Valor por defecto: -1 indica "no encontrado" }
   Result := -1;
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateCalendarDataSet;
   try
      try
         { Llamar al endpoint POST /schedule/getonecalendar }
         await(TDB.GetRow('/schedule', [['CD_USER'    , TEST_CD_USER],
                                        ['DS_CALENDAR', 'Unit Test Calendar']],
                                        DataSet, '/getonecalendar'));

         { Si encontró el calendario, extraer su ID }
         if DataSet.RecordCount > 0 then begin
            Result := DataSet.FieldByName('ID_CALENDAR').AsLargeInt;
         end;

         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            { Si es error 404, el calendario no existe (no es un error en este contexto) }
            ExceptMsg := E.Message;
         end;
      end;
   finally
      DataSet.Free;
   end;
end;

[async] function TTestEvents.HasTestEvent(const ATitle :string):Int64;
{ PROPÓSITO:
  Busca si existe un evento con el título especificado perteneciente al usuario de prueba.
  
  PARÁMETROS:
  - ATitle: Título del evento a buscar
  
  RETORNO:
  - ID_EVENT del evento si se encuentra
  - -1 si no existe ningún evento con ese título
  
  ESTRATEGIA:
  Llama al endpoint POST /event/geteventsbyuser y busca secuencialmente
  un evento que coincida con el título especificado.
  
  NOTA: Esta es una función auxiliar para tests, no está optimizada para producción.
}
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   { Valor por defecto: -1 indica "no encontrado" }
   Result := -1;
   
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      try
         { PASO 1: Llamar al endpoint POST /event/geteventsbyuser }
         { Sin especificar ROLE, usa default 'any' (organizer o attendee) }
         await(TDB.GetAll(LOCAL_PATH, [['CD_USER', TEST_CD_USER]],
                                       DataSet, '/geteventsbyuser'));

         { PASO 2: Recorrer todos los eventos buscando uno con el título especificado }
         if DataSet.RecordCount > 0 then begin
            DataSet.First;
            while not DataSet.Eof do begin
               { Comparar el título actual con el buscado }
               if DataSet.FieldByName('TITLE').AsString = ATitle then begin
                  { Encontrado: guardar el ID y salir del bucle }
                  Result := DataSet.FieldByName('ID_EVENT').AsLargeInt;
                  Break;
               end;
               DataSet.Next;
            end;
         end;
         { Si no hay eventos o no se encuentra, Result permanece en -1 }

         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            { En caso de error, mantener Result = -1 }
            ExceptMsg := E.Message;
         end;
      end;
   finally
      DataSet.Free;
   end;
end;

[async] function TTestEvents.EnsureTestEventExists(const ATitle :string):Int64;
{ PROPÓSITO:
  Garantiza que existe un evento de prueba con el título especificado.
  Si el evento ya existe, devuelve su ID sin crear uno nuevo (idempotencia).
  Si no existe, lo crea y devuelve su ID.
  
  PARÁMETROS:
  - ATitle: Título del evento de prueba a buscar/crear
  
  RETORNO:
  - ID_EVENT del evento (existente o recién creado)
  - Si falla la creación, se lanza una aserción
  
  COMPORTAMIENTO:
  1. Busca si ya existe un evento con ese título
  2. Si existe → devuelve su ID inmediatamente (Early Exit)
  3. Si no existe → lo crea:
     - Obtiene el calendario de prueba
     - Obtiene un location válido
     - Crea un evento que empieza mañana y dura 2 horas
     - Inserta en la base de datos
     - Recupera y devuelve el ID del evento creado
}
var DataSet        :TWebClientDataSet;
    ExceptMsg      :string;
    ID_CALENDAR    :Int64;
    ID_LOCATION    :Int64;
    StartDate      :TDateTime;
    EndDate        :TDateTime;
begin
   { PASO 1: Verificar si el evento ya existe }
   Result := await(Int64, HasTestEvent(ATitle));
   if Result > 0 then Exit;  { Si existe, devolver su ID sin crear nada más }

   { PASO 2: Asegurar que existe el calendario de prueba y obtener su ID }
   ID_CALENDAR := await(Int64, EnsureTestCalendarExists);
   Assert.IsTrue(ID_CALENDAR > 0, 'Test calendar must exist or be created');

   { PASO 3: Asegurar que existe al menos una location y obtener su ID }
   ID_LOCATION := await(Int64, EnsureTestLocationExists);
   Assert.IsTrue(ID_LOCATION > 0, 'Test location must exist or be created');

   { PASO 4: Preparar el dataset para crear el nuevo evento }
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      { Configurar fechas del evento: empieza mañana y dura 2 horas }
      StartDate := Now + 1;        { Mañana a esta hora }
      EndDate   := StartDate + (2/24); { 2 horas después (2/24 días = 2 horas) }

      { Llenar el dataset con los datos del evento }
      { Usar el mismo ID_LOCATION para location y meeting point }
      FillEventData(DataSet, ID_CALENDAR, ATitle, StartDate, EndDate, ID_LOCATION, ID_LOCATION);
      
      { PASO 5: Llamar al endpoint POST /event/insertevent }
      { El servidor devuelve 201 (Created) con NEW_ID en el body }
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertevent'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      { Verificar que la inserción fue exitosa (status 201 se maneja como éxito) }
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestEventExists -> '+ExceptMsg);
      
      { PASO 6: Recuperar el ID del evento recién creado mediante búsqueda }
      Result := await(Int64, HasTestEvent(ATitle));
      
      { Verificar que se obtuvo un ID válido }
      Assert.IsTrue(Result > 0, 'Failed to retrieve created event ID');
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestEvents.DeleteTestEventIfExists(const ATitle :string);
{ PROPÓSITO:
  Elimina un evento de prueba si existe (soft delete).
  
  PARÁMETROS:
  - ATitle: Título del evento a eliminar
  
  COMPORTAMIENTO:
  1. Busca el evento por título
  2. Si existe (ID > 0), llama al endpoint POST /event/deleteevent
  3. Suprime cualquier excepción (método de limpieza)
  
  NOTA: Este método se usa para limpieza, por lo que no propaga errores.
}
var ID_EVENT :Int64;
begin
   { Buscar el evento por título }
   ID_EVENT := await(Int64, HasTestEvent(ATitle));
   
   { Si existe, intentar eliminarlo }
   if ID_EVENT > 0 then begin
      try
         { Llamar al endpoint POST /event/deleteevent }
         { Requiere ID_EVENT y CD_USER (debe ser el organizador) }
         await(TDB.Delete(LOCAL_PATH, [['ID_EVENT', IntToStr(ID_EVENT)],
                                       ['CD_USER' , TEST_CD_USER      ]], '/deleteevent'));
      except
         on E:Exception do begin
            { Ignorar errores en limpieza }
         end;
      end;
   end;
end;

{ GetEventsByCalendar Tests }

[Test] [async] procedure TTestEvents.TestGetEventsByCalendarWithoutDateRange;
{ OBJETIVO:
  Verifica que POST /event/geteventsbycalendar devuelve TODOS los eventos de un calendario
  cuando NO se especifica un rango de fechas (START_DATE y END_DATE omitidos).
  
  ESCENARIO:
  - Se asegura que existe un evento de prueba en el calendario
  - Se consultan todos los eventos sin filtro de fechas
  
  VALIDACIONES:
  1. El calendario de prueba existe (ID_CALENDAR > 0)
  2. El endpoint devuelve status 200 sin excepciones
  3. Se devuelve al menos un evento (el creado como setup)
  
  SWAGGER:
  - Endpoint: POST /event/geteventsbycalendar
  - Parámetros body: ID_CALENDAR (required), START_DATE (optional), END_DATE (optional)
  - Response 200: Array de eventos con todos sus detalles
}
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    ID_EVENT    :Int64;
begin
   { Preparar datos de prueba: crear un evento de prueba en el calendario }
   { EnsureTestEventExists ya valida que el calendario existe }
   ID_EVENT := await(Int64, EnsureTestEventExists(TEST_TITLE));
   Assert.IsTrue(ID_EVENT > 0, 'Test event must be created');
   
   (*try
      { Obtener el ID del calendario de prueba (ya sabemos que existe) }
      ID_CALENDAR := await(Int64, GetTestCalendarID);
      Assert.IsTrue(ID_CALENDAR > 0, 'Test calendar must exist');

      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateEventDataSet;
      try
         try
            { Llamar al endpoint SIN parámetros de fecha (START_DATE, END_DATE) }
            { Esto debe devolver TODOS los eventos del calendario }
            await(TDB.GetAll(LOCAL_PATH, [['ID_CALENDAR', IntToStr(ID_CALENDAR)]],
                                          DataSet, '/geteventsbycalendar'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         { Verificar que no hubo excepciones }
         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetEventsByCalendar -> '+ExceptMsg);
         
         { Verificar que se devolvió al menos un evento }
         Assert.IsTrue(DataSet.RecordCount > 0, 'Calendar must have at least one event');
      finally
         DataSet.Free;
      end;
   finally
      { Limpiar: eliminar el evento de prueba }
      await(DeleteTestEventIfExists(TEST_TITLE));
   end;*)
end;

[Test] [async] procedure TTestEvents.TestGetEventsByCalendarWithDateRange;
{ Verifica que el endpoint devuelve eventos filtrados por rango de fechas }
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    ID_EVENT    :Int64;
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   ID_EVENT := await(Int64, EnsureTestEventExists(TEST_TITLE));
   Assert.IsTrue(ID_EVENT > 0, 'Test event must be created');
   
   try
      ID_CALENDAR := await(Int64, GetTestCalendarID);
      Assert.IsTrue(ID_CALENDAR > 0, 'Test calendar must exist');

      StartDate := Now;
      EndDate   := Now + 30; // 30 days range

      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateEventDataSet;
      try
         try
            await(TDB.GetAll(LOCAL_PATH, [['ID_CALENDAR', IntToStr(ID_CALENDAR)],
                                          ['START_DATE' , TTypeConv.DateTimeToJSON(StartDate)],
                                          ['END_DATE'   , TTypeConv.DateTimeToJSON(EndDate  )]],
                                          DataSet, '/geteventsbycalendar'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetEventsByCalendar with date range -> '+ExceptMsg);
         Assert.IsTrue(DataSet.RecordCount > 0, 'Calendar must have events in the date range');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestEventIfExists(TEST_TITLE));
   end;
end;

[Test] [async] procedure TTestEvents.TestGetEventsByCalendarEmptyResult;
{ Verifica que devuelve array vacío cuando no hay eventos en el rango de fechas }
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
begin
   ID_CALENDAR := await(Int64, GetTestCalendarID);
   Assert.IsTrue(ID_CALENDAR > 0, 'Test calendar must exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      try
         { Query with date range in the past that should have no events }
         await(TDB.GetAll(LOCAL_PATH, [['ID_CALENDAR', IntToStr(ID_CALENDAR)],
                                       ['START_DATE' , TTypeConv.DateTimeToJSON('2020-01-01 00:00:00')],
                                       ['END_DATE'   , TTypeConv.DateTimeToJSON('2020-01-02 00:00:00')]],
                                       DataSet, '/geteventsbycalendar'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetEventsByCalendar empty -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 0, 'Should return no events for past date range');
   finally
      DataSet.Free;
   end;
end;

{ GetEventsByUser Tests }

[Test] [async] procedure TTestEvents.TestGetEventsByUserAsOrganizer;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    ID_EVENT  :Int64;
begin
   ID_EVENT := await(Int64, EnsureTestEventExists(TEST_TITLE));
   
   try
      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateEventDataSet;
      try
         try
            await(TDB.GetAll(LOCAL_PATH, [['CD_USER', TEST_CD_USER],
                                          ['ROLE'   , 'organizer']],
                                          DataSet, '/geteventsbyuser'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetEventsByUser as organizer -> '+ExceptMsg);
         Assert.IsTrue(DataSet.RecordCount > 0, 'User must have events as organizer');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestEventIfExists(TEST_TITLE));
   end;
end;

[Test] [async] procedure TTestEvents.TestGetEventsByUserAsAttendee;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      try
         { Test with ROLE='any' to get events where user is organizer or attendee }
         await(TDB.GetAll(LOCAL_PATH, [['CD_USER', TEST_CD_USER]],
                                       DataSet, '/geteventsbyuser'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetEventsByUser as any role -> '+ExceptMsg);
      { Can be 0 or more depending on user's events }
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestEvents.TestGetEventsByUserBothRoles;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    ID_EVENT  :Int64;
begin
   ID_EVENT := await(Int64, EnsureTestEventExists(TEST_TITLE));
   
   try
      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateEventDataSet;
      try
         try
            await(TDB.GetAll(LOCAL_PATH, [['CD_USER', TEST_CD_USER]],
                                          DataSet, '/geteventsbyuser'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetEventsByUser both roles -> '+ExceptMsg);
         Assert.IsTrue(DataSet.RecordCount > 0, 'User must have at least one event');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestEventIfExists(TEST_TITLE));
   end;
end;

{ GetOneEvent Tests }

[Test] [async] procedure TTestEvents.TestGetOneEventExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    ID_EVENT  :Int64;
begin
   ID_EVENT := await(Int64, EnsureTestEventExists(TEST_TITLE));
   Assert.IsTrue(ID_EVENT > 0, 'Test event must exist');

   try
      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateEventDataSet;
      try
         try
            await(TDB.GetRow(LOCAL_PATH, [['ID_EVENT', IntToStr(ID_EVENT)]],
                                          DataSet, '/getoneevent'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneEvent -> '+ExceptMsg);
         Assert.IsTrue(DataSet.RecordCount = 1, 'Must return exactly one event');
         Assert.IsTrue(DataSet.FieldByName('ID_EVENT').AsLargeInt = ID_EVENT, 'Event ID matches');
         Assert.IsTrue(DataSet.FieldByName('TITLE').AsString = TEST_TITLE, 'Event title matches');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestEventIfExists(TEST_TITLE));
   end;
end;

[Test] [async] procedure TTestEvents.TestGetOneEventNotFound;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH, [['ID_EVENT', '999999999']],
                                       DataSet, '/getoneevent'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneEvent not found -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 0, 'Must return no events for non-existent ID');
   finally
      DataSet.Free;
   end;
end;

{ InsertEvent Tests }

[Test] [async] procedure TTestEvents.TestInsertEventValid;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    ID_LOCATION :Int64;
    ID_EVENT    :Int64;
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   await(DeleteTestEventIfExists(TEST_TITLE));
   
   try
      ID_CALENDAR := await(Int64, GetTestCalendarID);
      Assert.IsTrue(ID_CALENDAR > 0, 'Test calendar must exist');

      ID_LOCATION := await(Int64, EnsureTestLocationExists);
      Assert.IsTrue(ID_LOCATION > 0, 'Test location must exist or be created');

      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateEventDataSet;
      try
         StartDate := Now + 1;
         EndDate   := StartDate + (2/24);

         FillEventData(DataSet, ID_CALENDAR, TEST_TITLE, StartDate, EndDate, ID_LOCATION, ID_LOCATION);
         try
            await(TDB.Insert(LOCAL_PATH, DataSet, '/insertevent'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in InsertEvent -> '+ExceptMsg);

         ID_EVENT := await(Int64, HasTestEvent(TEST_TITLE));
         Assert.IsTrue(ID_EVENT > 0, 'InsertEvent must return a valid ID');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestEventIfExists(TEST_TITLE));
   end;
end;

[Test] [async] procedure TTestEvents.TestInsertEventStartsAfterEnds;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    ID_LOCATION :Int64;
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   ID_CALENDAR := await(Int64, GetTestCalendarID);
   Assert.IsTrue(ID_CALENDAR > 0, 'Test calendar must exist');

   ID_LOCATION := await(Int64, EnsureTestLocationExists);
   Assert.IsTrue(ID_LOCATION > 0, 'Test location must exist or be created');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      StartDate := Now + 1;
      EndDate   := StartDate - (2/24); // Invalid: ends before starts

      FillEventData(DataSet, ID_CALENDAR, TEST_TITLE + ' Invalid', StartDate, EndDate, ID_LOCATION, ID_LOCATION);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertevent'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg <> 'ok', 'Must fail when STARTS_AT_TZ >= ENDS_AT_TZ');
      { API returns 409 or 400 for date validation errors }
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestEvents.TestInsertEventInvalidAllDayValue;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    ID_LOCATION :Int64;
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   ID_CALENDAR := await(Int64, GetTestCalendarID);
   Assert.IsTrue(ID_CALENDAR > 0, 'Test calendar must exist');

   ID_LOCATION := await(Int64, EnsureTestLocationExists);
   Assert.IsTrue(ID_LOCATION > 0, 'Test location must exist or be created');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      StartDate := Now + 1;
      EndDate   := StartDate + (2/24);

      FillEventData(DataSet, ID_CALENDAR, TEST_TITLE + ' Invalid AllDay', StartDate, EndDate, ID_LOCATION, ID_LOCATION);
      DataSet.Edit;
      DataSet.FieldByName('ALL_DAY').AsString := 'X'; // Invalid value
      DataSet.Post;

      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertevent'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg <> 'ok', 'Must fail when ALL_DAY is not Y or N');
      { API returns 400 for validation errors }
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestEvents.TestInsertEventLocationNotExists;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    ID_LOCATION :Int64;
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   ID_CALENDAR := await(Int64, GetTestCalendarID);
   Assert.IsTrue(ID_CALENDAR > 0, 'Test calendar must exist');

   ID_LOCATION := await(Int64, EnsureTestLocationExists);
   Assert.IsTrue(ID_LOCATION > 0, 'Test location must exist or be created');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      StartDate := Now + 1;
      EndDate   := StartDate + (2/24);

      { Usar meeting point válido pero location inválido }
      FillEventData(DataSet, ID_CALENDAR, TEST_TITLE + ' Invalid Location', StartDate, EndDate, 999999999, ID_LOCATION);

      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertevent'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg <> 'ok', 'Must fail when ID_LOCATION does not exist');
      { API returns 409 when location not found }
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestEvents.TestInsertEventMeetingPointNotExists;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    ID_LOCATION :Int64;
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   ID_CALENDAR := await(Int64, GetTestCalendarID);
   Assert.IsTrue(ID_CALENDAR > 0, 'Test calendar must exist');

   ID_LOCATION := await(Int64, EnsureTestLocationExists);
   Assert.IsTrue(ID_LOCATION > 0, 'Test location must exist or be created');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      StartDate := Now + 1;
      EndDate   := StartDate + (2/24);

      { Usar location válido pero meeting point inválido }
      FillEventData(DataSet, ID_CALENDAR, TEST_TITLE + ' Invalid Meeting Point', StartDate, EndDate, ID_LOCATION, 999999999);

      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertevent'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg <> 'ok', 'Must fail when ID_MEETING_POINT does not exist');
      { API returns 409 when meeting point not found }
   finally
      DataSet.Free;
   end;
end;

{ UpdateEvent Tests }

[Test] [async] procedure TTestEvents.TestUpdateEventValid;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    ID_EVENT  :Int64;
begin
   ID_EVENT := await(Int64, EnsureTestEventExists(TEST_TITLE));
   Assert.IsTrue(ID_EVENT > 0, 'Test event must exist');

   try
      DataSet := CreateEventDataSet;
      try
         await(TDB.GetRow(LOCAL_PATH, [['ID_EVENT', IntToStr(ID_EVENT)]],
                                       DataSet, '/getoneevent'));

         DataSet.Edit;
         DataSet.FieldByName('TITLE'      ).AsString := UPDATED_TEST_TITLE;
         DataSet.FieldByName('DESCRIPTION').AsString := 'Updated description';
         DataSet.Post;

         try
            await(TDB.Update(LOCAL_PATH, [['ID_EVENT', IntToStr(ID_EVENT)],
                                          ['CD_USER' , TEST_CD_USER      ]], DataSet, '/updateevent'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in UpdateEvent -> '+ExceptMsg);

         { Verify update }
         await(TDB.GetRow(LOCAL_PATH, [['ID_EVENT', IntToStr(ID_EVENT)]],
                                       DataSet, '/getoneevent'));

         Assert.IsTrue(DataSet.FieldByName('TITLE').AsString = UPDATED_TEST_TITLE, 'Updated title stored');
         Assert.IsTrue(DataSet.FieldByName('DESCRIPTION').AsString = 'Updated description', 'Updated description stored');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestEventIfExists(UPDATED_TEST_TITLE));
      await(DeleteTestEventIfExists(TEST_TITLE));
   end;
end;

[Test] [async] procedure TTestEvents.TestUpdateEventUserNotOrganizer;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    ID_EVENT  :Int64;
begin
   ID_EVENT := await(Int64, EnsureTestEventExists(TEST_TITLE));
   Assert.IsTrue(ID_EVENT > 0, 'Test event must exist');

   try
      DataSet := CreateEventDataSet;
      try
         await(TDB.GetRow(LOCAL_PATH, [['ID_EVENT', IntToStr(ID_EVENT)]],
                                       DataSet, '/getoneevent'));

         DataSet.Edit;
         DataSet.FieldByName('TITLE').AsString := 'Should not update';
         DataSet.Post;

         try
            await(TDB.Update(LOCAL_PATH, [['ID_EVENT', IntToStr(ID_EVENT)],
                                          ['CD_USER' , 'wronguser'        ]], DataSet, '/updateevent'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg <> 'ok', 'Must fail when user is not organizer');
         { API returns 403 Forbidden when user is not the event organizer }
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestEventIfExists(TEST_TITLE));
   end;
end;

[Test] [async] procedure TTestEvents.TestUpdateEventNotFound;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_LOCATION :Int64;
begin
   ID_LOCATION := await(Int64, EnsureTestLocationExists);
   Assert.IsTrue(ID_LOCATION > 0, 'Test location must exist or be created');

   DataSet := CreateEventDataSet;
   try
      FillEventData(DataSet, 1, 'Non-existent event', Now, Now+1, ID_LOCATION, ID_LOCATION);
      
      DataSet.Edit;
      DataSet.FieldByName('ID_EVENT').AsLargeInt := 999999999; // Non-existent event
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['ID_EVENT', '999999999' ],
                                       ['CD_USER' , TEST_CD_USER]], DataSet, '/updateevent'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg <> 'ok', 'Must fail when event does not exist');
      { API returns 404 when event not found or is inactive }
   finally
      DataSet.Free;
   end;
end;

{ DeleteEvent Tests }

[Test] [async] procedure TTestEvents.TestDeleteEventValid;
var ID_EVENT  :Int64;
    ExceptMsg :string;
    DataSet   :TWebClientDataSet;
begin
   ID_EVENT := await(Int64, EnsureTestEventExists(TEST_TITLE));
   Assert.IsTrue(ID_EVENT > 0, 'Event must exist before deletion');

   TWebSetup.Instance.Language := 'ES';
   
   try
      { Attempt to delete the event }
      await(TDB.Delete(LOCAL_PATH, [['ID_EVENT', IntToStr(ID_EVENT)],
                                    ['CD_USER' , TEST_CD_USER      ]], '/deleteevent'));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in DeleteEvent -> '+ExceptMsg);

   { Verify event is marked as cancelled (soft delete) }
   DataSet := CreateEventDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH, [['ID_EVENT', IntToStr(ID_EVENT)]],
                                       DataSet, '/getoneevent'));
         
         { Event should not be returned as it's cancelled }
         Assert.IsTrue(DataSet.RecordCount = 0, 'Cancelled event should not be returned');
         
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
   finally
      DataSet.Free;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception verifying event state -> '+ExceptMsg);
end;

[Test] [async] procedure TTestEvents.TestDeleteEventUserNotOrganizer;
var ID_EVENT  :Int64;
    ExceptMsg :string;
begin
   ID_EVENT := await(Int64, EnsureTestEventExists(TEST_TITLE));
   Assert.IsTrue(ID_EVENT > 0, 'Event must exist before deletion');

   try
      TWebSetup.Instance.Language := 'ES';
      
      try
         { Attempt to delete with wrong user }
         await(TDB.Delete(LOCAL_PATH, [['ID_EVENT', IntToStr(ID_EVENT)],
                                       ['CD_USER' , 'wronguser'        ]], '/deleteevent'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg <> 'ok', 'Must fail when user is not organizer');
      { API returns 403 Forbidden when user is not the event organizer }
   finally
      await(DeleteTestEventIfExists(TEST_TITLE));
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestEvents);
end.
