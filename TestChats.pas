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
   published
      [Test] [async] procedure TestChatExists;
      [Test] [async] procedure TestCreateNewChat;
      [Test] [async] procedure TestGetChat;
   end;
{$M-}

implementation

uses senCille.WebSetup, senCille.DataManagement;

{ TTestChats }

[Test] [async] procedure TTestChats.TestChatExists;
{ Se envían dos códigos de participantes:
    El usuario actual y
    El usuario elegido de la lista

    Si existe una conversación en la que estén los dos participantes, exclusivamente
        se devuelve el GUID de esa conversación.

    En caso contrario se devuelve un GUID vacio
}

var ID_CHAT   :Int64;
    ExceptMsg :string;
begin
   TWebSetup.Instance.Language := 'ES';
   try
      ID_CHAT := await(Int64, TDB.GetInteger('/chats', '/chatexists',
                       [['CD_USER_1', 'ADMIN'   ],
                        ['CD_USER_2', 'PLAYERUS']]
                       ));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetValues -> '+ExceptMsg);
   //Assert.IsTrue(JSONArray.Count > 0, 'GetValues must return content.');
end;

[Test] [async] procedure TTestChats.TestCreateNewChat;
{ Se envían dos códigos de participantes:
    El usuario actual y
    El usuario elegido de la lista

    Se crea un nuevo Chat y se devuelve el GUID de ese nuevo Chat
}

var ID_CHAT   :Int64;
    ExceptMsg :string;
begin
   TWebSetup.Instance.Language := 'ES';
   try
      ID_CHAT := await(Int64, TDB.GetInteger('/chats', '/createnewchat',
                       [['CD_USER_1', 'ADMIN'   ],
                        ['CD_USER_2', 'PLAYERUS']]
                       ));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetValues -> '+ExceptMsg);
   Assert.IsTrue(ID_CHAT > -1, 'CreateNewChat must return a positive integer.');
end;

[Test] [async] procedure TTestChats.TestGetChat;
{ Se envía el GUID de un chat existente:
    Se devuelve el Chat Existente }

var JSONArray :TJSONArray;
    ExceptMsg :string;
begin
   TWebSetup.Instance.Language := 'ES';

   try
      JSONArray := await(TJSONArray, TDB.GetJSONArray('/localizations', [['FORM_NAME', 'TUsersForm']], '/getvalues'));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetValues -> '+ExceptMsg);
   Assert.IsTrue(JSONArray.Count > 0, 'GetValues must return content.');
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestChats);
end.
