unit TestTeams;

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
   TTestTeams = class(TObject)
   private
      const LOCAL_PATH            = '/teams';
      const TEST_TEAM_CODE        = 'UT_TEAM_0001';
      const TEST_TEAM_NAME        = 'Unit Test Team';
      const UPDATED_TEAM_NAME     = 'Unit Test Team - Updated';
      const TEST_PLAYER_CODE      = 'PLAYERUS'; //From PLAYERS
      const TEST_PLAYER_ROLE      = 'Unit Test Midfielder';
      const TEST_JERSEY_NUMBER    = '99';
   private
      function CreateTeamDataSet:TWebClientDataSet;
      function CreateTeamPlayerDataSet:TWebClientDataSet;
      procedure FillTeamData(ADataSet :TWebClientDataSet; const ATeamName :string);
      procedure FillTeamPlayerData(ADataSet :TWebClientDataSet);
      [async] function HasTestTeam:Boolean;
      [async] procedure EnsureTestTeamExists;
      [async] procedure DeleteTestTeamIfExists;
      [async] function HasTestTeamPlayer:Boolean;
      [async] procedure EnsureTestTeamPlayerExists;
      [async] procedure DeleteTestTeamPlayerIfExists;
   published
      [Test] [async] procedure TestInsert;
      [Test] [async] procedure TestLoad;
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
      [Test] [async] procedure TestUpdate;
      [Test] [async] procedure TestIsReferenced;
      [Test] [async] procedure TestDelete;
      [Test] [async] procedure TestGetOrderByFields;
      [Test] [async] procedure TestInsertTeamPlayer;
      [Test] [async] procedure TestGetOneTeamPlayer;
      [Test] [async] procedure TestGetAllTeamPlayers;
      [Test] [async] procedure TestDeleteTeamPlayer;
   end;
{$M-}

implementation

uses
   senCille.DataManagement;

{ TTestTeams }

function TTestTeams.CreateTeamDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_TEAM';
   NewField.Size := 14;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'DS_TEAM';
   NewField.Size := 14;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'NOTES';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'IMG_LOGO';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

function TTestTeams.CreateTeamPlayerDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_TEAM';
   NewField.Size := 14;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'CD_USER';
   NewField.Size := 50;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'PLAYER_ROLE';
   NewField.Size := 30;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName := 'JERSEY_NUMBER';
   NewField.Size := 5;
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName := 'NOTES';
   NewField.DataSet := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftMemo, 0);

   Result.Active := True;
end;

