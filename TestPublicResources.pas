unit TestPublicResources;

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
   TTestPublicResourcesController = class(TObject)
   private
      const PUBLIC_SAMPLE_PATH = '/publicsample';
      const ADMIN_BASE_PATH    = '/admin';
      function BuildPublicURL(const AResource :string) :string;
      function BuildAdminURL(const AResource :string) :string;
   published
      [Test] [async] procedure TestPublicSampleAccessible;
      [Test] [async] procedure TestResourceAWithoutAuthenticationFails;
      [Test] [async] procedure TestResourceAHtmlForAdmin;
      [Test] [async] procedure TestResourceAJsonForAdmin;
      [Test] [async] procedure TestResourceBForbiddenForAdminRole;
      [Test] [async] procedure TestResourceCForbiddenForAdminRole;
   end;
{$M-}

implementation

uses
   senCille.WebSetup,
   senCille.DataManagement;

{ TTestPublicResourcesController }

function TTestPublicResourcesController.BuildPublicURL(const AResource :string) :string;
begin
   Result := TMVCReq.Host + AResource;
end;

function TTestPublicResourcesController.BuildAdminURL(const AResource :string) :string;
begin
   Result := TMVCReq.Host + ADMIN_BASE_PATH + AResource;
end;

procedure TTestPublicResourcesController.TestPublicSampleAccessible;
(*var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;*)
begin
(*   TWebSetup.Instance;
   await(TWebSetup.Instance.SetAuthToken('null'));

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildPublicURL(PUBLIC_SAMPLE_PATH);
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Public sample must answer with HTTP 200.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'Public sample must return content.');
   finally
      Request.Free;
   end;*)
end;

procedure TTestPublicResourcesController.TestResourceAWithoutAuthenticationFails;
(*var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;*)
begin
(*   TWebSetup.Instance;
   await(TWebSetup.Instance.SetAuthToken('null'));

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildAdminURL('/resourceA');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status in [401, 403], 'Resource A must require authentication.');
   finally
      Request.Free;
   end;*)
end;

procedure TTestPublicResourcesController.TestResourceAHtmlForAdmin;
(*var Request      :TWebHttpRequest;
    Response     :TJSXMLHttpRequest;
    Token        :string;
    ContentType  :string;*)
begin
   (*TWebSetup.Instance;
   Token := await(string, TDB.AuthenticateUser('admin', 'lara'));
   await(TWebSetup.Instance.SetAuthToken(Token));

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildAdminURL('/resourceA');
      Request.Headers.Add('Accept=text/html');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Admin must access Resource A (HTML).');
      ContentType := LowerCase(Response.getResponseHeader('content-type'));
      Assert.IsTrue(Pos('text/html', ContentType) > 0, 'Resource A HTML must answer with text/html.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'Resource A HTML must return content.');
   finally
      Request.Free;
   end;

   await(TWebSetup.Instance.SetAuthToken('null'));*)
end;

procedure TTestPublicResourcesController.TestResourceAJsonForAdmin;
(*var Request      :TWebHttpRequest;
    Response     :TJSXMLHttpRequest;
    Token        :string;
    ContentType  :string;*)
begin
(*   TWebSetup.Instance;
   Token := await(string, TDB.AuthenticateUser('admin', 'lara'));
   await(TWebSetup.Instance.SetAuthToken(Token));

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildAdminURL('/resourceA');
      Request.Headers.Add('Accept=application/json');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Admin must access Resource A (JSON).');
      ContentType := LowerCase(Response.getResponseHeader('content-type'));
      Assert.IsTrue(Pos('application/json', ContentType) > 0, 'Resource A JSON must answer with application/json.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'Resource A JSON must return content.');
   finally
      Request.Free;
   end;

   await(TWebSetup.Instance.SetAuthToken('null'));*)
end;

procedure TTestPublicResourcesController.TestResourceBForbiddenForAdminRole;
(*var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
    Token    :string;*)
begin
(*   TWebSetup.Instance;
   Token := await(string, TDB.AuthenticateUser('admin', 'lara'));
   await(TWebSetup.Instance.SetAuthToken(Token));

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildAdminURL('/resourceB');
      Request.Headers.Add('Accept=application/json');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 403, 'Resource B must require MANAGER role.');
   finally
      Request.Free;
   end;

   await(TWebSetup.Instance.SetAuthToken('null'));*)
end;

procedure TTestPublicResourcesController.TestResourceCForbiddenForAdminRole;
(*var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
    Token    :string;*)
begin
(*   TWebSetup.Instance;
   Token := await(string, TDB.AuthenticateUser('admin', 'lara'));
   await(TWebSetup.Instance.SetAuthToken(Token));

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildAdminURL('/resourceC');
      Request.Headers.Add('Accept=application/json');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 403, 'Resource C must require USER role.');
   finally
      Request.Free;
   end;

   await(TWebSetup.Instance.SetAuthToken('null'));*)
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestPublicResourcesController);
end.
