%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tetris Player %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% testing stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
board([[0, 0, 0, 0, 1, 0, 1, 0],
	   [0, 0, 0, 1, 1, 1, 1, 1],
	   [0, 1, 0, 1, 0, 0, 0, 1],
	   [1, 0, 1, 1, 1, 0, 1, 1]]).

go:-
	board(Board),
	TCode is 3,  
	findMove(Board, TCode, Position, Rotation),
	writeBoard(NewBoard),
	write(Position), nl,
	write(Rotation), nl, !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% findMove
% finds the move and rotation values
% Board = 2d list (of lists) of all tiles on the board
% TCode = the tetromino code that is being played
% TPos = the returned position to play the tetromino ()
% RotVal = the returned rotation of the tetromino (0, 1, 2, or 3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
findMove(Board, TCode, FinalTPos, FinalRotVal) :-
	findall([NewBoard, NewDepth, TPos, RotVal], getBoards(Board, TCode, RotVal, TPos, NewBoard, NewDepth), BoardBag),
	findBest(BoardBag, [_, FinalTPos, FinalRotVal]),
	writeBoardFromBoardBag(BoardBag, FinalTPos, FinalRotVal).

writeBoardFromBoardBag(Bag, TPos, RotVal):-
	member([Board, _, TPos, RotVal], Bag),
	writeBoard(Board).

findBest(BoardBag, Best) :-
	scoreBoards(BoardBag, ScoredBag),
	getLowestScoringMove(ScoredBag, Best), !. %red cut

%	sort(ScoredBag, [Best | _]). %works in swi prolog but not tuprolog

scoreBoards([], []).
scoreBoards([[B, D, P, R] | T], [[Score, P, R] | TailScores]) :-
	score(B, D, Score),
	scoreBoards(T, TailScores).

score(B, D, Score) :-
	countCoveredTiles(B, Tiles),
	Score is 18 * Tiles - D.

writeBag([]).
writeBag([[H, _]| T]):-
	writeBoard(H), nl, nl,
	writeBag(T).

writeBoard([]).
writeBoard([H | T]):-
	write(H), nl,
	writeBoard(T).

getBoards(Board, TCode, RotVal, N, ResultBoard, NewDepth) :-
	inRange(N),
	convertBoard(Board, TCode, RotVal, N, NewBoard, NewDepth),
	removeLines(NewBoard, ResultBoard).

inRange(0). inRange(1). inRange(2). inRange(3). inRange(4). inRange(5). inRange(6). inRange(7). inRange(8). inRange(9).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TETROMINOES:
% --------------------------------------------------------------------------------------------
% I (1):
% Rotation 1 and 3: 
% 	XXXX
% Rotation 2 and 4:
% 	X
% 	X
% 	X
% 	X
% --------------------------------------------------------------------------------------------
% O (2):
% Rotation 1, 2, 3, and 4:
% 	XX
% 	XX
% --------------------------------------------------------------------------------------------
% T (3):
% Rotation 1:
% 	XXX
% 	 X
% Rotation 2:
% 	 X
% 	XX
% 	 X
% Rotation 3:
% 	 X
% 	XXX
% Rotation 4:
% 	 X
% 	 XX
% 	 X
% --------------------------------------------------------------------------------------------
% J (4):
% Rotation 1:
% 	XXX
% 	  X
% Rotation 2:
% 	 X
% 	 X
% 	XX
% Rotation 3:
% 	X
% 	XXX
% Rotation 4:
% 	 XX
% 	 X
% 	 X
% --------------------------------------------------------------------------------------------
% L (5):
% Rotation 1:
% 	XXX
% 	X
% Rotation 2:
% 	XX
% 	 X
% 	 X
% Rotation 3:
% 	  X
% 	XXX
% Rotation 4:
% 	 X
% 	 X
% 	 XX
% --------------------------------------------------------------------------------------------
% S (6):
% Rotation 1 and 3:
% 	 XX
% 	XX
% Rotation 2 and 4:
% 	X
% 	XX
% 	 X
% --------------------------------------------------------------------------------------------
% Z (7):
% Rotation 1 and 3:
% 	XX
% 	 XX
% Rotation 2 and 4:
% 	 X
% 	XX
% 	X
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convertBoard
% finds the new board given tetromino id, tetromino rotation, and tetromino position
% also finds the depth at which the tile is placed
% Board = the list of lists of all tiles on the board
% TId = the id of the tetromino being placed
% TRot = the rotation of the tetromino being placed
% TPos = the position of the tetromino being placed
% NewBoard = The returned board with the new tetromino in place
% Depth = the depth at which the tile was placed
% convertBoard(Board, TId, TRot, TPos, NewBoard, Depth).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%I tile, rotation 1 and 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 1, 1, TPos, NewBoard, Depth) :-
	convertBoardLine1(Board, TPos, NewBoard, Depth).
