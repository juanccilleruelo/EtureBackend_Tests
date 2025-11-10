unit TestCalendarEvents;

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
   TTestCalendarEvents = class(TObject)
   private
      const LOCAL_PATH            = '/calendarevents';
      const TEST_EVENT_ID         = 'UT_CALENDAR_EVENT_0001';
      const TEST_USER_CODE        = 'PLAYERUS';
      const TEST_EVENT_TITLE      = 'Unit Test Calendar Event';
      const UPDATED_EVENT_TITLE   = 'Unit Test Calendar Event - Updated';
      var CreatedID_EVENT :string;
      var StartDate       :TDateTime;
   private
      function CreateEventsDataSet:TWebClientDataSet;
      procedure FillEventData(ADataSet :TWebClientDataSet;
                              const ATitle :string;
                              const AStartDate, AEndDate :TDateTime);
      [async] function HasTestEvent:Boolean;
      [async] procedure EnsureTestEventExists;
      [async] procedure DeleteTestEventIfExists;
      [async] function  GetTheLastOne:string;
   published
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestLoad;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestUpdate;
      [Test] [async] procedure TestIsReferenced;
      [Test] [async] procedure TestDelete;
      [Test] [async] procedure TestGetOrderByFields;
      [Test] [async] procedure TestLoadNextCalendarEvents;
      [Test] [async] procedure TestLoadDayEvents;
      [Test] [async] procedure TestGetEngagementTypes;
      [Test] [async] procedure TestGetVisibilities;
      [Test] [async] procedure TestGetPriorities;
      [Test] [async] procedure TestGetStates;
   end;
{$M-}

implementation

uses System.DateUtils, senCille.DataManagement, senCille.TypeConverter;

{ TTestCalendarEvents }

function TTestCalendarEvents.CreateEventsDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'ID_EVENT';
   NewField.Size        := 36;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_USER';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_USER_CREATOR';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'ENGAGEMENT_TYPE';
   NewField.Size        := 1;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_EVENT';
   NewField.Size        := 150;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'EVENT_NOTES';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TDateTimeField.Create(Result);
   NewField.FieldName   := 'DT_START';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DT_START_DATE';
   NewField.Size        := 10;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DT_START_TIME';
   NewField.Size        := 5;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TDateTimeField.Create(Result);
   NewField.FieldName   := 'DT_END';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DT_END_DATE';
   NewField.Size        := 10;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DT_END_TIME';
   NewField.Size        := 5;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'LOCATION';
   NewField.Size        := 150;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CATEGORY';
   NewField.Size        := 150;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'VISIBILITY';
   NewField.Size        := 1;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'PRIORITY';
   NewField.Size        := 1;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'STATE';
   NewField.Size        := 1;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

procedure TTestCalendarEvents.FillEventData(ADataSet :TWebClientDataSet;
                                            const ATitle :string;
                                            const AStartDate, AEndDate :TDateTime);
begin
   ADataSet.Append;
   ADataSet.FieldByName('ID_EVENT').AsString         := TEST_EVENT_ID;
   ADataSet.FieldByName('CD_USER').AsString          := TEST_USER_CODE;
   ADataSet.FieldByName('CD_USER_CREATOR').AsString  := TEST_USER_CODE;
   ADataSet.FieldByName('ENGAGEMENT_TYPE').AsString  := 'M';
   ADataSet.FieldByName('DS_EVENT').AsString         := ATitle;
   ADataSet.FieldByName('EVENT_NOTES').AsString      := 'Automated test event';
   ADataSet.FieldByName('DT_START').AsDateTime       := AStartDate;
   ADataSet.FieldByName('DT_START_DATE').AsString    := FormatDateTime('yyyy-mm-dd', AStartDate);
   ADataSet.FieldByName('DT_START_TIME').AsString    := FormatDateTime('hh:nn', AStartDate);
   ADataSet.FieldByName('DT_END').AsDateTime         := AEndDate;
   ADataSet.FieldByName('DT_END_DATE').AsString      := FormatDateTime('yyyy-mm-dd', AEndDate);
   ADataSet.FieldByName('DT_END_TIME').AsString      := FormatDateTime('hh:nn', AEndDate);
   ADataSet.FieldByName('LOCATION').AsString         := 'Virtual';
   ADataSet.FieldByName('CATEGORY').AsString         := 'Automation';
   ADataSet.FieldByName('VISIBILITY').AsString       := 'P';
   ADataSet.FieldByName('PRIORITY').AsString         := 'N';
   ADataSet.FieldByName('STATE').AsString            := 'A';
   ADataSet.Post;
end;

[async] function TTestCalendarEvents.HasTestEvent:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateEventsDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['ID_EVENT', TEST_EVENT_ID]],
                          DataSet));
      except
         on E:Exception do begin
            if DataSet.Active then begin
               DataSet.EmptyDataSet;
            end;
         end;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestCalendarEvents.EnsureTestEventExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    EndDate   :TDateTime;
    Exists    :Boolean;
