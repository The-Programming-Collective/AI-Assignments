% X = bomb
% D = domino
% - = empty

% up is loc-y
% down is loc+y
% right is loc+1
% left is loc-1


replace_element(List, Index, OldValue, NewValue, Result) :-
    nth0(Index, List, OldValue, Temp),
    nth0(Index, Result, NewValue, Temp).


%Creates initial state space with bombs
createSpace([X|[Y|_]],Locations,Space) :-
    %length of the list
    Len is X*Y,
    length(TempSpace, Len),
    findall('-', between(1, Len, _), TempSpace),
    placeBombs(Locations,Y,TempSpace,Space),!.


placeBombs([],_,Space,Space).
placeBombs([ [X|[Y|_] ] |T],YCoord,TempSpace,Space):-
    %location of the bomb
    Loc is ((X-1)*YCoord)+(Y-1),
    replace_element(TempSpace,Loc,'-','X',TempTempSpace),
    placeBombs(T,YCoord,TempTempSpace,Space).


placeDomino(State,Size,Next):-
    left(Size, State, Next); right(Size, State, Next);
    up(Size, State, Next); down(Size, State, Next).


left(_,State, Next):-
    nth0(Location,State,'-'),
    Location1 is Location-1,
    nth0(Location1, State, '-'),
    replace_element(State, Location, _, 'D', NewState),
    replace_element(NewState, Location1, _, 'D', Next).


right(_, State, Next):-
    nth0(Location,State,'-'),
    Location1 is Location+1,
    nth0(Location1, State, '-'),
    replace_element(State, Location, _, 'D', NewState),
    replace_element(NewState, Location1, _, 'D', Next).


up([_|[Y|_]], State, Next):-
    nth0(Location,State,'-'),
    Location1 is Location-Y,
    nth0(Location1, State, '-'),
    replace_element(State, Location, _, 'D', NewState),
    replace_element(NewState, Location1, _, 'D', Next).


down([_|[Y|_]], State, Next):-
    nth0(Location,State,'-'),
    Location1 is Location+Y,
    nth0(Location1, State, '-'),
    replace_element(State, Location, _, 'D', NewState),
    replace_element(NewState, Location1, _, 'D', Next).


isGoal(State,Size):-
    not(placeDomino(State,Size,_)).


search(Open, _, Size, CurrentState):-
    getState(Open, CurrentState, _),
    isGoal(CurrentState,Size).


search(Open, Closed, Size, Goal):-
    getState(Open, CurrentNode, TmpOpen),
    getAllValidChildren(CurrentNode, Size, TmpOpen, Closed, Children),
    addChildren(Children, TmpOpen, NewOpen),
    append(Closed, CurrentNode, NewClosed),
    search(NewOpen, NewClosed, Size, Goal).


getState([CurrentNode|Rest], CurrentNode, Rest).


getAllValidChildren(Node, Size, Open, Closed, Children):-
    findall(Next, getNextState(Node, Size, Open, Closed, Next), Children).


getNextState(State, Size, Open, Closed, Next):-
    placeDomino(State, Size, Next),
    not(member(Next, Open)),
    not(member(Next, Closed)),
    isOkay(Next).


addChildren(Children, Open, NewOpen):-
    append(Open, Children, NewOpen).


isOkay(_):-true.


printSolution([State, null],_):-
    write(State), nl.
printSolution([State, Parent], Closed):-
    member([Parent, GrandParent], Closed),
    printSolution([Parent, GrandParent], Closed),
    write(State), nl.


init(Size,BombLocations,Goal):-
    createSpace(Size,BombLocations,InitialState),
    search([InitialState],[],Size,Goal).