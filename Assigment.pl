% X = bomb
% D = domino

% up is loc-y
% down is loc+y
% right is loc+1
% left is loc-1

%Creates initial state space with bombs
createSpace([X|[Y|_]],Locations,Space) :-
    %length of the list
    Len is X*Y,
    length(TempSpace, Len),
    placeBombs(Locations,Y,TempSpace,Space),!.


placeBombs([],_,Space,Space).
placeBombs([ [X|[Y|_] ] |T],YCoord,TempSpace,Space):-
    %location of the bomb
    Loc is ((X-1)*YCoord)+Y,
    placeBomb(Loc,TempSpace,TempTempSpace),
    placeBombs(T,YCoord,TempTempSpace,Space).


%places the bomb in the correct index
placeBomb(1,[_|T],['X'|T]).
placeBomb(Loc,[H|T],[H|OutSpace]):-
    Nloc is Loc-1,
    placeBomb(Nloc,T,OutSpace).



%createSpace(Size,BLocations,Space).
