function [value] = get_generic(key)

global fake_rp_box;  
if fake_rp_box==2, srate=200000; % GetSampleRate(RPbox('getsoundmachine'));
else               srate=50e6/1024;
end;
   
   
gvals = {
    'amp'                   , 0.095          ; ...
    'sampling_rate'         , srate          ; ...
    'ramp_dur'              , 0.05*1000      ; ...  
    'badboy_shh_len'        , 0.15           ; ...
    'badboy_spacer_len'     , 0.05           ; ...
    'badboy_reps'           , 4              ; ...
    'white_noise_len'       , 2              ; ...
    'trigger_time'          , 0.03           ; ...
    'side_list_left'        , 1              ; ...
    'side_list_right'       , 0              ; ...
    'min_prechord_time'     , 0.2            ; ...
    
    };

ind = find(strcmp(gvals(:,1), key));

if isempty(ind)
    error('Invalid param: %s! Please see avAIlable parameter values in protocolobj constructor', param);
end;

value = gvals{ind,2};