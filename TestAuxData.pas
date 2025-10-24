unit TestAuxData;

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
   TTestAuxDataController = class(TObject)
   private
      const LOCAL_PATH = '/auxdata';
      function BuildURL(const AResource :string): string;
   published
      [Test] [async] procedure TestSatActExam;
      [Test] [async] procedure TestSections;
      [Test] [async] procedure TestDivisions;
      [Test] [async] procedure TestEnglishLevels;
      [Test] [async] procedure TestCurrentlyStudying;
      [Test] [async] procedure TestSpanishLevels;
      [Test] [async] procedure TestMetrics;
      [Test] [async] procedure TestGrades;
   end;
{$M-}

implementation

uses
   senCille.WebSetup;

{ TTestAuxDataController }

function TTestAuxDataController.BuildURL(const AResource :string): string;
begin
   Result := TMVCReq.Host + LOCAL_PATH + AResource;
end;

procedure TTestAuxDataController.TestSatActExam;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/satactexam');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'SAT/ACT exam data must answer with HTTP 200.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'SAT/ACT exam data must return content.');
   finally
      Request.Free;
   end;
end;

procedure TTestAuxDataController.TestSections;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/sections');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Sections must answer with HTTP 200.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'Sections must return content.');
   finally
      Request.Free;
   end;
end;

procedure TTestAuxDataController.TestDivisions;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/divisions');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Divisions must answer with HTTP 200.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'Divisions must return content.');
   finally
      Request.Free;
   end;
end;

procedure TTestAuxDataController.TestEnglishLevels;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/englishlevels');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'English levels must answer with HTTP 200.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'English levels must return content.');
   finally
      Request.Free;
   end;
end;

procedure TTestAuxDataController.TestCurrentlyStudying;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/currentlystudying');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Currently studying data must answer with HTTP 200.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'Currently studying data must return content.');
   finally
      Request.Free;
   end;
end;

procedure TTestAuxDataController.TestSpanishLevels;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/spanishlevels');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Spanish levels must answer with HTTP 200.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'Spanish levels must return content.');
   finally
      Request.Free;
   end;
end;

procedure TTestAuxDataController.TestMetrics;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/metrics');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Metrics must answer with HTTP 200.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'Metrics must return content.');
   finally
      Request.Free;
   end;
end;

procedure TTestAuxDataController.TestGrades;
var Request  :TWebHttpRequest;
    Response :TJSXMLHttpRequest;
begin
   TWebSetup.Instance;

   Request := TWebHttpRequest.Create(nil);
   try
      Request.URL := BuildURL('/grades');
      Response := await(TJSXMLHttpRequest, Request.Perform);

      Assert.IsTrue(Response.Status = 200, 'Grades must answer with HTTP 200.');
      Assert.IsTrue(Trim(Response.ResponseText) <> '', 'Grades must return content.');
   finally
      Request.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestAuxDataController);
end.