begin
   StartDate := RecodeTime(IncDay(Date, 1), 9, 0, 0, 0);
   EndDate   := StartDate + EncodeTime(1, 0, 0, 0);
   Exists    := await(Boolean, HasTestEvent());

   if Exists then begin
      DataSet := CreateEventsDataSet;
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['ID_EVENT', TEST_EVENT_ID]],
                          DataSet));
         CreatedID_EVENT := DataSet.FieldByName('ID_EVENT').AsString;
         if DataSet.FieldByName('DT_START').AsDateTime < StartDate then begin
            DataSet.Edit;
            DataSet.FieldByName('DT_START').AsDateTime := StartDate;
            DataSet.FieldByName('DT_START_DATE').AsString := FormatDateTime('yyyy-mm-dd', StartDate);
            DataSet.FieldByName('DT_START_TIME').AsString := FormatDateTime('hh:nn', StartDate);
            DataSet.FieldByName('DT_END').AsDateTime := EndDate;
            DataSet.FieldByName('DT_END_DATE').AsString := FormatDateTime('yyyy-mm-dd', EndDate);
            DataSet.FieldByName('DT_END_TIME').AsString := FormatDateTime('hh:nn', EndDate);
            DataSet.Post;
            ExceptMsg := 'ok';
            try
               await(TDB.Update(LOCAL_PATH, [['ID_EVENT', CreatedID_EVENT], ['OLD_ID_EVENT', CreatedID_EVENT]], DataSet));
            except
               on E:Exception do begin
                  ExceptMsg := E.Message;
               end;
            end;
            Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestEventExists -> '+ExceptMsg);
         end;
      finally
         DataSet.Free;
      end;
      Exit;
   end;

   DataSet := CreateEventsDataSet;
   try
      FillEventData(DataSet, TEST_EVENT_TITLE, StartDate, EndDate);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestEventExists -> '+ExceptMsg);
      if ExceptMsg = 'ok' then begin
         CreatedID_EVENT := TEST_EVENT_ID;
      end;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestCalendarEvents.DeleteTestEventIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['ID_EVENT', CreatedID_EVENT]]));
   except
      on E:Exception do begin
         ;
      end;
   end;
end;

[async] function TTestCalendarEvents.GetTheLastOne:string;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateEventsDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['ID_EVENT', TEST_EVENT_ID]],
                          DataSet, '/getthelastone'));
      except
         on E:Exception do begin
            if DataSet.Active then begin
               DataSet.EmptyDataSet;
            end;
         end;
      end;
      Result := DataSet.FieldByName('ID_EVENT').AsString;
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCalendarEvents.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    StartDate :TDateTime;
begin
   await(DeleteTestEventIfExists());

   DataSet := CreateEventsDataSet;
   try
      StartDate := Now;
      FillEventData(DataSet, TEST_EVENT_TITLE, StartDate, StartDate + EncodeTime(2, 0, 0, 0));
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Insert -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCalendarEvents.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    StartDate :TDate; {The Date in witch starts the representation}
    EndDate   :TDate; {The Date in witch starts the representation}
    Count     :Integer;