convertBoard(Board, 1, 3, TPos, NewBoard, Depth) :-
	convertBoardLine1(Board, TPos, NewBoard, Depth).

convertBoardLine1(Board, TPos, NewBoard, Depth) :-
	findHLineDepth(Board, 0, TPos, Depth),
	AdjustedDepth is Depth - 1,
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	TPos4 is TPos3 + 1,
	placePoint(Board, TPos, AdjustedDepth, Board1),
	placePoint(Board1, TPos2, AdjustedDepth, Board2),
	placePoint(Board2, TPos3, AdjustedDepth, Board3),
	placePoint(Board3, TPos4, AdjustedDepth, NewBoard).

findHLineDepth([], Depth, _, Depth).
findHLineDepth([H | _], Depth, TPos, Depth) :-
	length(H, RowLength),
	createHLineRow(0, RowLength, TPos, HLineRow),
	getFilledIndices(H, FilledH),
	getFilledIndices(HLineRow, FilledHLineRow),
	myinter(FilledH, FilledHLineRow, Intersect),
	length(Intersect, Size),
	Size > 0.
findHLineDepth([H | T], Count, TPos, Depth) :-
	length(H, RowLength),
	createHLineRow(0, RowLength, TPos, HLineRow),
	getFilledIndices(H, FilledH),
	getFilledIndices(HLineRow, FilledHLineRow),
	myinter(FilledH, FilledHLineRow, Intersect),
	length(Intersect, Size),
	Size = 0,
	NewCount is Count + 1,
	findHLineDepth(T, NewCount, TPos, Depth).

createHLineRow(RowLength, RowLength, _, []).
createHLineRow(Count, RowLength, TPos, [0 | Rest]) :-
	Count < RowLength,
	Count > TPos + 3,
	NewCount is Count + 1,
	createHLineRow(NewCount, RowLength, TPos, Rest).
createHLineRow(Count, RowLength, TPos, [0 | Rest]) :-
	Count < RowLength,
	Count < TPos,
	NewCount is Count + 1,
	createHLineRow(NewCount, RowLength, TPos, Rest).
createHLineRow(Count, RowLength, TPos, [1 | Rest]) :-
	Count < RowLength,
	Count >= TPos,
	Count =< TPos + 3,
	NewCount is Count + 1,
	createHLineRow(NewCount, RowLength, TPos, Rest).

%I tile, rotation 2 and 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 1, 2, TPos, NewBoard, Depth) :-
	convertBoardLine2(Board, TPos, NewBoard, Depth).
convertBoard(Board, 1, 4, TPos, NewBoard, Depth) :-
	convertBoardLine2(Board, TPos, NewBoard, Depth).

