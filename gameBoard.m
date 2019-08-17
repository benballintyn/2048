classdef gameBoard < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        board
        noCombine
        boardHeight
        boardWidth
        fourProb
        cmap
        score
    end
    
    methods
        function obj = gameBoard(options)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.boardHeight = options.boardHeight;
            obj.boardWidth = options.boardWidth;
            obj.board = zeros(obj.boardHeight,obj.boardWidth);
            obj.noCombine = zeros(obj.boardHeight,obj.boardWidth);
            obj.fourProb = options.fourProb;
            rowPerm = randperm(4);
            colPerm = randperm(4);
            obj.board(rowPerm(1),colPerm(1)) = 2;
            obj.board(rowPerm(2),colPerm(2)) = 2;
            obj.cmap = prism;
            obj.cmap(1,:) = ones(1,3);
            if (strcmp(options.playMode,'human'))
                disp('Manual play')
            else
                figure;
                plotBoard(obj)
            end
        end
        
        function nMoved=updateBoard(obj,move)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.noCombine = zeros(obj.boardHeight,obj.boardWidth);
            nMoved = 0;
            switch move
                case 1 % up
                    for i=1:size(obj.board,2) % across columns (horizontal)
                        for j=1:size(obj.board,1) % down rows (vertical)
                            if (j==1 || obj.board(j,i)==0)
                                continue;
                            else
                                if (obj.board(j-1,i) == 0)
                                    aboveSquare = j-1;
                                    curSquare = j;
                                    nMoved = nMoved+1;
                                    while (aboveSquare > 0 && obj.board(aboveSquare,i) == 0)
                                        obj.board(aboveSquare,i) = obj.board(curSquare,i);
                                        obj.board(curSquare,i) = 0;
                                        aboveSquare = aboveSquare-1;
                                        curSquare = curSquare - 1;
                                    end
                                    if (aboveSquare > 0)
                                        if (obj.board(aboveSquare,i) == obj.board(curSquare,i) && ~obj.noCombine(aboveSquare,i))
                                            obj.board(aboveSquare,i) = obj.board(aboveSquare,i)*2;
                                            obj.board(curSquare,i) = 0;
                                            obj.noCombine(aboveSquare,i) = 1;
                                        end
                                    end
                                elseif (obj.board(j-1,i) == obj.board(j,i) && ~obj.noCombine(j-1,i))
                                    obj.board(j-1,i) = obj.board(j-1,i)*2;
                                    obj.board(j,i) = 0;
                                    obj.noCombine(j-1,i) = 1;
                                    nMoved=nMoved+1;
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
                                    nMoved = nMoved+1;
                                    while(leftSquare > 0 && obj.board(i,leftSquare) == 0)
                                        obj.board(i,leftSquare) = obj.board(i,curSquare);
                                        obj.board(i,curSquare) = 0;
                                        leftSquare = leftSquare-1;
                                        curSquare=curSquare-1;
                                    end
                                    if (leftSquare > 0)
                                        if (obj.board(i,leftSquare) == obj.board(i,curSquare) && ~obj.noCombine(i,leftSquare))
                                            obj.board(i,leftSquare) = obj.board(i,leftSquare)*2;
                                            obj.board(i,curSquare) = 0;
                                            obj.noCombine(i,leftSquare) = 1;
                                        end
                                    end
                                elseif (obj.board(i,j-1) == obj.board(i,j) && ~obj.noCombine(i,j-1))
                                    obj.board(i,j-1) = obj.board(i,j-1)*2;
                                    obj.board(i,j) = 0;
                                    obj.noCombine(i,j-1) = 1;
                                    nMoved = nMoved+1;
                                end
                            end
                        end
                    end
                case 3 % down
                    for i=1:size(obj.board,2) % across columns (horizontal)
                        for j=fliplr(1:size(obj.board,1)) % down rows (vertical)
                            if (j==obj.boardHeight || obj.board(j,i)==0)
                                continue;
                            else
                                if (obj.board(j+1,i) == 0)
                                    belowSquare = j+1;
                                    curSquare = j;
                                    nMoved = nMoved+1;
                                    while(belowSquare <= obj.boardHeight && obj.board(belowSquare,i) == 0)
                                        obj.board(belowSquare,i) = obj.board(curSquare,i);
                                        obj.board(curSquare,i) = 0;
                                        belowSquare = belowSquare + 1;
                                        curSquare = curSquare + 1;
                                    end
                                    if (belowSquare <= obj.boardHeight)
                                        if (obj.board(belowSquare,i) == obj.board(curSquare,i) && ~obj.noCombine(belowSquare,i))
                                            obj.board(belowSquare,i) = obj.board(belowSquare,i)*2;
                                            obj.board(curSquare,i) = 0;
                                            obj.noCombine(belowSquare,i) = 1;
                                        end
                                    end
                                elseif (obj.board(j+1,i) == obj.board(j,i) && ~obj.noCombine(j+1,i))
                                    obj.board(j+1,i) = obj.board(j+1,i)*2;
                                    obj.board(j,i) = 0;
                                    obj.noCombine(j+1,i) = 1;
                                    nMoved = nMoved+1;
                                end
                            end
                        end
                    end
                case 4 % right
                    for i=1:size(obj.board,1) % down rows (vertical)
                        for j=fliplr(1:size(obj.board,2)) % across columns (horizontal)
                            if (j == obj.boardWidth || obj.board(i,j) == 0)
                                continue;
                            else
                                if (obj.board(i,j+1) == 0)
                                    rightSquare = j+1;
                                    curSquare = j;
                                    nMoved = nMoved+1;
                                    while(rightSquare <= obj.boardWidth && obj.board(i,rightSquare) == 0)
                                        obj.board(i,rightSquare) = obj.board(i,curSquare);
                                        obj.board(i,curSquare) = 0;
                                        rightSquare = rightSquare+1;
                                        curSquare=curSquare+1;
                                    end
                                    if (rightSquare <= obj.boardWidth)
                                        if (obj.board(i,rightSquare) == obj.board(i,curSquare) && ~obj.noCombine(i,rightSquare))
                                            obj.board(i,rightSquare) = obj.board(i,rightSquare)*2;
                                            obj.board(i,curSquare) = 0;
                                            obj.noCombine(i,rightSquare) = 1;
                                        end
                                    end
                                elseif (obj.board(i,j+1) == obj.board(i,j) && ~obj.noCombine(i,j+1))
                                    obj.board(i,j+1) = obj.board(i,j+1)*2;
                                    obj.board(i,j) = 0;
                                    obj.noCombine(i,j+1) = 1;
                                    nMoved = nMoved+1;
                                end
                            end
                        end
                    end
            end
        end
        
        function newBlock(obj)
            zeroSquares = find(obj.board == 0);
            [i,j] = ind2sub([obj.boardHeight obj.boardWidth],zeroSquares);
            r = ceil(rand*length(i));
            if (rand < obj.fourProb)
                obj.board(i(r),j(r)) = 4;
            else
                obj.board(i(r),j(r)) = 2;
            end
        end
        
        function plotBoard(obj)
            imagesc(log2(obj.board)+1); colormap(obj.cmap); caxis([1 64]); %xlim([0 4]); %ylim([0 4])
            for i=1:obj.boardWidth
                for j=1:obj.boardHeight
                    if (obj.board(j,i) == 0)
                        continue;
                    else
                        text(i-.2,j,[num2str(obj.board(j,i))],'FontSize',20,'FontWeight','bold')
                    end
                end
            end
        end
    end
end

