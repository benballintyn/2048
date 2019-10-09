function [scores] = testAgent2048(agent)
boardOpts.boardWidth = 4;
boardOpts.boardHeight = 4;
boardOpts.fourProb = .1;
boardOpts.playMode = 'AI';

nGames = 100;
scores = zeros(1,nGames);
totalGames = 0;
actions = {'Up','Left','Down','Right'};
for game=1:nGames
    totalGames = totalGames+1;
    board = gameBoard(boardOpts);
    time = 0;
    while (~board.isGameOver())
        time = time+1;
        s1 = board.getGameState();
        [action,vals] = agent.act(s1);
        nMoved=board.updateBoard(action);
        board.plotBoard()
        disp(['values: ' num2str(vals) ' action: ' actions{action}])
        if (nMoved > 0)
            board.newBlock()
            board.plotBoard()
        else
            while(nMoved == 0)
                [action,vals] = agent.act(s1);
                disp(['values: ' num2str(vals) ' action: ' actions{action}])
                nMoved=board.updateBoard(action);
            end
            board.newBlock();
            board.plotBoard()
        end
    end
    disp(['Game #' num2str(game) ' final score = ' num2str(board.score)])
    scores(game) = board.score;
end
end

