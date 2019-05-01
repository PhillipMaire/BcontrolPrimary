% EXPER
% This is where it all begins.

%clear exper
global exper


addpath(pwd);

addpath([pwd '\Protocols']);
addpath([pwd '\utility']);
addpath([pwd '\modules']);
addpath([pwd '\soundtools']);

daqreset;

ModuleInit('Control');
SetParam('Control','slicerate','value',4,'range',[0 5]);
SetParam('Control','trialdur',10);
SetParam('Control','iti',0);
SetParam('Control','advance',1);

% ModuleInit('AI');
% AI('board_open','nidaq',1);
% set(exper.AI.daq,'InputType','NonReferencedSingleEnded')
% AI('samplerate',1000);
% 
% AI('add_chan',0,'nosepoke');
% % SetParam('AI','hwtrigger',1);AI('hwtrigger');
% SetParam('AI','save',0);
% AI('save');
% Explicitly set sampling rate.

% ModuleInit('Dio');

ModuleInit('RPbox');
% ModuleInit('pathdisplay');
Control('restore_layout');
Control('reset');
% turn off Control auto-save
set(findobj('tag','autosave'),'Checked','off');

% ModuleInit('AO');
% AO('board_open','nidaq',1);
% set(exper.AI.daq,'Transfermode','Interrupts')
% ModuleInit('FakeRat');
% ModuleInit('operant');