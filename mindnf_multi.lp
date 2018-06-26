variable(0..V-1) :- nvars(V).
hiddenVariable(V-H .. V-1) :- nvars(V), hidden(H).
termNumber(0..t-1).

{ literal(V, T, W) : variable(V), termNumber(T), variable(W) }.
{ -literal(V, T, W) : variable(V), termNumber(T), variable(W) }.

state(I) :- obs(I, _).
state(I) :- -obs(I, _).

termSatisfied(I, T, W) | -termSatisfied(I, T, W) :- state(I), termNumber(T), variable(W).
:- literal(V, T, W), not bit(I, V), termSatisfied(I, T, W).
:- -literal(V, T, W),  bit(I, V), termSatisfied(I, T, W).
:- #count{ V : literal(V, T, W), not bit(I, V) } = 0,
   #count{ V : -literal(V, T, W),  bit(I, V) } = 0,
   state(I),
   termNumber(T),
   variable(W),
   -termSatisfied(I, T, W).

dnfSatisfied(I, W) :- termSatisfied(I, T, W), termNumber(T).

:~ -obs(I, W), dnfSatisfied(I, W). [1@3, I, W]
:~ obs(I, W), not dnfSatisfied(I, W). [1@3, I, W]

:~ literal(V,T,W). [1@1, V, T, W]
:~ -literal(V,T,W). [1@1, V, T, W]

{hiddenBit(I, H)} :- state(I), hiddenVariable(H).
bit(I, V) :- hiddenBit(I, V).
:~ hiddenBit(I, H). [1@2, I, H]


%#minimize{ 1@1, V,T : literal(V,T) }.
%#minimize{ 1@1, V,T : -literal(V,T) }.
%#show termSatisfied/2.
%#show -termSatisfied/2.
#show literal/3.
#show -literal/3.
#show hiddenBit/2.
%#show -hiddenBit/2.