convertBoardLine2(Board, TPos, NewBoard, Depth) :-
	findVLineDepth(Board, 0, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	Depth3 is Depth2 - 1,
	Depth4 is Depth3 - 1,
	placePoint(Board, TPos, AdjustedDepth, Board1),
	placePoint(Board1, TPos, Depth2, Board2),
	placePoint(Board2, TPos, Depth3, Board3),
	placePoint(Board3, TPos, Depth4, NewBoard).

findVLineDepth([], Depth, _, Depth).
findVLineDepth([H | T], Count, TPos, Depth) :-
	\+rowTileFilled(H, 0, TPos),
	NewCount is Count + 1,
	findVLineDepth(T, NewCount, TPos, Depth).
findVLineDepth([H | _], Depth, TPos, Depth) :-
	rowTileFilled(H, 0, TPos).

rowTileFilled([H | _], TPos, TPos) :-
	H == 1.
rowTileFilled([_ | T], Count, TPos) :-
	Count < TPos,
	NewCount is Count + 1,
	rowTileFilled(T, NewCount, TPos).
%O tile, all rotations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 2, 1, TPos, NewBoard, Depth):-
	convertBoardO(Board, TPos, NewBoard, Depth).
convertBoard(Board, 2, 2, TPos, NewBoard, Depth):-
	convertBoardO(Board, TPos, NewBoard, Depth).
convertBoard(Board, 2, 3, TPos, NewBoard, Depth):-
	convertBoardO(Board, TPos, NewBoard, Depth).
convertBoard(Board, 2, 4, TPos, NewBoard, Depth):-
	convertBoardO(Board, TPos, NewBoard, Depth).

convertBoardO(Board, TPos, NewBoard, Depth):-
	findODepth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth -1,
	TPos2 is TPos + 1,
	placePoint(Board, TPos, AdjustedDepth, Board1),
	placePoint(Board1, TPos, Depth2, Board2),
	placePoint(Board2, TPos2, AdjustedDepth, Board3),
	placePoint(Board3, TPos2, Depth2, NewBoard).

findODepth(Board, TPos, Depth):-
	findVLineDepth(Board, 0, TPos, PotDepth),
	TPos2 is TPos + 1,
	findVLineDepth(Board, 0, TPos2, PotDepth2),
	compareODepth(PotDepth, PotDepth2, Depth).
compareODepth(X, Y, X):-
	X =< Y.
compareODepth(X, Y, Y):-
	X > Y.

%T tile, rotation 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 3, 1, TPos, NewBoard, Depth) :-
	convertBoardCross1(Board, TPos, NewBoard, Depth).

convertBoardCross1(Board, TPos, NewBoard, Depth) :-
	findT1Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	placePoint(Board, TPos, Depth2, Board1),
	placePoint(Board1, TPos2, Depth2, Board2),
	placePoint(Board2, TPos3, Depth2, Board3),
	placePoint(Board3, TPos2, AdjustedDepth, NewBoard).

findT1Depth(Board, TPos, Depth):-
	TPos2 is TPos + 1,
	TPos3 is TPos + 2,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	findVLineDepth(Board, 0, TPos3, Depth3),
	compareT1Depth(Depth1, Depth2, Depth3, Depth).

compareT1Depth(Depth1, Depth2, Depth3, Depth) :-
	Depth1 < Depth2,
	Depth1 =< Depth3,
	Depth is Depth1 + 1.
compareT1Depth(Depth1, Depth2, Depth3, Depth2) :-
	Depth2 =< Depth1,
	Depth2 =< Depth3.
compareT1Depth(Depth1, Depth2, Depth3, Depth) :-
	Depth3 < Depth1,
	Depth3 < Depth2,
	Depth is Depth3 + 1.

%T tile, rotation 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 3, 2, TPos, NewBoard, Depth) :-
	convertBoardCross2(Board, TPos, NewBoard, Depth).

convertBoardCross2(Board, TPos, NewBoard, Depth) :-
	findT2Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	Depth3 is Depth2 - 1,
	TPos2 is TPos + 1,
	placePoint(Board, TPos, Depth2, Board1),
	placePoint(Board1, TPos2, AdjustedDepth, Board2),
	placePoint(Board2, TPos2, Depth2, Board3),
	placePoint(Board3, TPos2, Depth3, NewBoard).

findT2Depth(Board, TPos, Depth) :-
	TPos2 is TPos + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	compareT2Depth(Depth1, Depth2, Depth).

compareT2Depth(Depth1, Depth2, Depth2) :-
	Depth2 =< Depth1.
compareT2Depth(Depth1, Depth2, Depth) :-
	Depth1 < Depth2,
	Depth is Depth1 + 1.