begin
   await(EnsureTestEventExists());
   CreatedID_EVENT := await(string, GetTheLastOne);

   StartDate := EncodeDate(2020, 1     , 1 );  {First Day of the year  }
   EndDate   := EncodeDate(2040, 12    , 31);  {Last  Day of the year  }

   DataSet := CreateEventsDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['ID_EVENT', CreatedID_EVENT]],
                           DataSet)
                          );

         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount > 0, 'Load must return rows');
      Assert.IsTrue(DataSet.Locate('ID_EVENT', CreatedID_EVENT, []), 'Test event located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCalendarEvents.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestEventExists());

   DataSet := CreateEventsDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['ID_EVENT', CreatedID_EVENT]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one event retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_EVENT').AsString = TEST_EVENT_TITLE, 'Event title matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCalendarEvents.TestGetAll;
var JSONArray :TJSONArray;
    ExceptMsg :string;
begin
   await(EnsureTestEventExists());

   try
      JSONArray := await(TJSONArray, TDB.GetJSONArray(LOCAL_PATH, [], '/getall'));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
         JSONArray := nil;
      end;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll -> '+ExceptMsg);
   Assert.IsTrue((JSONArray <> nil) and (JSONArray.Count > 0), 'GetAll must provide data');
end;

[Test] [async] procedure TTestCalendarEvents.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestEventExists());

   DataSet := CreateEventsDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['ID_EVENT', CreatedID_EVENT]],
                       DataSet));
      DataSet.Edit;
      DataSet.FieldByName('DS_EVENT').AsString := UPDATED_EVENT_TITLE;
      DataSet.Post;
      try
         await(TDB.Update(LOCAL_PATH, [['ID_EVENT', CreatedID_EVENT], ['OLD_ID_EVENT', CreatedID_EVENT]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
         end;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);
      await(TDB.GetRow(LOCAL_PATH,
                       [['ID_EVENT', CreatedID_EVENT]],
                       DataSet));
      Assert.IsTrue(DataSet.FieldByName('DS_EVENT').AsString = UPDATED_EVENT_TITLE, 'Updated event title stored correctly');
      DataSet.Edit;
      DataSet.FieldByName('DS_EVENT').AsString := TEST_EVENT_TITLE;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH, [['ID_EVENT', CreatedID_EVENT], ['OLD_ID_EVENT', CreatedID_EVENT]], DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCalendarEvents.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    ExceptMsg    :string;
    TextMessage  :string;
    IsReferenced :Boolean;
begin
   await(EnsureTestEventExists());

   DataSet := CreateEventsDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['ID_EVENT', CreatedID_EVENT]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do begin
            ExceptMsg := E.Message;
            IsReferenced := True;
         end;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test event should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCalendarEvents.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestEventExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['ID_EVENT', CreatedID_EVENT]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
      end;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateEventsDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['ID_EVENT', CreatedID_EVENT]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Event should have been removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestCalendarEvents.TestGetOrderByFields;
var JSONArray :TJSONArray;
    ExceptMsg :string;
begin
   try
      JSONArray := await(TJSONArray, TDB.GetJSONArray(LOCAL_PATH, [], '/getorderbyfields'));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
         JSONArray := nil;
      end;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOrderByFields -> '+ExceptMsg);
   {Currently there are not ORDER BY FIELDS for this table }
   Assert.IsTrue((JSONArray <> nil) and (JSONArray.Count = 0), 'Order by fields must be provided');
end;

[Test] [async] procedure TTestCalendarEvents.TestLoadNextCalendarEvents;
var JSONArray  :TJSONArray;
    ExceptMsg  :string;
    TargetDate :string;
begin
   await(EnsureTestEventExists());

   TargetDate := TTypeConv.DateTimeToJSON(StartDate -10);
   try
      JSONArray := await(TJSONArray, TDB.GetJSONArray(LOCAL_PATH ,
                                                      [['CD_USER', TEST_USER_CODE],
                                                       ['DATE'   , TargetDate    ]],
                                                      '/loadnextcalendarevents'));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
         JSONArray := nil;
      end;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in LoadNextCalendarEvents -> '+ExceptMsg);
   Assert.IsTrue((JSONArray <> nil) and (JSONArray.Count > 0), 'LoadNextCalendarEvents must return upcoming events');
end;

[Test] [async] procedure TTestCalendarEvents.TestLoadDayEvents;
var JSONArray  :TJSONArray;
    ExceptMsg  :string;
    TargetDate :string;
begin
   await(EnsureTestEventExists());

   TargetDate := FormatDateTime('yyyy-mm-dd', Now);
   try
      JSONArray := await(TJSONArray, TDB.GetJSONArray(LOCAL_PATH,
                           [['CD_USER', TEST_USER_CODE],
                            ['TargetDate', TargetDate]],
                           '/loaddayevents'));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
         JSONArray := nil;
      end;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in LoadDayEvents -> '+ExceptMsg);
   Assert.IsTrue((JSONArray <> nil) and (JSONArray.Count > 0), 'LoadDayEvents must return daily events');
end;

[Test] [async] procedure TTestCalendarEvents.TestGetEngagementTypes;
var JSONArray :TJSONArray;
    ExceptMsg :string;
begin
   try
      JSONArray := await(TJSONArray, TDB.GetJSONArray(LOCAL_PATH, [], '/getengagementtypes'));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
         JSONArray := nil;
      end;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetEngagementTypes -> '+ExceptMsg);
   Assert.IsTrue((JSONArray <> nil) and (JSONArray.Count > 0), 'Engagement types list must not be empty');
end;

[Test] [async] procedure TTestCalendarEvents.TestGetVisibilities;
var JSONArray :TJSONArray;
    ExceptMsg :string;
begin
   try
      JSONArray := await(TJSONArray, TDB.GetJSONArray(LOCAL_PATH, [], '/getvisibilities'));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
         JSONArray := nil;
      end;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetVisibilities -> '+ExceptMsg);
   Assert.IsTrue((JSONArray <> nil) and (JSONArray.Count > 0), 'Visibilities list must not be empty');
end;

[Test] [async] procedure TTestCalendarEvents.TestGetPriorities;
var JSONArray :TJSONArray;
    ExceptMsg :string;
begin
   try
      JSONArray := await(TJSONArray, TDB.GetJSONArray(LOCAL_PATH, [], '/getpriorities'));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
         JSONArray := nil;
      end;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetPriorities -> '+ExceptMsg);
   Assert.IsTrue((JSONArray <> nil) and (JSONArray.Count > 0), 'Priorities list must not be empty');
end;

[Test] [async] procedure TTestCalendarEvents.TestGetStates;
var JSONArray :TJSONArray;
    ExceptMsg :string;
begin
   try
      JSONArray := await(TJSONArray, TDB.GetJSONArray(LOCAL_PATH, [], '/getstates'));
      ExceptMsg := 'ok';
   except
      on E:Exception do begin
         ExceptMsg := E.Message;
         JSONArray := nil;
      end;
   end;
   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetStates -> '+ExceptMsg);
   Assert.IsTrue((JSONArray <> nil) and (JSONArray.Count > 0), 'States list must not be empty');
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestCalendarEvents);

end.
