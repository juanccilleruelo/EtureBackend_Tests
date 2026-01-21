unit TestBackendConnection;

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
  TTestBackendConnection = class(TObject)
  published
    [Test] [async] procedure Login_As_Admin;
    [Test] [async] procedure Login_As_Staff;
    [Test] [async] procedure Login_As_Agent;
    [Test] [async] procedure Login_As_Player_us;
    [Test] [async] procedure Login_As_Player_es;
  end;
{$M-}

implementation

uses
  SysUtils, senCille.WebSetup, senCille.DataManagement;

{ TTestBackendConnection }

procedure TTestBackendConnection.Login_As_Admin;
var Token :string;
    ErrMsg: string;
begin
   TWebSetup.Instance;
   ErrMsg := '';
   try
      Token := await(string, TDB.AuthenticateUser('admin', 'lara'));
   except
      on E:Exception do begin
         Token := '';
         ErrMsg := E.Message;
      end;
   end;

   Assert.IsTrue(Token <> '', Format('AuthenticateUser(admin) failed: %s', [ErrMsg]));

   try
      await(TWebSetup.Instance.SetAuthToken(Token));
   except
      on E:Exception do Assert.IsTrue(False, Format('SetAuthToken failed: %s; tokenLen=%d; tokenPreview=%s', [E.Message, Length(Token), Copy(Token,1,32)]));
   end;

   Assert.IsTrue((TWebSetup.Instance.AuthToken <> 'null') and (TWebSetup.Instance.AuthToken <> ''),
     Format('AuthToken not set correctly. TokenLen=%d Preview=%s', [Length(TWebSetup.Instance.AuthToken), Copy(TWebSetup.Instance.AuthToken,1,32)]));

   Assert.IsTrue(TWebSetup.Instance.UserId = 'admin', Format('Expected UserId=admin but is: %s; tokenPreview=%s', [TWebSetup.Instance.UserId, Copy(TWebSetup.Instance.AuthToken,1,32)]));
   Assert.IsTrue(TWebSetup.Instance.ContainsTheRole('ADMIN'), Format('Expected role ADMIN not present. UserId=%s; tokenPreview=%s', [TWebSetup.Instance.UserId, Copy(TWebSetup.Instance.AuthToken,1,32)]));
end;

procedure TTestBackendConnection.Login_As_Staff;
var Token :string;
    ErrMsg: string;
begin
   TWebSetup.Instance;
   ErrMsg := '';
   try
      Token := await(string, TDB.AuthenticateUser('staff', 'lara'));
   except
      on E:Exception do begin
         Token := '';
         ErrMsg := E.Message;
      end;
   end;

   Assert.IsTrue(Token <> '', Format('AuthenticateUser(staff) failed: %s', [ErrMsg]));
   try
      await(TWebSetup.Instance.SetAuthToken(Token));
   except
      on E:Exception do Assert.IsTrue(False, Format('SetAuthToken failed: %s; tokenLen=%d', [E.Message, Length(Token)]));
   end;

   Assert.IsTrue(TWebSetup.Instance.UserId = 'staff', Format('Expected UserId=staff but is: %s', [TWebSetup.Instance.UserId]));
   Assert.IsTrue(TWebSetup.Instance.ContainsTheRole('STAFF'), Format('Expected role STAFF not present. UserId=%s', [TWebSetup.Instance.UserId]));
end;

procedure TTestBackendConnection.Login_As_Agent;
var Token :string;
    ErrMsg: string;
begin
   TWebSetup.Instance;
   ErrMsg := '';
   try
      Token := await(string, TDB.AuthenticateUser('agent', 'lara'));
   except
      on E:Exception do begin
         Token := '';
         ErrMsg := E.Message;
      end;
   end;

   Assert.IsTrue(Token <> '', Format('AuthenticateUser(agent) failed: %s', [ErrMsg]));
   try
      await(TWebSetup.Instance.SetAuthToken(Token));
   except
      on E:Exception do Assert.IsTrue(False, Format('SetAuthToken failed: %s; tokenLen=%d', [E.Message, Length(Token)]));
   end;

   Assert.IsTrue(TWebSetup.Instance.UserId = 'agent', Format('Expected UserId=agent but is: %s', [TWebSetup.Instance.UserId]));
   Assert.IsTrue(TWebSetup.Instance.ContainsTheRole('AGENT'), Format('Expected role AGENT not present. UserId=%s', [TWebSetup.Instance.UserId]));
end;

procedure TTestBackendConnection.Login_As_Player_us;
var Token :string;
    ErrMsg: string;
begin
   TWebSetup.Instance;
   ErrMsg := '';
   try
      Token := await(string, TDB.AuthenticateUser('playerus', 'lara'));
   except
      on E:Exception do begin
         Token := '';
         ErrMsg := E.Message;
      end;
   end;

   Assert.IsTrue(Token <> '', Format('AuthenticateUser(playerus) failed: %s', [ErrMsg]));
   try
      await(TWebSetup.Instance.SetAuthToken(Token));
   except
      on E:Exception do Assert.IsTrue(False, Format('SetAuthToken failed: %s; tokenLen=%d', [E.Message, Length(Token)]));
   end;

   Assert.IsTrue(TWebSetup.Instance.UserId = 'playerus', Format('Expected UserId=playerus but is: %s', [TWebSetup.Instance.UserId]));
   Assert.IsTrue(TWebSetup.Instance.ContainsTheRole('PLAYER_US'), Format('Expected role PLAYER_US not present. UserId=%s', [TWebSetup.Instance.UserId]));
end;

procedure TTestBackendConnection.Login_As_Player_es;
var Token :string;
    ErrMsg: string;
begin
   TWebSetup.Instance;
   ErrMsg := '';
   try
      Token := await(string, TDB.AuthenticateUser('playeres', 'lara'));
   except
      on E:Exception do begin
         Token := '';
         ErrMsg := E.Message;
      end;
   end;

   Assert.IsTrue(Token <> '', Format('AuthenticateUser(playeres) failed: %s', [ErrMsg]));
   try
      await(TWebSetup.Instance.SetAuthToken(Token));
   except
      on E:Exception do Assert.IsTrue(False, Format('SetAuthToken failed: %s; tokenLen=%d', [E.Message, Length(Token)]));
   end;

   Assert.IsTrue(TWebSetup.Instance.UserId = 'playeres', Format('Expected UserId=playeres but is: %s', [TWebSetup.Instance.UserId]));
   Assert.IsTrue(TWebSetup.Instance.ContainsTheRole('PLAYER_ES'), Format('Expected role PLAYER_ES not present. UserId=%s', [TWebSetup.Instance.UserId]));
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestBackendConnection);
end.
