



%%
function [triggerCatchTrial, test2] = everyXtrialsWithZjitter(Xtrials, Zjitter,eventList ,eventOfInterest)
%use this format ...
% [triggerCatchTrial, ~] = everyXtrialsWithZjitter(Xtrials,Zjitter,eventList ,eventOfInterest)
% becasue the test2 is just for testing/ proof purposes

triggerCatchTrial = 0;
EVENTS = (eventList == eventOfInterest); %make 0s and 1s 1s mean event of interest occured
% Xtrials = 10;
% Zjitter = 1
rangeVar =  Xtrials-Zjitter : Xtrials+Zjitter;


if length(EVENTS)>=rangeVar(end)%if enough trials have gone by
    toFind = EVENTS(end-rangeVar(end)+1:end);
    toFind = flipud(toFind(:));
    test1 = find(toFind==1);
else %not enough trial choose at random probabilty of 1 over Xtrials if even has not occured yey
    if ~isempty(find(EVENTS ==1, 1)) %if event already occured
        test1 = [1 1]; %this will force a regular trial
    elseif rand(1)< (1/(Xtrials+1 -length(EVENTS) ))
        test1 =rangeVar(end); %this will force trigger
    else
        test1 = [1 1]; %this will force a regular trial
    end
end
if length(test1) == 1
    test2 = find( rangeVar == test1);
elseif length(test1) > 1
    test2 = [];
else
    test2 = length(rangeVar); %test1 is empty becasue no
    %last sound trial in range force trigger by making it last in
    %range var
end
if isempty(test2)
    % there was a sound trial too recently so leave it alone
else
    if rand(1)<=  1/(length(rangeVar)+1 - test2)
        triggerCatchTrial = 1;
    elseif  test2/length(rangeVar) == 1
        triggerCatchTrial = 1;
    end
end


triggerCatchTrial = logical(triggerCatchTrial);

