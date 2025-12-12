unit TestChats;

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
   TTestChats = class(TObject)
   private
      const LOCAL_PATH         = '/chats';
      const TEST_HOST_CD_USER  = 'ADMIN';
      const TEST_GUEST_CD_USER = 'PLAYERUS';
      const TEST_TITLE         = 'Unit Test Test Chat';
      const UPDATED_TITLE      = 'Unit Test Updated Test Chat';
   private
     function CreateDataSet:TWebClientDataSet;
     function CreateMessagesDataSet:TWebClientDataSet;
     procedure FillChatData(ADataSet :TWebClientDataSet; const ATitle :string; const AChatType: string = 'DIRECT');
     [async] function HasTestChat(HostUser, GuestUser :string):Boolean;
     [async] function EnsureTestChatExists(HostUser, GuestUser :string):Int64;
     [async] procedure DeleteTestChatIfExists(HostUser, GuestUser :string);
   published
      [Test] [async] procedure TestChatExists;
      [Test] [async] procedure TestCreateNewChat;
      [Test] [async] procedure TestGetChat;
      [Test] [async] procedure TestUpdateChat;
      [Test] [async] procedure TestDeleteChat;
      [Test] [async] procedure TestGetAll;
      {----- Messages  -----}
      [Test] [async] procedure TestInsertMessage;
   end;
{$M-}

implementation

uses senCille.WebSetup, senCille.DataManagement;

{ TTestChats }

function TTestChats.CreateDataSet: TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   // CHAT_ID BIGINT
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'CHAT_ID';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

   // HOST_CD_USER VARCHAR(50)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'HOST_CD_USER';
   NewField.Size      := 50;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // CHAT_TYPE VARCHAR(20)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CHAT_TYPE';
   NewField.Size      := 20;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // TITLE VARCHAR(200)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'TITLE';
   NewField.Size      := 200;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // STATUS VARCHAR(20)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'STATUS';
   NewField.Size      := 20;
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

   // LAST_MESSAGE_AT TIMESTAMP (nullable)
   NewField := TDateTimeField.Create(Result);
   NewField.FieldName := 'LAST_MESSAGE_AT';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   // LAST_MESSAGE_ID BIGINT (nullable)
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'LAST_MESSAGE_ID';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

   // CLOSED_AT TIMESTAMP (nullable)
   NewField := TDateTimeField.Create(Result);
   NewField.FieldName := 'CLOSED_AT';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   // METADATA_JSON BLOB SUB_TYPE TEXT
   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'METADATA_JSON';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

function TTestChats.CreateMessagesDataSet: TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   // MESSAGE_ID BIGINT
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'MESSAGE_ID';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

   // CHAT_ID BIGINT
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'CHAT_ID';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

   // SENDER_CD_USER VARCHAR(50)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'SENDER_CD_USER';
   NewField.Size      := 50;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // MESSAGE_TYPE VARCHAR(20)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'MESSAGE_TYPE';
   NewField.Size      := 20;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // CONTENT_TEXT BLOB SUB_TYPE TEXT
   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'CONTENT_TEXT';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   // CONTENT_URL VARCHAR(1000)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CONTENT_URL';
   NewField.Size      := 1000;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // CONTENT_DATA BLOB SUB_TYPE BINARY
   NewField := TBlobField.Create(Result);
   NewField.FieldName := 'CONTENT_DATA';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftBlob, 0);

   // MIME_TYPE VARCHAR(100)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'MIME_TYPE';
   NewField.Size      := 100;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // FILE_NAME VARCHAR(255)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'FILE_NAME';
   NewField.Size      := 255;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // FILE_SIZE_BYTES BIGINT
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'FILE_SIZE_BYTES';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

   // REFERENCED_MESSAGE_ID BIGINT
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'REFERENCED_MESSAGE_ID';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

   // REFERENCED_CHAT_ID BIGINT
   NewField := TLargeintField.Create(Result);
   NewField.FieldName := 'REFERENCED_CHAT_ID';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftLargeint, 0);

   // SENT_AT TIMESTAMP
   NewField := TDateTimeField.Create(Result);
   NewField.FieldName := 'SENT_AT';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   // EDITED_AT TIMESTAMP
   NewField := TDateTimeField.Create(Result);
   NewField.FieldName := 'EDITED_AT';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   // DELETED_AT TIMESTAMP
   NewField := TDateTimeField.Create(Result);
   NewField.FieldName := 'DELETED_AT';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftDateTime, 0);

   // STATUS VARCHAR(20)
   NewField := TStringField.Create(Result);
   NewField.FieldName := 'STATUS';
   NewField.Size      := 20;
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   // METADATA_JSON BLOB SUB_TYPE TEXT
   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'METADATA_JSON';
   NewField.DataSet   := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestChats.FillChatData(ADataSet :TWebClientDataSet; const ATitle :string; const AChatType: string = 'DIRECT');
