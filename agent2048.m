classdef agent2048 < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        netType
        gamma
        Qnet
        stateModel
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
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            defOpts = struct('netType','feedforward',...
                             'hiddenSizes',10,...
                             'gamma',.99,...
                             'actionSelectionMethod','e_greedy',...
                             'epsilon',.001,...
                             'temperature',.4,...
                             'maxUpdateBufferSize',32);
            
            if (isfield(options,'gamma'))
                obj.gamma = options.gamma;
            else
                disp(['no gamma provided... using default value ' num2str(defOpts.gamma)])
                obj.gamma = defOpts.gamma;
            end
            if (isfield(options,'netType'))
                if (strcmp(options.netType,'feedforward'))
                    obj.netType = 'feedforward';
                    obj.Qnet = feedforwardnet(options.hiddenSizes,'traingdm');
                    obj.Qnet.trainParam.showWindow = 0;
                    obj.Qnet = train(obj.Qnet,rand(16,1),rand(4,1));
                end
            else
                disp(['no netType provided... using default ' defOpts.netType])
                obj.netType = defOpts.netType;
                obj.Qnet = feedforwardnet(defOpts.hiddenSizes,'traingdm');
                obj.Qnet.trainParam.showWindow = 0;
                obj.Qnet = train(obj.Qnet,rand(16,10),rand(4,10));
            end
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
            obj.updateBuffer = struct('state1',{},'state2',{},'action',{},'reward',{});
            obj.replayBuffer = struct('state1',{},'state2',{},'action',{},'reward',{});
            if (isfield(options,'maxUpdateBufferSize'))
                obj.maxUpdateBufferSize = options.maxUpdateBufferSize;
            else
                disp(['No maxUpdateBufferSize provided... using default value ' num2str(defOpts.maxUpdateBufferSize)])
            end
        end
        
        function action = act(obj,currentState)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            actionValues = obj.Qnet(currentState);
            if (strcmp(obj.actionSelectionMethod,'e_greedy'))
                [~,action] = max(actionValues);
                if (rand < obj.epsilon)
                    action = ceil(rand*length(actionValues));
                end
            elseif (strcmp(obj.actionSelectionMethod,'softmax'))
                [softVals,action] = mySoftmax(actionValues,obj.temperature);
            end
        end
        
        function addToUpdateBuffer(obj,experience)
            %disp(['Update buffer length = ' num2str(length(obj.updateBuffer))])
            obj.updateBuffer(end+1) = experience;
            if (length(obj.updateBuffer) == obj.maxUpdateBufferSize)
                obj.updateQnet()
            end
        end
        
        function updateQnet(obj)
            s1 = [obj.updateBuffer.state1];
            s2 = [obj.updateBuffer.state2];
            actions = [obj.updateBuffer.action];
            r = [obj.updateBuffer.reward];
            targets = zeros(4,length(obj.updateBuffer));
            for i=1:length(obj.updateBuffer)
                targets(:,i) = obj.Qnet(s1(:,i));
                targets(actions(i)) = r(i) + obj.gamma*max(obj.Qnet(s2(:,i)));
            end
            obj.Qnet = train(obj.Qnet,s1,targets);
            obj.updateBuffer = struct('state1',{},'state2',{},'action',{},'reward',{});
        end
    end
end

