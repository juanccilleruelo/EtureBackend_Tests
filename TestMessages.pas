unit TestMessages;

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
   TTestMessages = class(TObject)
   private
   published
      [Test] [async] procedure TestGetValues;
   end;
{$M-}

implementation

uses senCille.WebSetup, senCille.DataManagement;

{ TTestMessages }

[Test] [async] procedure TTestMessages.TestGetValues;
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
   TTMSWEBUnitTestingRunner.RegisterClass(TTestMessages);
end.
