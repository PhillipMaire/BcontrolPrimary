function varargout = AO(varargin)
% AO
% A module for analog output
%
% The hwtrigger input pin for AO on a National Instruments board is PFI6
%
%
% SL Macknik, 9/00
% ZF MAInen 10/00
% mw 101801 added hack to AO('close') to allow for multiple AO objects (e.g. that of sealtest) 


global exper

if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
case 'init'
	
	% AO is called right before AI
	SetParam(me,'priority',2); 
	ModuleNeeds(me,{'AI'});

	fig = ModuleFigure(me,'visible','off');
	
	hs = 60;
	h = 5;
	vs = 20;
	n = 0;

	find_boards;

	InitParam(me,'SampleRate','ui','edit','value',8000,'pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'HwTrigger','ui','checkbox','pos',[h n*vs hs vs]); n = n+1;
	
	InitParam(me,'Send','ui','togglebutton','value',1,'pos',[h n*vs hs vs]);
	SetParamUI(me,'Send','string','Send','background',[0 1 0],'label','','pref',0);

	% reset
	uiControl('parent',fig,'string','Reset','tag','reset','style','pushbutton',...
		'callback',[me ';'],'foregroundcolor',[.9 0 0],'pos',[h+hs n*vs hs vs]); n=n+1;
	
	% Message box
	uiControl('parent',fig,'tag','Message','style','edit',...
		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1;
	
	set(fig,'pos',[5 234 128 n*vs],'visible','on');	
	
	

case 'slice'
	if 0
		if GetParam(me,'send')
			tot = round(exper.AO.daq.samplesavAIlable/1000);
			ot = round(exper.AO.daq.samplesoutput/1000);
			Message(me,sprintf('Out %dk; left %dk',ot,tot));
		else
			Message(me,'No output');
		end
	end
		
case 'trialready'
	if GetParam(me,'Send')
			% get rid of extra cued AO samples!
		if get(exper.AO.daq(1),'samplesavAIlable') > 0
			start(exper.AO.daq);
			stop(exper.AO.daq);
		end
		for n=1:length(exper.AO.daq)
			putdata(exper.AO.daq(n),exper.AO.data{n});
		end
		
		if 1
			cued = size(exper.AO.data{1},1)/1000;
			tot = get(exper.AO.daq(1),'samplesavAIlable')/1000;
		end
	end
	
case 'trialend'
	
case 'close'
    if ~isfield(exper.AO,'daq')
        return
    end
    for n=1:length(exper.AO.daq)
        for n=1:length(exper.AO.daq)
            %this hack prevents AO('close') from crashing if daqfind returns multiple AO objects
            %(which will happen if sealtest is running, since it has its own AO object!) mw 101801
            temp = daqfind('name',exper.AO.daq(n).name);
            if length(temp)==1
                dev(n) = daqfind('name',exper.AO.daq(n).name);
            elseif length(temp)==2 %if sealtest's AO object exists too
                dev{n}=temp{1};
            else error('hack didn''t work. mw 101801')
            end
            %        dev(n) = daqfind('name',exper.AO.daq(n).name);
        end
        
        %    dev(n) = daqfind('name',exper.AO.daq(n).name);
        %    end
        for n=1:length(dev)
            if strcmp(get(dev{n},'Running'),'On')
                stop(dev{n});
            end
            delete(dev{n});
        end
    end

%    AO = daqfind(
    exper.AO = rmfield( exper.AO, 'daq' );
	

% deal with UI callbacks

case 'AO_board_menu'
	name = get(gcbo,'user');
	if strcmp(name(1:5),'nidaq')
		adaptor = name(1:5);
		id = str2num(name(6));
	else
		adaptor = name(1:8);
		id = str2num(name(9));
	end
	
	if strcmp(get(gcbo,'checked'),'on')
		close_AO(adaptor,id);
	else
		open_AO(adaptor,id);
	end


case {'reset','putdata'}
	% a simple start/stop clears the cue
	if ~isvalid(exper.AO.daq)
        return
    end
    if strcmp(exper.AO.daq(1).running,'On')
		stop(exper.AO.daq);
	end
	reset_AO_data;

case 'hwtrigger'
	AO_pause;
	for n=1:length(exper.AO.daq)
		set_hwtrigger(exper.AO.daq(n));
	end

case 'slicerate'
	AO('samplerate')
	
case 'samplerate'
	if nargin >= 2
		SetParam(me, 'SampleRate', varargin{2});
	end	
	AO_pause;
	set(exper.AO.daq,'SampleRate',GetParam(me,'SampleRate'));
	SetParam(me,'SampleRate',exper.AO.daq(1).SampleRate);
	reset_AO_data;
	
case 'send'
	if nargin > 1
		SetParam(me,'send',varargin{2});
	end
	if GetParam(me,'send')
		SetParamUI(me,'send','background',[0 1 0]);
	else
		SetParamUI(me,'send','background',get(gcf,'color'));
	end
	
	
	
	
% implement external functions

case 'trigger'
	AO_start;
    
case 'pause'
    AO_pause;
	
case 'board_open'
	% AO('board_open',adaptor,id)
	% adaptor is 'nidaq' or 'winsound'
	board = open_AO(varargin{2},varargin{3});
	if board > 0
		nchan = length(exper.AO.daq(board).Channel);
	else
		nchan = 0;
	end
		
	varargout{1} = board;
	varargout{2} = nchan;
	

case 'board_close'
	% AO('board_close',adaptor,id)
	% adaptor is 'nidaq' or 'winsound'
	close_AO(varargin{2},varargin{3})

case 'channels'
	board = varargin{2};
	nchan = length(exper.AO.daq(board).Channel);
	varargout{1} = nchan;
	
case 'samples'
	varargout{1} = GetParam(me,'SampleRate')*GetParam('Control','trialdur');
	
case 'putsample'
	% AO('putsample',data)
	% AO('putsample',board,data)
	% Immediately set AO channels to a specific voltage.
	% If more than one board is in use, the board number should be 
	% specified. Data must be a vector with same length as the
	% number of channels on the board
	if strcmp(exper.AO.daq(1).sending,'On')
		Message(me,'Can''t putsample while sending','error');
	else
		if nargin > 2
			board = varargin{2};
			data = varargin{3};
		else
			if length(exper.AO.daq) == 1
				data = varargin{2};
				board = 1;
			else
				Message(me,'Must specify board number');
				return
			end
		end
		nchan = length(exper.AO.daq(board).Channel);
		if length(data) == nchan
			putsample(exper.AO.daq(board),data)
%			Message(me,sprintf('Putsamples board %d',board));
		else
			if nchan ~= 0
				Message(me,sprintf('Need %d channels!',nchan));
			else
				Message(me,sprintf('Board %d not initialized',board));
			end	
		end
	end
	
	
case 'setdata'
	% AO('setdata', board, data)

	if nargin > 2
		board = varargin{2};
		data = varargin{3};
	else
		if length(exper.AO.daq) == 1
			data = varargin{2};
			board = 1;
		else
			Message(me,'Must specify board number');
			return
		end
	end
	
	AOsize = GetParam(me,'SampleRate')*GetParam('Control','trialdur');
	
 	if size(data,2) ~= length(exper.AO.daq(board).channel) | ...
		size(data,1) ~= AOsize
		Message(me,sprintf('Data size must be %d x %d',AOsize,length(exper.AO.daq(board).channel)));
	else
		exper.AO.data{board} = data;
%		Message(me,'Loaded data');
	end
	
case {'setchandata','addchandata'}
    % these fcns clear the current AO data
	%   AO('setchandata', channel, data)
	%   AO('setchandata', board, channel, data)
    % while these sum the new data and the existing data
    %   AO('addchandata', channel, data)
    %   AO('addchandata', board, channel, data)
	
	if nargin >= 4
		% User specified board.
		board = varargin{2};
		chan = varargin{3};
		data = varargin{4};
	elseif nargin >= 3
		% No board specified. Assume board 1.
		board = 1;
		chan = varargin{2};
		data = varargin{3};
	else
		Message(me,'Incorrect use of setchandata.');
		return;
	end
	
	AOsize = round(GetParam(me,'SampleRate')*GetParam('Control','trialdur'));
	if size(data,1) > AOsize
		Message(me,sprintf('Data size must be <%d',AOsize));
	else
        switch varargin{1} 
        case 'setchandata'
            exper.AO.data{board}(1:length(data),chan) = data;
        case 'addchandata'
            exper.AO.data{board}(1:length(data),chan) = data + ...
                exper.AO.data{board}(1:length(data),chan);
        otherwise
        end
   		Message(me,sprintf('Loaded channel %d',chan));
	end        
	
otherwise	
	Message(me,'Invalid function')
end



% begin local functions

function out = callback
	out = [lower(mfilename) ';'];

function out = me
	out = lower(mfilename); 


function AO_pause
global exper
	if isfield(exper.AO,'daq')
		if strcmp(exper.AO.daq(1).running,'On')
			stop(exper.AO.daq);
		end
	end


function AO_start
global exper	
	if ~GetParam(me,'send')
		return 
	end
	if strcmp(exper.AO.daq(1).running,'On')
		stop(exper.AO.daq);
		Message(me,'Was sTill running!','error');
	end
	if exper.AO.daq(1).SamplesAvAIlable >= GetParam(me,'SampleRate')*GetParam('Control','TrialDur')
		start(exper.AO.daq);
		if ~GetParam(me,'hwtrigger')
			if strcmp(exper.AO.daq(1).running,'On')
				trigger(exper.AO.daq);
				Message(me,'Manually triggered');
			end
		end
		Message(me,'');
	else
		Message(me,sprintf('Too few (%d) samples cued',exper.AO.daq(1).SamplesAvAIlable));
	end
	% AI handles sending Dio trigger
	% note trigger for AO on NI boards is PFI-6




function find_boards

fig = findobj('type','figure','tag','AO');
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
				% this condition makes sure there is an analogoutput for this board
		if ~isempty(b.ObjectConstructorName{p,2})
			namestr = sprintf('%s%s-AO',adaptors{n},ids{p});
			label = sprintf('    %s (%s)',namestr,names{p});
			uimenu(hf,'tag','AO_board_menu','label',label,'user',namestr,'callback',callback);
		end
	end	
end

	

function close_AO(adaptor,id)
global exper

	boardname = sprintf('%s%d-AO',adaptor,id);
	AO = daqfind('name',boardname);
	
	if isempty(AO)
		Message(me,'Board not open')
	end
		
	for n=1:length(AO)
		if strcmp(get(AO{n},'running'),'On')
			stop(AO{n});
		end
		k = length(exper.AO.daq);
		while k >= 1
			if strcmp(exper.AO.daq(k).name,boardname)
				if length(exper.AO.daq) > 1
					exper.AO.daq(k) = [];
				else
					exper.AO = rmfield(exper.AO,'daq');
				end
			end
			k=k-1;
		end
		
		delete(AO{n});
		Message(me,sprintf('%s closed',boardname));
	end

	board_menu_labels;


	
function board = open_AO(adaptor,id)
global exper
	
	board = 0;
	boardname = sprintf('%s%d-AO',adaptor,id);
	if isfield(exper.AO,'daq')
		for n=1:length(exper.AO.daq)
			if strcmp(exper.AO.daq(n).Name,boardname)
				Message(me,'Already initialized');
				board = n;
				return
			end
		end
	end
	
	if ~strcmp(adaptor,'nidaq') & ~strcmp(adaptor,'winsound')
		Message(me,'nidaq and winsound are valid');
		return
	end
	boardinit = sprintf('analogoutput(''%s'',%d)',adaptor,id);
	AO = eval(boardinit); 

	AO.SampleRate = GetParam(me,'SampleRate');
	AO.TriggerFcn = {'ao_trig_handler'};
	
	switch adaptor
	case 'nidaq'
		h = daqhwinfo(AO);
		device = h.DeviceName;
		switch device
		case 'PCI-MIO-16E-4'
			AO.TransferMode = 'Interrupts';
			chan = 0:1;
		case 'PCI-6713'
			chan = 0:7;
		otherwise
			chan = 0:1;
		end
		for n=chan
			addchannel(AO,n,sprintf('Chan %d',n));
		end
		Message(me,'nidaq');
		ok = 1;
	case 'winsound'
		for n=1:2
			addchannel(AO,n,sprintf('Chan %d',n));
		end
		Message(me,'winsound');
	otherwise
		Message(me,'no board!');
		return
	end
	
	if isfield(exper.AO,'daq')
		exper.AO.daq(end+1) = AO;
	else 
		exper.AO.daq = AO;
	end
	
	set_hwtrigger(AO);
	
	Message(me,sprintf('%s%d initialized',AO.name));
	board_menu_labels;
	
	% erase data
	for n=1:length(exper.AO.daq)
		exper.AO.data{n} = [];
	end
	board = length(exper.AO.daq);	
	
%	reset_AO_data;


function board_menu_labels
global exper
	menuitems = findobj('tag','AO_board_menu');
	for n=1:length(menuitems)
		label = get(menuitems(n),'label');
		label(1:2) = '  ';
		set(menuitems(n),'checked','off','label',label);
	end
		
	if isfield(exper.AO,'daq')
		for n=1:length(exper.AO.daq)
			menuitem = findobj('tag','AO_board_menu','user',exper.AO.daq(n).name);
			label = get(menuitem,'label');
			label(1:2) = sprintf('%d:',n);
			set(menuitem,'checked','on','label',label);
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
	
		%if its possible to set the Trigger to HwDigital, then do it
		board.TriggerType = 'HwDigital';
	else
		board.TriggerType = 'Manual';
	end

	Message(me,sprintf('%s trigger',board.triggertype));

	


function reset_AO_data
global exper

	% get rid of extra cued AO samples!
	for n=1:length(exper.AO.daq)
        if exper.AO.daq(n).samplesavAIlable > 0
    		start(exper.AO.daq(n));
    		stop(exper.AO.daq(n));
    	end
    end
	
	
	for n=1:length(exper.AO.daq)
		nchan = length(exper.AO.daq(n).Channel);
		AOsamp = ceil(GetParam('AO','SampleRate')*GetParam('Control','trialdur'));
		if isempty(exper.AO.data{n}) | size(exper.AO.data{n},1) ~= AOsamp
			exper.AO.data{n} = zeros(AOsamp,nchan);
		end
		if GetParam(me,'Send')
			putdata(exper.AO.daq(n),exper.AO.data{n});
		end
		Message(me,'');
	end
	
%	Message(me,'Reset AO data');
%	Message(me,'');


