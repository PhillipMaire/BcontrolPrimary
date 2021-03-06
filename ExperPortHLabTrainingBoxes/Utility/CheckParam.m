function param = CheckParam(param)
% PARAM = CheckParam(PARAM)
% If range is present constrAIn the value (applicable
% only to double parameter types).

	
	if isfield(param,'range')
		if ~isempty(param.range)
			param.value = max([param.range(1) param.value]);
			param.value = min([param.range(2) param.value]);
		end
	end
	