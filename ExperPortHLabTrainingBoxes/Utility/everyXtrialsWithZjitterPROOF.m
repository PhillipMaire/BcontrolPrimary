% %%
% 
% userSetCatchTrialProb = .1;%10% trials will have a catch trial
% 
% 
% %% REMOVE THIS WHEN DONW TESTING ####
% userSetCatchTrialProb = 1%$#######################
% forceCatchTrial= rand(1)<userSetCatchTrialProb;
% 
% 
% 
% userSet = 10;
% 
% rand(userSet, 1)
% 
% 
% % every 10 trials on average but not every 10 exactly with only
% % 1 unit deviation
% % if 10 then trigger
% 
% everyNum = 10;
% jitterIs = 1
% 
% rangeVar =  everyNum-jitterIs : everyNum+jitterIs
% 
% tmp = zeros(1,100);
% tmp(ceil(rand(1,10).*100)) = 1;
% %%
% test3 = []
% for kk = 1:30000
%     % close all
%     tmp = [];
%     testALL = []
%     whichOne=[]
%     for k = 1:10
%         if length(tmp)>=rangeVar(end)%if enough trials have gone by
%             toFind = flip(tmp(end-rangeVar(end)+1:end));
%             test1 = find(toFind==1);
%         else %not enough trial choose at random probabilty of 1 over Xtrials if even has not occured yey
%             if ~isempty(find(tmp ==1)) %if event already occured
%                 test1 = [1 1]; %this will force a regular trial
%             elseif rand(1)< (1/(everyNum+1 -length(tmp) ))
%                 
%                 test1 =rangeVar(end); %this will force trigger
%             else
%                 test1 = [1 1]; %this will force a regular trial
%             end
%         end
%         if length(test1) == 1
%             test2 = find( rangeVar == test1);
%         elseif length(test1) > 1
%             test2 = [];
%         else
%             
%             test2 = length(rangeVar); %test1 is empty becasue no
%             %last sound trial in range force trigger by making it last in
%             %range var
%         end
%         
%         if isempty(test2)
%             % there was a sound trial too recently so leave it alone
%             triggerSoundTrial = 0;
%             WO = 0;
%         else
%             if rand(1)<=  1/(length(rangeVar)+1 - test2)
%                 triggerSoundTrial = 1;
%                 WO = test2;
%             elseif  test2/length(rangeVar) == 1
%                 
%                 triggerSoundTrial = 1;
%                 WO = test2;
%             end
%             
%         end
%         
%         
%         if triggerSoundTrial
%             tmp(end+1) =1;
%         else
%             tmp(end+1) =0;
%         end
%         
%         testALL(k) = triggerSoundTrial;
%         whichOne(k) = WO;
%     end
%     
%     
%     whichOne2 = whichOne(whichOne~=0);
%     % figure, hist(whichOne2, 30);
%     if isempty(find(whichOne))
%         test3(kk) = 0;
%     else
%         test3(kk) = find(whichOne);
%     end
% end
% figure, hist(test3, 50)

%% tester with the entire finction shows that period before there is enought
%% trials, the ditribtion is even in terms of when the catch trial is introduced
%% a 0 means that it didnt occur, and by design will occur the nxt trial, not shown here
showNoZerosIndist = 1;% show how ((Xtrials+Zjitter)-1)th trial is not forced yet to
% equal ditribution
showNoZerosIndist = 0; % see how program forces (Xtrials+Zjitter)th trial
% to be a catch trial so no 0s in distribution

close all
Xtrials = 10;
Zjitter = 1;
rangeVar =  Xtrials-Zjitter : Xtrials+Zjitter;
test3 = []
for kk = 1:30000
    % close all
    eventList = 0;
    eventOfInterest=1;
    testALL = [];
    whichOne=[];
    for k = 1:(Xtrials+Zjitter-showNoZerosIndist-1)
        
        [triggerCatchTrial, test2] = everyXtrialsWithZjitter(Xtrials, Zjitter,eventList ,eventOfInterest);
        
        if triggerCatchTrial
            
            eventList(end+1) =1;
        else
            eventList(end+1) =0;
        end
        
        testALL(k) = triggerCatchTrial;
        if isempty(test2)
            whichOne(k) = 0;
        else
            whichOne(k) = test2;
        end
    end
    
    
    whichOne2 = whichOne(whichOne~=0);
    % figure, hist(whichOne2, 30);
    if isempty(find(whichOne))
        test3(kk) = 0;
    else
        test3(kk) = find(whichOne);
    end
end
figure, hist(test3, 50)

%% this shows that the distribution of jitters are equally random. the plot is all
%% the delays of the events so for these setting...
% Xtrials = 10;
% Zjitter = 1;
% the numbers will be 9 thorugh 11 (trials) 

close all
Xtrials = 10;
Zjitter = 1;
rangeVar =  Xtrials-Zjitter : Xtrials+Zjitter;
    % close all
    eventList = 0;
    eventOfInterest=1;
    testALL = [];
    whichOne=[];
    for k = 1:2000
        
        [triggerCatchTrial, test2] = everyXtrialsWithZjitter(Xtrials, Zjitter,eventList ,eventOfInterest);
        
        if triggerCatchTrial
            
            eventList(end+1) =1;
        else
            eventList(end+1) =0;
        end
        
        testALL(k) = triggerCatchTrial;
        if isempty(test2)
            whichOne(k) = 0;
        else
            whichOne(k) = test2;
        end
    end
    whichOne = whichOne.*testALL; % only look at the trials which were catch trials 
    
    whichOne2 = whichOne(whichOne~=0);
    figure, hist(rangeVar(whichOne2), 30);
%     if isempty(find(whichOne))
%         test3(kk) = 0;
%     else
%         test3(kk) = find(whichOne);
%     end
