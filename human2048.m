% human 2048
global g
options.boardHeight = 4;
options.boardWidth = 4;
options.fourProb = .1;
options.playMode = 'human';
g = gameBoard(options);

h=figure;
set(h,'KeyPressFcn',@KeyPressCb);
g.plotBoard();

function KeyPressCb(~,evnt)
global g
    %fprintf('key pressed: %s\n',evnt.Key);
    if strcmpi(evnt.Key,'leftarrow')
        n=g.updateBoard(2);
        g.plotBoard();
        if (n > 0)
            g.newBlock();
            g.plotBoard();
        end
    elseif strcmpi(evnt.Key,'rightarrow')
        n=g.updateBoard(4);
        g.plotBoard();
        if (n > 0)
            g.newBlock();
            g.plotBoard();
        end
    elseif strcmpi(evnt.Key,'downarrow')
        n=g.updateBoard(3);
        g.plotBoard();
        if (n > 0)
            g.newBlock();
            g.plotBoard();
        end
    elseif (strcmpi(evnt.Key,'uparrow'))
        n=g.updateBoard(1);
        g.plotBoard();
        if (n > 0)
            g.newBlock();
            g.plotBoard();
        end
    end
end