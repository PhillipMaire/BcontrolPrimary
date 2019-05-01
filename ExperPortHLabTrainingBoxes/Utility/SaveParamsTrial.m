function out = SaveParamsTrial(module)
global exper
% SaveParamsTrial
% Keep track of parameter values by saving a copy in a vector
% (field name 'trial'). Can be retrieved using GetParamsTrial.
% SaveParamsTrial(MODULE)
%
% ZF MAINEN, CSHL, 10/00
%

module = lower(module);

sf = sprintf('exper.%s.param',module);
s = evalin('caller',sf);
fields = fieldnames(s);

trial = GetParam('Control','trial');
		
% go through all the parameters
for i=1:length(fields)
	sfs = sprintf('%s.%s',sf,fields{i});
	% save only the ones that need to be saved
	save = GetP(sfs,'save');
	if save
		trial_vals = GetP(sfs,'trial');
		val = GetP(sfs,'value');
		% if it's a list, we save the item, not the index
		list = GetP(sfs,'list');
		if ~isempty(list)
			 val = list{val};
         end
		trial_vals{trial} = val;
		SetP(sfs,'trial',trial_vals);
	end
end
