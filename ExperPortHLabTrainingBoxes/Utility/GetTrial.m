function trial = GetTrial
% TRIAL = GetTrial 
% Return the number of the current trial
global exper

	trial = exper.Control.param.trial.value;
	