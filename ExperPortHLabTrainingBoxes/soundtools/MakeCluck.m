function [cluck] = MakeCluck(varargin)
   
   pAIrs = { ...
     'cluck_spl'     3   ; ...
     'cluck_dur'     8   ; ...
     'cluck_freq'  2000  ; ...
     'ramp'         0.5  ; ...
  }; parseargs(varargin, pAIrs);


srate = get_generic('sampling_rate');
cluck = MakeChord(srate, cluck_spl, cluck_freq, 1, cluck_dur, ramp);
        