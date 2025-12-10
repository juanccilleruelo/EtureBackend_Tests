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
     procedure FillChatData(ADataSet :TWebClientDataSet; const ATitle :string; const AChatType: string = 'DIRECT');
     [async] function HasTestChat:Boolean;
     [async] function EnsureTestChatExists:Int64;
     [async] procedure DeleteTestChatIfExists;
   published
      [Test] [async] procedure TestChatExists;
      [Test] [async] procedure TestCreateNewChat;
      [Test] [async] procedure TestGetChat;
      [Test] [async] procedure TestUpdateChat;
      [Test] [async] procedure TestDeleteChat;
   end;
{$M-}

implementation

uses senCille.WebSetup, senCille.DataManagement;

{ TTestChats }

function TTestChats.CreateDataSet: TWebClientDataSet;
var
  NewField: TField;
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

[async] function TTestChats.HasTestChat:Boolean;
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
   Result := ID_CHAT <> -1;
end;

[async] function TTestChats.EnsureTestChatExists:Int64;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestChat()) then Exit;

   TWebSetup.Instance.Language := 'ES';
   try
      Result := await(Int64, TDB.GetInteger(LOCAL_PATH, '/createnewchat',
                       [['CD_USER_1', TEST_HOST_CD_USER ],
                        ['CD_USER_2', TEST_GUEST_CD_USER]]
                       ));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(Result > -1, 'EnsureTextChatExists -> '+ExceptMsg);
end;

[async] procedure TTestChats.DeleteTestChatIfExists;
var ID_CHAT :Int64;
begin
   ID_CHAT := await(Int64, TDB.GetInteger(LOCAL_PATH, '/chatexists',
                       [['CD_USER_1', TEST_HOST_CD_USER ],
                        ['CD_USER_2', TEST_GUEST_CD_USER]]
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
   await(DeleteTestChatIfExists());
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
      await(DeleteTestChatIfExists());
   end;
end;

[Test] [async] procedure TTestChats.TestGetChat;
{ Se envía el GUID de un chat existente:
    Se devuelve el Chat Existente }

var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    CHAT_ID   :Int64;
begin
   await(DeleteTestChatIfExists());

   CHAT_ID := await(Int64, EnsureTestChatExists());
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
      await(DeleteTestChatIfExists());
   end;
end;

[Test] [async] procedure TTestChats.TestUpdateChat;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    CHAT_ID   :Int64;
begin
   await(DeleteTestChatIfExists());

   CHAT_ID := await(Int64, EnsureTestChatExists());

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
      await(DeleteTestChatIfExists());
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
   await(DeleteTestChatIfExists());
   TWebSetup.Instance.Language := 'ES';

   CHAT_ID := await(Int64, EnsureTestChatExists());

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

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestChats);
end.
