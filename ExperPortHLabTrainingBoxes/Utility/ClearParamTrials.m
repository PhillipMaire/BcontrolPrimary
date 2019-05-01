function ClearParamTrials(module)
global exper
% ClearParamTrials
% Reset/clear saved parameters saved with SaveParamTrial(MODULE,TRIAL).
%
% ZF MAINEN, CSHL, 10/00
%

module = lower(module);

sf = sprintf('exper.%s.param',module);
s = evalin('caller',sf);
fields = fieldnames(s);
		
% go through all the parameters
for i=1:length(fields)
	sfs = sprintf('%s.%s',sf,fields{i});
	% save only the ones that need to be saved
	save = GetP(sfs,'save');
	if save
        SetP(sfs,'trial','');
    end
end