%T tile, rotation 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 3, 3, TPos, NewBoard, Depth) :-
	convertBoardCross3(Board, TPos, NewBoard, Depth).

convertBoardCross3(Board, TPos, NewBoard, Depth) :-
	findT3Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	placePoint(Board, TPos, AdjustedDepth, Board1),
	placePoint(Board1, TPos2, AdjustedDepth, Board2),
	placePoint(Board2, TPos3, AdjustedDepth, Board3),
	placePoint(Board3, TPos2, Depth2, NewBoard).

findT3Depth(Board, TPos, Depth) :-
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	findVLineDepth(Board, 0, TPos3, Depth3),
	compareT3Depth(Depth1, Depth2, Depth3, Depth).

compareT3Depth(Depth1, Depth2, Depth3, Depth1) :-
	Depth1 < Depth2,
	Depth1 < Depth3.
compareT3Depth(Depth1, Depth2, Depth3, Depth2) :-
	Depth2 =< Depth1,
	Depth2 < Depth3.
compareT3Depth(Depth1, Depth2, Depth3, Depth3) :-
	Depth3 =< Depth1,
	Depth3 =< Depth2.

%T tile, rotation 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 3, 4, TPos, NewBoard, Depth) :-
	convertBoardCross4(Board, TPos, NewBoard, Depth).

convertBoardCross4(Board, TPos, NewBoard, Depth) :-
	findT4Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	Depth3 is Depth2 - 1,
	TPos2 is TPos + 1,
	placePoint(Board, TPos2, Depth2, Board1),
	placePoint(Board1, TPos, AdjustedDepth, Board2),
	placePoint(Board2, TPos, Depth2, Board3),
	placePoint(Board3, TPos, Depth3, NewBoard).

findT4Depth(Board, TPos, Depth) :-
	TPos2 is TPos + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	compareT4Depth(Depth1, Depth2, Depth).

compareT4Depth(Depth1, Depth2, Depth1) :-
	Depth1 =< Depth2.
compareT4Depth(Depth1, Depth2, Depth) :-
	Depth2 < Depth1,
	Depth is Depth2 + 1.
%J tile, rotation 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 4, 1, TPos, NewBoard, Depth):-
	convertBoardJ1(Board, TPos, NewBoard, Depth).
convertBoardJ1(Board, TPos, NewBoard, Depth):-
	findJ1Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth -1,
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	placePoint(Board, TPos, Depth2, Board1),
	placePoint(Board1, TPos2, Depth2, Board2),
	placePoint(Board2, TPos3, Depth2, Board3),
	placePoint(Board3, TPos3, AdjustedDepth, NewBoard).

findJ1Depth(Board, TPos, Depth):-
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	findVLineDepth(Board, 0, TPos3, Depth3),
	NewDepth1 is Depth1 + 1,
	NewDepth2 is Depth2 + 1,
	compareJ1Depth(NewDepth1, NewDepth2, Depth3, Depth).

compareJ1Depth(Depth1, Depth2, Depth3, Depth1):-
	Depth1 =< Depth2,
	Depth1 =< Depth3.
compareJ1Depth(Depth1, Depth2, Depth3, Depth2):-
	Depth2 < Depth1,
	Depth2 =< Depth3.
compareJ1Depth(Depth1, Depth2, Depth3, Depth3):-
	Depth3 < Depth1,
	Depth3 < Depth2.

%J tile, rotation 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 4, 2, TPos, NewBoard, Depth) :-
	convertBoardJ2(Board, TPos, NewBoard, Depth).

convertBoardJ2(Board, TPos, NewBoard, Depth) :-
	findODepth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	Depth3 is Depth2 - 1,
	TPos2 is TPos + 1,
	placePoint(Board, TPos, AdjustedDepth, Board1),
	placePoint(Board1, TPos2, AdjustedDepth, Board2),
	placePoint(Board2, TPos2, Depth2, Board3),
	placePoint(Board3, TPos2, Depth3, NewBoard).

%J tile, rotation 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 4, 3, TPos, NewBoard, Depth):-
	convertBoardJ3(Board, TPos, NewBoard, Depth).
