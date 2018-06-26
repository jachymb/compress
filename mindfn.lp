variable(0..V-1) :- nvars(V).
%hiddenVariable(V-H .. V-1) :- nvars(V), hidden(H).
termNumber(0..t-1).

{ literal(V, T) : variable(V), termNumber(T) }.
{ -literal(V, T) : variable(V), termNumber(T) }.

state(I) :- obs(I).
state(I) :- -obs(I).

termSatisfied(I, T) | -termSatisfied(I, T) :- state(I), termNumber(T).
:- literal(V, T), -bit(I, V), termSatisfied(I, T).
:- -literal(V, T),  bit(I, V), termSatisfied(I, T).
:- #count{ V : literal(V, T), -bit(I, V) } = 0,
   #count{ V : -literal(V, T),  bit(I, V) } = 0,
   state(I), termNumber(T),
   -termSatisfied(I, T).

dnfSatisfied(I) :- termSatisfied(I, T), termNumber(T).

:~ -obs(I), dnfSatisfied(I). [1@2, I]
:~ obs(I), not dnfSatisfied(I). [1@2, I]

:~ literal(V,T). [1@1, V, T]
:~ -literal(V,T). [1@1, V, T]

%bit(I, H) | -bit(I, H) :- state(I), hiddenVariable(H).

%#minimize{ 1@1, V,T : literal(V,T) }.
%#minimize{ 1@1, V,T : -literal(V,T) }.
%#show termSatisfied/2.
%#show -termSatisfied/2.
#show literal/2.
#show -literal/2.
