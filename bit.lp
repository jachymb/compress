 bit(I, V) :- (2**V) & I = 2**V, variable(V), state(I).
-bit(I, V) :- (2**V) & I = 0,    variable(V), state(I).


