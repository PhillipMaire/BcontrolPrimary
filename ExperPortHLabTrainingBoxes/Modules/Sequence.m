function out = Sequence(varargin)
% Sequence
% 
% A general module for setting parameters in other modules
% by an arbitrary schedule.
%
% The schedule is specified by a Sequence file. In this file,
% each line consists of a Group name followed by one or more pAIrs of 
% parameter, value settings. A parameter is specified in the format
% module.param. 
% 
% Sequence File Format:
%
% init       : module.param=value,  module.param=value
% Group1name : module.param=value,  ..., module.param=value
%  .
%  .
%  .
% GroupKname : module.param=value  module.param=value
% 
% Each line must begin with a string specifying the Group name
% followed by a colon ':' and then 0 to n instances of 
% module.param=value separated by commas ','
% where "module.param" specifies an exper module and parameter name
% and value gives the setting to be applied. 
% Different Groups can specify values for the same or different parameters.
% All settings for a given Group should be kept on the same line.
%
% values
% values may be strings, doubles or arrays (with perhaps some limitations
% to be discovered(!) E.g. avoid using the format character colon ':'. 
%
% Comments
% Comment style is as Matlab (%).
%
% "Init" Group
% The first Group must be 'init'. The init Group is not executed or included except upon loading of
% file or selection of the init Group.
%
%
% UIControls specify whether the schedule is advanced (to the next entry) 
% on each trial and whether the order is randomized (and rerandomized) every
% iteration. 
%
% As for other modules, the trial-by-trial Sequence is saved and can be
% accessed after the experiment by GetParamTrial.
%
%
% Z. MAInen, CSHL 6/02
%

global exper

out = lower(mfilename);
if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
case {'init','reinit'}
	
	fig = ModuleFigure(me,'visible','off');	
	
	SetParam(me,'priority',1);  % has high priority

	hs = 200;
	h = 5;
	vs = 20;
	n = 0;
    
    InitParam(me,'rand','ui','checkbox','value',1,'pos',[h+hs*2/3 n*vs hs/3 vs]); n=n+1;
    InitParam(me,'advance','ui','checkbox','value',1,'list','','pos',[h+hs*2/3 n*vs hs/3 vs]);
    uiControl(fig,'tag','update','string','Update','style','togglebutton','value',1,...
        'callback',[me ';'],'background','green','pos',[h n*vs hs/3 vs]); n=n+1;
    
    uiControl(fig,'tag','settings','style','edit',...
        'enable','off','max',4,'horiz','left','pos',[h n*vs hs vs*3]); n=n+3;
    
    InitParam(me,'Group','ui','popupmenu','list',' ','settings',' ','index',' ','save',1,'value',1,'pos',[h n*vs hs vs]); n=n+1;
    
    uiControl(fig,'tag','open','style','pushbutton','string','<load Sequence>',...
        'callback',[me ';'],'horiz','left','pos',[h n*vs hs*2/3 vs]); 
    uiControl(fig,'tag','edit','style','pushbutton','string','Edit','callback',[me ';'],'pos',[h+hs*2/3 n*vs hs/3 vs]); n=n+1;
    
    
    
    % Message box
    uiControl('parent',fig,'tag','Message','style','edit',...
        'enable','inact','horiz','left','pos',[h n*vs hs vs]); n=n+1;
    
    
    h = uimenu(fig,'label','File');
    uimenu(h,'label','Open...','tag','file_open','callback',[me ';']);
	
    
	set(fig,'pos',[142 480-n*vs 68+hs n*vs],'visible','on');

case 'slice'
	
case 'trialready'
    

    
case 'trialend'

    SaveParamsTrial(me);

    trial = GetParam('Control','trial');
    Group = GetParamList(me,'Group');

    if ExistParam('Group') 
        Group('add',trial,Group);
    end

    
    % advance
    if GetParam(me,'advance')
	    next_Group = GetParam(me,'Group','value')+1;
	else
		next_Group = GetParam(me,'Group','value');
	end
	Group_len = length(GetParam(me,'Group','list'));
	
	% are we done with the Sequence?
	if next_Group > Group_len
        % note, we go back to 2 because the 1st is the init settings
		SetParam(me,'Group','value',2);
		if GetParam(me,'rand')
			randomize_Groups;
		end
	else
		SetParam(me,'Group','value',next_Group);
	end	

    % Here's where we apply the Group settings to the other modules:
    if GetUI(me,'update','value')
        apply_Group_settings;
    end
    
case 'reset'
    % initialize
    SetParam(me,'Group','value',1); 
    apply_Group_settings;

    % go to first in Sequence
    SetParam(me,'Group','value',2); 
    apply_Group_settings;
  

    
case 'Group'
%    varargout{1} = GetParamList(me,'Group');
    
    apply_Group_settings;
 
    
% handle UI parameter callbacks

case 'rand'
    if GetParam(me,'rand')
        randomize_Groups;
    else
        sort_Groups;
    end
    
case 'update'
    if get(gcbo,'value')
        set(gcbo,'background','green');
    else
        set(gcbo,'background',get(gcbf,'color'));
    end
    

case {'open','file_open'}
        
    pathfile = get(findobj(gcbf,'tag','open'),'user');
    if strcmp(action,'open') & ~isempty(pathfile)
        % user clicked to reopen the file
        filename = get(findobj(gcbf,'tag','open'),'string');
    else
        path = get(findobj(gcbf,'tag','file_open'),'user');
        filterspec = '*.txt';
        if ~isempty(path)
            filterspec = [path '\' filterspec];
        end
        prompt = 'Open Sequence file...';
        [filename, pathname] = uigetfile(filterspec, prompt);
        if isequal(filename,0)|isequal(pathname,0)
            return
        end
        set(findobj(gcbf,'tag','file_open'),'user',pathname);
        % set the file to [] until we are sure it's a good file
        set(findobj(gcbf,'tag','open'),'user',[]);
        
        pathfile = [pathname filename];
    end
    
    parse = textread(pathfile,'%s','delimiter',':','commentstyle','matlab');
    
    % Read and parse the Sequence file

    k = 1;
    for n=1:2:length(parse)
        name{k} = deblank(lower(parse{n}));
        settings{k} = parse{n+1};
        k=k+1;
    end
    
    % make sure the first line is 'init'
    if ~strcmp(lower(name{1}),'init')
        Message(me,'"init" Group must be first','error');
        return;
    else
        Message(me,sprintf('%d Groups read from %s',k-1,filename));
    end

    if check_Group_settings(settings)
        SetParam(me,'Group','list',name,'settings',settings,'index',1:k-1,'value',1);
        check = get(findobj(findobj('tag','Sequence','type','figure'),'tag','settings'),'string');
        apply_Group_settings;
        
        set(findobj(findobj('tag','Sequence','type','figure'),'tag','settings'),'string',check);
    
        % now set the filename
        set(findobj(gcbf,'tag','open'),'string',filename,'user',pathfile);
    end

case 'edit'
    pathfile = GetUI(me,'open','user');
    if ~isempty(pathfile)
        edit(pathfile);
    end
    
    
otherwise
	
end

% begin local functions

function out = me
	out = lower(mfilename); 
	
function out = callback
	out = [lower(mfilename) ';'];
    
    
function randomize_Groups
	% generate a random order
	gr_ind = GetParam(me,'Group','index');
    gr_list = GetParam(me,'Group','list');
    gr_settings = GetParam(me,'Group','settings');
	q = rand(1,length(gr_ind)-1);
	[val order] = sort(q);
    order = [1 order+1];
	for n=1:length(gr_ind)
        new_gr_ind(n) = gr_ind(order(n));	
        new_gr_list{n} = gr_list{order(n)};
        new_gr_settings{n} = gr_settings{order(n)};
	end
	SetParam(me,'Group','list',new_gr_list,'index',new_gr_ind,'settings',new_gr_settings);

    
function sort_Groups

	gr_ind = GetParam(me,'Group','index');
    gr_list = GetParam(me,'Group','list');
    gr_settings = GetParam(me,'Group','settings');
    q=sort(gr_ind);
    for n=1:length(q)
        new_gr_ind(n) = gr_ind(q(n));	
        new_gr_list{n} = gr_list{q(n)};
        new_gr_settings{n} = gr_settings{q(n)};
    end
	SetParam(me,'Group','list',new_gr_list,'index',new_gr_ind,'settings',new_gr_settings);

    


function apply_Group_settings
global exper

    str = GetParamList(me,'Group','settings');
    
    mpv = deblank(strread(str,'%s','delimiter','#,='));
    k = 1;
    for n=1:3:length(mpv)
        module = mpv{n};
        param = mpv{n+1};
        val = mpv{n+2};
        % convert value to numeric
        if length(str2num(val)) == 1
            val = str2num(val);
        end
        SetParam(module,param,val);
        if ExistParam('Orca')
		    Orca('set_info',k,val);
	    end 
        k = k+1;
    end
    set(findobj(findobj('tag','Sequence','type','figure'),'tag','settings'),'string',str);

    
function ok = check_Group_settings(settings)
global exper

    check = [];
    j=1;
	for k=1:length(settings)
        str = settings{k};
        mpv = deblank(strread(str,'%s','delimiter','#,='));
        for n=1:3:length(mpv)
            module = mpv{n};
            param = mpv{n+1};
            val = mpv{n+2};
            % convert value to numeric
            if length(str2num(val)) == 1
                val = str2num(val);
            end
            if ~ExistParam(module,param)
                check{j} = sprintf('Invalid param: %s.%s',module,param);
                j=j+1;
            end
        end
    end
    if isempty(check)
        check = 'All parameters OK!';
        ok = 1;
    else
        ok = 0;
    end
    set(findobj(findobj('tag','Sequence','type','figure'),'tag','settings'),'string',check);
    
        
