% Define the board size and bomb locations
:- dynamic board_size/1.
:- dynamic bomb/2.

% Define the predicates for placing and removing dominos
:- dynamic domino/5.
place_domino(R1, C1, R2, C2) :-
    \+ domino( R1, C1, R2, C2), \+ domino( R2, C2, R1, C1),
    \+ bomb(R1, C1), \+ bomb(R2, C2),
    (R1 =:= R2, C1 < C2 ; C1 =:= C2, R1 < R2),
    assertz(domino(_, R1, C1, R2, C2)).
remove_domino(R1, C1, R2, C2) :-
    retract(domino(_, R1, C1, R2, C2)).

% Define the predicate for calculating the maximum number of dominos
:- dynamic max_dominos/1.
calculate_max_dominos :-
    % Retrieve the board size and bomb locations from the database
    board_size(Rows-Cols),
    findall(bomb(R, C), bomb(R, C), Bombs),

    % Find all valid dominos and their orientations
    findall(Domino, (
        between(1, Rows, R1),
        between(1, Cols, C1),
        \+ member(bomb(R1, C1), Bombs),
        (
            R1 =:= Rows ; \+ domino(_, R1, C1, R1+1, C1),
            C1 =:= Cols ; \+ domino(_, R1, C1, R1, C1+1),
            R1 < Rows, C1 < Cols
        ),
        between(R1, Rows, R2),
        between(C1, Cols, C2),
        R1 =\= R2, C1 =\= C2,
        (
            R1 =:= R2-1, C1 =:= C2, \+ domino(_, R1, C1, R2, C2),
            Domino = domino(R1, C1, R2, C2, horizontal)
        ;
            R1 =:= R2, C1 =:= C2-1, \+ domino(_, R1, C1, R2, C2),
            Domino = domino(R1, C1, R2, C2, vertical)
        ),
        \+ member(bomb(R2, C2), Bombs)
    ), Dominos),

    % Count the number of unique dominos
    list_to_set(Dominos, UniqueDominos),
    length(UniqueDominos, MaxDominos),

    % Print the result
    format('The maximum number of dominos that can be placed is: ~d\n', [MaxDominos]).

domino(Index, R1, C1, R2, C2, Orientation) :-
    % Ensure that the domino index is non-negative
    nonneg(Index),

    % Ensure that the domino is either horizontal or vertical
    member(Orientation, [horizontal, vertical]),

    % Ensure that the domino is within the bounds of the board
    board_size(Rows-Cols),
    between(1, Rows, R1),
    between(1, Cols, C1),
    between(1, Rows, R2),
    between(1, Cols, C2),

    % Ensure that the domino tiles are adjacent and not overlapping
    (
        Orientation = horizontal,
        R1 =:= R2-1, C1 =:= C2,
        \+ member(bomb(R1, C1), [bomb(R1, C1), bomb(R2, C2)])
    ;
        Orientation = vertical,
        R1 =:= R2, C1 =:= C2-1,
        \+ member(bomb(R1, C1), [bomb(R1, C1), bomb(R2, C2)])
    ),

    % Ensure that the domino is not overlapping with any existing dominos
    \+ (
        domino(_, R1, C1, R2, C2, _),
        \+ (R1 =:= R2, C1 =:= C2, Orientation = horizontal)
    ),

    % Ensure that the domino is not overlapping with any bombs
    \+ member(bomb(R2, C2), [bomb(R1, C1), bomb(R2, C2)]).


% Define the main program
main :-
    % Get the board size from the user
    write('Enter the number of rows: '),
    read(Rows),
    write('Enter the number of columns: '),
    read(Cols),
    assertz(board_size(Rows-Cols)),

    % Get the bomb locations from the user
    write('Enter the row and column of bomb 1: '),
    read(Bomb1Row-Bomb1Col),
    assertz(bomb(Bomb1Row, Bomb1Col)),
    write('Enter the row and column of bomb 2: '),
    read(Bomb2Row-Bomb2Col),
    assertz(bomb(Bomb2Row, Bomb2Col)),

    % Calculate the maximum number of dominos
    calculate_max_dominos,
    max_dominos(MaxDominos),
    write('The maximum number of dominos that can be placed is: '),
    write(MaxDominos),

    % Clean up
    retractall(board_size(_)),
    retractall(bomb(_, _)),
    retractall(max_dominos(_)),
    retractall(domino(_, _, _, _, _)).
