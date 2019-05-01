function out = SetP(varargin)
% SetP
% Set values in the structure referred to by a structure pointer.
% The structure pointer SP is simply a string which names the structure:
% STRUCT = exper.Control.param WOULD MEAN SP = 'exper.Control.param'.
% NOTE: acts directly on the structure, not on a copy.
% 		
% STRUCT = SetP(SP)
% 		Return the structure from the structure pointer, untouched
% STRUCT = SetP(SP,FIELD,value)
% 		Set the value of one FIELD to value
% STRUCT = SetP(SP,FIELD1,value,[FIELD2,value2],...,[FIELDN,valueN])
%		Set the values of multiple FIELD names
% 	
% SP can be a cell array of structure names, in which case all 
% structures with FIELD have it set to value. It is not an error
% to operate on structures that do not have FIELD.
%
% ZF MAINEN, CSHL, 8/00
%

sp = varargin{1};
if ~iscell(sp) sp = {sp}; end
	
for p=1:length(sp)

	% here we get the actual structure
	s = evalin('caller',sp{p});

	% There are no fields unless this is a structure
%	if ~isstruct(s)
%		out{p} = [];
%	elseif nargin == 1
	if nargin == 1
		% A single parameter means we return just the structure
		out{p} = s;
	else
		c = 1;
		for n=2:2:nargin
			f = varargin{n};
			if isempty(inputname(n+1))
			% input is not a variable, but just a calaculation
			% try to evaluate it here
				a = varargin{n+1};
				if isnumeric(a)
					vs = mat2str(a);
				elseif isstr(a)
					vs = sprintf('''%s''',a);
				else
					Message('SetP cannot handle this kind of assignment!','error');
				end
			else
				vs = inputname(n+1);
			end
			spfv = sprintf('%s.%s = %s;',sp{p},f,vs);
			evalin('caller',spfv);
			c = c+1;
		end
	end
	out{p} = evalin('caller',sp{p});
end

out = stripcell(out);
	

	
	