procedure TTestTeams.FillTeamData(ADataSet :TWebClientDataSet; const ATeamName :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_TEAM' ).AsString := TEST_TEAM_CODE;
   ADataSet.FieldByName('DS_TEAM' ).AsString := ATeamName;
   ADataSet.FieldByName('NOTES'   ).AsString := 'Generated from automated unit testing.';
   ADataSet.FieldByName('IMG_LOGO').AsString := 'UnitTestLogo';
   ADataSet.Post;
end;

procedure TTestTeams.FillTeamPlayerData(ADataSet :TWebClientDataSet);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_TEAM'      ).AsString := TEST_TEAM_CODE;
   ADataSet.FieldByName('CD_USER'      ).AsString := TEST_PLAYER_CODE;
   ADataSet.FieldByName('PLAYER_ROLE'  ).AsString := TEST_PLAYER_ROLE;
   ADataSet.FieldByName('JERSEY_NUMBER').AsString := TEST_JERSEY_NUMBER;
   ADataSet.FieldByName('NOTES'        ).AsString := 'Generated from automated unit testing.';
   ADataSet.Post;
end;

[async] function TTestTeams.HasTestTeam:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateTeamDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_TEAM', TEST_TEAM_CODE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestTeams.EnsureTestTeamExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestTeam()) then Exit;

   DataSet := CreateTeamDataSet;
   try
      FillTeamData(DataSet, TEST_TEAM_NAME);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestTeamExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestTeams.DeleteTestTeamIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_TEAM', TEST_TEAM_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[async] function TTestTeams.HasTestTeamPlayer:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateTeamPlayerDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_TEAM', TEST_TEAM_CODE],
                           ['CD_USER', TEST_PLAYER_CODE]],
                          DataSet, '/getoneteamplayer'));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestTeams.EnsureTestTeamPlayerExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestTeamExists());
   if await(Boolean, HasTestTeamPlayer()) then Exit;

   DataSet := CreateTeamPlayerDataSet;
   try
      FillTeamPlayerData(DataSet);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertteamplayer'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestTeamPlayerExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestTeams.DeleteTestTeamPlayerIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE],
                        ['CD_USER', TEST_PLAYER_CODE]],
                        '/deleteteamplayer'));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestTeams.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(DeleteTestTeamIfExists());

   DataSet := CreateTeamDataSet;
   try
      FillTeamData(DataSet, TEST_TEAM_NAME);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Insert -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestTeams.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestTeamExists());

   DataSet := CreateTeamDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                        [['PageNumber', '1'        ],
                         ['SearchText', 'Unit Test'],
                         ['OrderField', ''         ]],
                        DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Count greater than 0');
      Assert.IsTrue(DataSet.Locate('CD_TEAM', TEST_TEAM_CODE, []), 'Test team located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestTeams.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestTeamExists());

   DataSet := CreateTeamDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_TEAM', TEST_TEAM_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_TEAM').AsString = TEST_TEAM_NAME, 'Team name matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestTeams.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestTeamExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_TEAM', 'DS_TEAM', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestTeams.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestTeamExists());

   DataSet := CreateTeamDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE]],
                       DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_TEAM').AsString := UPDATED_TEAM_NAME;
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH,
                          [['CD_TEAM', TEST_TEAM_CODE],
                           ['OLD_CD_TEAM', TEST_TEAM_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Update -> '+ExceptMsg);

      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE]],
                       DataSet));

      Assert.IsTrue(DataSet.FieldByName('DS_TEAM').AsString = UPDATED_TEAM_NAME, 'Updated team name stored in database');

      DataSet.Edit;
      DataSet.FieldByName('DS_TEAM').AsString := TEST_TEAM_NAME;
      DataSet.Post;
      await(TDB.Update(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE],
                        ['OLD_CD_TEAM', TEST_TEAM_CODE]],
                       DataSet));
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestTeams.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   await(EnsureTestTeamExists());

   DataSet := CreateTeamDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE]],
                       DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in IsReferenced -> '+ExceptMsg);
      Assert.IsTrue(IsReferenced = False, 'Test team should not be referenced');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestTeams.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestTeamExists());

   try
      await(TDB.Delete(LOCAL_PATH, [['CD_TEAM', TEST_TEAM_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete -> '+ExceptMsg);

   DataSet := CreateTeamDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE]],
                       DataSet));
      Assert.IsTrue(DataSet.IsEmpty, 'Team successfully removed');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestTeams.TestGetOrderByFields;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getorderbyfields', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOrderByFields -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Order by fields available');
   finally
      Items.Free;
   end;
end;

[Test] [async] procedure TTestTeams.TestInsertTeamPlayer;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestTeamExists());
   await(DeleteTestTeamPlayerIfExists());

   DataSet := CreateTeamPlayerDataSet;
   try
      FillTeamPlayerData(DataSet);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet, '/insertteamplayer'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in InsertTeamPlayer -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestTeams.TestGetOneTeamPlayer;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestTeamPlayerExists());

   DataSet := CreateTeamPlayerDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_TEAM', TEST_TEAM_CODE  ],
                           ['CD_USER', TEST_PLAYER_CODE]],
                          DataSet, '/getoneteamplayer'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneTeamPlayer -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one team player retrieved');
      Assert.IsTrue(DataSet.FieldByName('CD_USER').AsString = TEST_PLAYER_CODE, 'Team player code matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestTeams.TestGetAllTeamPlayers;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   await(EnsureTestTeamPlayerExists());

   DataSet := CreateTeamPlayerDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                                   [['CD_TEAM', TEST_TEAM_CODE]],
                                   DataSet, '/getallteamplayers'));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAllTeamPlayers -> '+ExceptMsg);
      Assert.IsTrue(Count > 0, 'Recovered more than 0 team players');
      Assert.IsTrue(DataSet.Locate('CD_USER', TEST_PLAYER_CODE, []), 'Test team player located in dataset');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestTeams.TestDeleteTeamPlayer;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestTeamPlayerExists());

   try
      await(TDB.Delete(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE  ],
                        ['CD_USER', TEST_PLAYER_CODE]],
                        '/deleteteamplayer'));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in DeleteTeamPlayer -> '+ExceptMsg);

   DataSet := CreateTeamPlayerDataSet;
   try
      await(TDB.GetRow(LOCAL_PATH,
                       [['CD_TEAM', TEST_TEAM_CODE  ],
                        ['CD_USER', TEST_PLAYER_CODE]],
                       DataSet, '/getoneteamplayer'));
      Assert.IsTrue(DataSet.IsEmpty, 'Team player successfully removed');
   finally
      DataSet.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestTeams);

end.
