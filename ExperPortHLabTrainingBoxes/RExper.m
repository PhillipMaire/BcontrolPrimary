% RExper
% Review exper

global exper

addpath(pwd);
addpath([pwd '\utility']);
addpath([pwd '\modules']);


ModuleInit('Control','reinit');
if ExistParam('Control','Sequence') % this is an abitrary parameter just to check that Control has been initialized
    ModuleInit('Group');
    ModuleInit('Sequence');
   % Control('modreload','Orca');
    Control('modreload','Opt');
    Control('modreload','Group');
    Control('modreload','Blob');
end


