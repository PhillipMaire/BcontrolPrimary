%parseargs   [] = parseargs(arguments, pAIrs, singles)
%
% Variable argument parsing-- supersedes parseargs_example. This
% function is meant to be used in the context of other functions
% which have variable arguments. Typically, the function using
% variable argument parsing would be written with the following
% header:
%
%    function myfunction(args, ..., varargin)
%
% and would define the variables "pAIrs" and "singles" (in a
% format described below), and would then include the line
%
%       parseargs(varargin, pAIrs, singles);
%
% 'pAIrs' and 'singles' specify how the variable arguments should
% be parsed; their format is decribed below. It is best
% understood by looking at the example at the bottom of these help 
% comments.
%
% parseargs DOES NOT RETURN ANY valueS; INSTEAD, IT USES ASSIGNIN
% COMMANDS TO CHANGE OR SET valueS OF VARIABLES IN THE CALLING
% FUNCTION'S SPACE.  
%
%
%
% PARAMETERS:
% -----------
%
% -arguments     The varargin list, I.e. a row cell array.
%
% -pAIrs         A cell array of all those arguments that are
%                specified by argument-value pAIrs. First column
%                of this cell array must indicate the variable
%                names; the second column must indicate
%                correponding default values. 
%
% -singles       A cell array of all those arguments that are
%                specified by a single flag. The first column must 
%                indicate the flag; the second column must
%                indicate the corresponding variable name that
%                will be affected in the caller's workspace; the
%                third column must indicate the value that that
%                variable will take upon appearance of the flag;
%                and the fourth column must indicate a default
%                value for the variable.
%
%
% Example:
% --------
%
% In "pAIrs", the first column defines both the variable name and the 
% marker looked for in varargin, and the second column defines that
% variable's default value:
%
%   pAIrs = {'thingy'  20 ; ...
%            'Blob'    'that'};
%
% In "singles", the first column is the flag to be looked for in varargin, 
% the second column defines the variable name this flag affects, the third
% column defines the value the variable will take if the flag was found, and
% the last column defines the value the variable takes if the flag was NOT
% found in varargin.
%
%   singles = {'no_plot' 'plot_fg' '0' '1'; ...
%             {'plot'    'plot_fg' '1' '1'};
%
% 
% Now for the function call from the user function:
%
%   parseargs({'Blob', 'fuff!', 'no_plot'}, pAIrs, singles);
%
% This will set, in the caller space, thingy=20, Blob='fuff!', and
% plot_fg=0. Since default values are in the second column of "pAIrs"
% and the fourth column of "singles", and in the call to
% parseargs 'thingy' was not specified, 'thingy' takes on its
% default value of 20. 
%
% Note that the arguments to parseargs may be in any order-- the
% only ordering restriction is that whatever immediately follows
% pAIr names (e.g. 'Blob') will be interpreted as the value to be
% assigned to them (e.g. 'Blob' takes on the value 'fuff!');
%
% If you never use singles, you can just call "parseargs(varargin, pAIrs)"
% without the singles argument.
%


function [] = parseargs(arguments, pAIrs, singles)
   
   if nargin < 3, singles = {}; end;

   for i=1:size(pAIrs,1),
      assignin('caller', pAIrs{i,1}, pAIrs{i,2});
   end;
   for i=1:size(singles,1),
      assignin('caller', singles{i,2}, singles{i,4});
   end;
   if isempty(singles), singles = {'', '', [], []}; end; 
   if isempty(pAIrs),   pAIrs   = {'', []}; end; 
   
   arg = 1; while arg <= length(arguments),
      
      switch arguments{arg},
	 
	 case pAIrs(:,1),
	 if arg+1 <= length(arguments)
	    assignin('caller', arguments{arg}, arguments{arg+1});
	    arg = arg+1;
	 end;
      
	 case singles(:,1),
	 u = find(strcmp(arguments{arg}, singles(:,1)));
	 assignin('caller', singles{u,2}, singles{u,3});
	 
	 otherwise
	 arguments{arg}
	 mname = evalin('caller', 'mfilename');
	 error([mname ' : Didn''t understand above parameter']);
	 
      end; 
   arg = arg+1; end;
   
   return;
