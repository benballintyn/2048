classdef agent2048 < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        isModelBased
        valueNet
        valueNetTrainOptions
        valueNetType
        modelNet
        modelNetTrainOptions
        modelNetType
        nStateVars
        nActionsPerState
        gamma
        updateBuffer
        maxUpdateBufferSize
        replayBuffer
        actionSelectionMethod
        rolloutN
        epsilon
        temperature
    end
    
    methods
        function obj = agent2048(options)
            % define the default options
            defOpts = struct('valueNetType','feedforward',...
                             'valueNetHiddenSizes',[256 16],...
                             'nStateVars',16,...
                             'nActionsPerState',4,...
                             'modelNetType','feedforward',...
                             'modelNetHiddenSizes',289,...
                             'gamma',.99,...
                             'actionSelectionMethod','e_greedy',...
                             'epsilon',.001,...
                             'temperature',.4,...
                             'maxUpdateBufferSize',1024,...
                             'preTrainingDataPath','none');
            
            % If a gamma (discount factor) is provided, use it
            if (isfield(options,'gamma'))
                obj.gamma = options.gamma;
            else
                disp(['no gamma provided... using default value ' num2str(defOpts.gamma)])
                obj.gamma = defOpts.gamma;
            end
            
            % If a value net is not provided, read from options what type 
            % of NN to use for the value net and initialize it
            if (isfield(options,'valueNet'))
                disp('Value net provided')
                obj.valueNet = options.valueNet;
                if (isfield(options,'valueNetTrainOptions'))
                    obj.valueNetTrainOptions = options.valueNetTrainOptions;
                else
                    obj.valueNetTrainOptions = trainingOptions('rmsprop','MiniBatchSize',64,...
                                                      'Shuffle','every-epoch',...
                                                      'ExecutionEnvironment','gpu');
                end
            else
                disp('Value net not provided... creating a new one')
                valueNetLayers = [sequenceInputLayer(20)
                                  fullyConnectedLayer(400)
                                  reluLayer
                                  fullyConnectedLayer(100)
                                  reluLayer
                                  fullyConnectedLayer(50)
                                  reluLayer
                                  fullyConnectedLayer(1)
                                  regressionLayer];
                obj.valueNetTrainOptions = trainingOptions('rmsprop','MiniBatchSize',64,...
                                                  'Shuffle','every-epoch',...
                                                  'ExecutionEnvironment','gpu');
                randInput = 2.^(ceil(rand(20,1)*8));
                randInput(end-3:end) = 0; randAction = ceil(rand*4);
                randInput(end-4+randAction) = 1;
                randValue = max(randInput);
                obj.valueNet = trainNetwork(randInput,randValue,valueNetLayers,obj.valueNetTrainOptions);
            end
            
            % Read from options what type of NN to use for the state
            % transition net and initialize it
            if (options.isModelBased)
                obj.isModelBased = 1;
                if (isfield(options,'modelNet'))
                    obj.modelNet = options.modelNet;
                    if (isfield(options,'modelNetTrainOptions'))
                        obj.modelNetTrainOptions = options.modelNetTrainOptions;
                    else
                        obj.modelNetTrainOptions = trainingOptions('rmsprop','MiniBatchSize',64,...
                                                                   'Shuffle','every-epoch',...
                                                                   'ExecutionEnvironment','gpu');
                    end
                else
                    modelNetLayers = [sequenceInputLayer(20)
                                      fullyConnectedLayer(400)
                                      reluLayer
                                      fullyConnectedLayer(400)
                                      reluLayer
                                      fullyConnectedLayer(256)
                                      reluLayer
                                      fullyConnectedLayer(16)
                                      regressionLayer];
                    obj.modelNetTrainOptions = trainingOptions('rmsprop','MiniBatchSize',64,...
                                                                   'Shuffle','every-epoch',...
                                                                   'ExecutionEnvironment','gpu');
                    randInput = cell(1,1);
                    randInput{1,1} = 2.^(ceil(rand(20,1)*8));
                    randInput{1,1}(end-3:end) = 0; randAction = ceil(rand*4);
                    randInput{1,1}(end-4+randAction) = 1;
                    randNextState = cell(1,1);
                    randNextState{1,1} = 2.^(ceil(rand(16,1))*8);
                    obj.modelNet = trainNetwork(randInput,randNextState,modelNetLayers,obj.modelNetTrainOptions);
                end
            else
                obj.isModelBased = 0;
            end
            
            % Check if a path to pretraining data is given. If so, pre train
            % the valueNet and the modelNet (if agent is model-based)
            
            
            % pull the desired actionSelectionMethod (policy, e.g. e-greedy/softmax) from the
            % options if it exists
            if (strcmp(options.actionSelectionMethod,'e_greedy'))
                obj.actionSelectionMethod = 'e_greedy';
                if (isfield(options,'epsilon'))
                    obj.epsilon = options.epsilon;
                else
                    disp(['no epsilon provided... using default value ' num2str(defOpts.epsilon)])
                    obj.epsilon = defOpts.epsilon;
                end
            elseif (strcmp(options.actionSelectionMethod,'softmax'))
                obj.actionSelectionMethod = 'softmax';
                if (isfield(options,'temperature'))
                    obj.temperature = options.temperature;
                else
                    disp(['no temperature provided... using default value ' num2str(defOpts.temperature)])
                    obj.temperature = defOpts.temperature;
                end
            end
            
            % Initialize empty update and replay buffers to store
            % experiences
            obj.updateBuffer = struct('state1',{},'state2',{},'action',{},'reward',{},'time',{});
            obj.replayBuffer = struct('state1',{},'state2',{},'action',{},'reward',{},'time',{});
            if (isfield(options,'maxUpdateBufferSize'))
                obj.maxUpdateBufferSize = options.maxUpdateBufferSize;
            else
                disp(['No maxUpdateBufferSize provided... using default value ' num2str(defOpts.maxUpdateBufferSize)])
            end
        end
        
        % This method takes as input a representaton of the current state
        % and feeds it into the value network to obtain predicted values.
        % It then has the actionSelectionMethod operate on these values to
        % choose an action
        function [action,actionValues] = act(obj,currentState,varargin)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if (isempty(varargin))
                COEFF = varargin{1};
                MU = varargin{2};
                for i=1:4
                    curAction = zeros(4,1); curAction(i) = 1;
                    stateAction = [currentState; curAction];
                    stateAction = ((stateAction-MU)'*COEFF)';
                    actionValues(i) = predict(obj.valueNet,stateAction);
                end
            else
                for i=1:4
                    curAction = zeros(4,1); curAction(i) = 1;
                    stateAction = [currentState; curAction];
                    actionValues(i) = predict(obj.valueNet,stateAction);
                end
            end
            if (strcmp(obj.actionSelectionMethod,'e_greedy'))
                [~,action] = max(actionValues);
                if (rand < obj.epsilon)
                    action = ceil(rand*length(actionValues));
                end
            elseif (strcmp(obj.actionSelectionMethod,'softmax'))
                [softVals,action] = mySoftmax(actionValues,obj.temperature);
                actionValues = softVals;
            end
        end
        
        % add an experience to the updateBuffer
        function addToUpdateBuffer(obj,experience)
            %disp(['Update buffer length = ' num2str(length(obj.updateBuffer))])
            obj.updateBuffer(end+1) = experience;
            %{
            if (length(obj.updateBuffer) == obj.maxUpdateBufferSize)
                obj.updateValueNet()
            end
            %}
        end
        
        % add an experience to the replayBuffer
        function addToReplayBuffer(obj,experience)
            obj.replayBuffer(end+1) = experience;
        end
        
        % update the value network with the experiences stored in the
        % update buffer
        function updateValueNet(obj,allRewards)
            if (length(obj.updateBuffer) == 0)
                return;
            end
            disp(['Updating valueNet with updateBuffer of length ' num2str(length(obj.updateBuffer))])
            s1 = [obj.updateBuffer.state1];
            %s2 = [obj.updateBuffer.state2];
            actions = [obj.updateBuffer.action];
            actionVecs = zeros(4,length(obj.updateBuffer));
            for i=1:length(obj.updateBuffer)
                actionVecs(actions(i),i) = 1;
            end
            Xtr = [s1; actionVecs];
            %r = [obj.updateBuffer.reward];
            targets = zeros(1,length(obj.updateBuffer));
            %{
            for i=1:length(obj.updateBuffer)
                targets(i) = r(i) + obj.gamma*max(predict(obj.valueNet,Xtr(:,i)));
            end
            %}
            for i=1:length(obj.updateBuffer)
                targets(i) = obj.getReturn(allRewards(i:end));
            end
            randOrder = randperm(length(obj.updateBuffer));
            Xtr = Xtr(:,randOrder);
            targets = targets(randOrder);
            obj.valueNet = trainNetwork(Xtr,targets,obj.valueNet.Layers,obj.valueNetTrainOptions);
            obj.updateBuffer = struct('state1',{},'state2',{},'action',{},'reward',{},'time',{});
        end
        
        function G = getReturn(obj,allRewards)
            G = 0;
            for i=1:length(allRewards)
                G = G + obj.gamma^(i-1)*allRewards(i);
            end
        end
    end
end

