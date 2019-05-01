function varargout = Group(varargin)
% Group
%
% This module collects Groups of trials based on parameters such as odor ID.
% These can be used by other modules to select useful Groups of trials for
% averaging, etc.
% 
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
	
	SetParam(me,'priority',6);
    
 	hs = 200;
	h = 5;
	vs = 20;
	n = 0;
   
    
    uiControl(fig,'style','pushbutton','string','Add','callback',[me ';'],'tag','add_from_param','pos',[h+hs/3 n*vs hs/3 vs]); 
    uiControl(fig,'style','pushbutton','string','Add all','callback',[me ';'],'tag','add_all_from_param','pos',[h+hs*2/3 n*vs hs/3 vs]); 
    uiControl(fig,'style','pushbutton','string','Collect','callback',[me ';'],'tag','collect','pos',[h n*vs hs/3 vs]); n=n+1
    InitParam(me,'value','ui','popupmenu','list',{' '},'value',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'param','ui','popupmenu','list',{' '},'value',1,'pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'module','ui','popupmenu','list',{' '},'value',1,'pos',[h n*vs hs vs]); n=n+1;
   
    update_collect;
    
    n=n+1;

    
%    InitParam(me,'review','ui','popupmenu','list',' ','value',1,'trials',' ','pos',[h n*vs hs vs]); n=n+1;

    uiControl(fig,'style','pushbutton','string','Update','callback',[me ';'],'tag','update_Group','pos',[h+hs*2/3 n*vs hs/3 vs]); 
    uiControl(fig,'style','pushbutton','string','Del all','callback',[me ';'],'tag','del_all','pos',[h+hs/3 n*vs hs/3 vs]); 
    uiControl(fig,'style','pushbutton','string','Move dn','callback',[me ';'],'tag','move_dn','pos',[h n*vs hs/3 vs]); n=n+1;
    
    uiControl(fig,'style','pushbutton','string','New','callback',[me ';'],'tag','new_Group','pos',[h+hs*2/3 n*vs hs/3 vs]); 
    uiControl(fig,'style','pushbutton','string','Del','callback',[me ';'],'tag','del','pos',[h+hs/3 n*vs hs/3 vs]); 
    uiControl(fig,'style','pushbutton','string','Move up','callback',[me ';'],'tag','move_up','pos',[h n*vs hs/3 vs]); n=n+1
    
    InitParam(me,'Group','ui','popupmenu','list',{' '},'trials',{' '},'value',1,'pos',[h n*vs hs vs]); n=n+2;
  

    InitParam(me,'name','ui','edit','value','','pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'trials','ui','edit','value','','pos',[h n*vs hs vs]); n=n+1;

    n=n+1;
    InitParam(me,'invalid','ui','edit','value','','pos',[h n*vs hs vs]); n=n+1;
    InitParam(me,'valid','ui','edit','value','','pos',[h n*vs hs vs]); n=n+1;
    
    hf = uimenu(fig,'label','File');
	uimenu(hf,'label','Open...','tag','open','callback',[me ';']);
	uimenu(hf,'label','Save...','tag','save','callback',[me ';']);
    uimenu(hf,'label','Export...','tag','export','callback',[me ';'],'separator','on');
    uimenu(hf,'label','Import...','tag','import','callback',[me ';']);
    uimenu(hf,'label','Copy .sets','tag','copy_sets','callback',[me ';']);


    
    % Message box
    uiControl('parent',fig,'tag','Message','style','edit',...
        'enable','inact','horiz','left','pos',[h n*vs hs vs]); n=n+1;
    
	set(fig,'pos',[142 480-n*vs 68+hs n*vs],'visible','on');
    
    
case 'slice'
	
case 'trialready'
    
case 'trialend'
   	SaveParamsTrial(me);
    
case 'close'
    
case 'preload'
	
case 'load'
    if ~isfield(exper,me)
        ModuleInit(me);
    end
    LoadParams(me);
    
case 'reset'
    SetParam(me,'Group','value',1,'list',{' '},'trials',{' '});
    update_Group;
    
    
% functions that are called by other modules that work with Group


case 'current'
% [trials, name] = Group('current')
% return the currently selected Group of trials and its name
% trials is an array, name is a string. Invalid trials are
% removed. Both trials and name are passed as strings.

   varargout{1} = remove_invalid(GetParam(me,'trials'));
   varargout{2} = GetParam(me,'name');

   
case 'all'
% [trials, name] = Group('all')
% Return cell arrays of all the Groups and their names. 
% Invalid trials are removed. Both trials and names are passed as strings.

   trials = GetParam(me,'Group','trials'); 
   for n=1:length(trials)
       val_trials{n} = remove_invalid(trials{n});
   end
   varargout{1} = val_trials;
   if nargout > 1
       names = GetParam(me,'Group','list');
       varargout{2} = names; 
   end
    
   
case 'all_valid'
    
    % trials = Group('all_valid')
    % Return all valid trials in all Groups as a single list.
    
    
    val_trials = [];
    trials = GetParam(me,'Group','trials'); 
    for n=1:length(trials)
        val_trials = [val_trials remove_invalid(trials{n})];
    end
    varargout{1} = sprintf('%d ',(sort(str2num(val_trials))));
    
    
case 'add'
% Group('add',trial,name]
% Add a trial to the Group 'name'. Create a new Group if 
% name does not exist.


    trials = GetParam(me,'Group','trials'); 
    Groups = GetParam(me,'Group','list'); 
    
    new_trial = varargin{2};
    if ischar(new_trial)
        new_trial = str2num(new_trial)
    end
    new_Group = varargin{3};
    
    % start at 2 because the first string is not used
    for n=1:length(Groups)
        if ~isempty(Groups{n}) & strmatch(Groups{n},new_Group)
            tr = str2num(trials{n});
            if isempty(find(tr == new_trial))
                trials{n} = num2str(sort([tr new_trial]));
            end
            SetParam(me,'Group','trials',trials,'value',n);
            update_Group;
            return;
        end
    end
    
    % search fAIled, so add a new one
    Groups{end+1} = new_Group;
    trials{end+1} = num2str(new_trial);
    
    SetParam(me,'Group','list',Groups,'trials',trials,'value',length(Groups));
    
    update_Group;
    

    
   
case 'match'
% [name, index] = Group('match',target_trial)
% Target is a string specifying a trial
% Returns the first Group which includes the target trial.
% Name is a string and index is a number.

    target = varargin{2};
    if ischar(target)
        target = str2num(target);
    end
    trials = GetParam(me,'Group','trials'); 
    Groups = GetParam(me,'Group','list'); 
    
    varargout{1} = [];
    for n=1:length(trials)
        tr = str2num(trials{n});
        if ~isempty(find(tr == target))
            varargout{1} = Groups{n};
            if nargout > 1
                varargout{2} = n;
            end
            return;
        end
    end
    
    
case 'get'
% [trials, index] = Group('get',target_Group)
% Returns the trials associated with a Group
% Target_Group can be either a string (Group name)
% of the index of the Group (value of the popupmenu ui).
% Trials are returned as a string. Invalid trials are removed.
    
    
    trials = GetParam(me,'Group','trials'); 
    Groups = GetParam(me,'Group','list'); 
    
    target_Group = varargin{2};
    
    % if passed a string, then search for it
    if ischar(target_Group)
        % start at 2 because the first string is not used
        for n=1:length(Groups)
            if strmatch(Groups{n},target_Group)
                varargout{1} = remove_invalid(trials{n});
                if nargout ==2 
                    varargout{2} = n;
                end
                return;
            end
        end
        % search fAIled
        varargout{1} = [];
    else 
        % if passed a number just return the trials
        varargout{1} = trials{target_Group};
    end
    
case 'add_invalid'
% invalid = Group('add_invalid',trials)
% Add trials to the invalid list. Trials can be passed as
% an array or a string. Checks to avoid duplicates.

    trials = varargin{2};
    if ischar(trials)
        trials = str2num(trials);
    end
    
    invalid = GetParam(me,'invalid');
    if ~isempty(invalid)
        invalid = str2num(invalid);
        
        for n=1:length(trials)
            if isempty(find(trials(n) == invalid))
                invalid(end+1) = trials(n);
            end
        end
        invalid = sprintf('%d ',sort(invalid));
        SetParam(me,'invalid',invalid(1:end-1));
    else 
        SetParam(me,'invalid',num2str(trials));
    end
    
    
case 'remove_invalid'
% invalid = Group('remove_invalid',trials)
% Remove trials from the invalid list. Trials can be passed as
% an array or a string. It is NOT an error to try to remove 
% trials which are not presently invalid.
    
    trials = varargin{2};
    
    if ischar(trials)
        trials = str2num(trials);
    end
    invalid_num = str2num(GetParam('Group','invalid'));
    for n=1:length(trials)
        good_ind = find(invalid_num ~= trials(n));
        invalid_num = invalid_num(good_ind);
    end
    
    new_invalid = sprintf('%d ',invalid_num); 
    SetParam('Group','invalid',new_invalid(1:end-1));
    varargout{1} = new_invalid(1:end-1);
           


% handle UI parameter callbacks

    
case 'module'
    update_collect;
            
 
case 'value'
    trials = GetParamList(me,'value','trials');
    SetParam(me,'trials',trials);
	
    
case 'new_Group'
    % update the Group to reflect new trials and name
    trials_list = GetParam(me,'Group','trials'); 
    trials_list{end+1} = ' ';    
    SetParam(me,'trials',' ');
    SetParam(me,'name',' ');
    SetParam(me,'Group','trials',trials_list);
  
    name_list = GetParam(me,'Group','list');      % list of names
    name_list{end+1} = ' ';
    SetParam(me,'Group','list',name_list);
   
case 'update_Group'
    % update the Group to reflect new trials and name
    trials_list = GetParam(me,'Group','trials'); 
    trials_list{GetParam(me,'Group','value')} = GetParam(me,'trials');    
    SetParam(me,'Group','trials',trials_list);
  
    name_list = GetParam(me,'Group','list');      % list of names
    name_list{GetParam(me,'Group','value')} = GetParam(me,'name');    
    SetParam(me,'Group','list',name_list);
    update_Group;

    
case 'collect'
    if ExistParam('Control','run') & GetParam('Control','run')
        Message(me,'Stop run before collecting trials','error');
        return;
    else
        collect;
        Message(me,'');
    end
    
    
    
    
case 'Group'
    tr = GetParamList(me,'Group','trials');

    SetParam(me,'trials',tr);
    SetParam(me,'name',GetParamList(me,'Group','list'));
    

    
case 'add_from_param'
    trials = GetParam(me,'trials');
 
    if isempty(trials)
%        SetParam(me,'trials',select_trials(trs{GetParam(me,'value','value')}));
        return
    end


    trials_list = GetParam(me,'Group','trials');  % list of trials
    name_list = GetParam(me,'Group','list');      % list of names
    
    name = sprintf('%s',GetParamList(me,'value'));
    
    ind = length(trials_list)+1;
    
    trials_list{ind} = select_trials(trials);
    name_list{ind} = name;
        
    SetParam(me,'Group','trials',trials_list,'list',name_list,'value',ind);
    
    update_Group;
    
case 'add_all_from_param'
    for n=1:length(GetParam(me,'value','list'))
        SetParam(me,'value',n);
        Group('value');
        Group('add_from_param');
    end
 
    
case 'del'
    ind = GetParam(me,'Group','value');
    trials_list = GetParam(me,'Group','trials'); % list of trials
    name_list = GetParam(me,'Group','list');  % list of comments
       
    k=1;
    for n=1:length(trials_list)
        if n ~= ind    
            new_name_list{k} = name_list{n};
            new_trials_list{k} = trials_list{n};
            k=k+1;
        end
    end
    ind = max([ind-1 1]);
    
    SetParam(me,'Group','trials',new_trials_list,'value',ind,'list',new_name_list);
    update_Group;
    
    
case 'del_all'
    if strcmp(questdlg('Remove all trials?'),'Yes')
        SetParam(me,'Group','value',1,'list',{' '},'trials',{' '});
        update_Group;
    end
    
case 'move_dn'
    % move the current Group down in the list
    s_list = GetParam(me,'Group','list');
    s_trials = GetParam(me,'Group','trials');
    v = GetParam(me,'Group','value');
    
    if v == 1
        return;
    end
    tmp = s_list{v-1};
    s_list{v-1} = s_list{v};
    s_list{v} = tmp;
    ttmp = s_trials{v-1};
    s_trials{v-1} = s_trials{v};
    s_trials{v} = ttmp;
    SetParam(me,'Group','list',s_list);
    SetParam(me,'Group','trials',s_trials);
    SetParam(me,'Group','value',v-1);
    update_Group;
    
case 'move_up'
    % move the current Group up in the list
    s_list = GetParam(me,'Group','list');
    s_trials = GetParam(me,'Group','trials');
    v = GetParam(me,'Group','value');
    
    if v == length(s_list)
        return;
    end
    
    tmp = s_list{v+1};
    s_list{v+1} = s_list{v};
    s_list{v} = tmp;
    ttmp = s_trials{v+1};
    s_trials{v+1} = s_trials{v};
    s_trials{v} = ttmp;
    
    SetParam(me,'Group','list',s_list);
    SetParam(me,'Group','trials',s_trials);
    SetParam(me,'Group','value',v+1);
    update_Group;
    
    
case 'open'
    
    path = get(get(gcbo,'parent'),'user');
    if isempty(path)
	    filterspec = '*.mat';
    else 
        filterspec = [path '\*.mat'];
    end
    prompt = 'Load Groups from mat file...';
	[filename, pathname] = uigetfile(filterspec, prompt);
    if isequal(filename,0)|isequal(pathname,0)
         Message(me,'Open canceled');
         return
    end
	set(get(gcbo,'parent'),'user',pathname);
    s = load([pathname '\' filename]);
    exper = setfield(exper,'Group',s.Group);
    Message(me,['Opened ' filename]);
    LoadParams(me);
    
    
case 'save'
    path = get(get(gcbo,'parent'),'user');
    filterspec = sprintf('%s_Groups.mat',GetParam('Control','expid'));
    if ~isempty(path)
        filterspec = [path '\' filterspec];
    end
    prompt = 'Save Groups to mat file...';
	[filename, pathname] = uiputfile(filterspec, prompt);
    if isequal(filename,0)|isequal(pathname,0)
         Message(me,'Save canceled');
         return
    end
	set(get(gcbo,'parent'),'user',pathname);
    Group = exper.Group;
    save([pathname '\' filename],'Group');
    Message(me,['Saved ' filename]);
    
    
case 'export'
    % to format suitable for excel
    path = get(get(gcbo,'parent'),'user');
    filterspec = sprintf('%s_Groups.txt',GetParam('Control','expid'));
    if ~isempty(path)
        filterspec = [path '\' filterspec];
    end
    prompt = 'Export Groups to text/xls file...';
	[filename, pathname] = uiputfile(filterspec, prompt);
    if isequal(filename,0)|isequal(pathname,0)
         Message(me,'Export canceled');
         return
    end
	set(get(gcbo,'parent'),'user',pathname);
    fid = fopen([pathname '\' filename],'w');
    if fid == -1
        Message(me,'Cannot write to file','error');
        return    
    end
    
    s_list = GetParam(me,'Group','list');
    s_trials = GetParam(me,'Group','trials');
    
    for n=1:length(s_list)
        
        fprintf(fid,'%s\t',s_list{n});
        tr = str2num(s_trials{n});
        for k=1:length(tr)
            fprintf(fid,'%d\t',tr(k));
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
    Message(me,['Exported ' filename]);
    
    
case 'import'
    path = get(get(gcbo,'parent'),'user');
    filterspec = '*.txt';
    if ~isempty(path)
        filterspec = [path '\' filterspec];
    end
    prompt = 'Import Groups file...';
    [filename, pathname] = uigetfile(filterspec, prompt);
    if isequal(filename,0)|isequal(pathname,0)
        return
    end
    set(get(gcbo,'parent'),'user',pathname);
    
    % first read into lines
    parse = textread([pathname filename],'%s','commentstyle','matlab');
    
    k = 0;
    for n=1:length(parse)
        % is this a Group name -- that is, not a trial number?
        if isempty(str2num(parse{n}))
            k=k+1;
            names{k} = parse{n};
            trials{k} = [];
        else
            trials{k} = [trials{k} ' ' parse{n}];
        end
    end
    
    Message(me,sprintf('Imported %d Groups',k))
     
    SetParam(me,'Group','list',names);
    SetParam(me,'Group','trials',trials);
    SetParam(me,'Group','value',1);
    update_Group;
 
    
case 'copy_sets'
    
    SetParam(me,'invalid',GetParam('sets','invalid'));
    SetParam(me,'valid',GetParam('sets','valid'));
    
    SetParam(me,'Group','value',GetParam('sets','sets','value'));
    SetParam(me,'Group','list',GetParam('sets','sets','list'));
    SetParam(me,'Group','trials',GetParam('sets','sets','trials'));
    
    
    
    
   
otherwise
	
end

% begin local functions

function out = me
	out = lower(mfilename); 
	
function out = callback
	out = [lower(mfilename) ';'];

    
function update_Group

    [trials,names] = Group('all');
    val = GetParam('Group','Group');
    SetParam(me,'trials',trials{val});
    SetParam(me,'name',names{val});
 
    % these functions allow Group to update lists in any figure that makes
    % use of a popupmenu tagged 'Group' or edit ui tagged 'trials'
    % for each of these ui's to be found, they should have the 'user' field set to 'Group'
    
    set(findobj('style','edit','tag','trials','user','Group'),'string',trials{val});
    set(findobj('style','popupmenu','user','Group'),'string',names,'value',val);
    
    % Opt may have more to do 
    Opt('update_Group');
    
function update_collect
global exper

    modules = fieldnames(exper);    
    SetParam(me,'module','list',modules);
    
    module = GetParamList(me,'module');
    fields = eval(sprintf('fieldnames(exper.%s.param)',module));
    params = {' '};
    k=1;
    for n=1:length(fields)
        save = eval(sprintf('exper.%s.param.%s.save',module,fields{n}));
        if save
            params{k} = fields{n};
            k=k+1;
        end
    end
    
    SetParam(me,'param','list',params,'value',1);
    
    
function collect
global exper

    % any parameter specified by the user
    
    module = GetParamList(me,'module');
    param = GetParamList(me,'param');
    
    trials = 1:length(GetParam(module,param,'trial'));
    
    current_trial = GetParam('Control','trial');
	if ExistParam('Control','run') & GetParam('Control','run')
        AI('pause');
        if ExistParam('AO')
    		AO('pause');
        end
        restart = 1;
    else
        restart = 0;
    end
    
    
    numeric = 0;
    for n=1:length(trials)
        SetParam('Control','trial',trials(n));
        
        % should retrieve the saved parameters
        CallModule(module,'trialreview');
        
        xr = GetParamTrial(module,param,trials(n));
        
        if isnumeric(xr)
            x{n} = num2str(xr);
            numeric = 1;
        elseif isstr(xr)
            x{n} = xr;
        end
    end
    
    % order the trials
    xs = {' '};
    k = 1;
    trs = {' '};
    for n=1:length(trials)
        match = strcmp(x{n},xs);

        if ~match
            xs{k} = x{n};
            trs{k} = num2str(trials(n));
            k = k+1;
        else
            trs{match} = [trs{match} ' ' num2str(trials(n))];
        end
    end
    
    % sort 
    [xs,i] = sort(xs);
    trs = trs(i);
    
    SetParam(me,'value','list',xs,'trials',trs,'value',1);
    SetParam('Control','trial',current_trial);
    if restart
        Control('run');
    end
    
    
    
function good = select_trials(trials,valid,invalid)
global exper

    
    if nargin < 3
        invalid = str2num(GetParam(me,'invalid'));
    end
    if nargin < 2
        valid = str2num(GetParam(me,'valid'));
    end
    if nargin < 1
        trials = 1:length(GetParam('Control','trialdur','trial'));
    else
        if isstr(trials)
            trials = str2num(trials);
        end
    end
        
    used = [];
    if isempty(valid)
        valid = 1:length(exper.Opt.trial);
    end
    
    good = '';
    k=1;
    for n=1:length(trials)
        if ~isempty(find([-1 valid] == trials(n))) & isempty(find([-1 invalid] == trials(n)))
            good(k) = trials(n);
            k=k+1;
        end
    end
    if ~isempty(good)
        good = sprintf('%d ',good);
    end

    
function good = remove_invalid(trials_str)

    good = '';
    k=1;
    trials = str2num(trials_str);
    invalid = str2num(GetParam('Group','invalid'));
    for n=1:length(trials)
        if isempty(find([-1 invalid] == trials(n)))
            good(k) = trials(n);
            k=k+1;
        end
    end
    if ~isempty(good)
        good = sprintf('%d ',good);
    end
 
    
