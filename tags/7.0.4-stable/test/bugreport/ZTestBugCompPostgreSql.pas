{*********************************************************}
{                                                         }
{                 Zeos Database Objects                   }
{      Test Cases for PostgreSQL Component Bug Reports    }
{                                                         }
{*********************************************************}

{@********************************************************}
{    Copyright (c) 1999-2006 Zeos Development Group       }
{                                                         }
{ License Agreement:                                      }
{                                                         }
{ This library is distributed in the hope that it will be }
{ useful, but WITHOUT ANY WARRANTY; without even the      }
{ implied warranty of MERCHANTABILITY or FITNESS FOR      }
{ A PARTICULAR PURPOSE.  See the GNU Lesser General       }
{ Public License for more details.                        }
{                                                         }
{ The source code of the ZEOS Libraries and packages are  }
{ distributed under the Library GNU General Public        }
{ License (see the file COPYING / COPYING.ZEOS)           }
{ with the following  modification:                       }
{ As a special exception, the copyright holders of this   }
{ library give you permission to link this library with   }
{ independent modules to produce an executable,           }
{ regardless of the license terms of these independent    }
{ modules, and to copy and distribute the resulting       }
{ executable under terms of your choice, provided that    }
{ you also meet, for each linked independent module,      }
{ the terms and conditions of the license of that module. }
{ An independent module is a module which is not derived  }
{ from or based on this library. If you modify this       }
{ library, you may extend this exception to your version  }
{ of the library, but you are not obligated to do so.     }
{ If you do not wish to do so, delete this exception      }
{ statement from your version.                            }
{                                                         }
{                                                         }
{ The project web site is located on:                     }
{   http://zeos.firmos.at  (FORUM)                        }
{   http://zeosbugs.firmos.at (BUGTRACKER)                }
{   svn://zeos.firmos.at/zeos/trunk (SVN Repository)      }
{                                                         }
{   http://www.sourceforge.net/projects/zeoslib.          }
{   http://www.zeoslib.sourceforge.net                    }
{                                                         }
{                                                         }
{                                                         }
{                                 Zeos Development Group. }
{********************************************************@}

unit ZTestBugCompPostgreSql;

interface

{$I ZBugReport.inc}

uses
  {$IFNDEF LINUX}
    {$IFDEF WITH_VCL_PREFIX}
    Vcl.DBCtrls,
    {$ELSE}
    DBCtrls,
    {$ENDIF}
  {$ENDIF}
  Classes, DB, {$IFDEF FPC}testregistry{$ELSE}TestFramework{$ENDIF}, ZDataset,
  ZConnection, ZDbcIntfs, ZSqlTestCase, ZSqlUpdate,
  ZCompatibility, SysUtils, ZTestConsts, ZSqlProcessor, ZSqlMetadata;

type

  {** Implements a bug report test case for PostgreSQL components. }
  TZTestCompPostgreSQLBugReport = class(TZAbstractCompSQLTestCase)
  protected
    function GetSupportedProtocols: string; override;
  published
    procedure Test707339;
    procedure Test707337;
    procedure Test707338;
    procedure Test709879;
    procedure Test727373;
    procedure Test739519;
    procedure Test739444;
    procedure Test759184;
    procedure Test765111;
    procedure Test766053;
    procedure Test816846;
    procedure Test824780;
    procedure Test815854;
    procedure Test831559;
    procedure Test894367;
    procedure Test933623;
    procedure Test994562;
    procedure Test1043252;
    procedure TestMantis240;
  end;

  TZTestCompPostgreSQLBugReportMBCs = class(TZAbstractCompSQLTestCaseMBCs)
  protected
    function GetSupportedProtocols: string; override;
  public
    procedure TestStandartConfirmingStrings(Query: TZQuery; Connection: TZConnection);
  published
    procedure TestStandartConfirmingStringsOn;
    procedure TestStandartConfirmingStringsOff;
  end;
implementation

uses ZSysUtils, ZTestCase;

{ TZTestCompPostgreSQLBugReport }

function TZTestCompPostgreSQLBugReport.GetSupportedProtocols: string;
begin
  Result := pl_all_postgresql;
end;

{**
  Test the bug report #707339.

  create table booltest(
   colnn bool not null,
   col   bool null
  );

  insert into booltest( colnn, col ) values( true, true );
  insert into booltest( colnn, col ) values( false, false );

  select * from booltest;

  When I open this query and show all rows in DBGrid all is good,
  but when i read fields manualy every field value returns "True".
}
procedure TZTestCompPostgreSQLBugReport.Test707339;
(*
var
  Query: TZQuery;
*)
begin
  if SkipForReason(srClosedBug) then Exit;
(*
  Query := CreateQuery;
  try
    Query.Connection := Connection;
    Query.SQL.Text := 'SELECT COLNN, COL FROM booltest';
    Query.Open;
    CheckEquals('True', Query.FieldByName('COLNN').AsString);
    CheckEquals('True', Query.FieldByName('COL').AsString);
    Query.Next;
    CheckEquals('False', Query.FieldByName('COLNN').AsString);
    CheckEquals('False', Query.FieldByName('COL').AsString);
    Query.Close;
  finally
    Query.Free;
  end;
*)
end;

{**
  Test the bug report #707337.

  Query:
  select idtab, 'value' as virt_col from tab;

  Column virt_col is not exist in resultset
}
procedure TZTestCompPostgreSQLBugReport.Test707337;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateQuery;
  try
    Query.SQL.Text := 'select p_id, ''value'' as virt_col from people';
    Query.Open;
    CheckEquals('value', Query.FieldByName('virt_col').AsString);
    Query.Close;
  finally
    Query.Free;
  end;
end;

{**
  Test the bug report #707338.

  Query:
  select idtab::text as txt from tab;

  ::text is type cast, not param
}
procedure TZTestCompPostgreSQLBugReport.Test707338;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateQuery;
  try
    Query.ParamCheck := False;
    Query.SQL.Text := 'select p_id::text as txt from people';
    Query.Open;
    Query.Close;
  finally
    Query.Free;
  end;
end;

{**
  Test the bug report #709879.

  "Out of memory" when field is interval(n)
}
procedure TZTestCompPostgreSQLBugReport.Test709879;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateQuery;
  try
    Query.SQL.Text := 'select now() - now() as timediff';
    Query.Open;
    Check(StartsWith(Query.FieldByName('timediff').AsString, '00:00'));
    Query.Close;
  finally
    Query.Free;
  end;
end;

procedure TZTestCompPostgreSQLBugReport.Test727373;
var
  Query: TZQuery;
  UpdateSql: TZUpdateSQL;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateQuery;
  try
    UpdateSql := TZUpdateSQL.Create(nil);
    try
      Query.SQL.Text := 'delete from people where p_id >= ' + IntToStr(TEST_ROW_ID);
      Query.ExecSQL;

      Query.SQL.Text := 'select p.*, d.dep_name from people p ' +
        ' left outer join department d on p.p_id = d.dep_id ' +
        ' where p_id = ' + IntToStr(TEST_ROW_ID);
      Query.UpdateObject := UpdateSql;
      UpdateSql.InsertSQL.Text := 'insert into people (p_id, p_name, p_begin_work, ' +
        ' p_end_work) values (:p_id, :p_name, :p_begin_work, :p_end_work)';
      UpdateSql.ModifySQL.Text := 'update people set p_id = :p_id, p_name = :p_name, ' +
        ' p_begin_work = :p_begin_work, p_end_work = :p_end_work where p_id = :OLD_p_id';
      UpdateSql.DeleteSQL.Text := 'delete from people where p_id = :OLD_p_id';
      UpdateSql.Params.ParamByName('p_id').DataType := ftInteger;
      UpdateSql.Params.ParamByName('p_id').ParamType := ptInput;
      UpdateSql.Params.ParamByName('p_name').DataType := ftString;
      UpdateSql.Params.ParamByName('p_name').ParamType := ptInput;
      UpdateSql.Params.ParamByName('p_begin_work').DataType := ftTime;
      UpdateSql.Params.ParamByName('p_begin_work').ParamType := ptInput;
      UpdateSql.Params.ParamByName('p_end_work').DataType := ftTime;
      UpdateSql.Params.ParamByName('p_end_work').ParamType := ptInput;
      UpdateSql.Params.ParamByName('OLD_p_id').DataType := ftInteger;
      UpdateSql.Params.ParamByName('OLD_p_id').ParamType := ptInput;

      Query.Open;
      Query.Append;
      Query.FieldByName('p_id').AsInteger := TEST_ROW_ID;
      Query.FieldByName('p_name').AsString := 'Vasia';
      Query.FieldByName('p_begin_work').AsDateTime := EncodeTime(9, 30, 0, 0);
      Query.FieldByName('p_end_work').AsDateTime := EncodeTime(18, 30, 0, 0);
      Query.Post;
      Query.ApplyUpdates;
      Query.Close;

      Query.Open;
      CheckEquals(False, Query.IsEmpty);
      CheckEquals(TEST_ROW_ID, Query.FieldByName('p_id').AsInteger);
      CheckEquals('Vasia', Query.FieldByName('p_name').AsString);
      CheckEquals(EncodeTime(9, 30, 0, 0), Query.FieldByName('p_begin_work').AsDateTime);
      CheckEquals(EncodeTime(18, 30, 0, 0), Query.FieldByName('p_end_work').AsDateTime);
      Query.Edit;
      Query.FieldByName('p_id').AsInteger := TEST_ROW_ID;
      Query.FieldByName('p_name').AsString := 'Petia';
      Query.FieldByName('p_begin_work').AsDateTime := EncodeTime(10, 0, 0, 0);
      Query.FieldByName('p_end_work').AsDateTime := EncodeTime(19, 0, 0, 0);
      Query.Post;
      Query.ApplyUpdates;
      Query.Close;

      Query.Open;
      CheckEquals(False, Query.IsEmpty);
      CheckEquals(TEST_ROW_ID, Query.FieldByName('p_id').AsInteger);
      CheckEquals('Petia', Query.FieldByName('p_name').AsString);
      CheckEquals(EncodeTime(10, 0, 0, 0), Query.FieldByName('p_begin_work').AsDateTime, 0.001);
      CheckEquals(EncodeTime(19, 0, 0, 0), Query.FieldByName('p_end_work').AsDateTime, 0.001);
      Query.Delete;
      Query.ApplyUpdates;
      Query.Close;

      Query.Open;
      CheckEquals(True, Query.IsEmpty);
    finally
      UpdateSql.Free;
    end;
  finally
    Query.Free;
  end;
end;

{**
  Test the bug report #739519.

  After posting updates AffectedRows property is always 0.
}
procedure TZTestCompPostgreSQLBugReport.Test739519;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateQuery;
  try
    Query.SQL.Text := 'delete from test739519';
    Query.ExecSQL;

    Query.SQL.Text := 'insert into test739519 (id, fld, fld1)'
      + ' values (1, ''aaa'', ''bbb'')';
    Query.ExecSQL;
    CheckEquals(1, Query.RowsAffected);

    Query.SQL.Text := 'insert into test739519 (id, fld, fld1)'
      + ' values (2, ''ccc'', ''ddd'')';
    Query.ExecSQL;
    CheckEquals(1, Query.RowsAffected);

    Query.SQL.Text := 'update test739519 set fld = ''xyz''';
    Query.ExecSQL;
    CheckEquals(2, Query.RowsAffected);

    Query.SQL.Text := 'delete from test739519';
    Query.ExecSQL;
    CheckEquals(2, Query.RowsAffected);
  finally
    Query.Free;
  end;

end;

{**
  Test the bug report #739444.

  Aliases for fields do not work. Result Set after
  execution SQL query do not contain the aliased fields.
}
procedure TZTestCompPostgreSQLBugReport.Test739444;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateQuery;
  try
    // Query.RequestLive := True;
    Query.SQL.Text := 'select count(*) as items, sum(c_weight) as total, '+
      ' AVG(c_width) as average from cargo ';
    Query.Open;

    CheckEquals('items', Query.Fields[0].FieldName);
    CheckEquals('total', Query.Fields[1].FieldName);
    CheckEquals('average', Query.Fields[2].FieldName);
    CheckEquals(4, Query.Fields[0].AsInteger);
    CheckEquals(8434, Query.Fields[1].AsInteger);
    CheckEquals(8.5, Query.Fields[2].AsFloat, 0.01);
    Query.Close;
  finally
    Query.Free;
  end;
end;

{**
  Test the bug report #759184.

  Empty fields in string concatination expression.
}
procedure TZTestCompPostgreSQLBugReport.Test759184;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateQuery;
  try
    Query.SQL.Text := 'select p_id || p_name as expr from people where p_id=1';
    Query.Open;

    CheckEquals('expr', Query.Fields[0].FieldName);
    CheckEquals('1Vasia Pupkin', Query.Fields[0].AsString);
    Query.Close;
  finally
    Query.Free;
  end;
end;

procedure TZTestCompPostgreSQLBugReport.Test765111;
var
  Batch: TZSqlProcessor;
begin
  if SkipForReason(srClosedBug) then Exit;

  Connection.AutoCommit := True;
  Batch := TZSqlProcessor.Create(nil);
  try
    Batch.Connection := Connection;
    Batch.Connection.AutoCommit := False;
    Batch.Script.Text := 'DELETE FROM people where p_id = '
      + IntToStr(TEST_ROW_ID);
    Batch.Execute;
    Connection.Rollback;
  finally
    Batch.Free;
  end;
end;

{**
  Test the bug report #766053.

  Invalid variant type conversion when using TDBLookupComboBox
}
procedure TZTestCompPostgreSQLBugReport.Test766053;
{$IFNDEF LINUX}
var
  Query1, Query2: TZQuery;
  DSQuery1, DSQuery2: TDataSource;
  LookUp: TDBLookupComboBox;
{$ENDIF}
begin
  if SkipForReason(srClosedBug) then Exit;

{$IFNDEF LINUX}
  Query1 := CreateQuery;
  Query2 := CreateQuery;
  DSQuery1 := TDataSource.Create(nil);
  DSQuery2 := TDataSource.Create(nil);
  LookUp := TDBLookupComboBox.Create(nil);;
  try
    Query1.SQL.Text := 'select * from test766053a';
    Query2.SQL.Text := 'select * from test766053b';
    DSQuery1.DataSet := Query1;
    DSQuery2.DataSet := Query2;
    LookUp.DataSource := DSQuery1;
    LookUp.ListSource := DSQuery2;
    LookUp.DataField := 'id';
    LookUp.KeyField := 'id';
    LookUp.ListField := 'fld';
    Query1.Open;
    Query2.Open;
  finally
    LookUp.Free;
    Query1.Free;
    Query2.Free;
    DSQuery1.Free;
    DSQuery2.Free;
  end;
{$ENDIF}
end;

{**
  Test the bug report #816846.

  Bad update behavior when no primary key
}
procedure TZTestCompPostgreSQLBugReport.Test816846;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateQuery;
  try
    Query.SQL.Text := 'select fld1, fld2 from test816846 order by fld1';
    Query.Open;

    CheckEquals(2, Query.RecordCount);
    Query.Last;
    Query.Edit;
    Query.Fields[1].AsString := 'd';
    Query.Post;
    CheckEquals('d', Query.Fields[1].AsString);

    Query.Edit;
    Query.Fields[1].AsString := 'ddd';
    Query.Post;
    Query.Refresh;
    Query.Last;
    CheckEquals('ddd', Query.Fields[1].AsString);

    Query.Edit;
    Query.Fields[1].AsString := 'd';
    Query.Post;

    Query.Close;
  finally
    Query.Free;
  end;
end;

{**
  Test the bug report #824780.

  TZMetadata does not show schemas.
}
procedure TZTestCompPostgreSQLBugReport.Test824780;
var
  Metadata: TZSQLMetadata;
begin
  if SkipForReason(srClosedBug) then Exit;

  if Connection.Protocol <> 'postgresql-7' then
    Exit;

  Metadata := TZSQLMetadata.Create(nil);
  try
    Metadata.Connection := Connection;
    Metadata.MetadataType := mdSchemas;
    Metadata.Open;

    Check(Metadata.RecordCount > 0);
    Metadata.Locate('TABLE_SCHEM', 'xyz', []);
    Check(Metadata.Found);

    Metadata.Close;
  finally
    Metadata.Free;
  end;
end;

{**
  Test the bug report #Test815854.

  Problem with support for schemas.
}
procedure TZTestCompPostgreSQLBugReport.Test815854;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;
  if Connection.Protocol <> 'postgresql-7' then
    Exit;

  Query := CreateQuery;
  try
    Query.SQL.Text := 'delete from xyz.test824780';
    Query.ExecSQL;

    // Query.RequestLive := True;
    Query.SQL.Text := 'select fld1, fld2 from xyz.test824780';
    Query.Open;

    CheckEquals(Ord(ftInteger), Ord(Query.Fields[0].DataType));
    CheckEquals(Ord(ftString), Ord(Query.Fields[1].DataType));

    Query.Insert;
    Query.Fields[0].AsInteger := 123456;
    Query.Fields[1].AsString := 'abcdef';
    Query.Post;

    Query.Refresh;
    Check(not Query.Eof);
    CheckEquals(1, Query.RecNo);
    CheckEquals(123456, Query.Fields[0].AsInteger);
    CheckEquals('abcdef', Query.Fields[1].AsString);

    Query.SQL.Text := 'delete from xyz.test824780';
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

{**
  Test the bug report #Test831559.

  Use keywords in column name.
}
procedure TZTestCompPostgreSQLBugReport.Test831559;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateQuery;
  try
    Query.SQL.Text := 'delete from "insert"';
    Query.ExecSQL;

    // Query.RequestLive := True;
    Query.SQL.Text := 'select * from "insert"';
    Query.Open;

    Query.Insert;
    Query.Fields[0].AsString := 'abcdef';
    Query.Fields[1].AsInteger := 123456;
    Query.Post;

    Query.Refresh;
    Check(not Query.Eof);
    CheckEquals(1, Query.RecNo);
    CheckEquals('abcdef', Query.Fields[0].AsString);
    CheckEquals(123456, Query.Fields[1].AsInteger);

    Query.SQL.Text := 'delete from "insert"';
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

{**
  Test the bug report #894367.

  Incorrect parsing of complex queries.
}
procedure TZTestCompPostgreSQLBugReport.Test894367;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateQuery;
  try
    // Query.RequestLive := True;
    Query.SQL.Text := 'SELECT d65.f3 as a,t65.f2 as b,t65.f3 as c'
      + ' FROM test894367a as t65, test894367b as d65'
      + ' WHERE d65.f1=t65.f1';
    Query.Open;

    if (Connection.DbcConnection.GetConSettings.CPType = cCP_UTF16 ) then
      CheckEquals(ord(ftWideString), Ord(Query.Fields[0].DataType))
    else
      CheckEquals(Ord(ftString), Ord(Query.Fields[0].DataType));
    CheckEquals(Ord(ftBoolean), Ord(Query.Fields[1].DataType));
    CheckEquals(Ord(ftBoolean), Ord(Query.Fields[2].DataType));

    Query.Close;

    Query.SQL.Text := 'SELECT test894367b.f3,test894367a.f2,test894367a.f3'
      + ' FROM test894367a, test894367b'
      + ' WHERE test894367a.f1=test894367b.f1';
    Query.Open;

    if (Connection.DbcConnection.GetConSettings.CPType = cCP_UTF16 ) then
      CheckEquals(ord(ftWideString), Ord(Query.Fields[0].DataType))
    else
      CheckEquals(Ord(ftString), Ord(Query.Fields[0].DataType));
    CheckEquals(Ord(ftBoolean), Ord(Query.Fields[1].DataType));
    CheckEquals(Ord(ftBoolean), Ord(Query.Fields[2].DataType));

    Query.Close;
  finally
    Query.Free;
  end;
end;

{**
  Test the bug report #933623.
  Command is aborten until the next of transaction block.
}
procedure TZTestCompPostgreSQLBugReport.Test933623;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Connection.AutoCommit := True;
  Connection.TransactIsolationLevel := tiReadCommitted;
  Query := CreateQuery;
  try
    try
      Query.SQL.Text := 'select * from people where xp_id=1';
      Query.Open;
      Fail('Incorrect syntax error processing');
    except
      // Ignore.
    end;

    Query.SQL.Text := 'select * from people where p_id=1';
    Query.Open;

    Query.Close;
  finally
    Query.Free;
  end;
end;

{**
  Test the bug report #894367.
  Incorrect parsing of complex queries.
}
procedure TZTestCompPostgreSQLBugReport.Test994562;
var
  Query: TZReadOnlyQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateReadOnlyQuery;
  try
    Query.SQL.Clear;
    Query.SQL.Append('SELECT *');
    Query.SQL.Append('-- SQL Comment');
    Query.SQL.Append('FROM people');
    Query.SQL.Append('WHERE p_id=:p_id');
    Query.SQL.Append('-- SQL Comment');

    CheckEquals(1, Query.Params.Count);
    Query.Params[0].AsInteger := 1;

    Query.Open;
    CheckEquals(1, Query.RecordCount);
    Query.Close;
  finally
    Query.Free;
  end;
end;

{**
  Test the bug report #1043252.
  "No Argument for format %s" exception.
}
procedure TZTestCompPostgreSQLBugReport.Test1043252;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateQuery;
  try
    Query.SQL.Text := 'select p_name as " xxx xxx " from people where p_id=1';
    Query.Open;

    CheckEquals(1, Query.RecordCount);
    CheckEquals(' xxx xxx ', Query.FieldDefs[0].Name);
    CheckEquals('Vasia Pupkin', Query.Fields[0].AsString);
    CheckEquals('Vasia Pupkin', Query.FieldByName(' xxx xxx ').AsString);

    Query.Close;

    Query.SQL.Text := 'select p_name from people where p_id=1';
    Query.Open;
    Query.FieldDefs[0].DisplayName := ' xxx xxx '; //Changes nothing since which D-Version?

    CheckEquals(1, Query.RecordCount);
    {$IFDEF FPC}
    CheckEquals(' xxx xxx ', Query.FieldDefs[0].Name);
    {$ELSE}
    {$IFDEF VER150BELOW}
    CheckEquals(' xxx xxx ', Query.FieldDefs[0].Name); //EgonHugeist: Changed from ' xxx xxx ' -> select!
    {$ELSE}
    CheckEquals('p_name', Query.FieldDefs[0].Name); //EgonHugeist: Changed from ' xxx xxx ' -> select!
    {$ENDIF}
    {$ENDIF}
    //CheckEquals(' xxx xxx ', Query.FieldDefs[0].DisplayName); //EgonHugeist: The TFieldDef inherites from TCollectionItem! the DisplayName is'nt changeable there. This is only possible if we create a class of TFieldDef and override the SetDisplayName method
    CheckEquals('Vasia Pupkin', Query.Fields[0].AsString);
    CheckEquals('Vasia Pupkin', Query.FieldByName('p_name').AsString);

    Query.Close;
  finally
    Query.Free;
  end;
end;

{** Matin#0000240
Hi!

I tried to run a ZQuery to get the table

"ntax_bejovo_konyvelesi_tipusok"

primary keys.

select r.relname as "Table", c.conname,
contype as "Constraint Type"
from pg_class r, pg_constraint c
where r.oid = c.conrelid;

In PGADMIN and EMS PG Manager I got good result, the:

"ntax_bejovo_konyvelesi_tipusok_pkey"


But Zeos Query is set the Field Size to 32, and I don't found the needed columns of the primary key in the next Query...


When I cast the field:

cast(c.conname as varchar(100)),

the field size is correctly 100.

Is this bug, or this based on "unknown field type" of PG that automatically set to 32... :-(
}
procedure TZTestCompPostgreSQLBugReport.TestMantis240;
var
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  Query := CreateQuery;
  try
    Query.SQL.Text := 'select r.relname as "Table", c.conname, ' +
            ' contype as "Constraint Type" ' +
            ' from pg_class r, pg_constraint c ' +
            ' where r.oid = c.conrelid and r.relname = ''ntax_bejovo_konyvelesi_tipusok''; ';
    Query.Open;
    CheckEquals('ntax_bejovo_konyvelesi_tipusok_pkey', Query.FieldByName('conname').AsString);
  finally
    Query.Free;
  end;
end;

{ TZTestCompPostgreSQLBugReportMBCs }
function TZTestCompPostgreSQLBugReportMBCs.GetSupportedProtocols: string;
begin
  Result := pl_all_postgresql;
end;

procedure TZTestCompPostgreSQLBugReportMBCs.TestStandartConfirmingStrings(Query: TZQuery; Connection: TZConnection);
const
  QuoteString1 = String('\'', 1 --''');
  QuoteString2 = String('�����\000');
begin
  Query.ParamChar := ':';
  Query.ParamCheck := True;
  Query.SQL.Text := 'select cast(:test as TEXT)';

  Query.ParamByName('test').AsString := QuoteString1;
  Query.Open;
  CheckEquals(QuoteString1, Query.Fields[0].AsString);
  Query.Close;

  Query.ParamByName('test').AsString := GetDBTestString(QuoteString2, Connection.DbcConnection.GetConSettings);
  Query.Open;

  CheckEquals(QuoteString2, Query.Fields[0].AsString, Connection.DbcConnection.GetConSettings);
  Query.Close;
end;

procedure TZTestCompPostgreSQLBugReportMBCs.TestStandartConfirmingStringsOn;
var
  TempConnection: TZConnection;          // Attention : local Connection
  Query: TZQuery;
begin
//??  if SkipForReason(srClosedBug) then Exit;

  TempConnection := CreateDatasetConnection;
  TempConnection.Properties.Add('standard_conforming_strings=ON');
  Query := TZQuery.Create(nil);
  Query.Connection := TempConnection;
  try
    TestStandartConfirmingStrings(Query, TempConnection);
  finally
    Query.Free;
    TempConnection.Free;
  end;
end;

procedure TZTestCompPostgreSQLBugReportMBCs.TestStandartConfirmingStringsOff;
var
  TempConnection: TZConnection;
  Query: TZQuery;
begin
  if SkipForReason(srClosedBug) then Exit;

  TempConnection := CreateDatasetConnection;
  TempConnection.Properties.Add('standard_conforming_strings=OFF');
  Query := TZQuery.Create(nil);
  Query.Connection := TempConnection;
  try
    TestStandartConfirmingStrings(Query, TempConnection);
  finally
    Query.Free;
    TempConnection.Free;
  end;
end;

initialization
  RegisterTest('bugreport',TZTestCompPostgreSQLBugReport.Suite);
  RegisterTest('bugreport',TZTestCompPostgreSQLBugReportMBCs.Suite);
end.
