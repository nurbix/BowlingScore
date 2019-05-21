unit BowlingGame;

interface

uses System.Generics.Collections, SysUtils;

type

  IGame = interface
    ['{B1B1825B-A39E-4C12-ABCC-FB8D5A78FABB}']

    procedure Start;
    function Roll(pins: Integer) : Tlist<Integer>;
    function ScoresByFrame: Tlist<Integer>;
    function GetTotalScore: Integer;
    property TotalScore : Integer read GetTotalScore;
  end;


  TGame = class(TInterfacedObject, IGame)
  strict private
    type
      state = (
                FIRST_ROLL,            // First Ball in frame, no Spare, no Strike in previous frame
                SECOND_ROLL,           // Second Ball in frame, no Strike in previous frame
                STRIKE_LAST_ROLL,      // Strike in last Roll
                SPARE_LAST_ROLL,       // Spare in last Roll
                TWO_STRIKES,           // Two Consecutive Strikes
                SEC_ROLL_AFTER_STRIKE  // Second Roll after Strike
              );

    var
      // State of the Game. Will be equal to one of the state enum.
      GameState: state;

      // Frame index, can be 1..10,
      frameIndex: Integer;

      // Current Score of the Game
      GameScore: Integer;

      // Game Scores by frame
      GameScores: TList<Integer>;

      // Number of pins in first roll of the frame
      firstBall: Integer;

      // Maximum possible score
      MaxPossible : Integer;

  private
    function frameNumber : Integer;
    procedure IncreaseScoreBy(Score : Integer);
    procedure DecreaseMaxPossibleBy(Amount : Integer);
  published
    procedure Start;
    function Roll(pins: Integer): TList<Integer>;
    function ScoresByFrame: TList<Integer>;
    function GetTotalScore: Integer;
    Function IsGameOver : Boolean;
    function GetMaxPossible : Integer;
    constructor Create;
    destructor Destroy;
  end;

implementation

function TGame.Roll(pins: Integer) : TList<Integer>;
begin
  if not (pins in [0..10]) then
      raise Exception.Create('Number of pins must be between 0 and 10');

  case GameState of
    FIRST_ROLL:
               begin
                 if pins = 10 then
                   begin
                     GameState := STRIKE_LAST_ROLL;
                     Inc(frameIndex);
                   end
                 else
                   begin
                     firstBall := pins;
                     DecreaseMaxPossibleBy(10);
                     GameState := SECOND_ROLL;
                   end;
               end;

    SECOND_ROLL:
               begin
                 if firstBall + pins = 10 then
                   begin
                     Inc(frameIndex);
                     GameState := SPARE_LAST_ROLL;
                   end
                 else
                   begin
                     Inc(frameIndex);
                     IncreaseScoreBy(firstBall + pins);
                     DecreaseMaxPossibleBy(20 - firstBall - pins);
                     GameState := FIRST_ROLL;
                   end;
               end;

    SPARE_LAST_ROLL:
               begin
                  IncreaseScoreBy(10 + pins);
                  DecreaseMaxPossibleBy(10 - pins);
                  if pins = 10 then
                    begin
                      Inc(frameIndex);
                      GameState := STRIKE_LAST_ROLL;
                    end
                  else
                    begin
                      firstBall := pins;
                      DecreaseMaxPossibleBy(10);
                      GameState := SECOND_ROLL;
                    end;
               end;

    STRIKE_LAST_ROLL:
               begin
                  if pins = 10 then
                    begin
                      Inc(frameIndex);
                      GameState := TWO_STRIKES;
                    end
                  else
                    begin
                      firstBall := pins;
                      DecreaseMaxPossibleBy(20);
                      GameState := SEC_ROLL_AFTER_STRIKE;
                    end;
               end;

    TWO_STRIKES:
               begin
                  IncreaseScoreBy(20 + pins);
                  if pins = 10 then
                    begin
                      Inc(frameIndex);
                    end
                  else
                    begin
                      firstBall := pins;
                      if frameNumber = 10 then
                         DecreaseMaxPossibleBy(10 + (10 - pins))
                      else
                         DecreaseMaxPossibleBy(20 + (10 - pins));
                      GameState := SEC_ROLL_AFTER_STRIKE;
                    end;
               end;

    SEC_ROLL_AFTER_STRIKE:
               begin
                  IncreaseScoreBy(10 + firstBall + pins);
                  if firstBall + pins = 10 then
                    begin
                      Inc(frameIndex);
                      GameState := SPARE_LAST_ROLL;
                    end
                  else
                    begin
                      IncreaseScoreBy(firstBall + pins);
                        //DecreaseMaxPossibleBy(10 + (10 - (firstBall + pins)) + (10 - (firstBall + pins)));
                        DecreaseMaxPossibleBy(30 - 2 * firstBall - 2 * pins);
                      GameState := FIRST_ROLL;
                    end;
               end;
  end;

  Result := GameScores;
end;

constructor TGame.Create;
begin
  frameIndex := 1;
  GameScore := 0;
  MaxPossible := 300;
  GameScores := TList<Integer>.Create;
end;

procedure TGame.DecreaseMaxPossibleBy(Amount: Integer);
begin
   MaxPossible := MaxPossible - Amount;
end;

destructor TGame.Destroy;
begin
  GameScores.Free;
  GameScores := nil;
  Inherited;
end;

function TGame.frameNumber: Integer;
begin
  if GameScores.Count = 10 then
     Result := 11
  else if frameIndex > 10 then
     Result := 10
  else
     Result := FrameIndex;
end;

function TGame.ScoresByFrame: TList<Integer>;
begin
    Result:= GameScores;
end;

procedure TGame.Start;
var
  i: Integer;
begin

  GameState := FIRST_ROLL;
  frameIndex := 1;
  GameScore := 0;
  MaxPossible := 300;
  GameScores.Clear;
end;


function TGame.GetMaxPossible: Integer;
begin
   Result := MaxPossible;
end;

function TGame.GetTotalScore: Integer;
begin
  if GameScores.Count = 11 then
    Result := GameScores[9]
  else
    Result := GameScore;
end;

procedure TGame.IncreaseScoreBy(Score: Integer);
begin
   GameScore := GameScore + Score;
   GameScores.Add(GameScore);
end;

function TGame.IsGameOver: Boolean;
begin
   Result := Self.frameNumber > 10;
end;

end.
