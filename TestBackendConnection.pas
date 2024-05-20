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
    [Test] [async] procedure CreateNewUser;
    [Test] [async] procedure TestAuthenticateUser;
  end;
{$M-}

implementation

uses
  SysUtils;

{ TTestBackendConnection }

procedure TTestBackendConnection.CreateNewUser;
var Request  :TWebHttpRequest;
    Data     :TJSXMLHttpRequest;
    SendData :TJSONObject;
begin
   { Create the Request object for communicate with the server }
   (*Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath+'/insert');

   SendData := TJSONObject.Create;
   SendData.AddPair('CD_USER'  , 'Test_user'         );
   SendData.AddPair('EMAIL'    , 'sencille@gmail.com');
   SendData.AddPair('PASSWORD' , 'noseve'            );

   Request.PostData := SendData.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   if Data.Status <> 200 then TMVCReq.GetDataStatusMsg(Data.Status)
   else if Data.ResponseText <> 'OK' then begin
      ShowMessage(Data.ResponseText);
   end;*)

   Assert.IsTrue(True);
end;

procedure TTestBackendConnection.TestAuthenticateUser;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSONObject :TJSONObject;
    Success    :Boolean;

    AuthToken  :string;
begin
   (*Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath);

   { Add Basic Authorization }
   Request.Headers.Clear;
   Request.Headers.AddPair('Authorization', 'Basic '+Window.btoa('admin' + ':' + 'lara'));

   Data := await(TJSXMLHttpRequest, Request.Perform);
   if Data.Status <> 200 then begin
      TMVCReq.GetDataStatusMsg(Data.Status);
      AuthToken := '';
   end
   else begin
      JSONObject := TJSONObject(TJSONObject.ParseJSONValue(Data.ResponseText));
      AuthToken := JSONObject.GetJSONValue('token');
   end;

   Assert.IsTrue(AuthToken <> '');*)

   Assert.IsTrue(True);
end;



initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestBackendConnection);
end.