convertBoardJ3(Board, TPos, NewBoard, Depth):-
	findJ3Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	placePoint(Board, TPos, Depth2, Board1),
	placePoint(Board1, TPos, AdjustedDepth, Board2),
	placePoint(Board2, TPos2, AdjustedDepth, Board3),
	placePoint(Board3, TPos3, AdjustedDepth, NewBoard).

findJ3Depth(Board, TPos, Depth):-
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	findVLineDepth(Board, 0, TPos3, Depth3),
	compareJ3Depth(Depth1, Depth2, Depth3, Depth).

compareJ3Depth(Depth1, Depth2, Depth3, Depth1):-
	Depth1 =< Depth2,
	Depth1 =< Depth3.
compareJ3Depth(Depth1, Depth2, Depth3, Depth2):-
	Depth2 < Depth1,
	Depth2 =< Depth3.
compareJ3Depth(Depth1, Depth2, Depth3, Depth3):-
	Depth3 < Depth1,
	Depth3 < Depth2.

%J tile, rotation 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 4, 4, TPos, NewBoard, Depth) :-
	convertBoardJ4(Board, TPos, NewBoard, Depth).

convertBoardJ4(Board, TPos, NewBoard, Depth) :-
	findJ4Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	Depth3 is Depth2 - 1,
	TPos2 is TPos + 1,
	placePoint(Board, TPos, AdjustedDepth, Board1),
	placePoint(Board1, TPos, Depth2, Board2),
	placePoint(Board2, TPos, Depth3, Board3),
	placePoint(Board3, TPos2, Depth3, NewBoard).

findJ4Depth(Board, TPos, Depth) :-
	TPos2 is TPos + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	compareJ4Depth(Depth1, Depth2, Depth).

compareJ4Depth(Depth1, Depth2, Depth1) :-
	Depth1 =< Depth2 + 2.
compareJ4Depth(Depth1, Depth2, Depth) :-
	Depth2 < Depth1 - 2,
	Depth is Depth2 + 2.

%L tile, rotation 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 5, 1, TPos, NewBoard, Depth):-
	convertBoardL1(Board, TPos, NewBoard, Depth).
convertBoardL1(Board, TPos, NewBoard, Depth):-
	findL1Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth -1,
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	placePoint(Board, TPos, Depth2, Board1),
	placePoint(Board1, TPos2, Depth2, Board2),
	placePoint(Board2, TPos3, Depth2, Board3),
	placePoint(Board3, TPos, AdjustedDepth, NewBoard).

findL1Depth(Board, TPos, Depth):-
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	findVLineDepth(Board, 0, TPos3, Depth3),
	NewDepth2 is Depth2 + 1,
	NewDepth3 is Depth3 + 1,
	compareJ1Depth(Depth1, NewDepth2, NewDepth3, Depth).

%L tile, rotation 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 5, 2, TPos, NewBoard, Depth) :-
	convertBoardL2(Board, TPos, NewBoard, Depth).

convertBoardL2(Board, TPos, NewBoard, Depth) :-
	findL2Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	Depth3 is Depth2 - 1,
	TPos2 is TPos + 1,
	placePoint(Board, TPos2, AdjustedDepth, Board1),
	placePoint(Board1, TPos2, Depth2, Board2),
	placePoint(Board2, TPos2, Depth3, Board3),
	placePoint(Board3, TPos, Depth3, NewBoard).

findL2Depth(Board, TPos, Depth) :-
	TPos2 is TPos + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	compareL2Depth(Depth1, Depth2, Depth).

compareL2Depth(Depth1, Depth2, Depth) :-
	Depth1 =< Depth2 - 2,
	Depth is Depth1 + 2.
compareL2Depth(Depth1, Depth2, Depth2) :-
	Depth2 < Depth1 + 2.

%L tile, rotation 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 5, 3, TPos, NewBoard, Depth):-
	convertBoardL3(Board, TPos, NewBoard, Depth).
