unit TestAssays;

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
   TTestAssaysController = class(TObject)
   private
      const LOCAL_PATH = '/assays';
      function BuildURL(const AResource :string): string;
   published
      [Test] [async] procedure TestIndexReturnsSuccess;
      [Test] [async] procedure TestGetReversedString;
      [Test] [async] procedure TestGetReversedStringWithSpaces;
      [Test] [async] procedure TestPublicSectionAccessible;
   end;
{$M-}

implementation

uses
   senCille.WebSetup;

{ TTestAssaysController }

function TTestAssaysController.BuildURL(const AResource :string): string;
begin
   Result := TMVCReq.Host + LOCAL_PATH + AResource;
end;

procedure TTestAssaysController.TestIndexReturnsSuccess;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/');
      Request.Method := 'GET';

      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Index must answer with HTTP 200.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'Index must return content.');
   finally
      Request.Free;
   end;
end;

procedure TTestAssaysController.TestGetReversedString;
const INPUT_VALUE  = 'Hello';
      OUTPUT_VALUE = 'olleH';
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/reversedstrings/' + INPUT_VALUE);
      Request.Method := 'GET';
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Reversed string must answer with HTTP 200.');
      Assert.AreEqual(OUTPUT_VALUE, string(Response.ResponseText), 'Reversed string value.');
   finally
      Request.Free;
   end;
end;

procedure TTestAssaysController.TestGetReversedStringWithSpaces;
const INPUT_VALUE  = 'Eture Tests';
      OUTPUT_VALUE = 'stseT erutE';
var Request        :TWebHttpRequest;
    EncodedValue   :string;
    Response       :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      EncodedValue := StringReplace(INPUT_VALUE, ' ', '%20', [rfReplaceAll]);
      Request.URL := BuildURL('/reversedstrings/' + EncodedValue);
      Request.Method := 'GET';
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Reversed string with spaces must answer with HTTP 200.');
      Assert.AreEqual(OUTPUT_VALUE, string(Response.ResponseText), 'Reversed string with spaces value.');
   finally
      Request.Free;
   end;
end;

procedure TTestAssaysController.TestPublicSectionAccessible;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/public');
      Request.Method := 'GET';

      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Public section must be accessible without authentication.');
   finally
      Request.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestAssaysController);
end.
