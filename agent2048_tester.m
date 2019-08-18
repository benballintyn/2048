%2048 agent tester
agentOpts.netType = 'feedforward';
agentOpts.hiddenSizes = [256 16];
agentOpts.gamma = .99;
agentOpts.actionSelectionMethod = 'e_greedy';
agentOpts.epsilon = .05;
agentOpts.maxUpdateBufferSize = 32;
if (exist('bestAgent','file'))
    bestAgent = load('bestAgent.mat'); bestAgent = bestAgent.bestAgent;
    a = bestAgent;
else
    a = agent2048(agentOpts);
end
%h = figure;
boardOpts.boardWidth = 4;
boardOpts.boardHeight = 4;
boardOpts.fourProb = .1;
boardOpts.playMode = 'AI';

nEpochs = 1000;
scores = zeros(1,nEpochs);
for epochs = 1:nEpochs
    board = gameBoard(boardOpts);
    while (~board.isGameOver())
        curScore = board.score;
        s1 = board.getGameState();
        action = a.act(s1);
        nMoved=board.updateBoard(action);
        %board.plotBoard()
        if (nMoved > 0)
            board.newBlock()
            %board.plotBoard()
            newScore = board.score;
            r = newScore - curScore;
            s2 = board.getGameState();
            exp = struct('state1',s1,'action',action,'reward',r,'state2',s2);
            a.addToUpdateBuffer(exp);
        else
            r = -.1;
            s2 = board.getGameState();
            exp = struct('state1',s1,'action',action,'reward',r,'state2',s2);
            a.addToUpdateBuffer(exp);
        end
    end
    a.updateQnet();
    disp(['Done with epoch #' num2str(epochs)])
    scores(epochs) = board.score;
end
bestAgent = a;
save('bestAgent.mat','bestAgent','-mat')