convertBoardL3(Board, TPos, NewBoard, Depth):-
	findL3Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	placePoint(Board, TPos3, Depth2, Board1),
	placePoint(Board1, TPos, AdjustedDepth, Board2),
	placePoint(Board2, TPos2, AdjustedDepth, Board3),
	placePoint(Board3, TPos3, AdjustedDepth, NewBoard).

findL3Depth(Board, TPos, Depth):-
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	findVLineDepth(Board, 0, TPos3, Depth3),
	compareJ3Depth(Depth1, Depth2, Depth3, Depth).

%L tile, rotation 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 5, 4, TPos, NewBoard, Depth) :-
	convertBoardL4(Board, TPos, NewBoard, Depth).

convertBoardL4(Board, TPos, NewBoard, Depth) :-
	findODepth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	Depth3 is Depth2 - 1,
	TPos2 is TPos + 1,
	placePoint(Board, TPos, AdjustedDepth, Board1),
	placePoint(Board1, TPos, Depth2, Board2),
	placePoint(Board2, TPos, Depth3, Board3),
	placePoint(Board3, TPos2, AdjustedDepth, NewBoard).

%S tile, rotation 1 and 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 6, 1, TPos, NewBoard, Depth) :-
	convertBoardS1(Board, TPos, NewBoard, Depth).
convertBoard(Board, 6, 3, TPos, NewBoard, Depth) :-
	convertBoardS1(Board, TPos, NewBoard, Depth).

convertBoardS1(Board, TPos, NewBoard, Depth) :-
	findS1Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	placePoint(Board, TPos, AdjustedDepth, Board1),
	placePoint(Board1, TPos2, AdjustedDepth, Board2),
	placePoint(Board2, TPos2, Depth2, Board3),
	placePoint(Board3, TPos3, Depth2, NewBoard).

findS1Depth(Board, TPos, Depth) :-
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	findVLineDepth(Board, 0, TPos3, Depth3),
	compareS1Depth(Depth1, Depth2, Depth3, Depth).

compareS1Depth(Depth1, Depth2, Depth3, Depth1) :-
	Depth1 =< Depth2,
	Depth1 =< Depth3 + 1.
compareS1Depth(Depth1, Depth2, Depth3, Depth2) :-
	Depth2 < Depth1,
	Depth2 =< Depth3 + 1.
compareS1Depth(Depth1, Depth2, Depth3, Depth) :-
	Depth3 < Depth1 - 1,
	Depth3 < Depth2 - 1,
	Depth is Depth3 + 1.

%S tile, rotation 2 and 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 6, 2, TPos, NewBoard, Depth) :-
	convertBoardS2(Board, TPos, NewBoard, Depth).
convertBoard(Board, 6, 4, TPos, NewBoard, Depth) :-
	convertBoardS2(Board, TPos, NewBoard, Depth).

convertBoardS2(Board, TPos, NewBoard, Depth) :-
	findS2Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	Depth3 is Depth2 - 1,
	TPos2 is TPos + 1,
	placePoint(Board, TPos2, AdjustedDepth, Board1),
	placePoint(Board1, TPos2, Depth2, Board2),
	placePoint(Board2, TPos, Depth2, Board3),
	placePoint(Board3, TPos, Depth3, NewBoard).

findS2Depth(Board, TPos, Depth) :-
	TPos2 is TPos + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	compareS2Depth(Depth1, Depth2, Depth).

compareS2Depth(Depth1, Depth2, Depth) :-
	Depth1 =< Depth2 - 1,
	Depth is Depth1 + 1.
compareS2Depth(Depth1, Depth2, Depth2) :-
	Depth2 < Depth1 + 1.

%Z tile, rotation 1 and 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 7, 1, TPos, NewBoard, Depth) :-
	convertBoardZ1(Board, TPos, NewBoard, Depth).
convertBoard(Board, 7, 3, TPos, NewBoard, Depth) :-
	convertBoardZ1(Board, TPos, NewBoard, Depth).

convertBoardZ1(Board, TPos, NewBoard, Depth) :-
	findZ1Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	placePoint(Board, TPos, Depth2, Board1),
	placePoint(Board1, TPos2, Depth2, Board2),
	placePoint(Board2, TPos2, AdjustedDepth, Board3),
	placePoint(Board3, TPos3, AdjustedDepth, NewBoard).

