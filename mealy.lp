%{stateRepresentationBits(1..Bits)} = 1 :- maxStateRepresentationBits(Bits).
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
{transitionOutput(StateA, InSymbol, OutSymbol) : symbol(OutSymbol)} = 1 :-
  state(StateA),
  symbol(InSymbol).

output(0, 0).
output(T, SymbolB) :-
  iteration(T),
  stateAt(T, State),
  transitionOutput(State, SymbolA, SymbolB),
  output(T-1, SymbolA).
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
  output(T-1, InSymbol),
  stateAt(T-1, StateA),
  transitionState(StateA, InSymbol, StateB),
  iteration(T).

%output(T, OutSymbol) :- 
%  input(T, InSymbol),
%  stateAt(T, StateA),
%  transitionOutput(StateA, InSymbol, OutSymbol),
%  iteration(T+1).

:~ desired(T, OutSymbolA),
   output(T, OutSymbolB),
   OutSymbolA != OutSymbolB. [1@2, T]
:~ representationSize(Bits). [Bits@1]
#show transitionState/3.
#show transitionOutput/3.
