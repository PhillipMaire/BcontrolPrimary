function R = preprocessEmbC(C,stim_trial,stim_delay_in_task_periods,stim_dur_in_task_periods,...
    whisker_pos_thresh_low,whisker_pos_thresh_high,stim_state_for_EmbC,stim_AOM_power)
%
% INPUTS:
%   C: An embedded C program as a string.
%   stim_trial: A boolean indicating whether stimulations should be enabled
%               in returned program.
%
% RETURNS:
%
%   R: A preprocessed C program suitable for use as an argument to 
%       @RTLSM/SetStateProgram.m
%
% DHO, 7/10.
%

R = C;


% if stim_trial == true
%     find_pattern = 'STIM_TRIAL_BOOL = 0'; % This is the default, currently in the C program.
%     replace_pattern = 'STIM_TRIAL_BOOL = 1';
%     ind = strfind(C,find_pattern);
%     
%     if length(find_pattern) ~= length(replace_pattern)
%         error('Find and replace text must be same length.')
%     end
%     
%     R(ind:(ind+(length(find_pattern)-1))) = replace_pattern;
% end

%----------------
if stim_trial == true
    find_pattern = 'STIM_TRIAL_BOOL = 0'; % This is the default, currently in the C program.
    replace_pattern = 'STIM_TRIAL_BOOL = 1';
    ind = strfind(R,find_pattern);
    pre = R(1:(ind-1));
    post = R((ind+length(find_pattern)):end);
    R = [pre replace_pattern post];
end

%----------------
find_pattern = 'static unsigned stim_queue[XXX + 1]'; % This is the default, currently in the C program.
                                                      % 'XXX' is not defined and will error absent this preprocessing.
replace_pattern = ['static unsigned stim_queue[' int2str(stim_delay_in_task_periods) ' + 1]'];
ind = strfind(R,find_pattern);
pre = R(1:(ind-1));
post = R((ind+length(find_pattern)):end);
R = [pre replace_pattern post];

%----------------
find_pattern = 'const unsigned stim_dur_473 = XXX'; % This is the default, currently in the C program.
                                                      % 'XXX' is not defined and will error absent this preprocessing.
replace_pattern = ['const unsigned stim_dur_473 = ' int2str(stim_dur_in_task_periods)];
ind = strfind(R,find_pattern);
pre = R(1:(ind-1));
post = R((ind+length(find_pattern)):end);
R = [pre replace_pattern post];

%----------------
find_pattern = 'const double whisker_pos_thresh_low = XXX'; % This is the default, currently in the C program.
                                                      % 'XXX' is not defined and will error absent this preprocessing.
replace_pattern = ['const double whisker_pos_thresh_low = ' sprintf('%0.1f',whisker_pos_thresh_low)];
ind = strfind(R,find_pattern);
pre = R(1:(ind-1));
post = R((ind+length(find_pattern)):end);
R = [pre replace_pattern post];

%----------------
find_pattern = 'const double whisker_pos_thresh_high = XXX'; % This is the default, currently in the C program.
                                                      % 'XXX' is not defined and will error absent this preprocessing.
replace_pattern = ['const double whisker_pos_thresh_high = ' sprintf('%0.1f',whisker_pos_thresh_high)];
ind = strfind(R,find_pattern);
pre = R(1:(ind-1));
post = R((ind+length(find_pattern)):end);
R = [pre replace_pattern post];

% %----------------
% find_pattern = 'const double stim_type_for_EmbC = XXX'; % This is the default, currently in the C program.
%                                           % 'XXX' is not defined and will error absent this preprocessing.
% replace_pattern = ['const double stim_type_for_EmbC = ' int2str(stim_type_for_EmbC)];
% ind = strfind(R,find_pattern);
% pre = R(1:(ind-1));
% post = R((ind+length(find_pattern)):end);
% R = [pre replace_pattern post];



%----------------
find_pattern = 'static unsigned stim_state[XXX]'; % This is the default, currently in the C program.
                                          % 'XXX' is not defined and will error absent this preprocessing.
replace_pattern = ['static unsigned stim_state[' int2str(length(stim_state_for_EmbC)) ']'];
ind = strfind(R,find_pattern);
pre = R(1:(ind-1));
post = R((ind+length(find_pattern)):end);
R = [pre replace_pattern post];


%----------------
find_pattern = '{XXX}'; % This is the default, currently in the C program.
                        % 'XXX' is not defined and will error absent this preprocessing.
replace_pattern = int2str(stim_state_for_EmbC);
replace_pattern(findstr(replace_pattern,'  '))=',';
replace_pattern(findstr(replace_pattern,' '))=[];
replace_pattern=['{', replace_pattern, '}'];
ind = strfind(R,find_pattern);
pre = R(1:(ind-1));
post = R((ind+length(find_pattern)):end);
R = [pre replace_pattern post];


%----------------
find_pattern = 'const double stim_AOM_power = XXX'; % This is the default, currently in the C program.
                                          % 'XXX' is not defined and will error absent this preprocessing.
replace_pattern = ['const double stim_AOM_power = ' sprintf('%0.1f',stim_AOM_power)];
ind = strfind(R,find_pattern);
pre = R(1:(ind-1));
post = R((ind+length(find_pattern)):end);
R = [pre replace_pattern post];



