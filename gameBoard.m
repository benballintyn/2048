classdef gameBoard < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        board
        boardHeight
        boardWidth
    end
    
    methods
        function obj = gameBoard(options)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.boardHeight = options.boardHeight;
            obj.boardWidth = options.boardWidth;
            obj.board = zeros(obj.boardHeight,obj.boardWidth);
        end
        
        function updateBoard(obj,move)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            switch move
                case 1 % up
                    for i=1:size(obj.board,2) % across columns (horizontal)
                        for j=1:size(obj.board,1) % down rows (vertical)
                            if (j==1 || obj.board(i,j)==0)
                                continue;
                            else
                                if (obj.board(j-1,i) == 0)
                                    aboveSquare = j-1;
                                    curSquare = j;
                                    while(obj.board(aboveSquare,i) == 0 && aboveSquare > 0)
                                        obj.board(aboveSquare,i) = obj.board(curSquare,i);
                                        obj.board(curSquare,i) = 0;
                                        aboveSquare = aboveSquare-1;
                                        curSquare = curSquare - 1;
                                    end
                                    if (aboveSquare > 0)
                                        if (obj.board(aboveSquare,i) == obj.board(curSquare,i))
                                            obj.board(aboveSquare,i) = obj.board(aboveSquare,i)*2;
                                            obj.board(curSquare,i) = 0;
                                        end
                                    end
                                elseif (obj.board(j-1,i) == obj.board(j,i))
                                    obj.board(j-1,i) = obj.board(j-1,i)*2;
                                    obj.board(j,i) = 0;
                                end
                            end
                        end
                    end
                case 2 % left
                    for i=1:size(obj.board,1) % down rows (vertical)
                        for j=1:size(obj.board,2) % across columns (horizontal)
                            if (j == 1 || obj.board(i,j) == 0)
                                continue;
                            else
                                if (obj.board(i,j-1) == 0)
                                    leftSquare = j-1;
                                    curSquare = j;
                                    while(obj.board(i,leftSquare) == 0 && leftSquare > 0)
                                        obj.board(i,leftSquare) = obj.board(i,curSquare);
                                        obj.board(i,curSquare) = 0;
                                        leftSquare = leftSquare-1;
                                        curSquare=curSquare-1;
                                    end
                                    if (leftSquare > 0)
                                        if (obj.board(i,leftSquare) == obj.board(i,curSquare))
                                            obj.board(i,leftSquare) = obj.board(i,leftSquare)*2;
                                            obj.board(i,curSquare) = 0;
                                        end
                                    end
                                elseif (obj.board(i,j-1) == obj.board(i,j))
                                    obj.board(i,j-1) = obj.board(i,j-1)*2;
                                    obj.board(i,j) = 0;
                                end
                            end
                        end
                    end
                case 3 % down
                    for i=1:size(obj.board,2) % across columns (horizontal)
                        for j=1:size(obj.board,1) % down rows (vertical)
                            if (j==obj.boardHeight || obj.board(i,j)==0)
                                continue;
                            else
                                if (obj.board(j+1,i) == 0)
                                    belowSquare = j+1;
                                    curSquare = j;
                                    while(obj.board(belowSquare,i) == 0 && belowSquare <= obj.boardHeight)
                                        obj.board(belowSquare,i) = obj.board(curSquare,i);
                                        obj.board(curSquare,i) = 0;
                                        belowSquare = belowSquare + 1;
                                        curSquare = curSquare + 1;
                                    end
                                    if (belowSquare <= obj.boardHeight)
                                        if (obj.board(belowSquare,i) == obj.board(curSquare,i))
                                            obj.board(belowSquare,i) = obj.board(belowSquare,i)*2;
                                            obj.board(curSquare,i) = 0;
                                        end
                                    end
                                elseif (obj.board(j+1,i) == obj.board(j,i))
                                    obj.board(j+1,i) = obj.board(j+1,i)*2;
                                    obj.board(j,i) = 0;
                                end
                            end
                        end
                    end
                case 4 % right
                    for i=1:size(obj.board,1) % down rows (vertical)
                        for j=1:size(obj.board,2) % across columns (horizontal)
                            if (j == obj.boardWidth || obj.board(i,j) == 0)
                                continue;
                            else
                                if (obj.board(i,j+1) == 0)
                                    rightSquare = j+1;
                                    curSquare = j;
                                    while(obj.board(i,rightSquare) == 0 && rightSquare <= obj.boardWidth)
                                        obj.board(i,rightSquare) = obj.board(i,curSquare);
                                        obj.board(i,curSquare) = 0;
                                        rightSquare = rightSquare+1;
                                        curSquare=curSquare+1;
                                    end
                                    if (rightSquare <= obj.boardWidth)
                                        if (obj.board(i,rightSquare) == obj.board(i,curSquare))
                                            obj.board(i,rightSquare) = obj.board(i,rightSquare)*2;
                                            obj.board(i,curSquare) = 0;
                                        end
                                    end
                                elseif (obj.board(i,j+1) == obj.board(i,j))
                                    obj.board(i,j+1) = obj.board(i,j+1)*2;
                                    obj.board(i,j) = 0;
                                end
                            end
                        end
                    end
            end
        end
    end
end

