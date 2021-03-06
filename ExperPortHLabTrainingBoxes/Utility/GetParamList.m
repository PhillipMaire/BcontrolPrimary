function out = GetParamList(module,param,field)
% GetParamList
% Retrieve PARAM values from an exper MODULE.
% 
% OUT = GetParamList(MODULE,PARAM,FIELD)
%   Assume that the field is a list and return the item
%   corresponding to the current value field.
%
% ZF MAINEN, CSHL, 8/01
%
global exper

param = lower(param);
module = lower(module);
if nargin < 3 
    field = 'list';
end

sf = sprintf('exper.%s.param.%s',module,param);

val = GetP(sf,'value');
list = GetP(sf,field);
if iscell(list) & ~isempty(list)
	out = list{val};
else
    out = {};
end
