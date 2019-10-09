function [Xtr,Ytr,Xval,Yval,Xtst,Ytst,Xpca,G,COEFF,MU] = makeTrainValTestSets(data)
s1 = [data.state1];
a = [data.action];
G = [data.G];
actions = zeros(4,length(a));
for i=1:length(a)
    actions(a(i),i) = 1;
end
X = [s1; actions];
randInds = randperm(length(a));
X = X(:,randInds);
[COEFF, SCORE, LATENT, TSQUARED, EXPLAINED, MU] = pca(X');
for i=1:size(COEFF,2)
    Xpca(i,:) = (X'*COEFF(:,i))';
end
tstValFrac = floor(.1*length(data));
trEnd = length(data) - 2*tstValFrac;
valEnd = trEnd + tstValFrac;
tstEnd = valEnd + tstValFrac;
G = G(randInds);
for i=1:trEnd
    Xtr{i} = Xpca(:,i);
    Ytr{i} = G(i);
end
for i=trEnd+1:valEnd
    Xval{i-trEnd} = Xpca(:,i);
    Yval{i-trEnd} = G(i);
end
for i=valEnd+1:tstEnd
    Xtst{i - valEnd} = Xpca(:,i);
    Ytst{i - valEnd} = G(i);
end

end

