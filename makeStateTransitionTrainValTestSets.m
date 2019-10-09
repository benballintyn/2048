function [Xtr,Ytr,Xval,Yval,Xtst,Ytst,X,s2] = makeStateTransitionTrainValTestSets(data)
s1 = [data.state1];
a = [data.action];
s2 = [data.state2];
actions = zeros(4,length(a));
for i=1:length(a)
    actions(a(i),i) = 1;
end
X = [s1; actions];
randInds = randperm(length(a));
X = X(:,randInds);
s2 = s2(:,randInds);
tstValFrac = floor(.1*length(a));
trEnd = length(a) - 2*tstValFrac;
valEnd = trEnd + tstValFrac;
tstEnd = valEnd + tstValFrac;
for i=1:trEnd
    Xtr{i} = X(:,i);
    Ytr{i} = s2(:,i);
end
for i=trEnd+1:valEnd
    Xval{i-trEnd} = X(:,i);
    Yval{i-trEnd} = s2(:,i);
end
for i=valEnd+1:tstEnd
    Xtst{i - valEnd} = X(:,i);
    Ytst{i - valEnd} = s2(:,i);
end
end

