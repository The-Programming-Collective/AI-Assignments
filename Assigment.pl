%Creates an empty space state with propper size
createSpace([X|T],Locations,Space) :-
    T = [Y|_],
    %length of the list
    Len is X*Y,
    length(TempSpace, Len),
    placeBombs(Locations,Y,TempSpace,Space).


placeBombs([],_,Space,Space).
placeBombs([H|T],YCoord,TempSpace,Space):-
    H = [X|T1],
    T1 = [Y|_],
    %location of the bomb
    Loc is ((X-1)*YCoord)+Y,
    placeBomb(Loc,TempSpace,TempTempSpace),
    placeBombs(T,YpcoCoord,TempTempSpace,Space).


%places the bomb in the correct index
placeBomb(1,[_|T],['X'|T]).
placeBomb(Loc,[H|T],[H|OutSpace]):-
    Nloc is Loc-1,
    placeBomb(Nloc,T,OutSpace).


%Creates initial state space with bombs
createSpace(Size,BLocations,Space).
