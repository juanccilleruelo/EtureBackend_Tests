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
      const LOCAL_PATH = '/localizations';
      function BuildURL(const AResource :string): string;
   published
      [Test] [async] procedure TestGetValues;
      [Test] [async] procedure TestGetLanguages;
      [Test] [async] procedure TestTranslate;
      [Test] [async] procedure TestGetMessage;
   end;
{$M-}

implementation

uses
   senCille.WebSetup;

{ TTestLocalizations }

function TTestLocalizations.BuildURL(const AResource :string): string;
begin
   Result := TMVCReq.Host + LOCAL_PATH + AResource;
end;

[Test] [async] procedure TTestLocalizations.TestGetValues;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/getvalues');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue((Response.Status >= 200) and (Response.Status < 300), 'GetValues must answer with HTTP success.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'GetValues must return content.');
   finally
      Request.Free;
   end;
end;

[Test] [async] procedure TTestLocalizations.TestGetLanguages;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/getlanguages');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue((Response.Status >= 200) and (Response.Status < 300), 'GetLanguages must answer with HTTP success.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'GetLanguages must return content.');
   finally
      Request.Free;
   end;
end;

[Test] [async] procedure TTestLocalizations.TestTranslate;
const SAMPLE_TEXT    = 'Hello world';
      SOURCE_LANG    = 'en';
      TARGET_LANG    = 'es';
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
    Payload  :TJSONObject;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/translate');
      Request.Method := 'POST';
      Request.Headers.Values['Content-Type'] := 'application/json';

      Payload := TJSONObject.Create;
      try
         Payload.AddPair('Text', SAMPLE_TEXT);
         Payload.AddPair('SourceLanguage', SOURCE_LANG);
         Payload.AddPair('TargetLanguage', TARGET_LANG);
         Request.PostData := Payload.ToString;
      finally
         Payload.Free;
      end;

      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue((Response.Status >= 200) and (Response.Status < 300), 'Translate must answer with HTTP success.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'Translate must return translated content.');
   finally
      Request.Free;
   end;
end;

[Test] [async] procedure TTestLocalizations.TestGetMessage;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/message');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'GetMessage must answer with HTTP 200.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'GetMessage must return content.');
   finally
      Request.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestLocalizations);

end.
