% EXPER
% This is where it all begins.

global exper

daqreset;

ModuleInit('Control');
if ~isempty(GetParam('Control','user'))

        ModuleInit('AI');
        % need to add at least one channel to AI 
        AI('board_open','nidaq',1);
        AI('add_chan',6,'');

        ModuleInit('AO');
        ModuleInit('ValveCheck');
        ModuleInit('Sequence');
        ModuleInit('Group');
        Control('restore_layout');
 

        SetParam('Control','trialdur',10);
        SetParam('Control','iti',15);
        SetParam('Control','advance',1);

        Control('reset');
        

else
    clear exper
end
