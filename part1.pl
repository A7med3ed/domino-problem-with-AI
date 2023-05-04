create_board(Rule, Rows, Cols, BombLocations) :-
    create_board_helper(Rows, Cols, BombLocations, [], Board),
    format("~w:~n", [Rule]),
    print_board(Board),flatten(Board,New),
    search([[New,null]],[],Rows,Cols).


create_board_helper(0, _, _, Acc, Acc).
create_board_helper(Row, Cols, BombLocations, Acc, Board) :-
    create_row(Cols, Row, BombLocations, [], RowList),
    append(Acc, [RowList], NewAcc),
    NextRow is Row - 1,
    create_board_helper(NextRow, Cols, BombLocations, NewAcc, Board).

create_row(0, _, _, Acc, Acc).
create_row(Col, Row, BombLocations, Acc, RowList) :-
    (member([Row, Col], BombLocations) -> append(Acc, ['b'], Acc1); Acc1 = Acc),
    (\+ member([Row, Col], BombLocations) -> append(Acc1, ['*'], RowAcc); RowAcc = Acc1),
    NextCol is Col - 1,
    create_row(NextCol, Row, BombLocations, RowAcc, RowList).

print_board([]).
print_board([H|T]) :-
    maplist(write, H),
    nl,
    print_board(T).




search(Open, Closed,_,_):-
getState(Open, [CurrentState,Parent], _), % Step 1
% write("Search is complete!"), nl,
printSolution([CurrentState,Parent], Closed).

search(Open, Closed,M,N):-
getState(Open, CurrentNode, TmpOpen),
getAllValidChildren(CurrentNode,TmpOpen,Closed,Children,M,N), % Step3
addChildren(Children, TmpOpen, NewOpen), % Step 4
append(Closed, [CurrentNode], NewClosed), % Step 5.1
search(NewOpen, NewClosed,M,N). % Step 5.2

% Implementation of step 3 to get the next states
getAllValidChildren(Node, Open, Closed, Children,M,N):-
findall(Next, getNextState(Node, Open, Closed, Next,M,N), Children).

getNextState([State,_], Open, Closed, [Next,State],M,N):-
move(State, Next,M,N),
not(member([Next,_], Open)),
not(member([Next,_], Closed)),
isOkay(Next).

getState([CurrentNode|Rest], CurrentNode, Rest).

addChildren(Children, Open, NewOpen):-
append(Open, Children, NewOpen).

% Implementation of printSolution to print the actual solution path
printSolution([State, null],_):-
write(State), nl.

printSolution([State, Parent], Closed):-
member([Parent, GrandParent], Closed),
printSolution([Parent, GrandParent], Closed),
write(State), nl.
% How can we implement DFS, DLS and UCS?

move(State, Next,M,N):-
horizontall(State, Next,M,N);verticall(State, Next,M,N).

horizontall(State, Next,M,N):-
nth0(EmptyTileIndex, State, '*'),
EmptyTileIndex \= M*N-1,
NewIndex is EmptyTileIndex + 1,
nth0(NewIndex, State, Element),
Element = '*',
replace(EmptyTileIndex, State,'_', Result),
replace(NewIndex, Result,'_', Next).

verticall(State, Next,M,N):-
nth0(EmptyTileIndex, State, '*'),
% check if we on last row
L is M*N,
RowIndex is EmptyTileIndex // N,
LastRowIndex is L // N - 1,
not(RowIndex =:= LastRowIndex),
NewIndex is EmptyTileIndex + N,
nth0(NewIndex, State, Element),
Element = '*',
replace(EmptyTileIndex, State,'|', Result),
replace(NewIndex, Result,'|', Next).


replace(I, L, E, K) :-
  nth0(I, L, _, R),
  nth0(I, K, E, R).

isOkay(_):- true. % This problem has no rules













