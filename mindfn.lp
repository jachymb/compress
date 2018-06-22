variable(0..V-1) :- nvars(V).
termNumber(0..t-1).

{ posLit(V, T) : variable(V), termNumber(T) }.
{ negLit(V, T) : variable(V), termNumber(T) }.
:- posLit(V, T), negLit(V, T).

:- posObs(I), negObs(I).
state(I) :- posObs(I).
state(I) :- negObs(I).

termSatisfied(I, T) | -termSatisfied(I, T) :- state(I), termNumber(T).
:- posLit(V, T), -bit(I, V), termSatisfied(I, T).
:- negLit(V, T),  bit(I, V), termSatisfied(I, T).
:- #count{ V : posLit(V, T), -bit(I, V) } = 0,
   #count{ V : negLit(V, T),  bit(I, V) } = 0,
   state(I), termNumber(T),
   -termSatisfied(I, T).

dnfSatisfied(I) :- termSatisfied(I, T), termNumber(T).

:- negObs(I), dnfSatisfied(I).
:- posObs(I), not dnfSatisfied(I).

#minimize{ 1@1, V,T : posLit(V,T) }.
#minimize{ 1@1, V,T : negLit(V,T) }.
%#show termSatisfied/2.
%#show -termSatisfied/2.
#show posLit/2.
#show negLit/2.