findZ1Depth(Board, TPos, Depth) :-
	TPos2 is TPos + 1,
	TPos3 is TPos2 + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	findVLineDepth(Board, 0, TPos3, Depth3),
	compareZ1Depth(Depth1, Depth2, Depth3, Depth).

compareZ1Depth(Depth1, Depth2, Depth3, Depth) :-
	Depth1 =< Depth2 - 1,
	Depth1 =< Depth3 - 1,
	Depth is Depth1 + 1.
compareZ1Depth(Depth1, Depth2, Depth3, Depth2) :-
	Depth2 < Depth1 + 1,
	Depth2 =< Depth3.
compareZ1Depth(Depth1, Depth2, Depth3, Depth3) :-
	Depth3 < Depth1 + 1,
	Depth3 < Depth2.

%Z tile, rotation 2 and 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convertBoard(Board, 7, 2, TPos, NewBoard, Depth) :-
	convertBoardZ2(Board, TPos, NewBoard, Depth).
convertBoard(Board, 7, 4, TPos, NewBoard, Depth) :-
	convertBoardZ2(Board, TPos, NewBoard, Depth).

convertBoardZ2(Board, TPos, NewBoard, Depth) :-
	findZ2Depth(Board, TPos, Depth),
	AdjustedDepth is Depth - 1,
	Depth2 is AdjustedDepth - 1,
	Depth3 is Depth2 - 1,
	TPos2 is TPos + 1,
	placePoint(Board, TPos, AdjustedDepth, Board1),
	placePoint(Board1, TPos, Depth2, Board2),
	placePoint(Board2, TPos2, Depth2, Board3),
	placePoint(Board3, TPos2, Depth3, NewBoard).

findZ2Depth(Board, TPos, Depth) :-
	TPos2 is TPos + 1,
	findVLineDepth(Board, 0, TPos, Depth1),
	findVLineDepth(Board, 0, TPos2, Depth2),
	compareZ2Depth(Depth1, Depth2, Depth).

compareZ2Depth(Depth1, Depth2, Depth1) :-
	Depth1 =< Depth2 + 1.
compareZ2Depth(Depth1, Depth2, Depth) :-
	Depth2 < Depth1 - 1,
	Depth is Depth2 + 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% countCoveredTiles
% counts the number of covered tiles (empty tiles that have a nonempty tile above)
% does this by sizing the myinter between the filled indices of a row with ...
% ... the empty indices of the row beneath
% TileList = 2d list (of lists) of all tiles on the board
% NumCoveredTiles = the returned number of covered tiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
countCoveredTiles(RowList, NumCoveredTiles) :-
	countCoveredTilesA(RowList, NumCoveredTiles, []).
countCoveredTilesA([], 0, _).
countCoveredTilesA([H | T], NumCoveredTiles, []) :-
	!, countCoveredTilesA(T, NumCoveredTiles, H). %red cut, avoids double execution
countCoveredTilesA([H | T], NumCoveredTiles, LastRow) :-
	countCoveredTilesB(LastRow, H, InterLength),
	countCoveredTilesA(T, Sum, H),
	NumCoveredTiles is Sum + InterLength.
countCoveredTilesB(LastRow, CurrentRow, InterLength) :-
	getFilledIndices(LastRow, FilledList),
	getEmptyIndices(CurrentRow, EmptyList),
	myinter(FilledList, EmptyList, InterList),
	length(InterList, InterLength).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getEmptyIndices
% counts the number of empty tiles in a row
% RowList = list of tiles in the row, 0 for empty, 1 for full
% IndexList = the list of indices of empty tiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
getEmptyIndices(RowList, IndexList) :-
	getEmptyIndicesA(RowList, IndexList, 0).
getEmptyIndicesA([], [], _).
getEmptyIndicesA([H | T], [Index | Rest], Index) :-
	H is 0,
	NewIndex is Index + 1,
	getEmptyIndicesA(T, Rest, NewIndex).
