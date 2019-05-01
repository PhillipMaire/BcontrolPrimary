function varargout = AI(varargin)
% AI
% A module for analog input
% The hwtrigger input pin for AI on a National Instruments board is PFI0/TRIG1
% 
% AI('trigger')
% AI('pause')
% data = AI('slice_data',hwchan)
% AI('trial_data')
% AI('add_chan')
% AI('slice2time')
% AI('time2slice')
%
% ZFM, CSHL 10/00
%
global exper

%out = lower(mfilename);
if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
    
    
	
case 'init'
		
	% AI goes last so that other modules can access it's data before
	% it is cleared for the next trial
	SetParam(me,'priority',3);

	fig = ModuleFigure(me,'visible','off');	
	
	hs = 60;
	h = 5;
	vs = 20;
	n = 0;

	find_boards;
	
	hf = uimenu(fig,'label','Chan','tag','channel');
	hf = uimenu(fig,'label','Scope','tag','scope');
	
	InitParam(me,'Backlog','ui','disp','format','%.1f','pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'SampleRate','ui','edit','value',8000,'pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'HWTrigger','ui','checkbox','value',0,'pos',[h n*vs hs vs]); n = n+1;
	if GetParam('Control','SliceRate') > 0
		ss = GetParam(me,'SampleRate')/GetParam('Control','SliceRate');
	else 
		ss = 0;
	end
	InitParam(me,'SamplesPerSlice','value',ss);
		
	InitParam(me,'SamplesPerTrial','value',...
		GetParam('Control','TrialDur')*GetParam(me,'SampleRate'));

  	InitParam(me,'Save','ui','togglebutton','value',1,'pref',0,'pos',[h n*vs hs vs]); n=n+1;
	SetParamUI(me,'Save','string','Save','background',[0 1 0],'label','');

	
	% Message box
	uiControl(fig,'tag','Message','style','edit',...
		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n = n+1;
	
	set(fig,'pos',[5 461-n*vs 128 n*vs],'visible','on');

    	
case 'slice'
	
	get_AI_slice_data;
	
	% update these things only 1/sec
if ~mod(GetParam('Control','slice'),GetParam('Control','slicerate'))
	backlog = exper.AI.daq.samplesavAIlable/GetParam(me,'SamplesPerSlice')
	SetParam(me,'backlog',backlog);
	if backlog > 2
		Message(me,'Slice rate too high!');
	end
	if backlog > 10
		AI_pause;
	end

	if backlog > 1
		SetParamUI(me,'backlog','background',[1 0 0]);
	else
		SetParamUI(me,'backlog','background',[0.8 0.8 0.8]);
	end
end
	
update_slice_plots;


	
case 'trialready'
	AI_trial_ready;
	
	
case 'trialend'
	if GetParam('Control','SliceRate') == 0
		get_AI_trial_data;
	end
	update_trial_plots;
	
	
case 'close'
	close_all_AI;
    
case 'check_path'
    % not sure if this is useful ZFM 10-02-03
if 0    
    if exist(get(exper.AI.daq,'LogFileName'))
        set_path('datapath','AI data already exists. Confirm or change DATA directory...');
    end
end
	
	
% handle UI parameter callbacks
	
case 'reset'
	AI_pause;
	stop(exper.AI.daq);
	flushdata(exper.AI.daq);
	SetParam(me,'backlog',0);
	SetParamUI(me,'backlog','background',get(gcf,'color'));
	Message(me,'');
	
case 'save'
   	if nargin > 1
		SetParam(me,'save',varargin{2});
	end
	AI_pause;
	if GetParam(me,'save')
		set(exper.AI.daq,'loggingmode','disk&memory');
		set(exper.AI.daq,'logtodiskmode','overwrite');
		SetParamUI(me,'save','background',[0 1 0]);
	else
		set(exper.AI.daq,'loggingmode','memory');
		SetParamUI(me,'save','background',get(gcf,'color'));
	end

	
case 'hwtrigger'
	AI_pause;
	set_hwtrigger(exper.AI.daq);
	AI_trial_ready;
	

case 'slicerate'
	AI('samplerate');
	
case 'samplerate'
    if ~isfield(exper.AI,'daq')
        return
    end
	if nargin >= 2
		SetParam(me, 'SampleRate', varargin{2});
	end	
    AI_pause;
    if ~strcmp(exper.AI.daq.running,'On')
        if GetParam('Control','slicerate') == 0
            SetParam(me,'SamplesPerTrial',GetParam('Control','TrialDur')*GetParam(me,'SampleRate'));
            SetParam(me,'SamplesPerSlice',GetParam(me,'SamplesPerTrial'));
            set(exper.AI.daq,'SamplesAcquiredFcnCount',GetParam(me,'SamplesPerTrial'));
        else
            SetParam(me,'SamplesPerSlice',GetParam(me,'SampleRate')/GetParam('Control','SliceRate'));
            SetParam(me,'SamplesPerTrial',GetParam('Control','TrialDur')*GetParam(me,'SampleRate'));
            SetParam('Control','SlicePerTrial',GetParam(me,'SamplesPerTrial')/GetParam(me,'SamplesPerSlice'));
            set(exper.AI.daq,'SamplesAcquiredFcnCount',GetParam(me,'SamplesPerSlice'));
        end
        set(exper.AI.daq,'SampleRate',GetParam(me,'SampleRate'));
        SetParam(me,'SampleRate',exper.AI.daq.SampleRate);
        set(exper.AI.daq,'SamplesPerTrigger',GetParam(me,'SamplesPerTrial'));
        
        set_slice_axes;
        set_trial_axes;
        AI_trial_ready;
    end
%	Message(me,'Reset AI samplerate')
	
case 'end'
	SetParam(me,'EndExp',1);
	
case 'AI_board_menu'
	name = get(gcbo,'user');
	if strcmp(name(1:5),'nidaq')
		adaptor = name(1:5);
		id = str2num(name(6));
	else
		adaptor = name(1:8);
		id = str2num(name(9));
	end
	
	if strcmp(get(gcbo,'checked'),'on')
		close_AI(adaptor,id);
	else
		open_AI(adaptor,id);
	end

	
	
case 'chan_menu'
	if strcmp(get(gcbo,'checked'),'on')
		del_chan(get(gcbo,'user'));
		set(gcbo,'checked','off');
	else
		chan = get(gcbo,'user');
		ok = add_chan(get(gcbo,'user'));
		if ok 
			set(gcbo,'checked','on');
		end
	end
	
case 'scope_menu'
	if strcmp(get(gcbo,'checked'),'on')
		close_scope(get(gcbo,'user'));
		set(gcbo,'checked','off');
	else
		chan = get(gcbo,'user');
		add_scope(get(gcbo,'user'));
		set(gcbo,'checked','on');
	end
	
case 'close_scope'
	% called from the scope figure itself
	HWChan = get(gcbf,'tag');
	set(findobj('tag','scope_menu','user',str2num(HWChan)),'checked','off');
	closereq;
	
case 'scope_slice'
	set(gcbo,'checked','on');
	set(findobj(gcbf,'tag','scope_trial'),'checked','off')
	set(findobj(gcbf,'type','line'),'tag','slice');
	set(findobj(gcbf,'type','axes'),'tag','slice');
	set_slice_axes;
	
case 'scope_trial'
	set(gcbo,'checked','on');
	set(findobj(gcbf,'tag','scope_slice'),'checked','off')
	set(findobj(gcbf,'type','line'),'tag','trial');
	set(findobj(gcbf,'type','axes'),'tag','trial');
	set_trial_axes;
	
	
% implement external functions	


case 'board_open'
	% AI('board_open',adaptor,id)
	% adaptor is 'nidaq' or 'winsound'
	board = open_AI(varargin{2},varargin{3});
	if board > 0
		nchan = length(exper.AI.daq(board).Channel);
	else
		nchan = 0;
	end
		
	varargout{1} = board;
	varargout{2} = nchan;
	
case 'channels'
	nchan = length(exper.AI.daq.Channel);


case 'board_close'
	% AO('board_close',adaptor,id)
	% adaptor is 'nidaq' or 'winsound'
	close_AI(varargin{2},varargin{3})

	
case 'pause'
	AI_pause;
	
case 'trigger'
	AI_start;
	
case 'slice_data'
	% note, we are using hardware channel numbers 
	hwchan = varargin{2};
	s_ind = data_ind_slice;
		if nargin > 2
			if length(s_ind) < length(varargin{3})
				varargout{1} = [];
				return
			end
			s_ind = s_ind(varargin{3});
		end
		channel = daqfind(exper.AI.daq,'HwChannel',hwchan);
		if ~isempty(channel)
			channel = channel{1};
			index = channel.Index;
			varargout{1} = exper.AI.data(s_ind,index);
		else
			varargout{1} = [];
		end
		
case 'trial_data'
	hwchan = varargin{2};
	s_ind = data_ind_trial;
		if nargin > 2
			if length(s_ind) < length(varargin{3})
				varargout{1} = [];
				return
			end
			s_ind = s_ind(varargin{3});
		end
		channel = daqfind(exper.AI.daq,'HwChannel',hwchan);
		if ~isempty(channel)
			channel = channel{1};
			index = channel.Index;
			varargout{1} = exper.AI.data(s_ind,index);
		else
			varargout{1} = [];
		end
		
	
case 'add_chan'
	% ADDCHAN(HWCHAN, NAME)
	% Initialize an analog input channel.
	hwchan = varargin{2};
	name = varargin{3};
	success = add_chan(hwchan,name);
	
case 'del_chan'
	% AI('del_chan', HWCHAN)
	% Delete a channel.
	hwchan = varargin{2};
	del_chan(hwchan);
	
otherwise	
	
end

% begin local functions

function out = me
out = lower(mfilename); 

function out = callback
out = [lower(mfilename) ';'];



function find_boards

fig = findobj('type','figure','tag','AI');
hf = uimenu(fig,'label','Board','tag','board');
delete(findobj('parent',hf));	% kill existing labels

%adaptors = {'nidaq','winsound'};
a=daqhwinfo;
adaptors = a.InstalledAdaptors;

for n=1:length(adaptors)
	b = daqhwinfo(adaptors{n});
	names = b.BoardNames;
	ids = b.InstalledBoardIds;
	for p=1:length(names)
		% this condition makes sure there is an analoginput for this board
		if ~isempty(b.ObjectConstructorName{p,1})
			namestr = sprintf('%s%s-AI',adaptors{n},ids{p});
			label = sprintf('    %s (%s)',namestr,names{p});
			uimenu(hf,'tag','AI_board_menu','label',label,'user',namestr,'callback',callback);
		end
	end	
end



function close_all_AI
global exper
% user wants to close all boards
if ~isfield(exper.AI,'daq')
    return
end
daq = exper.AI.daq;
if isvalid(daq)
    for n=1:length(daq)
        if length(daq) > 1
            d = daqhwinfo(daq(n));
        else
            d = daqhwinfo(daq);
        end
        if strcmp(d.SubsystemType,'AnalogInput')
            adaptor = d.AdaptorName;
            id = str2num(d.ID);
            close_AI(adaptor,id);		
        end
    end
end

		
function close_AI(adaptor,id)
global exper

	boardname = sprintf('%s%d-AI',adaptor,id);
	AI = daqfind('name',boardname);
	
	if isempty(AI)
		Message(me,'Board not open')
	end
		
	for n=1:length(AI)
		if strcmp(get(AI{n},'running'),'On')
			stop(AI{n});
		end
		k = length(exper.AI.daq);
		while k >= 1
			if strcmp(exper.AI.daq(k).name,boardname)
				if length(exper.AI.daq) > 1
					exper.AI.daq(k) = [];
				else
					exper.AI = rmfield(exper.AI,'daq');
				end
			end
			k=k-1;
		end
		
		delete(AI{n});
		Message(me,sprintf('%s closed',boardname));
	end
	board_menu_labels;

	% get rid of those pesky lines!
	delete(findobj('type','line','tag',me));


function board = open_AI(adaptor,id)
global exper
	
	board = 0;
	boardname = sprintf('%s%d-AI',adaptor,id);
	
	% for now, just allow a single AI
	if isfield(exper.AI,'daq')
        close_all_AI;
    end
%     
%         if isvalid(exper.AI.daq) & strcmp(exper.AI.daq.Name,boardname)
%             Message(me,'Already initialized');
%             board = n;
%             board_menu_labels;
%             return
%         end

	if ~strcmp(adaptor,'nidaq') & ~strcmp(adaptor,'winsound')
		Message(me,'nidaq and winsound are valid');
		return
	end
	boardinit = sprintf('analoginput(''%s'',%d)',adaptor,id);
	AI = eval(boardinit); 


	AI.SampleRate = GetParam(me,'SampleRate');
	if GetParam(me,'SamplesPerSlice') > 0
		AI.SamplesAcquiredFcnCount = GetParam(me,'SamplesPerSlice');
	else
		AI.SamplesAcquiredFcnCount = GetParam(me,'SamplesPerTrial');
	end
	AI.SamplesAcquiredFcn = {'ai_handler'};
	AI.TriggerFcn = {'ai_trig_handler'};
	AI.SamplesPerTrigger = GetParam(me,'SamplesPerTrial');
	AI.TriggerRepeat = 0;
	
	if GetParam(me,'save')
		set(AI,'loggingmode','disk&memory');
		set(AI,'logtodiskmode','overwrite');
	else
		set(AI,'loggingmode','memory');
	end
	
	%get the type of input types the boards likes
	inputs = propinfo(AI, 'InputType');
	%if its possible to set the InputType to SingleEnded, then do it
	if ~isempty(find(strcmp(inputs.ConstrAIntvalue, 'SingleEnded')))
		AI.InputType = 'SingleEnded';
	end
	
	h = daqhwinfo(AI);
	
	SetParam(me,'samplerate','range',[h.MinSampleRate h.MaxSampleRate]);
	
	exper.AI.daq = AI;
	set_hwtrigger(AI);
	chan_menu(AI);
	Message(me,sprintf('%s initialized',AI.name));
	
	board_menu_labels;
	%board_menu_labels;
	AI_trial_ready;
	

function board_menu_labels
global exper
	menuitems = findobj('tag','AI_board_menu');
	for n=1:length(menuitems)
		label = get(menuitems(n),'label');
		label(1:2) = '  ';
		set(menuitems(n),'checked','off','label',label);
	end
		
	if isfield(exper.AI,'daq')
		for n=1:length(exper.AI.daq)
			menuitem = findobj('tag','AI_board_menu','user',exper.AI.daq(n).name);
			label = get(menuitem,'label');
			label(1:2) = sprintf('%d:',n);
			set(menuitem,'checked','on','label',label);
		end
	end



function chan_menu(AI)
global exper

hf = findobj('type','uimenu','tag','channel');
hf2 = findobj('type','uimenu','tag','scope');
delete(findobj('parent',hf2));
delete(findobj('parent',hf));

a=daqhwinfo(AI);
chan = a.SingleEndedIDs;
for n=1:length(chan)
	hw = chan(n);
	ch = daqfind(AI,'HwChannel',hw);
	mh = uimenu(hf,'tag','chan_menu','user',hw,'callback',callback);
	if ~isempty(ch)
		name = get(ch{1},'ChannelName');
		str = sprintf('Ch %d: %s',hw,name);
		set(mh,'checked','on','label',str);
		uimenu(hf2,'tag','scope_menu','label',str,'user',hw,'callback',callback);
	else
		str = sprintf('Ch %d',hw);
		set(mh,'checked','off','label',str);
	end
end


function out = add_chan(HWChan, name)
global exper

if GetParam('Control','Run')
	AI_pause;
end

cancelled = 0;
hw = daqfind(exper.AI.daq,'HWchan',HWChan);
if isempty(hw)
	if nargin < 2
		board = exper.AI.daq.name;
		prompt = 'Enter channel name:';
		dtitle = sprintf('Add AI channel %d to %s',HWChan,board);
		default = sprintf('Chan %d',HWChan);
		lineno = [1 25];
		n = inputdlg(prompt,dtitle,lineno,{default});
		if ~isempty(n)
			name = n{1};
		else
			cancelled = 1;
		end
	end
	if cancelled
		out = 0;
		return;
	else
		channel = addchannel(exper.AI.daq,HWChan,name);
		out = 1;	
		Message(me,sprintf('Chan %d added',HWChan));
	end
else
	Message(me,sprintf('Chan %d already added',HWChan),'error');
	out = 0;
	return;
end
chan_menu(exper.AI.daq);
n = length(exper.AI.daq.channel);
exper.AI.data = zeros(GetParam(me,'SamplesPerTrial'),n);


function del_chan(HWChan)
global exper

%if GetParam(me,'Run')
	AI_pause;
%end

ch = daqfind(exper.AI.daq,'HWchan',HWChan);
%ch = daqfind('HWchan',HWChan);
if isempty(ch)
	Message(me,sprintf('Ch %d: no such channel to delete',HWChan));
	return;
end
delete(ch{1});
Message(me,sprintf('Chan %d deleted',HWChan));
close_scope(HWChan);
chan_menu(exper.AI.daq);
n = length(exper.AI.daq.channel);
exper.AI.data = zeros(GetParam(me,'SamplesPerTrial'),n);



function AI_trial_ready
global exper

exper.AI.data = zeros(GetParam(me,'SamplesPerTrial'),length(exper.AI.daq.Channel));

trialstr = sprintf('%03d',GetParam('Control','trial'));
fname = [GetParam('Control','datapath') '\' GetParam('Control','expid') trialstr];
if strcmp(exper.AI.daq.running,'On')
	stop(exper.AI.daq);
	set(exper.AI.daq,'logfilename',fname);
% 	start(exper.AI.daq);
else
	set(exper.AI.daq,'logfilename',fname);
end




function get_AI_slice_data
global exper
% Retrieve analog input data from the daq board

samples = GetParam(me,'SamplesPerSlice');
if samples <= exper.AI.daq.samplesavAIlable
	a = getdata(exper.AI.daq,samples);
	exper.AI.data(data_ind_slice,1:size(a,2)) = a(1:samples,:);
end



function get_AI_trial_data
global exper
% Retrieve analog input data from the daq board

samples = GetParam(me,'SamplesPerTrial');
if samples <= exper.AI.daq.samplesavAIlable
	a = getdata(exper.AI.daq,samples);
	exper.AI.data(data_ind_trial,1:size(a,2)) = a(1:samples,:);
end


function out = data_ind_slice(slice)
if nargin < 1
	slice = GetParam('Control','slice')
end
ds = GetParam(me,'SamplesPerSlice');
d0 = 1+(slice-1)*ds;
d1 = d0 + ds -1;
out = d0:d1;



function out = data_ind_trial
out = 1:GetParam(me,'SamplesPerTrial');



function AI_pause
global exper
	if ~isfield(exper.AI,'daq') return; end
	
	if strcmp(exper.AI.daq.running,'On')
		if strcmp(exper.AI.daq.logging,'On')
			Message('Control','Stopping at trial end...');
		else
			stop(exper.AI.daq);
			SetParamUI('Control','run','Background',get(gcf,'color'));
		end
	else
		SetParamUI('Control','run','Background',get(gcf,'color'));
	end



function AI_start
global exper	
if ~isfield(exper.AI,'daq') | isempty(exper.AI.daq.channel)
	Message(me,'Can''t start acquisition until channels are added!','error');
	SetParam('Control','run',0);
	SetParamUI('Control','run','background',get(gcf,'color'));
else
    
    if ~strcmp(exper.AI.daq.running,'On')
        start(exper.AI.daq);
        if ~GetParam(me,'hwtrigger')
            trigger(exper.AI.daq);
        else
            Message(me,'WAIting for hw trigger...');
        end
        SetParam('Control','run',1);
        SetParamUI('Control','run','background',[0 1 0]);
    end
end


function set_hwtrigger(board)
global exper
	%if its possible to set the Trigger to HwDigital, then do it

		
	inputs = propinfo(board, 'TriggerType');
	if isempty(find(strcmp(inputs.ConstrAIntvalue, 'HwDigital')))
		SetParamUI(me,'hwtrigger','enable','off');
		SetParam(me,'hwtrigger','value',0,'range',[0 0]);
	else
		SetParamUI(me,'hwtrigger','enable','on');
		SetParam(me,'hwtrigger','range',[0 1]);
	end

	if max(GetParam(me,'hwtrigger','range')) & GetParam(me,'hwtrigger')
		board.TriggerType = 'HwDigital';
	else
		board.TriggerType = 'Manual';
	end
	Message(me,sprintf('%s trigger',exper.AI.daq.triggertype));
	


% ------------------------------------------------------------------------
% oscilloscope functions
% ------------------------------------------------------------------------
 
	
function close_scope(HWChan)
delete(findobj('type','figure','tag',num2str(HWChan)));   
set(findobj('tag','scope_menu','user',HWChan),'checked','off');



function add_scope(HWChan)
global exper

ch = daqfind(exper.AI.daq,'HWChannel',HWChan);
if isempty(ch) 
	Message(me,'No such channel to scope','error');
	return; 
end
fig = figure('tag',num2str(HWChan),'doublebuffer','on','numbertitle','off',...
	'CloseRequestFcn',{'AI(''close_scope'')'},'pos',[492   730   757   217]);

hm = uimenu(fig,'label','Scope');
uimenu(hm,'label','Slice update','tag','scope_slice','callback',[me ';']);
uimenu(hm,'label','Trial update','checked','on','tag','scope_trial','callback',[me ';']);

channel = ch{1};
name = channel.ChannelName;
set(fig,'name',sprintf('Analog input: %s channel %d: %s',...
	exper.AI.daq.name,HWChan,name));

ax = axes('parent',fig,'tag','trial','XLimMode','manual','XLim',[0 GetParam('Control','trialdur')],...
	'ylim',[-10 10],'ylimmode','manual','drawmode','fast');

xdat = (1:GetParam(me,'samplespertrial'))/GetParam(me,'samplerate');
lh = line(xdat,xdat*0,'tag','trial','user',channel,'parent',ax);



function set_trial_axes
h = findobj('tag','trial','type','axes');
set(h,'XLimMode','manual','XLim',[0 GetParam('Control','trialdur')]);
h = findobj('tag','trial','type','line');
xdat = (1:GetParam(me,'samplespertrial'))/GetParam(me,'samplerate');
set(h,'XData',xdat,'ydata',xdat*0);



function set_slice_axes 
h = findobj('tag','slice','type','axes');
set(h,'XLimMode','manual','XLim',[0 1/( GetParam('Control','slicerate') + (GetParam('Control','slicerate') == 0))]);

h = findobj('tag','slice','type','line');
xdat = (1:GetParam(me,'samplesperslice'))/GetParam(me,'samplerate');
set(h,'XData',xdat,'ydata',xdat*0);



function update_slice_plots
global exper

hl = findobj('type','line','tag','slice');	
%	if ~isempty(hl)
%		ind = 1:GetParam(me,'samplesperslice');
%	end
for n=1:length(hl)
	hw = get(hl(n),'user');
	chan = get(hw,'Index');
	set(hl(n),'YData',exper.AI.data(data_ind_slice,chan));
end



function update_trial_plots
global exper

hl = findobj('type','line','tag','trial');	
for n=1:length(hl)
	hw = get(hl(n),'user');
	chan = get(hw,'Index');
	set(hl(n),'YData',exper.AI.data(data_ind_trial,chan));
end