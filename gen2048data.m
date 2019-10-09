function [allExperiences,scores] = gen2048data(nGames)
boardOpts.boardWidth = 4;
boardOpts.boardHeight = 4;
boardOpts.fourProb = .1;
boardOpts.playMode = 'other';
allExperiences = struct('state1',{},'action',{},'reward',{},'state2',{},'time',{},'G',{});
count=0;
for i=1:nGames
    board=gameBoard(boardOpts);
    time = 0;
    gameExp = struct('state1',{},'action',{},'reward',{},'state2',{},'time',{},'G',{});
    gameRewards = [];
    while (~board.isGameOver())
        count=count+1;
        time = time+1;
        curScore = board.score;
        s1 = board.getGameState();
        s1(s1 > 0) = log2(s1(s1>0));
        randAction = ceil(rand*4);
        nMoved=board.updateBoard(randAction);
        if (nMoved > 0)
            board.newBlock()
            newScore = board.score;
            r = newScore - curScore;
            s2 = board.getGameState();
            s2(s2>0) = log2(s2(s2>0));
            exp = struct('state1',s1,'action',randAction,'reward',r,'state2',s2,'time',time,'G',0);
        else
            r = -.1;
            s2 = board.getGameState();
            s2(s2>0) = log2(s2(s2>0));
            exp = struct('state1',s1,'action',randAction,'reward',r,'state2',s2,'time',time,'G',0);
        end
        gameExp(time) = exp;
        gameRewards(time) = r;
        %
    end
    for t=1:time
        G = 0;
        for t2=t:time
            G = G + (.7^(t2 - t))*gameRewards(t2);
        end
        gameExp(t).G = G;
    end
    scores(i) = board.score;
    allExperiences = [allExperiences gameExp];
end
end

