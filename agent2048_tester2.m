%2048 agent tester2
%h = figure;
boardOpts.boardWidth = 4;
boardOpts.boardHeight = 4;
boardOpts.fourProb = .1;
boardOpts.playMode = 'AI';

actions = {'Up','Left','Down','Right'};
nEpochs = 100;
nGamesPerEpoch = 100;
scores = zeros(1,nEpochs);
totalGames = 0;
for epochs = 1:nEpochs
    for game = 1:nGamesPerEpoch
        totalGames = totalGames+1;
        board = gameBoard(boardOpts);
        time = 0;
        while (~board.isGameOver())
            time = time+1;
            curScore = board.score;
            s1 = board.getGameState();
            [action,vals] = a.act(s1,COEFF,MU);
            disp(['values: ' num2str(vals) ' action: ' actions{action}])
            nMoved=board.updateBoard(action);
            board.plotBoard()
            if (nMoved > 0)
                board.newBlock()
                board.plotBoard()
                newScore = board.score;
                r = (newScore - curScore);
                rewards(time) = r;
                s2 = board.getGameState();
                exp = struct('state1',s1,'action',action,'reward',r,'state2',s2,'time',time);
                a.addToUpdateBuffer(exp);
            else
                r = -10;
                rewards(time) = r;
                s2 = board.getGameState();
                exp = struct('state1',s1,'action',action,'reward',r,'state2',s2,'time',time);
                a.addToUpdateBuffer(exp);
                badMoveCount = 0;
                while(nMoved == 0 && badMoveCount < 100)
                    [action,vals] = a.act(s1,COEFF,MU);
                    disp(['values: ' num2str(vals) ' action: ' actions{action}])
                    nMoved=board.updateBoard(action);
                    if (nMoved == 0)
                        r = -10;
                        rewards(time) = r;
                        s2 = board.getGameState();
                        exp = struct('state1',s1,'action',action,'reward',r,'state2',s2,'time',time);
                        a.addToUpdateBuffer(exp);
                        badMoveCount = badMoveCount+1;
                    else
                        newScore = board.score;
                        r = (newScore - curScore);
                        rewards(time) = r;
                        s2 = board.getGameState();
                        exp = struct('state1',s1,'action',action,'reward',r,'state2',s2,'time',time);
                        a.addToUpdateBuffer(exp);
                    end
                end
                if (badMoveCount >= 100)
                    while(nMoved == 0)
                        action = ceil(rand*4);
                        nMoved=board.updateBoard(action);
                        if (nMoved == 0)
                            r = -10;
                            rewards(time) = r;
                            s2 = board.getGameState();
                            exp = struct('state1',s1,'action',action,'reward',r,'state2',s2,'time',time);
                            a.addToUpdateBuffer(exp);
                            badMoveCount = badMoveCount+1;
                        else
                            newScore = board.score;
                            r = (newScore - curScore);
                            rewards(time) = r;
                            s2 = board.getGameState();
                            exp = struct('state1',s1,'action',action,'reward',r,'state2',s2,'time',time);
                            a.addToUpdateBuffer(exp);
                        end
                    end
                end
                badMoveCount = 0;
                board.newBlock();
                board.plotBoard()
            end
        end
        disp(['Done with game #' num2str(game)])
        scores(totalGames) = board.score;
        a.updateValueNet(rewards);
        clear rewards
    end
    %a.updateValueNet();
    disp(['Done with epoch #' num2str(epochs)])
    bestAgent = a;
    save('bestAgent.mat','bestAgent','-mat')
end