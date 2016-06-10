function [randVarInRange] = randBetween(x, y, varargin)
% Picks random number between x and y input. order doesn't matter. 
% varargin input 'both' to randomly multiply the output by -1 or 1. 
% ie randBetween(.25, .5, 'both'), will lead to a random number between
% 0.25 and 0.5 OR -0.25 and 0.5. -psm 

%randVarInRange = randBetween(x, y, varargin)
 
randVarInRange = y + (x-y)*rand(1,1);

if nargin > 2
    if x*y < 0
        error('when using ''both'', input numbers must be the same sign otherwise will lead to overlapping probabilities')
    end
switch varargin{1}
    case 'both'

        if rand()>.5
            randVarInRange = randVarInRange*-1
        end
end
end
end