getEmptyIndicesA([H | T], Rest, Index) :-
	H is 1,
	NewIndex is Index + 1,
	getEmptyIndicesA(T, Rest, NewIndex).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getFilledIndices
% counts the number of filled tiles in a row
% RowList = list of tiles in the row, 0 for empty, 1 for full
% IndexList = the list of indices of filled tiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
getFilledIndices(RowList, IndexList) :-
	getFilledIndicesA(RowList, IndexList, 0).
getFilledIndicesA([], [], _).
getFilledIndicesA([H | T], [Index | Rest], Index) :-
	H is 1,
	NewIndex is Index + 1,
	getFilledIndicesA(T, Rest, NewIndex).
getFilledIndicesA([H | T], Rest, Index) :-
	H is 0,
	NewIndex is Index + 1,
	getFilledIndicesA(T, Rest, NewIndex).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% placePoint
% fills in a tile of the board
% Board = the board being modified
% XCoord = the x-coordinate to fill in
% YCoord = the y-coordinate to fill in (distance from the top)
% NewBoard = the modified board
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
placePoint(Board, XCoord, YCoord, NewBoard) :-
	placePoint(Board, XCoord, 0, YCoord, NewBoard).
placePoint([H | T], XCoord, YCoord, YCoord, [NewH | T]) :-
	placePointInRow(H, 0, XCoord, NewH).
placePoint([H | T], XCoord, Count, YCoord, [H | NewT]) :-
	Count < YCoord,
	NewCount is Count + 1,
	placePoint(T, XCoord, NewCount, YCoord, NewT).
placePointInRow([H | T], XCoord, XCoord, [1 | T]).
placePointInRow([H | T], Count, XCoord, [H | NewT]) :-
	Count < XCoord,
	NewCount is Count + 1,
	placePointInRow(T, NewCount, XCoord, NewT).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% removeLines
% takes out all the complete lines in a board
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
removeLines(Board, ResultBoard) :-
	removeLines(Board, NewBoard, 0, NumRemoved),
	addBlankLines(0, NumRemoved, NewBoard, ResultBoard).

removeLines([], [], NumRemoved, NumRemoved).
removeLines([H | T], NewT, Count, NumRemoved) :-
	allOnes(H),
	NewCount is Count + 1,
	removeLines(T, NewT, NewCount, NumRemoved).
removeLines([H | T], [H | NewT], Count, NumRemoved) :-
	\+ allOnes(H),
	removeLines(T, NewT, Count, NumRemoved).

addBlankLines(NumRemoved, NumRemoved, ResultBoard, ResultBoard).
addBlankLines(Count, NumRemoved, [H | T], Result) :-
	Count < NumRemoved,
	NewCount is Count + 1,
	length(H, HLen),
	createBlankLine(HLen, Blank),
	addBlankLines(NewCount, NumRemoved, [Blank | [H | T]], Result).

allOnes([1]).
allOnes([1 | T]) :-
	allOnes(T).

createBlankLine(0, []).
createBlankLine(Length, [0 | Rest]) :-
	Length > 0,
	NewLength is Length - 1,
	createBlankLine(NewLength, Rest).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% roll your own!
% below are predicates we had to make in order to get this to work with tuprolog
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myinter([], [], []).
myinter([], _, []).
myinter(_, [], []).
myinter([H | T], List, Result) :-
	\+ member(H, List),
	myinter(T, List, Result).
myinter([H | T], List, [H | Rest]) :-
	member(H, List),
	myinter(T, List, Rest).

%instead of sort
getLowestScoringMove(ScoredBag, [LowestScore, P, R]) :-
	findLowestScore(ScoredBag, 1000, LowestScore),
	member([LowestScore, P, R], ScoredBag).
findLowestScore([], LowestScore, LowestScore).
findLowestScore([[HS | _] | T], Record, LowestScore) :-
	HS < Record,
	findLowestScore(T, HS, LowestScore).
findLowestScore([[HS | _] | T], Record, LowestScore) :-
	HS >= Record,
	findLowestScore(T, Record, LowestScore).
