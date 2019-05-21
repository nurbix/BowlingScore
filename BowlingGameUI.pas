unit BowlingGameUI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  BowlingGame;

type

  TForm1 = class(TForm)
    Panel1: TPanel;
    Frame1: TPanel;
    Button13: TButton;
    Shape23: TShape;
    Score1: TLabel;
    Roll1: TLabel;
    Roll2: TLabel;
    Shape24: TShape;
    Frame2: TPanel;
    Shape26: TShape;
    Shape27: TShape;
    Score2: TLabel;
    Roll3: TLabel;
    Roll4: TLabel;
    Button14: TButton;
    Frame4: TPanel;
    Shape28: TShape;
    Shape29: TShape;
    Score4: TLabel;
    Roll7: TLabel;
    Roll8: TLabel;
    Button15: TButton;
    Frame3: TPanel;
    Shape30: TShape;
    Shape31: TShape;
    Score3: TLabel;
    Roll5: TLabel;
    Roll6: TLabel;
    Button16: TButton;
    Frame5: TPanel;
    Shape32: TShape;
    Shape33: TShape;
    Score5: TLabel;
    Roll9: TLabel;
    Roll10: TLabel;
    Button17: TButton;
    Frame6: TPanel;
    Shape34: TShape;
    Shape35: TShape;
    Score6: TLabel;
    Roll11: TLabel;
    Roll12: TLabel;
    Button18: TButton;
    Frame7: TPanel;
    Shape36: TShape;
    Shape37: TShape;
    Score7: TLabel;
    Roll13: TLabel;
    Roll14: TLabel;
    Button19: TButton;
    Frame8: TPanel;
    Shape38: TShape;
    Shape39: TShape;
    Score8: TLabel;
    Roll15: TLabel;
    Roll16: TLabel;
    Button20: TButton;
    Frame9: TPanel;
    Shape40: TShape;
    Shape41: TShape;
    Score9: TLabel;
    Roll17: TLabel;
    Roll18: TLabel;
    Button21: TButton;
    Frame10: TPanel;
    Shape42: TShape;
    Shape43: TShape;
    Score10: TLabel;
    Roll19: TLabel;
    Roll20: TLabel;
    Button22: TButton;
    Panel13: TPanel;
    Shape44: TShape;
    TotalScore: TLabel;
    Button23: TButton;
    Panel14: TPanel;
    Shape46: TShape;
    FinalScore: TLabel;
    Button24: TButton;
    Shape48: TShape;
    Roll21: TLabel;
    NewGamebtn: TButton;
    procedure RollButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NewGamebtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure changeVisibility(pin: Integer);
    procedure ChangePinBtnsVisibility(iStart, iEnd: Integer; Visibility: Boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  arrPinsBtns: Array [0 .. 10] of TButton;
  arrPinsPnls: Array [1 .. 10] of TPanel;

implementation

{$R *.dfm}

var
  Game: TGame;
  SecPanel: TPanel;
  ScoreIndex: Integer;
  Scores: TList<Integer>;
  Score: Integer;

  RollIndex: Integer;
  FirstBall10thFrame : Integer;

procedure TForm1.RollButtonClick(Sender: TObject);
var
  I, RollNum: Integer;
  PinCaption: String;
begin
  RollNum := StrToInt((Sender as TButton).Caption);
  PinCaption := IntToStr(RollNum);
  changeVisibility(RollNum);

  Scores := Game.Roll(RollNum);

  for I := ScoreIndex - 1 to Scores.Count - 1 do
  begin
    Score := Scores[I];
    (FindComponent('Score' + IntToStr(ScoreIndex)) as TLabel).Caption :=
      IntToStr(Score);
    Inc(ScoreIndex);
  end;

  if (RollNum = 10) AND ((RollIndex mod 2 = 1) OR (RollIndex >= 19)) then
  begin
    PinCaption := 'X';
    if (RollIndex < 19) then
      Inc(RollIndex);
  end;

  (FindComponent('Roll' + IntToStr(RollIndex)) as TLabel).Caption := PinCaption;

  if (RollIndex >= 19) and (Rollnum <> 10) then
     FirstBall10thFrame := RollNum;
  Inc(RollIndex);

  TotalScore.Caption := Game.GetTotalScore.ToString;
  FinalScore.Caption := Game.GetMaxPossible.ToString;

  if Game.IsGameOver then
  begin
    Panel1.Enabled := false;
    FinalScore.Caption := Game.GetTotalScore.ToString;
    ChangePinBtnsVisibility(0, 10, True);
  end;

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  pin: Integer;
begin
  //pin := StrToInt(Edit1.Text);
  Game.Roll(pin);
end;

procedure TForm1.changeVisibility(pin: Integer);
var
  I: Integer;
begin
  if ((RollIndex mod 2 = 1) and (pin <> 10) and (RollIndex < 19))
      OR ((RollIndex >= 19) and (FirstBall10thFrame + pin <> 10)) then
    ChangePinBtnsVisibility(11 - pin, 10, False)
  else
    ChangePinBtnsVisibility(0, 10, true);

end;

procedure TForm1.ChangePinBtnsVisibility(iStart, iEnd: Integer; Visibility: Boolean);
var
  I: Integer;
begin
  for I := iStart to iEnd do
    arrPinsBtns[I].Visible := Visibility;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Game.Destroy;
  Scores.Clear;
end;

procedure TForm1.FormCreate(Sender: TObject);
const
  ButtonWidth  = 50;
  ButtonHeight = 50;
  Space        = 10;
var
  I, iLeft: Integer;
begin
  Game := TGame.Create;

  iLeft := 16;
  for I := 0 to 10 do
  begin
    arrPinsBtns[I] := TButton.Create(Form1);

    with arrPinsBtns[I] do
    begin
      Parent := Panel1;
      Caption := IntToStr(I);
      Width := ButtonWidth;
      Height := ButtonHeight;
      Left := iLeft;
      Top := 16;
      Font.Style := [fsBold];

      OnClick := RollButtonClick;
    end;

    iLeft := iLeft + ButtonWidth + Space;
  end;

end;

procedure TForm1.FormShow(Sender: TObject);
begin
  NewGamebtn.Click;
end;

procedure TForm1.NewGamebtnClick(Sender: TObject);
var
  I: Integer;
begin
  Game.Start;

  if Scores = nil then
    Scores := TList<Integer>.Create
  else
    Scores.Clear;

  RollIndex := 1;
  ScoreIndex := 1;
  FirstBall10thFrame := 0;

  for I := 1 to 10 do
    (FindComponent('Score' + IntToStr(I)) as TLabel).Caption := '';

  for I := 1 to 21 do
    (FindComponent('Roll' + IntToStr(I)) as TLabel).Caption := '';

  TotalScore.Caption := '';
  FinalScore.Caption := '';

  Panel1.Enabled := true;
  ChangePinBtnsVisibility(0, 10, true);

end;

end.
