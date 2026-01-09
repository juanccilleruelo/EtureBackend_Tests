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
      const TEST_ID_LOCATION       = 1;
      const TEST_ID_MEETING_POINT  = 1;
   private
      function CreateEventDataSet:TWebClientDataSet;
      procedure FillEventData(ADataSet :TWebClientDataSet; const AID_CALENDAR :Int64; const ATitle :string; const AStartsAt, AEndsAt :TDateTime);
      [async] function GetTestCalendarID:Int64;
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

procedure TTestEvents.FillEventData(ADataSet :TWebClientDataSet; const AID_CALENDAR :Int64; const ATitle :string; const AStartsAt, AEndsAt :TDateTime);
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
   ADataSet.FieldByName('ID_LOCATION'     ).AsLargeInt := TEST_ID_LOCATION;
   ADataSet.FieldByName('ID_MEETING_POINT').AsLargeInt := TEST_ID_MEETING_POINT;
   ADataSet.FieldByName('ST'              ).AsString   := 'A';

   ADataSet.Post;
end;

[async] function TTestEvents.GetTestCalendarID:Int64;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   Result := -1;
   TWebSetup.Instance.Language := 'ES';
   DataSet := TWebClientDataSet.Create(nil);
   try
      try
         await(TDB.GetRow('/schedule', [['CD_USER'    , TEST_CD_USER],
                                        ['DS_CALENDAR', 'Unit Test Calendar']],
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

[async] function TTestEvents.HasTestEvent(const ATitle :string):Int64;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   Result := -1;
   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      try
         await(TDB.GetAll(LOCAL_PATH, [['CD_USER', TEST_CD_USER]],
                                       DataSet, '/geteventsbyuser'));

         DataSet.First;
         while not DataSet.Eof do begin
            if DataSet.FieldByName('TITLE').AsString = ATitle then begin
               Result := DataSet.FieldByName('ID_EVENT').AsLargeInt;
               Break;
            end;
            DataSet.Next;
         end;

         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
   finally
      DataSet.Free;
   end;
end;

[async] function TTestEvents.EnsureTestEventExists(const ATitle :string):Int64;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   Result := await(Int64, HasTestEvent(ATitle));
   if Result <> -1 then Exit;

   ID_CALENDAR := await(Int64, GetTestCalendarID);
   if ID_CALENDAR = -1 then
      raise Exception.Create('Test calendar does not exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      StartDate := Now + 1;
      EndDate   := StartDate + (2/24); // 2 hours later

      FillEventData(DataSet, ID_CALENDAR, ATitle, StartDate, EndDate);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertevent'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestEventExists -> '+ExceptMsg);
      
      Result := await(Int64, HasTestEvent(ATitle));
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestEvents.DeleteTestEventIfExists(const ATitle :string);
var ID_EVENT :Int64;
begin
   ID_EVENT := await(Int64, HasTestEvent(ATitle));
   if ID_EVENT > -1 then begin
      try
         await(TDB.Delete(LOCAL_PATH, [['ID_EVENT', IntToStr(ID_EVENT)],
                                       ['CD_USER' , TEST_CD_USER      ]], '/deleteevent'));
      except
         on E:Exception do ;
      end;
   end;
end;

{ GetEventsByCalendar Tests }

[Test] [async] procedure TTestEvents.TestGetEventsByCalendarWithoutDateRange;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    ID_EVENT    :Int64;
begin
   ID_EVENT := await(Int64, EnsureTestEventExists(TEST_TITLE));
   
   try
      ID_CALENDAR := await(Int64, GetTestCalendarID);
      Assert.IsTrue(ID_CALENDAR > -1, 'Test calendar must exist');

      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateEventDataSet;
      try
         try
            await(TDB.GetAll(LOCAL_PATH, [['ID_CALENDAR', IntToStr(ID_CALENDAR)]],
                                          DataSet, '/geteventsbycalendar'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetEventsByCalendar -> '+ExceptMsg);
         Assert.IsTrue(DataSet.RecordCount > 0, 'Calendar must have at least one event');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestEventIfExists(TEST_TITLE));
   end;
end;

[Test] [async] procedure TTestEvents.TestGetEventsByCalendarWithDateRange;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    ID_EVENT    :Int64;
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   ID_EVENT := await(Int64, EnsureTestEventExists(TEST_TITLE));
   
   try
      ID_CALENDAR := await(Int64, GetTestCalendarID);
      Assert.IsTrue(ID_CALENDAR > -1, 'Test calendar must exist');

      StartDate := Now;
      EndDate   := Now + 30; // 30 days range

      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateEventDataSet;
      try
         try
            await(TDB.GetAll(LOCAL_PATH, [['ID_CALENDAR', IntToStr(ID_CALENDAR)],
                                          ['START_DATE' , FormatDateTime('yyyy-mm-dd hh:nn:ss', StartDate)],
                                          ['END_DATE'   , FormatDateTime('yyyy-mm-dd hh:nn:ss', EndDate)]],
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
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
begin
   ID_CALENDAR := await(Int64, GetTestCalendarID);
   Assert.IsTrue(ID_CALENDAR > -1, 'Test calendar must exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      try
         { Query with date range in the past that should have no events }
         await(TDB.GetAll(LOCAL_PATH, [['ID_CALENDAR', IntToStr(ID_CALENDAR)],
                                       ['START_DATE' , '2020-01-01 00:00:00'],
                                       ['END_DATE'   , '2020-01-02 00:00:00']],
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
         await(TDB.GetAll(LOCAL_PATH, [['CD_USER', TEST_CD_USER],
                                       ['ROLE'   , 'attendee']],
                                       DataSet, '/geteventsbyuser'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetEventsByUser as attendee -> '+ExceptMsg);
      { Can be 0 if user has no invitations }
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
   Assert.IsTrue(ID_EVENT > -1, 'Test event must exist');

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
    ID_EVENT    :Int64;
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   await(DeleteTestEventIfExists(TEST_TITLE));
   
   try
      ID_CALENDAR := await(Int64, GetTestCalendarID);
      Assert.IsTrue(ID_CALENDAR > -1, 'Test calendar must exist');

      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateEventDataSet;
      try
         StartDate := Now + 1;
         EndDate   := StartDate + (2/24);

         FillEventData(DataSet, ID_CALENDAR, TEST_TITLE, StartDate, EndDate);
         try
            await(TDB.Insert(LOCAL_PATH, DataSet, '/insertevent'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in InsertEvent -> '+ExceptMsg);

         ID_EVENT := await(Int64, HasTestEvent(TEST_TITLE));
         Assert.IsTrue(ID_EVENT > -1, 'InsertEvent must return a valid ID');
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
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   ID_CALENDAR := await(Int64, GetTestCalendarID);
   Assert.IsTrue(ID_CALENDAR > -1, 'Test calendar must exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      StartDate := Now + 1;
      EndDate   := StartDate - (2/24); // Invalid: ends before starts

      FillEventData(DataSet, ID_CALENDAR, TEST_TITLE + ' Invalid', StartDate, EndDate);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertevent'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg <> 'ok', 'Must fail when STARTS_AT_TZ >= ENDS_AT_TZ');
      Assert.IsTrue(Pos('STARTS_AT_TZ', ExceptMsg) > 0, 'Error message must mention STARTS_AT_TZ');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestEvents.TestInsertEventInvalidAllDayValue;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   ID_CALENDAR := await(Int64, GetTestCalendarID);
   Assert.IsTrue(ID_CALENDAR > -1, 'Test calendar must exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      StartDate := Now + 1;
      EndDate   := StartDate + (2/24);

      FillEventData(DataSet, ID_CALENDAR, TEST_TITLE + ' Invalid AllDay', StartDate, EndDate);
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
      Assert.IsTrue(Pos('ALL_DAY', ExceptMsg) > 0, 'Error message must mention ALL_DAY');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestEvents.TestInsertEventLocationNotExists;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   ID_CALENDAR := await(Int64, GetTestCalendarID);
   Assert.IsTrue(ID_CALENDAR > -1, 'Test calendar must exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      StartDate := Now + 1;
      EndDate   := StartDate + (2/24);

      FillEventData(DataSet, ID_CALENDAR, TEST_TITLE + ' Invalid Location', StartDate, EndDate);
      DataSet.Edit;
      DataSet.FieldByName('ID_LOCATION').AsLargeInt := 999999999; // Non-existent location
      DataSet.Post;

      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertevent'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg <> 'ok', 'Must fail when ID_LOCATION does not exist');
      Assert.IsTrue(Pos('ID_LOCATION', ExceptMsg) > 0, 'Error message must mention ID_LOCATION');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestEvents.TestInsertEventMeetingPointNotExists;
var DataSet     :TWebClientDataSet;
    ExceptMsg   :string;
    ID_CALENDAR :Int64;
    StartDate   :TDateTime;
    EndDate     :TDateTime;
begin
   ID_CALENDAR := await(Int64, GetTestCalendarID);
   Assert.IsTrue(ID_CALENDAR > -1, 'Test calendar must exist');

   TWebSetup.Instance.Language := 'ES';
   DataSet := CreateEventDataSet;
   try
      StartDate := Now + 1;
      EndDate   := StartDate + (2/24);

      FillEventData(DataSet, ID_CALENDAR, TEST_TITLE + ' Invalid Meeting Point', StartDate, EndDate);
      DataSet.Edit;
      DataSet.FieldByName('ID_MEETING_POINT').AsLargeInt := 999999999; // Non-existent meeting point
      DataSet.Post;

      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertevent'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg <> 'ok', 'Must fail when ID_MEETING_POINT does not exist');
      Assert.IsTrue(Pos('ID_MEETING_POINT', ExceptMsg) > 0, 'Error message must mention ID_MEETING_POINT');
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
   Assert.IsTrue(ID_EVENT > -1, 'Test event must exist');

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
   Assert.IsTrue(ID_EVENT > -1, 'Test event must exist');

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
         Assert.IsTrue(Pos('organizer', LowerCase(ExceptMsg)) > 0, 'Error message must mention organizer');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestEventIfExists(TEST_TITLE));
   end;
end;

[Test] [async] procedure TTestEvents.TestUpdateEventNotFound;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   DataSet := CreateEventDataSet;
   try
      FillEventData(DataSet, 1, 'Non-existent event', Now, Now+1);
      
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
      Assert.IsTrue(Pos('not found', LowerCase(ExceptMsg)) > 0, 'Error message must mention not found');
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
   Assert.IsTrue(ID_EVENT > -1, 'Event must exist before deletion');

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
   Assert.IsTrue(ID_EVENT > -1, 'Event must exist before deletion');

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
      Assert.IsTrue(Pos('organizer', LowerCase(ExceptMsg)) > 0, 'Error message must mention organizer');
   finally
      await(DeleteTestEventIfExists(TEST_TITLE));
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestEvents);
end.
