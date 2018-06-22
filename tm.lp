timestamp(1 .. MaxTimestamp) :- maxtime(MaxTimestamp).
memoryCell(0 .. MemorySize - 1) :- memorySize(MemorySize).
states(2**Bits) :- stateRepresentationBits(Bits).
tapeSymbols(2**Bits) :- tapeSymbolRepresentationBits(Bits).
state(0 .. NumStates - 1) :- states(NumStates).
haltState(NumStates - 1) :- states(NumStates).
-haltState(0 .. NumStates - 2) :- states(NumStates).
tapeSymbol(0 .. NumTapeSymbols - 1) :- tapeSymbols(NumTapeSymbols).
direction(-MaxJump .. -1; 1 .. MaxJump) :-
  directionRepresentationBits(Bits),
  MaxJump = 2**(Bits-1).

transitionTableSize((NumStates - 1) * NumTapeSymbols) :-
  states(NumStates),
  tapeSymbols(NumTapeSymbols).

representationSize(TableSize * EntrySize) :-
  stateRepresentationBits(StateRepresentationBits),
  tapeSymbolRepresentationBits(TapeSymbolRepresentationBits),
  directionRepresentationBits(DirectionRepresentationBits),
  transitionTableSize(TableSize),
  EntrySize = StateRepresentationBits + TapeSymbolRepresentationBits + DirectionRepresentationBits.
problemSize(Size) :- Size = #max{ (1+Position) : desired(Position, _) }.
compressRatio(ProblemSize / RepresentationSize) :- 
  problemSize(ProblemSize),
  representationSize(RepresentationSize).


{transitionState(StateA, TapeSymbol, StateB) : state(StateB)} = 1 :-
  tapeSymbol(TapeSymbol),
  -haltState(StateA).
{transitionDirection(State, TapeSymbol, Direction) : direction(Direction)} = 1 :-
  tapeSymbol(TapeSymbol),
  -haltState(State).
{transitionTapeSymbol(State, TapeSymbolA, TapeSymbolB) : tapeSymbol(TapeSymbolB)} = 1 :-
  tapeSymbol(TapeSymbolA),
  -haltState(State).


headPosition(0, 0).
headPosition(Timestamp + 1, (Position + Direction + MemorySize) \ MemorySize) :-
  headPosition(Timestamp, Position),
  stateAt(Timestamp, State),
  memoryCellAt(Timestamp, Position, TapeSymbol),
  transitionDirection(State, TapeSymbol, Direction),
  timestamp(Timestamp + 1),
  memorySize(MemorySize).

memoryCellAt(0, Position, 0) :- memoryCell(Position).
memoryCellAt(Timestamp + 1, Position, TapeSymbol) :-
  memoryCellAt(Timestamp, Position, TapeSymbol),
  not headPosition(Timestamp, Position),
  timestamp(Timestamp + 1),
  stateAt(Timestamp, State),
  -haltState(State).
memoryCellAt(Timestamp + 1, Position, TapeSymbolB) :-
  headPosition(Timestamp, Position), 
  stateAt(Timestamp, State),
  memoryCellAt(Timestamp, Position, TapeSymbolA),
  transitionTapeSymbol(State, TapeSymbolA, TapeSymbolB),
  timestamp(Timestamp + 1),
  -haltState(State).

stateAt(0,0).
stateAt(Timestamp + 1, StateB) :-
   stateAt(Timestamp, StateA),
   headPosition(Timestamp, Position),
   memoryCellAt(Timestamp, Position, TapeSymbol),
   transitionState(StateA, TapeSymbol, StateB),
   timestamp(Timestamp + 1).

{success(Timestamp) : timestamp(Timestamp)} = 1.
:- success(Timestamp), stateAt(Timestamp, State), -haltState(State).
:- success(Timestamp), desired(Position, TapeSymbol), not memoryCellAt(Timestamp, Position, TapeSymbol).


% Optimization
maxPosition(MaxPosition) :- MaxPosition = #max{Position : headPosition(_, Position)}.
#minimize {MaxPosition@1, MaxPosition : maxPosition(MaxPosition) }.
#minimize {Timestamp@2, Timestamp : success(Timestamp)}.
#minimize {Bits@3, Bits : representationSize(Bits)}.

% Sanity checks - in normal cases should not make any difference:
%:- headPosition(Timestamp, PositionA), headPosition(Timestamp, PositionB), PositionA != PositionB.
%:- memoryCellAt(Timestamp, Position, TapeSymbolA), memoryCellAt(Timestamp, Position, TapeSymbolB), TapeSymbolA != TapeSymbolB.
%:- stateAt(Timestamp, StateA), stateAt(Timestamp, StateB), StateA != StateB.
:- desired(Position, _), not memoryCell(Position).
:- desired(_, TapeSymbol), not tapeSymbol(TapeSymbol).
:- stateRepresentationBits(Bits), Bits < 1.
:- tapeSymbolRepresentationBits(Bits), Bits < 1.
:- desired(Position, _), memorySize(MemorySize), MemorySize <= Position.
:- desired(Position, TapeSymbol), TapeSymbol != 0, maxtime(MaxTimestamp), MaxTimestamp <= Position.

tapeSymbolRepresentationBits(1).
stateRepresentationBits(2).
directionRepresentationBits(1).
memorySize(20).
maxtime(40).
desired(7, 1).

#show representationSize/1.
#show problemSize/1.
#show transitionState/3.
#show transitionDirection/3.
#show transitionTapeSymbol/3.
#show success/1.
#show direction/1.
#show transitionTableSize/1.
#show compressRatio/1.
%#show memoryCellAt/3.
%#show headPosition/2.
%#show stateAt/2.
