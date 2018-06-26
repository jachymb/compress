%{stateRepresentationBits(1..Bits)} = 1 :- maxStateRepresentationBits(Bits).
stateRepresentationBits(b).
states(2**Bits) :- stateRepresentationBits(Bits).
state(0 .. NumStates - 1) :- states(NumStates).
iteration(1..Max) :- iterations(Max).

%{inputSize(T) : iteration(T)} = 1.

symbols(2**Bits) :- symbolRepresentationBits(Bits).
symbol(0..N-1) :- symbols(N).

representationSize(States*In*States + States*In*Out) :-
  states(States),
  symbolRepresentationBits(In),
  symbolRepresentationBits(Out).

{transitionState(StateA, InSymbol, StateB) : state(StateB)} = 1 :-
  state(StateA),
  symbol(InSymbol).
{transitionOutput(StateA, InSymbol)} :-
  state(StateA),
  symbol(InSymbol).

output(T) :-
  iteration(T),
  stateAt(T, State),
  transitionOutput(State, 1),
  output(T-1).
output(T) :-
  iteration(T),
  stateAt(T, State),
  transitionOutput(State, 0),
  not output(T-1).
%{input(T, InSymbol) : symbol(InSymbol)} = 1 :-
%  T=0..InputSize-1,
%  inputSize(InputSize).
%input(T, OutInSymbol) :-
%  T = InputSize..Max,
%  inputSize(InputSize),
%  iterations(Max),
%  output(T - InputSize, OutInSymbol).

stateAt(0, 0).
stateAt(T, StateB) :-
  output(T-1),
  stateAt(T-1, StateA),
  transitionState(StateA, 1, StateB),
  iteration(T).
stateAt(T, StateB) :-
  not output(T-1),
  stateAt(T-1, StateA),
  transitionState(StateA, 0, StateB),
  iteration(T).


%output(T, OutSymbol) :- 
%  input(T, InSymbol),
%  stateAt(T, StateA),
%  transitionOutput(StateA, InSymbol, OutSymbol),
%  iteration(T+1).

:~ desired(T),
   not output(T). [1@2, T]
:~ not desired(T),
   output(T). [1@2, T] 
:~ representationSize(Bits). [Bits@1]
:~ iterations(MaxT), symbolRepresentationBits(Bits). [Bits * MaxT @ 0]
#show transitionState/3.
#show transitionOutput/2.
