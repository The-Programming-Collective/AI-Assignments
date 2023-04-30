% X = bomb
% V = domino vertical (loc-1)
% H = domino horizontal (loc+y)
% - = empty


replace_element(List, Index, OldValue, NewValue, Result) :-
    nth0(Index, List, OldValue, Temp),
    nth0(Index, Result, NewValue, Temp).


%Creates initial state space with bombs
create_space([X|[Y|_]],Locations,Space) :-
    %length of the list
    Len is X*Y,
    length(TempSpace, Len),
    findall("-", between(1, Len, _), TempSpace),
    place_bombs(Locations,Y,TempSpace,Space),!.


%places the bombs
place_bombs([],_,Space,Space).
place_bombs([ [X|[Y|_] ] |T],YCoord,TempSpace,Space):-
    %location of the bomb
    Loc is ((X-1)*YCoord)+(Y-1),
    replace_element(TempSpace,Loc,"-","X",TempTempSpace),
    place_bombs(T,YCoord,TempTempSpace,Space).


place_domino(State,Size,Next):-
    vertical(Size, State, Next); 
    horizontal(Size, State, Next).


vertical([_|[Y|_]],State, Next):-
    nth0(Location,State,"-"),
    Location1 is Location+Y,
    nth0(Location1, State, "-"),
    replace_element(State, Location, _, "V", NewState),
    replace_element(NewState, Location1, _, "V", Next).


horizontal([_|[Y|_]], State, Next):-
    nth0(Location,State,"-"),
    not(0 is Location mod Y),
    Location1 is Location-1,
    nth0(Location1, State, "-"),
    replace_element(State, Location, _, "H", NewState),
    replace_element(NewState, Location1, _, "H", Next).


%if no more dominos can be places then its goal
is_goal(State,Size):-
    not(place_domino(State,Size,_)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uninformed_search(Open, _, Size, CurrentState):-
    get_state(Open,[CurrentState,_], _),
    is_goal(CurrentState,Size).


uninformed_search(Open, Closed, Size, Goal):-
    get_state(Open, CurrentNode, TmpOpen),
    get_all_valid_children(CurrentNode, Size, TmpOpen, Closed, Children),
    add_children(Children, TmpOpen, NewOpen),
    append(Closed, [CurrentNode], NewClosed),
    uninformed_search(NewOpen, NewClosed, Size, Goal).


% BFS
get_state([CurrentNode|Rest], CurrentNode, Rest).


get_all_valid_children(Node, Size, Open, Closed, Children):-
    findall(Next, get_next_state(Node, Size, Open, Closed, Next), Children).


get_next_state([State,_], Size, Open, Closed, [Next,State]):-
    place_domino(State, Size, Next),
    not(member([Next,_], Open)),
    not(member([Next,_], Closed)),
    is_okay(Next).


% adds new states to the end of the open list (BFS)
add_children(Children, Open, NewOpen):-
    append(Open, Children, NewOpen).


is_okay(_):-true.


init_uninformed(Size,BombLocations,Goal):-
    create_space(Size,BombLocations,InitialState),
    uninformed_search([[InitialState,[]]],[],Size,Goal).