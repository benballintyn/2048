% gen2048data script
preTrainingData = struct('state1',{},'action',{},'reward',{},'state2',{},'time',{},'G',{});
allScores = [];
for i=1:100
    [exp,scores] = gen2048data(100);
    preTrainingData = [preTrainingData exp];
    allScores = [allScores scores];
    disp(['Done with round ' num2str(i)])
end
%save('preTrainingData.mat','preTrainingData','-mat')