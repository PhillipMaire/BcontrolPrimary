function ClearPrefs(user)
% ClearPrefs(USER)
% Using builtin Matlab pref functions, clear saved preferences
% for the specified user
% See SavePrefs(USER), RestorePrefs(USER)

% ZF MAINEN, CSHL, 1/01

global exper

% look at all the preferences
p = GetPref;
pref = fieldnames(p);
% find preferences matching the user
for n=1:length(pref)
    [prefuser module_param] = strtok(pref{n},'.');
    if strcmp(prefuser,user)
        % decompose pref into module, param
        [module param] = strtok(module_param,'.');
        param = strtok(param,'.');
    
        % clear the preferences
        rmpref(pref{n});
    end
end