begin
   ADataSet.Append;

   // No se asigna CHAT_ID: lo genera el servidor / base de datos
   // ADataSet.FieldByName('CHAT_ID').Clear;

   // Usuario anfitrión del chat
   ADataSet.FieldByName('HOST_CD_USER').AsString := TEST_HOST_CD_USER;

   // Tipo de chat: 'DIRECT' o 'GROUP'
   ADataSet.FieldByName('CHAT_TYPE').AsString := AChatType;

   // Título del chat (para DIRECT puedes usar algo genérico o dejarlo vacío)
   ADataSet.FieldByName('TITLE').AsString := ATitle;

   // Estado inicial del chat
   ADataSet.FieldByName('STATUS').AsString := 'ACTIVE';

   // Fechas y últimos mensajes: los dejará a NULL el cliente,
   // y se rellenarán en el servidor cuando corresponda:
   // ADataSet.FieldByName('CREATED_AT').Clear;
   // ADataSet.FieldByName('UPDATED_AT').Clear;
   // ADataSet.FieldByName('LAST_MESSAGE_AT').Clear;
   // ADataSet.FieldByName('LAST_MESSAGE_ID').Clear;
   // ADataSet.FieldByName('CLOSED_AT').Clear;

   // Metadatos JSON opcionales: lo más simple es dejarlo vacío o NULL
   // según cómo lo trate tu backend.
   ADataSet.FieldByName('METADATA_JSON').AsString := ''; // o .Clear;

   ADataSet.Post;
end;

[async] function TTestChats.HasTestChat(HostUser, GuestUser :string):Boolean;
var ID_CHAT   :Int64;
    ExceptMsg :string;
begin
   TWebSetup.Instance.Language := 'ES';
   try
      ID_CHAT := await(Int64, TDB.GetInteger(LOCAL_PATH, '/chatexists',
                       [['CD_USER_1', HostUser],
                        ['CD_USER_2', GuestUser]]
                       ));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;
   Result := ID_CHAT <> -1;
end;

[async] function TTestChats.EnsureTestChatExists(HostUser, GuestUser :string):Int64;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestChat(HostUser, GuestUser)) then Exit;

   TWebSetup.Instance.Language := 'ES';
   try
      Result := await(Int64, TDB.GetInteger(LOCAL_PATH, '/createnewchat',
                       [['CD_USER_1', HostUser ],
                        ['CD_USER_2', GuestUser]]
                       ));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(Result > -1, 'EnsureTextChatExists -> '+ExceptMsg);
end;

[async] procedure TTestChats.DeleteTestChatIfExists(HostUser, GuestUser :string);
var ID_CHAT :Int64;
begin
   ID_CHAT := await(Int64, TDB.GetInteger(LOCAL_PATH, '/chatexists',
                       [['CD_USER_1', HostUser ],
                        ['CD_USER_2', GuestUser]]
                       ));
   if ID_CHAT > -1 then begin
      try
         await(TDB.Delete(LOCAL_PATH, [['CHAT_ID', IntToStr(ID_CHAT)]], '/deletechat'));
      except
         on E:Exception do ;
      end;
   end;
end;


[Test] [async] procedure TTestChats.TestChatExists;
{ Se envían dos códigos de participantes:
    El usuario anfitrion y
    El usuario invitado

    Si existe una conversación en la que estén los dos participantes, exclusivamente
        se devuelve el GUID de esa conversación.

    En caso contrario se devuelve un GUID -1
}

var ID_CHAT   :Int64;
    ExceptMsg :string;
