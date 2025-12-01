unit TestLocalizations;

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
   TTestLocalizations = class(TObject)
   private
   published
      [Test] [async] procedure TestGetValues;
      [Test] [async] procedure TestGetLanguages;
      [Test] [async] procedure TestTranslateWithForm;
      [Test] [async] procedure TestTranslateWord;
      [Test] [async] procedure TestGetMessage;
   end;
{$M-}

implementation

uses senCille.WebSetup, senCille.DataManagement;

{ TTestLocalizations }

[Test] [async] procedure TTestLocalizations.TestGetValues;
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

[Test] [async] procedure TTestLocalizations.TestGetLanguages;
var JSONArray :TJSONArray;
    ExceptMsg :string;
begin
   TWebSetup.Instance.Language := 'ES';

   // Delegate the backend call to TDB to reuse unified error handling.
   try
      JSONArray := await(TJSONArray, TDB.GetJSONArray('/localizations', [], '/getlanguages'));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetLanguages -> '+ExceptMsg);
   Assert.IsTrue(JSONArray.Count > 0, 'GetLanguages must return content.');
end;

[Test] [async] procedure TTestLocalizations.TestTranslateWithForm;
var Params    :TArrayOfStringPairs;
    ExceptMsg :string;
    Value     :string;
begin
   TWebSetup.Instance.Language := 'ES';

   Params  := [['form', 'TUsersForm'],
               ['word', 'Actions'   ]];
   try
      Value := await(string, TDB.GetString('/localizations', '/translate', Params));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in /translate -> '+ExceptMsg);
   Assert.IsTrue(LowerCase(Value) = 'acciones', 'The translation of Actions must be Acciones');
end;

[Test] [async] procedure TTestLocalizations.TestTranslateWord;
var Params    :TArrayOfStringPairs;
    ExceptMsg :string;
    Value     :string;
begin
   TWebSetup.Instance.Language := 'ES';

   Params  := [['word', 'Week']];
   try
      Value := await(string, TDB.GetString('/localizations', '/translate', Params));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in /translate -> '+ExceptMsg);
   Assert.IsTrue(LowerCase(Value) = 'semana', 'The translation of Week must be Semana');
end;

[Test] [async] procedure TTestLocalizations.TestGetMessage;
var Params    :TArrayOfStringPairs;
    ExceptMsg :string;
    Value     :string;
begin
   TWebSetup.Instance.Language := 'ES';

   Params  := [['message', 'NoPendingInvitations']];
   try
      Value := await(string, TDB.GetString('/localizations', '/message', Params));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in /message -> '+ExceptMsg);
   Assert.IsTrue(SameText(Value, 'No hay invitaciones pendientes'), 'The translation of ''NoPendingInvitations'' shall be ''No hay invitaciones pendientes'' ');
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestLocalizations);
end.
