function out = GetParamsTrial(module,trial)
global exper
% GetParamsTrial
% Retrieve *saved* values from all PARAMS of an exper MODULE.
% 
% GetParamsTrial(MODULE,TRIAL)
%
% ZF MAINEN, CSHL, 8/01
%

module = lower(module);

if nargin<2
    trial= GetParam('Control','trial');
end

sf = sprintf('exper.%s.param',module);
s = evalin('caller',sf);
fields = fieldnames(s);
		
% go through all the parameters
for i=1:length(fields)
	sfs = sprintf('%s.%s',sf,fields{i});
	% retrieve only the ones that were saved
	if GetP(sfs,'save')
		trial_vals = GetP(sfs,'trial');
		SetP(sfs,'value',trial_vals{trial});
	end
end