begin
   TWebSetup.Instance.Language := 'ES';
   try
      ID_CHAT := await(Int64, TDB.GetInteger(LOCAL_PATH, '/chatexists',
                       [['CD_USER_1', TEST_HOST_CD_USER ],
                        ['CD_USER_2', TEST_GUEST_CD_USER]]
                       ));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in ChatExists -> '+ExceptMsg);
   Assert.IsTrue(ID_CHAT = -1, 'TestChatExists must say it does not exists.');
end;

[Test] [async] procedure TTestChats.TestCreateNewChat;
{ Se envían dos códigos de participantes:
    El usuario anfitrión y
    El usuario invitado

    Se crea un nuevo Chat y se devuelve el GUID de ese nuevo Chat
}
var ID_CHAT   :Int64;
    ExceptMsg :string;
begin
   await(DeleteTestChatIfExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));
   try
      TWebSetup.Instance.Language := 'ES';
      try
         ID_CHAT := await(Int64, TDB.GetInteger(LOCAL_PATH, '/createnewchat',
                          [['CD_USER_1', TEST_HOST_CD_USER ],
                           ['CD_USER_2', TEST_GUEST_CD_USER]]
                          ));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in CreateNewChat -> '+ExceptMsg);
      Assert.IsTrue(ID_CHAT > -1, 'CreateNewChat must return a positive integer.');
   finally
      await(DeleteTestChatIfExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));
   end;
end;

[Test] [async] procedure TTestChats.TestGetChat;
{ Se envía el GUID de un chat existente:
    Se devuelve el Chat Existente }

var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    CHAT_ID   :Int64;
begin
   await(DeleteTestChatIfExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));

   CHAT_ID := await(Int64, EnsureTestChatExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));
   try
      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateDataSet;
      try
         try
            await(TDB.GetRow(LOCAL_PATH, [['CHAT_ID', IntToStr(CHAT_ID)]], DataSet, '/getchat'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetChat -> '+ExceptMsg);
         Assert.IsTrue(DataSet.RecordCount > 0, 'GetChat must return content.');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestChatIfExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));
   end;
end;

[Test] [async] procedure TTestChats.TestUpdateChat;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    CHAT_ID   :Int64;
begin
   await(DeleteTestChatIfExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));

   CHAT_ID := await(Int64, EnsureTestChatExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));

   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH, [['CHAT_ID', IntToStr(CHAT_ID)]], DataSet, '/getchat'));

      DataSet.Edit;
      DataSet.FieldByName('TITLE').AsString := UPDATED_TITLE;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['CHAT_ID', IntToStr(CHAT_ID)]], DataSet, '/updatechat'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH, [['CHAT_ID', IntToStr(CHAT_ID)]], DataSet, '/getchat'));

      Assert.IsTrue(DataSet.FieldByName('TITLE').AsString = UPDATED_TITLE, 'Updated title stored in database');
   finally
      DataSet.Free;
      await(DeleteTestChatIfExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));
   end;
end;

[Test] [async] procedure TTestChats.TestDeleteChat;
{ Se envía el GUID de un chat existente:
    No devuelve nada }

var JSONArray :TJSONArray;
    ExceptMsg :string;
    CHAT_ID   :Int64;
    DataSet   :TWebClientDataSet;
begin
   await(DeleteTestChatIfExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));
   TWebSetup.Instance.Language := 'ES';

   CHAT_ID := await(Int64, EnsureTestChatExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));

   try
      await(TDB.Delete(LOCAL_PATH, [['CHAT_ID', IntToStr(CHAT_ID)]], '/deletechat'));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in DeleteChat -> '+ExceptMsg);
   DataSet := CreateDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH, [['CHAT_ID', IntToStr(CHAT_ID)]], DataSet, '/getchat'));
      Assert.IsTrue(DataSet.RecordCount = 0, 'DeleteChat->GetRow must not return content.');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestChats.TestGetAll;
{ Recupera todos los chats activos de un usuario:
    Carga el Array de chats en el DataSet }

var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    //CHAT_ID_1 :Int64;
    //CHAT_ID_2 :Int64;
    //CHAT_ID_3 :Int64;
    //CHAT_ID_4 :Int64;
    //CHAT_ID_5 :Int64;
    //CHAT_ID_6 :Int64;
