friend(ahmed, samy).
friend(ahmed, fouad).
friend(samy, mohammed).
friend(samy, said).
friend(samy, omar).
friend(samy, abdullah).
friend(fouad, abdullah).
friend(abdullah, khaled).
friend(abdullah, ibrahim).
friend(abdullah, omar).
friend(mostafa, marwan).
friend(marwan, hassan).
friend(hassan, ali).

friend(hend, aisha).
friend(hend, mariam).
friend(hend, khadija).
friend(huda, mariam).
friend(huda, aisha).
friend(huda, lamia).
friend(mariam, hagar).
friend(mariam, zainab).
friend(aisha, zainab).
friend(lamia, zainab).
friend(zainab, rokaya).
friend(zainab, eman).
friend(eman, laila).

%Utility functions
member(Item, [Item|_]):-!.
member(Item, [_|Tail]):-
    member(Item, Tail).


count([],_,0).
count([Element|T],Element,Result):-
    count(T,Element,TResult), !,
    Result is TResult + 1.
count([H|T],Element,TResult):- 
    H \= Element,
    count(T,Element,TResult).


%Task 1
is_friend(Person,Friend):-
    friend(Person,Friend);
    friend(Friend,Person),!.


%Task 2
friendList(Person, Friends) :-
    friendListHelper(Person, [], Friends).

friendListHelper(Person, KnownFriends, Friends) :-
    is_friend(Person, Friend),
    not(member(Friend,KnownFriends)),
    friendListHelper(Person, [Friend|KnownFriends], Friends).
friendListHelper(_, Friends, Friends):-!.


%Task 3
friendListCount(Person,N):-
    friendList(Person,List),
    friendListCountHelper(List,0,N),
    !.
    
friendListCountHelper([],Count,Count).
friendListCountHelper([_|T],Count,N):-
    Count1 is Count+1,
    friendListCountHelper(T,Count1,N).


%Task 4
peopleYouMayKnow(Person,People):-
    is_friend(Person,Friend),
    is_friend(Friend,People),
    not(Person = People),
    not(is_friend(Person,People)).


%Task 5
peopleYouMayKnow(Person,N,Out):-
    peopleYouMayKnowHelper(Person,[],List),
    stripList(List,[],StrippedList),
    countEach(StrippedList,N,Out).

%Counts each item in a list.
countEach([],_,_):-false.
countEach([H|T],N,H):-
    count([H|T],H,C),
    C is N,!.
countEach([_|T],N,Out):-
    countEach(T,N,Out).

%Gets the Tail of the Head of a nested list
stripList([],StrippedList,StrippedList).
stripList([[H|T2]|T],StrippedList,Out):-
    stripList(T,[T2|StrippedList],Out).


peopleYouMayKnowHelper(Person,KnownMFriends,MFriends):-
    %Get the mutual friend
    is_friend(Person,Friend),
    is_friend(Friend,Mfriend),
    %check if the mutual friend is already a friend
    %or if already an item in the list
    %or if the mutual friend is the first person himself
    not(Person = Mfriend),
    not(is_friend(Person,Mfriend)),
    not(member([Friend|Mfriend],KnownMFriends)),
    %recursion
    peopleYouMayKnowHelper(Person,[[Friend|Mfriend]|KnownMFriends],MFriends),!.
%base case after the main function to return when a fail occurs.
peopleYouMayKnowHelper(_,MFriends,MFriends):-!.


%Task 6
peopleYouMayKnowList(Person,L):-
    peopleYouMayKnowListHelper(Person,[],L).

peopleYouMayKnowListHelper(Person,KnownMFriends,MFriends):-
    %Get the mutual friend
    is_friend(Person,Friend),
    is_friend(Friend,Mfriend),
    %check if the mutual friend is already a friend
    %or if already an item in the list
    %or if the mutual friend is the first person himself
    not(Person = Mfriend),
    not(is_friend(Person,Mfriend)),
    not(member(Mfriend,KnownMFriends)),
    %recursion
    peopleYouMayKnowListHelper(Person,[Mfriend|KnownMFriends],MFriends),!.
%base case after the main function to return when a fail occurs.
peopleYouMayKnowListHelper(_,MFriends,MFriends):-!.


%Bonus Task
peopleYouMayKnow_indirect(Person, S):-
    getAllMutuals(Person, DirectFriendsList), % get all level 2 ('direct') friends list.
    friend(Person, Level1Friend),
    friend(Level1Friend, Level2Friend),
    getAllConnections(Level2Friend, Level3PlusFriend), % get level 3+ friend.
    not(member(Level3PlusFriend, DirectFriendsList)), % check if level 3 friend is not already a level 2 friend for Person
    S = Level3PlusFriend.


getAllConnections(X,Y):- % recursive call on a node to visit all the nodes its connected to. Basically like visiting all children in a tree.
    friend(X,Y).
getAllConnections(X,Y):-
    friend(X,Z),
    getAllConnections(Z,Y).


getAllMutualsHelper(Person, List, MutualsList):-
    peopleYouMayKnow(Person, Mutual),
    not(member(Mutual, List)),
    getAllMutualsHelper(Person, [Mutual|List], MutualsList).
getAllMutualsHelper(_, MutualsList, MutualsList).


getAllMutuals(Person, MutualsList):-
    getAllMutualsHelper(Person, [], MutualsList), !.








% peopleYouMayKnowHelper(_,Out,0,Out).
% peopleYouMayKnowHelper(Person,L,N,Out):-
%     N1 is N-1,
%     is_friend(Person,Friend),
%     L1 = [Person|L],
%     not(member(Friend,L1)),
%     peopleYouMayKnowHelper(Friend,L1,N1,Out).