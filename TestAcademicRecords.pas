unit TestAcademicRecords;

interface

uses
  WEBLib.UnitTesting.Classes;

type
{$M+}
  // Example of a class containing methods with unit tests.
  // Mark it with [TestFixture] custom attribute and register with
  // TTMSWEBUnitTestingRunner as shown below.
  [TestFixture]
  TMyTestClassUnit3 = class(TObject)
  published
    // Example method that contains a unit test. Annotate it with [Test]
    [Test]
    procedure TestIntToStr;
  end;
{$M-}

implementation

uses
  SysUtils;

{ TMyTestClassUnit3 }

procedure TMyTestClassUnit3.TestIntToStr;
begin
  // Use static methods of Assert to specify your test condition.
  Assert.AreEqual('42', IntToStr(42));
end;

initialization
  //Registration of the test classes.
  TTMSWEBUnitTestingRunner.RegisterClass(TMyTestClassUnit3);

end.
