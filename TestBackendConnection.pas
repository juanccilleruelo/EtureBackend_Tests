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

const LocalPath = '/login';

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
begin
   TWebSetup.Instance;
   Token := await(string, TDB.AuthenticateUser('admin', 'lara'));
   await(TWebSetup.Instance.SetAuthToken(Token));

   Assert.IsTrue (TWebSetup.Instance.AuthToken <> 'null' , 'AuthToken Assigned'     );
   Assert.IsTrue (TWebSetup.Instance.UserId     = 'admin', Format('Must be admin but is : %s', [TWebSetup.Instance.UserId]));
   Assert.IsTrue (TWebSetup.Instance.ContainsTheRole('ADMIN'), 'Is not ADMIN');
end;

procedure TTestBackendConnection.Login_As_Staff;
var Token :string;
begin
   TWebSetup.Instance;
   Token := await(string, TDB.AuthenticateUser('staff', 'lara'));
   await(TWebSetup.Instance.SetAuthToken(Token));

   Assert.IsTrue (TWebSetup.Instance.AuthToken <> 'null' , 'AuthToken Assigned'     );
   Assert.IsTrue (TWebSetup.Instance.UserId     = 'staff', Format('Must be staff but is : %s', [TWebSetup.Instance.UserId]));
   Assert.IsTrue (TWebSetup.Instance.ContainsTheRole('STAFF'), 'Is not STAFF');
end;

procedure TTestBackendConnection.Login_As_Agent;
var Token :string;
begin
   TWebSetup.Instance;
   Token := await(string, TDB.AuthenticateUser('agent', 'lara'));
   await(TWebSetup.Instance.SetAuthToken(Token));

   Assert.IsTrue (TWebSetup.Instance.AuthToken <> 'null' , 'AuthToken Assigned'     );
   Assert.IsTrue (TWebSetup.Instance.UserId     = 'agent', Format('Must be staff but is : %s', [TWebSetup.Instance.UserId]));
   Assert.IsTrue (TWebSetup.Instance.ContainsTheRole('AGENT'), 'Is not AGENT');
end;

procedure TTestBackendConnection.Login_As_Player_us;
var Token :string;
begin
   TWebSetup.Instance;
   Token := await(string, TDB.AuthenticateUser('playerus', 'lara'));
   await(TWebSetup.Instance.SetAuthToken(Token));

   Assert.IsTrue (TWebSetup.Instance.AuthToken <> 'null' , 'AuthToken Assigned'     );
   Assert.IsTrue (TWebSetup.Instance.UserId     = 'playerus', Format('Must be staff but is : %s', [TWebSetup.Instance.UserId]));
   Assert.IsTrue (TWebSetup.Instance.ContainsTheRole('PLAYER_US'), 'Is not PLAYER_US');
end;

procedure TTestBackendConnection.Login_As_Player_es;
var Token :string;
begin
   TWebSetup.Instance;
   Token := await(string, TDB.AuthenticateUser('playeres', 'lara'));
   await(TWebSetup.Instance.SetAuthToken(Token));

   Assert.IsTrue (TWebSetup.Instance.AuthToken <> 'null' , 'AuthToken Assigned'     );
   Assert.IsTrue (TWebSetup.Instance.UserId     = 'playeres', Format('Must be staff but is : %s', [TWebSetup.Instance.UserId]));
   Assert.IsTrue (TWebSetup.Instance.ContainsTheRole('PLAYER_ES'), 'Is not PLAYER_ES');
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestBackendConnection);
end.