begin
   await(DeleteTestChatIfExists(TEST_HOST_CD_USER, 'PLAYERUS'));
   await(DeleteTestChatIfExists(TEST_HOST_CD_USER, 'STAFF'   ));
   await(DeleteTestChatIfExists(TEST_HOST_CD_USER, 'AGENT'   ));
   await(DeleteTestChatIfExists(TEST_HOST_CD_USER, 'PARENT'  ));
   await(DeleteTestChatIfExists(TEST_HOST_CD_USER, 'PLAYERES'));
   await(DeleteTestChatIfExists(TEST_HOST_CD_USER, 'COACH'   ));

   await(Int64, EnsureTestChatExists(TEST_HOST_CD_USER, 'PLAYERUS'));
   await(Int64, EnsureTestChatExists(TEST_HOST_CD_USER, 'STAFF'   ));
   await(Int64, EnsureTestChatExists(TEST_HOST_CD_USER, 'AGENT'   ));
   await(Int64, EnsureTestChatExists(TEST_HOST_CD_USER, 'PARENT'  ));
   await(Int64, EnsureTestChatExists(TEST_HOST_CD_USER, 'PLAYERES'));
   await(Int64, EnsureTestChatExists(TEST_HOST_CD_USER, 'COACH'   ));

   try
      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateDataSet;
      try
         try
            await(TDB.GetAll(LOCAL_PATH, [['CD_USER', TEST_HOST_CD_USER]], DataSet));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll -> '+ExceptMsg);
         Assert.IsTrue(DataSet.RecordCount > 0, 'GetAll must return content.');
         Assert.IsTrue(DataSet.RecordCount = 6, 'GetAll must return 6 chats.');
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestChatIfExists(TEST_HOST_CD_USER, 'PLAYERUS'));
      await(DeleteTestChatIfExists(TEST_HOST_CD_USER, 'STAFF'   ));
      await(DeleteTestChatIfExists(TEST_HOST_CD_USER, 'AGENT'   ));
      await(DeleteTestChatIfExists(TEST_HOST_CD_USER, 'PARENT'  ));
      await(DeleteTestChatIfExists(TEST_HOST_CD_USER, 'PLAYERES'));
      await(DeleteTestChatIfExists(TEST_HOST_CD_USER, 'COACH'   ));
   end;
end;

{----- Messages -----}

[Test] [async] procedure TTestChats.TestInsertMessage;
var DataSet    :TWebClientDataSet;
    CheckData  :TWebClientDataSet;
    ExceptMsg  :string;
    CHAT_ID    :Int64;
    MessageTxt :string;
begin
   await(DeleteTestChatIfExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));
   CHAT_ID := await(Int64, EnsureTestChatExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));
   MessageTxt := 'Unit test message ' + FormatDateTime('yyyymmddhhnnsszzz', Now);

   try
      TWebSetup.Instance.Language := 'ES';
      DataSet := CreateMessagesDataSet;
      try
         DataSet.Append;
         DataSet.FieldByName('CHAT_ID').AsLargeInt        := CHAT_ID;
         DataSet.FieldByName('SENDER_CD_USER').AsString   := TEST_HOST_CD_USER;
         DataSet.FieldByName('MESSAGE_TYPE').AsString     := 'TEXT';
         DataSet.FieldByName('CONTENT_TEXT').AsString     := MessageTxt;
         DataSet.FieldByName('STATUS').AsString           := 'NORMAL';
         DataSet.Post;

         try
            await(TDB.Insert(LOCAL_PATH, DataSet, '/insertmessage'));
            ExceptMsg := 'ok';
         except
            on E:Exception do ExceptMsg := E.Message;
         end;

         Assert.IsTrue(ExceptMsg = 'ok', 'Exception in InsertMessage -> '+ExceptMsg);

         CheckData := CreateMessagesDataSet;
         try
            await(TDB.GetAll(LOCAL_PATH, [['CHAT_ID', IntToStr(CHAT_ID)]], CheckData, '/getmessages'));
            Assert.IsTrue(CheckData.RecordCount > 0, 'GetMessages must return content.');
            Assert.IsTrue(CheckData.Locate('CONTENT_TEXT', MessageTxt, []), 'Inserted message found in chat.');
         finally
            CheckData.Free;
         end;
      finally
         DataSet.Free;
      end;
   finally
      await(DeleteTestChatIfExists(TEST_HOST_CD_USER, TEST_GUEST_CD_USER));
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestChats);
end.



