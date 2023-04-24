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
create_space([X|[Y|_]],Locations,Space) :-
    %length of the list
    Len is X*Y,
    length(TempSpace, Len),
    findall('-', between(1, Len, _), TempSpace),
    place_bombs(Locations,Y,TempSpace,Space),!.

%places the bombs
place_bombs([],_,Space,Space).
place_bombs([ [X|[Y|_] ] |T],YCoord,TempSpace,Space):-
    %location of the bomb
    Loc is ((X-1)*YCoord)+(Y-1),
    replace_element(TempSpace,Loc,'-','X',TempTempSpace),
    place_bombs(T,YCoord,TempTempSpace,Space).


place_domino(State,Size,Next):-
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


%if no more dominos can be places then its goal
is_goal(State,Size):-
    not(place_domino(State,Size,_)).


search(Open, _, Size, CurrentState):-
    get_state(Open, CurrentState, _),
    is_goal(CurrentState,Size).


search(Open, Closed, Size, Goal):-
    get_state(Open, CurrentNode, TmpOpen),
    get_all_valid_children(CurrentNode, Size, TmpOpen, Closed, Children),
    add_children(Children, TmpOpen, NewOpen),
    append(Closed, CurrentNode, NewClosed),
    search(NewOpen, NewClosed, Size, Goal).


get_state([CurrentNode|Rest], CurrentNode, Rest).


get_all_valid_children(Node, Size, Open, Closed, Children):-
    findall(Next, get_next_state(Node, Size, Open, Closed, Next), Children).


get_next_state(State, Size, Open, Closed, Next):-
    place_domino(State, Size, Next),
    not(member(Next, Open)),
    not(member(Next, Closed)),
    is_okay(Next).


add_children(Children, Open, NewOpen):-
    append(Open, Children, NewOpen).


is_okay(_):-true.


init_informed(Size,BombLocations,Goal):-
    create_space(Size,BombLocations,InitialState),
    search([InitialState],[],Size,Goal).