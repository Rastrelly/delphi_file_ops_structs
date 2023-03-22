unit udelphifostructs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  staff = record
    name,surname:string;
    age:integer;
    post:integer;
  end;

  staffarr =  array of staff;

  { TForm1 }

  TForm1 = class(TForm)
    btnAdd: TButton;
    btnModify: TButton;
    btnRemove: TButton;
    btnSaveDb: TButton;
    btnLoadDb: TButton;
    cbPost: TComboBox;
    edName: TEdit;
    edSName: TEdit;
    edAge: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    listRecords: TListBox;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SaveDialog1: TSaveDialog;
    procedure btnLoadDbClick(Sender: TObject);
    procedure btnSaveDbClick(Sender: TObject);
    procedure SaveDatabase(fn:string);
    procedure LoadDatabase(fn:string);
    procedure listRecordsClick(Sender: TObject);
    procedure ReadStaff(var cstaff:staff);
    procedure WriteStaff(cstaff:staff);
    procedure RefreshWorkerList;
    procedure btnAddClick(Sender: TObject);
    procedure btnModifyClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  workers:staffarr;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.SaveDatabase(fn:string);
var dbFile:TextFile;
    i,l:integer;
begin
  l:=Length(workers);
  AssignFile(dbFile,fn);
  Rewrite(dbFile);

  WriteLn(dbFile,'data='+inttostr(l)+';');

  if (l>0) then
  begin
    for i:=0 to l-1 do
    begin
      WriteLn(dbFile,'newentry=;');
      WriteLn(dbFile,'name='+workers[i].name+';');
      WriteLn(dbFile,'sname='+workers[i].surname+';');
      WriteLn(dbFile,'age='+inttostr(workers[i].age)+';');
      WriteLn(dbFile,'post='+inttostr(workers[i].post)+';');
    end;
  end;

  CloseFile(dbFile);

end;


procedure TForm1.LoadDatabase(fn:string);
var dbFile:TextFile;
    i,l,ll,cw,csi:integer;
    cline:string;
    word1, word2:string;
    cs:char;
begin
  SetLength(workers,0);
  AssignFile(dbFile,fn);
  Reset(dbFile);
  cw:=-1;

  while not eof(dbFile) do
  begin
    ReadLn(dbFile,cline);
    ShowMessage(cline);
    ll:=Length(cline);
    cs:=cline[1]; csi:=1;
    word1:=''; word2:='';
    while (cs<>'=') do
    begin
      word1:=word1+cs;
      inc(csi);
      cs:=cline[csi];
    end;
    while (cs<>';') do
    begin
      if not (cs='=') then
        word2:=word2+cs;
      inc(csi);
      cs:=cline[csi];
    end;

    Memo1.Lines.Add(word1+' = '+word2);

    if (word1='data') then
    begin
      SetLength(workers,strtoint(word2));
      Memo1.Lines.Add('Set workers length to: '+IntToStr(length(workers)));
    end;
    if (word1='name') then
    begin
      workers[High(cw)].name:=word2;
    end;
    if (word1='sname') then
    begin
      workers[High(cw)].surname:=word2;
    end;
    if (word1='age') then
    begin
      workers[High(cw)].age:=strtoint(word2);
    end;
    if (word1='post') then
    begin
      workers[High(cw)].post:=strtoint(word2);
    end;
    if (word1='newentry') then
    begin
      inc(cw);
    end;
  end;

  CloseFile(dbFile);

  RefreshWorkerList;

end;

procedure TForm1.btnSaveDbClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    SaveDatabase(SaveDialog1.FileName);
  end;
end;

procedure TForm1.btnLoadDbClick(Sender: TObject);
begin
  if (OpenDialog1.Execute) then
  begin
       LoadDatabase(OpenDialog1.FileName);
  end;
end;

function addArrElem(var arr:staffarr):integer;
begin
  setlength(arr,length(arr)+1);
  result:=Length(arr)-1;
end;

procedure removeArrElem(index:integer; var arr:staffarr);
var i,l:integer;
begin
  l:=Length(arr);
  if (l>1) then
  begin
    if (index>0) and (index<l) then
    begin
      for i:=index to l-2 do
      begin
        arr[i]:=arr[i+1];
      end;
      SetLength(arr,Length(arr)-1);
    end;
  end
  else
  begin
    SetLength(arr,0);
  end;
end;

procedure TForm1.ReadStaff(var cstaff:staff);
begin
  cstaff.name:=edName.Text;
  cstaff.surname:=edSName.Text;
  TryStrToInt(edAge.Text,cstaff.age);
  cstaff.post:=cbPost.ItemIndex;
end;

procedure TForm1.listRecordsClick(Sender: TObject);
begin
  if (listRecords.ItemIndex<>-1) then
  begin
    WriteStaff(workers[listRecords.ItemIndex]);
  end;
end;

procedure TForm1.WriteStaff(cstaff:staff);
begin
  edName.Text:=cstaff.name;
  edSName.Text:=cstaff.surname;
  edAge.Text:=inttostr(cstaff.age);
  cbPost.ItemIndex:=cstaff.post;
end;

procedure TForm1.RefreshWorkerList;
var i,l:integer;
begin
  listRecords.Clear;
  l:=Length(workers);
  if (l>0) then
  begin
    for i:=0 to l-1 do
    begin
      listRecords.Items.Add(workers[i].name+' '+workers[i].surname);
    end;
  end;
end;

procedure TForm1.btnAddClick(Sender: TObject);
var el:integer;
begin
  el:=addArrElem(workers);
  ReadStaff(workers[el]);
  RefreshWorkerList;
end;

procedure TForm1.btnModifyClick(Sender: TObject);
var el:integer;
begin
  if (listRecords.ItemIndex<>-1) then
  begin
    el:=listRecords.ItemIndex;
    ReadStaff(workers[el]);
  end;
  RefreshWorkerList;
end;

procedure TForm1.btnRemoveClick(Sender: TObject);
var el:integer;
begin
  if (listRecords.ItemIndex<>-1) then
  begin
    el:=listRecords.ItemIndex;
    removeArrElem(el,workers);
  end;
  RefreshWorkerList;
end;

end.

