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


place_domino(State,Size,Next,1):-
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
    not(place_domino(State,Size,_,_)).


:- dynamic numDominos_variable/1.


set_numDominos_variable(Value):-
    retractall(numDominos_variable(_)),
    assert(numDominos_variable(Value)).


get_numDominos_variable(Value):-
    numDominos_variable(Value).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
informed_search(Open, _, Size, [CurrentState,_,HuresticCost,DominoNum]):-
    get_best_state(Open, [CurrentState,_,HuresticCost,DominoNum], _),
    is_goal(CurrentState,Size),get_numDominos_variable(Var),(
    (
        Var < DominoNum,
        set_numDominos_variable(DominoNum),
        write(DominoNum),write(" is the max number of dominos.")
    );
    (
        Var == DominoNum
    );
    (
        fail
    ))
    .


informed_search(Open, Closed, Size, Goal):-
    get_best_state(Open, CurrentNode, TmpOpen),
    get_all_valid_children_informed(CurrentNode, Size, TmpOpen, Closed, Children),
    add_children(Children, TmpOpen, NewOpen),
    append(Closed, CurrentNode, NewClosed),
    informed_search(NewOpen, NewClosed, Size, Goal).


get_best_state(Open, Node, NewOpen):-
    find_min(Open,Node),
    delete(Open,Node,NewOpen).


find_min([Node],Node):-!.
find_min([Head|T], Min):-
    find_min(T, TmpMin),
    Head = [_,_,HeadH,_],
    TmpMin = [_,_,TmpH,_],
    (TmpH < HeadH -> Min = TmpMin,! ; Min = Head).


get_all_valid_children_informed(Node, Size, Open, Closed, Children):-
    findall(Next, get_next_state_informed(Node, Size, Open, Closed, Next), Children).


get_next_state_informed([State,_,_,OldDominoNum], Size, Open, Closed, [Next,State,HuresticCost,NewDominoNum]):-
    place_domino(State, Size, Next, DominoNum),
    NewDominoNum is OldDominoNum+DominoNum,
    heuristic_value(Size,Next,HuresticCost),
    not(member([Next,_,_,_], Open)),
    not(member([Next,_,_,_], Closed)),
    is_okay(Next).


heuristic_value(Size,Next,HuresticCost):-
    count_invalid(Next,Next,0,Size,0,HuresticCost),!.


count_invalid(_,[],_,_,HuresticCost,HuresticCost).


count_invalid(State,["-"|T],Index,Size,Cost,HuresticCost):-
    Size = [_|[Y|_]],
    IndexLeft is Index-1,
    IndexRight is Index+1,
    IndexUp is Index-Y,
    IndexDown is Index+Y,
    (
        not(0 is Index mod Y ),nth0(IndexLeft,State,"-"),!;
        not(0 is IndexRight mod Y ),nth0(IndexRight,State,"-"),!;
        nth0(IndexUp,State,"-"),!;
        nth0(IndexDown,State,"-"),!
    ),
    NewIndex is Index+1,
    count_invalid(State,T,NewIndex,Size,Cost,HuresticCost).


count_invalid(State,["-"|T],Index,Size,Cost,HuresticCost):-
    NewCost is Cost+1,
    NewIndex is Index+1,
    count_invalid(State,T,NewIndex,Size,NewCost,HuresticCost).


count_invalid(State,[_|T],Index,Size,Cost,HuresticCost):-
    NewIndex is Index+1,
    count_invalid(State,T,NewIndex,Size,Cost,HuresticCost).


add_children(Children, Open, NewOpen):-
    append(Open, Children, NewOpen).


is_okay(_):-true.


init_informed(Size,BombLocations,Goal):-
    create_space(Size,BombLocations,InitialState),
    set_numDominos_variable(-1),
    informed_search([[InitialState,[],0,0]],[],Size,Goal).