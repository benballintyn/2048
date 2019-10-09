function [agent] = preTrainAgentValueNet(agent,preTrainingData,batchSize)
nsamples = length(preTrainingData);
nbatches = ceil(nsamples/batchSize);
for i=1:nbatches
    randInds = ceil(rand(1,batchSize)*nsamples);
    s1 = [preTrainingData(randInds).state1];
    a  = [preTrainingData(randInds).action];
    r  = [preTrainingData(randInds).reward];
    s2 = [preTrainingData(randInds).state2];
    v2 = agent.Qnet(s2);
    t = agent.Qnet(s1);
    for j=1:batchSize
        t(a(j),j) = r(j) + agent.gamma*max(v2(:,j));
    end
    agent.Qnet = train(agent.Qnet,s1,t,'UseGPU','yes');
    disp(['Done with batch #' num2str(i) ' of ' num2str(nbatches)])
end
end

