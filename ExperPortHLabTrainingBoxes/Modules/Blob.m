function varargout = Blob(varargin)
% Opt
% Optical imaging analysis
%
% ZF MAInen 07/01
%
% Blob ANALYSIS
%
% analysis functions
% ------------------
% Blob('correl',sweeps1,sweeps2)
% Blob('dist_geom',sweeps1,sweeps2)
% Blob('cluster',sweeps1,sweeps2,...,sweepsn)
% Blob('winners',sweeps1,sweeps2...,sweepsN)	% plot Blobs as filled circles with
%																	% colors assigned to the strongest
%																	% odor (sweep) for each Blob
% Blob('map',sweeps,hue,thresh)	 plot Blobs as filled circles with
%														 color hue, only if < thresh
% Blob('imap',sweeps,range)	 plot Blobs as filled circles with
%												 fill color reflecting intensity
%												 range is [min max]
% Blob('tuning',sweeps1,sweeps2,...,sweepsN)		lines connecting sweeps
% Blob('matrix',sweeps1,sweeps2,...,sweepsN)


global exper

if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

%fig=findobj('tag','Opt_ratio_fig');

switch action
	
case {'init','reinit'}
	
	% Blob is after Optical
	SetParam(me,'priority',7); 

	fig = ModuleFigure(me,'visible','off');	
	
    hs = 60;
	h = 5;
	vs = 20;
    n = 0;
    
    uiControl(fig,'style','pushbutton','string','Ratio(param)','callback',[me ';'],'tag','x_plot','pos',[h n*vs hs*2 vs]); n=n+1;
    uiControl(fig,'style','pushbutton','string','Correl(s1,s2)','callback',[me ';'],'tag','correl','pos',[h n*vs hs*2 vs]); n=n+1;
      % Group 1
    uiControl(fig,'style','text','string','Group 1','horiz','left','pos',[h+hs+5 n*vs hs vs]); 
    uiControl(fig,'style','popupmenu','string',{'Press Group/update'},'value',1,'background','white',...
        'tag','Group_1','user','Group','callback',[me ';'],'pos',[h n*vs hs vs]); n=n+1;
  
    % Group 2
    uiControl(fig,'style','text','string','Group 2','horiz','left','pos',[h+hs+5 n*vs hs vs]); 
    uiControl(fig,'style','popupmenu','string',{'Press Group/update'},'value',1,'background','white',...
        'tag','Group_2','user','Group','callback',[me ';'],'pos',[h n*vs hs vs]); n=n+1;
  
    
    uiControl(fig,'style','text','string','Analysis functions','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1.5;
    
    uiControl(fig,'style','pushbutton','string','cluster','callback',[me ';'],'tag','cluster','pos',[h+hs n*vs hs vs]); 
  
    uiControl(fig,'style','pushbutton','string','matrix','callback',[me ';'],'tag','matrix','pos',[h n*vs hs vs]); n=n+1;
    uiControl(fig,'style','text','string','range','horiz','left','pos',[h+hs+15 n*vs hs vs]); 
    uiControl(fig,'style','edit','string','0.003','background','white',...
        'tag','range','horiz','right','callback',[me ';'],'pos',[h n*vs hs+15 vs]); n=n+1;
    uiControl(fig,'style','text','string','format','horiz','left','pos',[h+hs+15 n*vs hs vs]); 
    uiControl(fig,'style','popupmenu','string',{'mean','mean,sd'},'value',1,'background','white',...
        'tag','format','callback',[me ';'],'pos',[h n*vs hs+15 vs]); n=n+1;
    uiControl(fig,'style','text','string','normalize','horiz','left','pos',[h+hs+15 n*vs hs vs]); 
    uiControl(fig,'style','popupmenu','string',{'none','Blob','Group','Blob_sel'},'value',1,'background','white',...
        'tag','normalize','callback',[me ';'],'pos',[h n*vs hs+15 vs]); n=n+1;
    

    uiControl(fig,'style','text','string','Display','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1.5;
  
    uiControl(fig,'style','text','string','measure','horiz','left','pos',[h+hs+15 n*vs hs vs]); 
    uiControl(fig,'style','popupmenu','string',{'ratio','ratio_time','abs_time'},'value',1,'background','white',...
        'tag','measure','callback',[me ';'],'pos',[h n*vs hs+15 vs]); n=n+1;
  
    uiControl(fig,'style','text','string','Calculations','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1.5;
    
    uiControl(fig,'style','pushbutton','string','extract now','callback',[me ';'],'tag','calc_ratios','pos',[h n*vs hs vs]); n=n+1;
    
    InitParam(me,'active','ui','edit','value','','pos',[h n*vs hs vs]); n=n+1;    
   
     uiControl(fig,'style','text','string','source','horiz','left','pos',[h+hs+15 n*vs hs vs]); 
    uiControl(fig,'style','popupmenu','string',{'image','timecourse'},'value',1,'background','white',...
        'tag','source','callback',[me ';'],'pos',[h n*vs hs+15 vs]); n=n+1;
  
     uiControl(fig,'style','text','string','extract values','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1.5;
   
    
    uiControl(fig,'style','pushbutton','string','Clear all','callback',[me ';'],'tag','clear','pos',[h n*vs hs vs]);n=n+1;
    InitParam(me,'select','ui','popupmenu','list',{' '},'value',1,'pos',[h n*vs hs vs]); n=n+1;
 
    	% Message box
	uiControl('parent',fig,'tag','Message','style','edit',...
		'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1;

    hf = uimenu(fig,'label','File');
	uimenu(hf,'label','Open...','tag','open','callback',[me ';']);
	uimenu(hf,'label','Save...','tag','save','callback',[me ';']);
	uimenu(hf,'label','Export all...','tag','export_all','callback',[me ';'],'separator','on');
	uimenu(hf,'label','Export Groups...','tag','export_Groups','callback',[me ';']);
    
	set(fig,'pos',[200 290-n*vs hs*2+8 n*vs],'visible','on');
    set(findobj('parent',fig,'style','text'),'background',get(fig,'color'));
    
    if ~isfield(exper.Blob,'roi')
        exper.Blob.roi = [];
        exper.Blob.result = [];
        h=findobj('tag','Opt_ratio_fig');
        delete(findobj(h,'tag','Blob','type','line'));
        delete(findobj(h,'tag','Blob','type','text'));
    end
    
    for n=1:length(exper.Blob.roi)
        b{n} = num2str(n);
    end
    SetParam(me,'select','list',b,'value',1);
    
     
    
case 'open'    
    path = get(get(gcbo,'parent'),'user');
    if isempty(path)
	    filterspec = '*.mat';
    else 
        filterspec = [path '\*.mat'];
    end
    prompt = 'Load Blobs from mat file...';
	[filename, pathname] = uigetfile(filterspec, prompt);
    if isequal(filename,0)|isequal(pathname,0)
         Message(me,'Open canceled');
         return
    end
	set(get(gcbo,'parent'),'user',pathname);
    s = load([pathname '\' filename]);
    exper = setfield(exper,'Blob',s.Blob);
    Message(me,['Opened ' filename]);
    LoadParams(me);
    
    
case 'save'
    path = get(get(gcbo,'parent'),'user');
    filterspec = sprintf('%s_Blob.mat',GetParam('Control','expid'));
    if ~isempty(path)
        filterspec = [path '\' filterspec];
    end
    prompt = 'Save Blobs to mat file...';
	[filename, pathname] = uiputfile(filterspec, prompt);
    if isequal(filename,0)|isequal(pathname,0)
         Message(me,'Save canceled');
         return
    end
	set(get(gcbo,'parent'),'user',pathname);
    Blob = exper.Blob;
    save([pathname '\' filename],'Blob');
    Message(me,['Saved ' filename]);
    
case 'export_Groups'
    [trials, names] = Group('all');
    
    [filename, pathname] = uiputfile('*.txt','Save Blob data to ascii file...');
    if ~filename
        return
    end
    fid = fopen([pathname '\' filename],'w');
    if fid == -1
        Message(me,'Problem opening file for writing!','error');
        return
    end
        
    [X, SX, Y, SY, ind] = get_Blob_matrix;
    
    n_Groups=size(X,1);
    n_Blobs=size(X,2);
    n_times=size(X,3);
   
    print_Blob_header(fid,ind,'Groups');
    
    for n=1:n_Groups
        for j=1:n_times
                fprintf(fid,'%s\t',names{n+1});   % n+1 = skip first Group
            if n_times > 1
                fprintf(fid,'%d\t',(j-1)*exper.Blob.stack);
            end
            for k=1:n_Blobs
                fprintf(fid,'%g\t',X(n,k,j));
            end      
            
            for k=1:n_Blobs
                fprintf(fid,'%g\t',SX(n,k,j));
            end
            fprintf(fid,'\n');
        end
        if n_times > 1, fprintf(fid,'\n'); end
      end
    fclose(fid);
    Message(me,'');
    
    
case 'export_all'
    [filename, pathname] = uiputfile('*.txt','Save Blob data to ascii file...');
    if ~filename
        return
    end
    fid = fopen([pathname '\' filename],'w');
    if fid == -1
        Message(me,'Could not open file for writing','error');
        return;
    end
    
    trials = str2num(Group('all_valid'));
    [X, SX, Y, SY, ind] = get_Blob_matrix(trials);
    
    print_Blob_header(fid,ind,'all');
    
    for n=1:size(X,1)
        for j=1:size(X,3)
            % this wierd comparison gets rid of NaN's -- there is probably a more 
            % correct way to do this...
            if ~isnan(X(n,1,j))
                tr = trials(n);
                fprintf(fid,'%d\t',tr);
                name = Group('match',tr);
                if isempty(name), name=' '; end
                fprintf(fid,'%s\t',name);
                time = GetParamTrial('Control','exptime',tr);
                fprintf(fid,'%d\t',time);
                if size(X,3) > 1, fprintf(fid,'%d\t',(j-1)*exper.Blob.stack); end
                for k=1:size(X,2)
                    fprintf(fid,'%g\t',X(n,k,j));
                end
                fprintf(fid,'\n');
            end
        end
        if size(X,3) > 1, fprintf(fid,'\n'); end
    end
    fclose(fid);
    


case 'draw'
   ax = varargin{2};
   roi = exper.Blob.roi;
   for n=1:length(roi)
       x = exper.Blob.roi(n).x;
       y = exper.Blob.roi(n).y;
       draw_circle(ax,n,x,y);
   end
    
case 'clear'
    if strcmp(questdlg('Clear all Blobs?'),'Yes')
        ax = findobj('tag','Opt_axes');
        delete(findobj(ax,'tag','Blob'));
        exper.Blob.roi = [];
        SetParam(me,'select','list',{''},'value',1);
    end    
    
    
case 'select'
    
%    fig = findobj('tag','Opt_ratio_fig','user',1);
    ax = findobj('tag','Opt_axes');
% fig = gcbf;   
    set(findobj(ax,'tag','Blob','type','line'),'linewidth',1);
    set(findobj(ax,'tag','Blob','type','text'),'fontweight','normal');
    select = str2num(GetParamList(me,'select'));
    set(findobj(ax,'tag','Blob','type','line','user',select),'linewidth',2);
    set(findobj(ax,'tag','Blob','type','text','user',select),'fontweight','bold');
   

    
case 'stale_ratios'
    for n=1:length(exper.Blob.roi)
        exper.Blob.roi(n).recalc = 1;
    end
    stale_ratios;
    

case {'sort_by_x','sort_by_x'}
    
   
    b = length(exper.Blob.roi);
    
    for n=1:b
        switch action
        case 'sort_by_x'
            v(n) = mean(exper.Blob.roi(n).x);
        case 'sort_by_y'
            v(n) = mean(exper.Blob.roi(n).x);
        end
    end
    [val new_order] = sort(v);
    
    
    temp_roi = exper.Blob.roi;
    for n=1:b
        exper.Blob.roi(n) = temp_roi(new_order(n));
    end
  %  fig = findobj('tag','Opt_ratio_fig');
    fig = gcbf;
    Blobs = findobj(fig,'tag','Blob');
    if isempty(Blobs)
        ax = findobj(gcbf,'tag','Opt_axes');
        ax = ax(1);
    else
        ax = get(Blobs(1),'parent');
        delete(Blobs);
   end
    
    for n=1:length(exper.Blob.roi)
        h = draw_circle(ax,n,exper.Blob.roi(n).x,exper.Blob.roi(n).y);    
    end    
    
    
    
    
% -------------------------------------------------------------------
% mouse and keys
% -------------------------------------------------------------------

case 'buttonmotion'
  %  obj = get(gcbf,'currentobject');
  %  if ~strcmp(get(obj,'tag'),'Blob')
    if ~strcmp(get(gco,'tag'),'Blob') | ~strcmp(get(gco,'type'),'line')
        return;
    end

    ax = get(gco,'parent');
    b = get(gco,'user');
    pos = get(ax,'CurrentPoint');
    
    switch get(gcbf,'SelectionType');
    case 'normal'       % left button
        % move it
        move_circle(b,pos,radius(gco));
    case 'extend'       % middle-button or left+right-buttons or shift/left-button
        % move it
        move_circle(b,pos,radius(gco));
    case 'alt'          % right button
        % change radius
        move_circle(b,center(gco),distance(center(gco),pos));
    otherwise
    end
        
case 'buttonup'
    switch get(gcbf,'SelectionType');
    case 'normal'       % left button
    case 'extend'       % middle-button or left+right-buttons or shift/left-button
    case 'alt'          % right-button or alt/left-button
    case 'open'
    otherwise
    end
%    if strcmp(get(gco,'tag'),'Blob')
%        Blob_stats(gco);
%    end
    
case 'buttondown'
%    fig = findobj('tag','Opt_ratio_fig','user',1);
    fig = gcbf;
    
    switch get(fig,'SelectionType');

    case 'normal'       % left button
        % select
        if strcmp(get(gco,'tag'),'Blob') & strcmp(get(gco,'type'),'line')
            b = get(gco,'user');
%            SetParam(me,'select',num2str(b));
            SetParam(me,'select',b);
            set(findobj(fig,'tag','Blob','type','line'),'linewidth',1,'visible','on');
            set(findobj(fig,'tag','Blob','type','text'),'fontweight','normal');
            set(findobj(fig,'tag','Blob','type','line','user',b),'linewidth',2);
            set(findobj(fig,'tag','Blob','type','text','user',b),'fontweight','bold');

            Blob_stats(gco);
%            refresh(fig);
        end
    case 'extend'       % middle-button or left+right-buttofns or shift/left-button
    case 'alt'          % right-button or alt/left-button
    case 'open'         % double click
        % don't know the radius, so make it 10
        ho = findobj(fig,'tag','Blob','type','line');
        ax = get(gcf,'currentaxes');
        
        if isempty(ho)
            new_circle(ax,get(ax,'currentpoint'),10);
        else
            new_circle(ax,get(ax,'currentpoint'),radius(ho(1)));
        end
        b = length(exper.Blob.roi);
        set(findobj(fig,'tag','Blob','type','line'),'linewidth',1);
        set(findobj(fig,'tag','Blob','type','text'),'fontweight','normal');
        set(findobj(fig,'tag','Blob','type','line','user',b),'linewidth',2);
        set(findobj(fig,'tag','Blob','type','text','user',b),'fontweight','bold');
        for n=1:b
            bl{n} = num2str(n);
        end
        SetParam(me,'select','list',bl,'value',b);
            

    otherwise
    end
   
case 'keypress'
    key = double(get(gcbf,'CurrentCharacter'));
    if isempty(key) 
        return;
    end
 %   fig = findobj('tag','Opt_ratio_fig');
 fig = gcbf;
    
    b = str2num(GetParamList(me,'select'));    
    h = findobj(fig,'tag','Blob','type','line','user',b);
    x = get(h(1),'xdata');
    y = get(h(1),'ydata');

    switch key
    case 30         % up arrow
        y = y + 1;
        set(h,'ydata',y);
        Blob_stats(h(1));
    case 29         % right arrow
        x = x + 1;
        set(h,'xdata',x);
        Blob_stats(h(1));
    case 28         % left arrow
        x = x - 1;
        set(h,'xdata',x);
        Blob_stats(h(1));
    case 31         % bottom arrow
        y = y - 1;
        set(h,'ydata',y);
        Blob_stats(h(1));
    case {45,95}  % make smaller
        [x, y] = move_circle(b,center(h(1)),max([radius(h(1))-1 1]));
        set(h,'xdata',x,'ydata',y)
        Blob_stats(h(1));
    case {43,61}  % make bigger
        [x, y] = move_circle(b,center(h(1)),radius(h(1))+1);
        set(h,'xdata',x,'ydata',y)
        Blob_stats(h(1));
    case 'x'        % delete
        dh = findobj(gcbf,'tag','Blob');
        delete(dh);
        exper.Blob.roi = [exper.Blob.roi(1:b-1) exper.Blob.roi(b+1:end)];
        mx = length(exper.Blob.roi);
        for n=1:mx
            bl{n} = num2str(n);
        end
        SetParam(me,'select','list',bl,'value',mx);
        Blob('draw',gca);
        
        return;
    otherwise
        Message(me,key);        
        return;
    end
    
    move_circle(b,center(h(1)),radius(h(1)));

    
    
case 'calc_ratios'
    calc_ratios(varargin{2:end});
    
case 'get_Blob_matrix'
    varargout{:} = get_Blob_matrix(varargin{2:end});
    
case 'preload'
    
%    h=findobj('tag','Opt_ratio_fig');

%    delete(findobj(h,'tag','Blob','type','line'));
    delete(findobj('tag','Blob','type','line'));
    delete(findobj('tag','Blob','type','text'));

    
case 'load'
    if ~isfield(exper,'Blob')
        ModuleInit('Blob');
    end
    
    if ~isfield(exper.Blob,'roi')
        exper.Blob.roi = [];
        exper.Blob.result = [];
    end
    
    if ~ExistParam(me,'active')
        InitParam(me,'active','value','');
    end

    LoadParams(me);
    update_Groups;
    
    

case 'close'
    
    
    
    
% -------------------------------------------------------------------
% analysis functions
% -------------------------------------------------------------------


    
case 'x_plot'
    % we plot the value of each Blob as a function of
    % any parameter specified by the user
    
    module = GetParamList('Group','module');
    param = GetParamList('Group','param');
    
    trials = Group('get',get(findobj(gcbf,'tag','Group_1'),'value'));

    numeric = 0;
    for n=1:length(trials)
        SetParam('Control','trial',trials(n));
        CallModule(module,'trialreview');
        
        % xr = GetParamTrial(module,param,trials(n));
        
        xr = GetParam(module,param);
        
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
    for n=1:length(trials)
        match = strmatch(x{n},xs);
        if isempty(match)        
            xs{k} = x{n};
            trs{k} = trials(n);
            k = k+1;
        else
            trs{match} = [trs{match} trials(n)];
        end
    end
    
    rois = GetParamList(me,'select');
    if isempty(rois)
        rois = 1:length(exper.Blob.roi);
    else
        rois = str2num(rois);
    end
                
    
    % calculate 
    for n=1:length(xs)
        ys{n} = exper.Blob.roi(1).ratio(trs{n});
        for k=rois
            ys{n} = [ys{n} exper.Blob.roi(k).ratio(trs{n})];
        end
        ysm(n) = mean(ys{n});
    end
    
    % finally plot
    figure;
    if numeric
        for n=1:length(xs)
            xsn(n) = str2num(xs{n});
        end
        plot(xsn,ysm,'ko ');
    else
        plot(ysm,'ko ');
        set(gca,'Xtick',1:length(xs),'XTickLabel',xs);
    end
    xlabel(sprintf('%s %s',module,param));
    
    exper.Blob.result.x=xs;
    exper.Blob.result.y=ys;
    
    
    
    
case 'correl'
 
    s1 = str2num(Group('get',get(findobj(gcbf,'tag','Group_1'),'value')));
    s2 = str2num(Group('get',get(findobj(gcbf,'tag','Group_2'),'value')));

    rois = 1:length(exper.Blob.roi);
    
    x = [];
    y = [];
    for k=rois
        x = [x mean(exper.Blob.roi(k).ratio(s1))];
        y = [y mean(exper.Blob.roi(k).ratio(s2))];
    end
    figure;
    plot(x,y,'o');
    exper.Blob.result.x=x;
    exper.Blob.result.y=y;

    
case 'matrix'
   [X, SX, Y, SY, ind] = get_Blob_matrix;
   
   range = str2num(get(findobj(gcbf,'tag','range'),'string'));
       
   
   nBlob = size(X,2);
   nGroups = size(X,1);   
   
    fig = findobj('type','figure','tag','ratio_matrix');
    if isempty(fig)
        fig = figure('tag','ratio_matrix');    
    else
        figure(fig);
        clf
    end
   cmp=colormap;
   switch GetPopupmenuItem('format',gcbf)
   case 'mean'
       for n=1:nGroups
           for k=1:nBlob
               [rx,ry] = circle(Y(n,k)/range*0.5);
               patch(rx+k,ry+n,[0 0 0]);
           end
       end       
       
   case 'mean,sd'
       for n=1:nGroups
           for k=1:nBlob
               [rx,ry] = circle(Y(n,k)/range*0.5);
               patch(rx+k,ry+n,[0 0 0]);
               [srx,sry] = circle(SY(n,k)/range*0.5);
               h = line(srx+k,sry+n,'color','red');
           end
       end       

   otherwise

   end
   set(gca,'XLim',[0 nBlob+1],'Xtick',1:nBlob,'XTickLabel',ind');
   xlabel('Glomerulus');
   [trials, Group_names] = Group('all');
   set(gca,'YLim',[0 nGroups+1],'Ytick',1:nGroups,'YTickLabel',Group_names(2:end));
   ylabel('Odor');
   bgd_subtract = GetPopupmenuItem('bgd_subtract',findobj('type','figure','tag','Opt'));
   filter = GetPopupmenuItem('filter',findobj('type','figure','tag','Opt'));
   title(sprintf('filt: %s:%s Base:%d-%d Resp:%1.1f-%1.1f range=%1.4f',filter,bgd_subtract,GetParam('Opt','base_del')/2,GetParam('Opt','base_dur')/2,GetParam('Opt','resp_del')/2,GetParam('Opt','resp_del')/2+GetParam('Opt','resp_dur')/2,range));
   switch GetPopupmenuItem('normalize');
       %   case {'clip','clip+sd'}
   case 'clip'
       range = get(findobj(gcbf,'tag','range'),'string');
       text(1,nGroups+2,sprintf('range = %s',range));
   case 'glom'
       text(1,nGroups+2,sprintf('normalized by glomerulus'));
   case 'odor'
       text(1,nGroups+2,sprintf('normalized by odor'));
   case 'sel_glom'
       text(1,nGroups+2,sprintf('normalized by glom %s',GetParamList(me,'select')));
   end
   
   exper.Blob.result.x=X;
   exper.Blob.result.y=Y;
   
   
   
case 'cluster'
   [X, SX, Y, SY] = get_Blob_matrix;
   
   D = pdist(Y);
   Z = linkage(D,'ward'); 		% incremental sum of squares from adding Groups
   dendrogram(Z);
   
   
   [trials, Groupnames] = Group('all');
   order = str2num(get(gca,'XTickLabel'));
   for n=1:length(order)
       ordered_names{n} = Groupnames{order(n)+1};
   end
   set(gca,'XTickLabel',ordered_names);
   xlabel('Odor');
   ylabel('Distance');
   
   exper.Blob.result.D=D;
   exper.Blob.result.Z=Z;
   
   
   
%
% Blob('dist_geom',sweeps1,sweeps2)
%
case 'dist_geom'
   sweeps1 = varargin{2};
   sweeps2 = varargin{3};
   x = [];
   y = [];
   for k=1:length(exper.Blob.roi)
      x = [x mean(exper.Blob.roi(k).ratio(sweeps1))];
      y = [y mean(exper.Blob.roi(k).ratio(sweeps2))];
   end
   x = x/max(abs(x));
   y = y/max(abs(y));
   dist = sqrt(sum((x - y) .^ 2));
   disp(['dist: ', num2str(dist)]);
   exper.Blob.result.x=x;
   exper.Blob.result.y=y;
   exper.Blob.result.dist = dist;
   
   

   
%   
% Blob('winners',sweeps1,sweeps2...,sweepsN)	% plot Blobs as filled circles with
%										        % colors assigned to the strongest
%										        % odor (sweep) for each Blob
%
case 'winners'
   for n=1:nargin-1
	   for k=1:length(exper.Blob.roi)
	      X(n,k) = mean(exper.Blob.roi(k).ratio(varargin{n+1}));
      end
   end
   % find the winners -- largest responses for each 
   [Y I] = min(X);   
   exper.Blob.result.I=I;
   exper.Blob.result.Y=Y;
   hsv = ones(length(I),3);
   hsv(:,1) = I'/max(I);
   hsv(:,2) = 1;
%   hsv(:,2) = mod(1:length(I),2)'/2+0.5;
   %   hsv(:,3) = (Y'-min(Y))/(max(Y)-min(Y));
%   hsv(:,3) = 1.25-hsv(:,2)/2;
   hsv(:,3) = 1;
   rgb = hsv2rgb(hsv);
   exper.Blob.result.hsv = hsv;
   exper.Blob.result.rgb = rgb;
   
   for k=1:length(exper.Blob.roi)
      tag = sprintf('Blob %d',k);
      h = findobj(fig,'tag',tag);
      
      x = get(h,'xdata');
      y = get(h,'ydata');
      patch(x,y,rgb(k,:));
   end
   
%   
% Blob('map',sweeps,hue,thresh)	 plot Blobs as filled circles with
%														 color hue, only if < thresh
%														
case 'map'
      
   for k=1:length(exper.Blob.roi)
		X(k) = mean(exper.Blob.roi(k).ratio(varargin{2}));
   end
   hue = varargin{3};
   thresh = varargin{4};
   
   hsv = [hue 1 0.9];
   rgb = hsv2rgb(hsv);
   
   for k=1:length(exper.Blob.roi)
      if X(k) < thresh
         tag = sprintf('Blob %d',k);
	      h = findobj('tag',tag);
      
   	   x = get(h,'xdata');
      	y = get(h,'ydata');
         patch(x,y,rgb);
      end
   end
   exper.Blob.result.X=X;
   
%   
% Blob('imap',sweeps,range)	 plot Blobs as filled circles with
%												 fill color reflecting intensity
%												 range is [min max]
%														
case 'imap'
   
   Optical('ratio',varargin{2});
   Blob('hide');
      
   for k=1:length(exper.Blob.roi)
		X(k) = mean(exper.Blob.roi(k).ratio(varargin{2}));
   end
   range = varargin{3};
   
   cmp = jet;
   
   for k=1:length(exper.Blob.roi)
      if X(k) < range(2)
         tag = sprintf('Blob %d',k);
	      h = findobj('tag',tag);
      
   	   x = get(h,'xdata');
         y = get(h,'ydata');
         
         v = 1-((X(k)-range(1))/(range(2)-range(1)));
         if v > 1 v=1; end;
         c = round(v*(length(cmp)-1))+1;
         
         patch(x,y,cmp(c,:));
      end
   end
   exper.Blob.result.X=X;


%
% Blob('tuning',sweeps1,sweeps2,...,sweepsN)		lines connecting sweeps
%
case 'tuning'
   
   nBlob = length(exper.Blob.roi);
   for n=1:nargin-1
	   for k=1:nBlob
         X(n,k) = mean(exper.Blob.roi(k).ratio(varargin{n+1}));
      end
   end
   %   X = (1-(X-min(min(X)))/(max(max(X))-min(min(X))));
   r = [GetParam('Opt','lowrange') GetParam('Opt','highrange')];
   Y = 1-((X-r(1))/(r(2)-r(1)));
   Y(find(Y > 1)) = 1;
   Y(find(Y < 0)) = 0;

	for k=1:nBlob
   	line(1:nargin-1,X(:,k));
   end
   
   exper.Blob.result.X=X;
   exper.Blob.result.Y=Y;
   
           
otherwise	
	Message(me,'')
end


% -----------  local functions         

% begin local functions

function out = callback
	out = [lower(mfilename) ';'];

function out = me
	out = lower(mfilename); 
    
   
function stale_ratios
   % as of now, do nothing.
   
function [x,y] = new_circle(ax,pos,radius)
global exper
    
    b = length(exper.Blob.roi) + 1;
    [rx,ry] = circle(radius);
    x = pos(1,1) + rx;
    y = pos(1,2) + ry;
	exper.Blob.roi(b).x = x;
	exper.Blob.roi(b).y = y;
	exper.Blob.roi(b).ratio(1:length(exper.Opt.trial)) = 0;

	h = draw_circle(ax,b,x,y);
    
    SetParam(me,'select',num2str(b));
    exper.Blob.roi(b).recalc = 1;
    stale_ratios;
    
function h = draw_circle(ax,b,x,y)

    fig = get(ax,'parent');
    boff = 4;
    % figure out the color
    c = [0 1 0];
    menu_c = get(findobj(fig,'tag','set_Blob_color'),'user');
    if ~isempty(menu_c)
        c = menu_c;
    end
        
	h = line('xdata',x,'ydata',y,'parent',ax,'color',c,'linewidth',1,'linestyle','-','tag','Blob','user',b);

    show_labels = get(findobj(fig,'tag','Blob_labels'),'checked');
    txt=text(x(1)+boff,y(1)+boff,num2str(b),'parent',ax,'tag','Blob','user',b,'color',c,...
        'fontweight','normal','visible',show_labels);
    


    
function [x,y] = move_circle(b,pos,r)
global exper    
    boff = 4;
    [rx,ry] = circle(r);
    x = pos(1,1) + rx;
    y = pos(1,2) + ry;
	exper.Blob.roi(b).x = x;
	exper.Blob.roi(b).y = y;
	set(findobj('tag','Blob','type','line','user',b),'xdata',x,'ydata',y);
    set(findobj('tag','Blob','type','text','user',b),'pos',[x(1)+boff y(1)+boff]);
    exper.Blob.roi(b).recalc = 1;
    stale_ratios;

    
function [x,y] = circle(radius)
	% make an roi to approximate a circle
    pts = 24;
	for n=1:pts+1
        theta = n/pts * 2 * pi;
        x(n) = sin(theta)*radius;
        y(n) = cos(theta)*radius;
	end
    
function r = radius(obj)
    x = get(obj,'xdata');
    y = get(obj,'ydata');
    r = (max(x)-min(x))/2;
    
function d = distance(pos1,pos2)
    d = sqrt((pos2(1,1)-pos1(1,1))^2 + (pos2(1,2)-pos2(1,2))^2);

function pos = center(obj)
    x = get(obj,'xdata');
    y = get(obj,'ydata');
    pos(1,1) = (max(x)-min(x))/2 + min(x);
    pos(1,2) = (max(y)-min(y))/2 + min(y);
    
function Blob_stats(h)
global exper

    %tr = str2num(GetParam('Opt','trials'));
    ax = get(h,'parent');
    user = get(ax,'user');
    tr = str2num(user.trials);
    
    if length(tr) == 1
        
        x = get(h,'xdata');
        y = get(h,'ydata');
        b = get(h,'user');
        [m, s] = calc_ratio(tr,x,y);
        Message(me,sprintf('%2d: %.3g+/-%.3g%%',b,m*100,s*100));
    end
    
    
    
function print_Blob_header(fid,ind,type)
global exper

    N = length(ind);

    fprintf(fid,'Exp ID: %s\n',GetParam('Control','expid'));
    fprintf(fid,'Measure: %s\n',GetPopupmenuItem('measure'));
    switch GetPopupmenuItem('filter',findobj('type','figure','tag','Opt'))
    case 'none'
        fprintf(fid,'Filter: none\n');
    case 'bandpass'
        fprintf(fid,'Filter: bandpass (%d %d)\n',exper.Blob.lowpass, exper.Blob.highpass);
    case 'lowpass'
        fprintf(fid,'Filter: lowpass %d\n',exper.Blob.lowpass);
    case 'highpass'
        fprintf(fid,'Filter: highpass %d\n',exper.Blob.highpass);
    end
    if isfield(exper.Blob,'base_del')
        fprintf(fid,'Base: del %d, dur %d frames\n',exper.Blob.base_del,exper.Blob.base_dur);
        if strcmp(GetPopupmenuItem('measure'),'ratio')
            fprintf(fid,'Resp: del %d, dur %d frames\n',exper.Blob.resp_del,exper.Blob.resp_dur);
        else
            fprintf(fid,'Resp: each %d frames averaged\n',exper.Blob.stack);
        end 
    end
    
    if strcmp(type,'Groups')
        hstr = '\t';
    else
        hstr = '\t\t\t';
    end
    if ~strcmp(GetPopupmenuItem('measure'),'ratio') 
        hstr = [hstr '\t'];
    end
    
    fprintf(fid,[' ' hstr]);
    for k=ind
        fprintf(fid,'%d\t',ind(k));
    end
    fprintf(fid,['\nx' hstr]);
    for k=ind
        fprintf(fid,'%d\t',mean(exper.Blob.roi(ind(k)).y));
    end
    fprintf(fid,['\ndx' hstr]);
    for k=ind
        fprintf(fid,'%d\t',max(exper.Blob.roi(ind(k)).y)-min(exper.Blob.roi(ind(k)).y));
    end
    fprintf(fid,['\ny' hstr]);
    for k=ind
        fprintf(fid,'%d\t',mean(exper.Blob.roi(ind(k)).x));
    end
    fprintf(fid,['\ndy' hstr]);
    for k=ind
        fprintf(fid,'%d\t',max(exper.Blob.roi(ind(k)).y)-min(exper.Blob.roi(ind(k)).y));
    end
    fprintf(fid,'\n');
    
    if strcmp(type,'Groups')
        fprintf(fid,'Group\t');
        if ~strcmp(GetPopupmenuItem('measure'),'ratio') 
            fprintf(fid,'Frame\t'); 
        end
        for k=ind
            fprintf(fid,'Mean %d\t',ind(k));
        end
        for k=ind
            fprintf(fid,'SD %d\t',ind(k));
        end
    else
        fprintf(fid,'Trial\tGroup\tTime\t');
        if ~strcmp(GetPopupmenuItem('measure'),'ratio') 
            fprintf(fid,'Frame\t'); 
        end
        for k=ind
            fprintf(fid,'%d\t',k);   
        end
    end
    fprintf(fid,'\n');
    
    
    
function calc_ratios(tr)
global exper

   % Start with the valid trials from Group, or all the trials if these are not specified
   % Then take out the invalid trials.    
 %  trials = str2num(GetParam('Group','valid'));
 %  if isempty(trials)
 %      trials = 1:length(exper.Opt.trial);
 %  end
%   trials = Group('remove_invalid',trials);
   
% this will return only the trials that are valid and
% occur in some Group
    trials = str2num(Group('all_valid'));  
   
   % decide which Blobs we're using
   active = GetParam(me,'active');
   if ~isempty(active)
       Blob_ind = str2num(active);
   else 
       Blob_ind = 1:length(exper.Blob.roi);
   end
   
   % First, select a target image. We use the first trial selected
   % This is just used to get the size of the image when using ROIPOLY.
   
   image = exper.Opt.trial(trials(1)).rawratio.byteimage;
   
   for k=Blob_ind
       
       % Here we create matrices from the regions of interest. 
       % Note, we must use flipud because the stupid convention for displaying in matlab.
       % Tthis issue recurs whenever measuring or displaying images).
       
       roi{k} = flipud(roipoly(image,exper.Blob.roi(k).y,exper.Blob.roi(k).x));
   end
   
   
   wh = wAItbar(0,'Calculating Blobs...');
   
   high = GetParam('Opt','highpass');
   low = GetParam('Opt','lowpass');
   
   Blob_clear = [];
    % if there is a change of filters, then we must clear the whole matrix
   if ~isfield(exper.Blob,'highpass') | high ~= exper.Blob.highpass | low ~= exper.Blob.lowpass
       if strcmp(questdlg('Filter settings have changed. Clear all Blob calculations?'),'Yes')
           Blob_clear = 1:length(exper.Blob.roi);
       end    
   end
   % save the filter settings. They must be the same for all Blobs.
   exper.Blob.highpass = high;
   exper.Blob.lowpass = low;
  
   
   if ~isempty(Blob_clear)
       if ~strcmp(questdlg('Are you sure you want to erase old Blob calculations?'),'Yes')
           return;
       end
       for k=Blob_clear
           exper.Blob.roi(k).raw = [];
           exper.Blob.roi(k).high = [];
           exper.Blob.roi(k).low = [];
           exper.Blob.stack = 0;
       end
   end
   
   % the source for the signal
   calc_timecourse = strcmp(GetPopupmenuItem('source',gcbf),'timecourse');
   stack = Opt('stack');
   
   [base,resp] = Opt('windows');
   
   n=0;
   % loop over trials
   for j=trials
       

       
       if calc_timecourse
           % read from the appropriate .avi file (allowing user to select directory)
           filename = Opt('get_avi_filename',j);
           if isempty(filename)
               return
           end
           
           nframes = max(AviRead(filename))/stack;
           exper.Blob.stack = stack;
       else
           % get ratio image directly from saved Opt structure
           raw = Opt('get_rawratio',j);          
           nframes = 1;
           exper.Blob.stack = 0;
       end
       exper.Blob.nframes(j) = nframes;
       
       % get background region of interest to calculate background values below
       % this only has to be done once
       if n==0
           if ~exist('raw')
               raw = AviRead(filename,1,'avg');
           end
           bgd_roi = Opt('get_bgd_roi',raw);
       end
       
       % loop over frames
       % if not calculating time course then nframes is just 1 and this isn't really a loop
       
       % Also note that if we are calculating the full time course then we are not
       % computing the ratio, whereas if we are calculating from the images we have the ratio
       
       for f=1:nframes
       %   try
              wh=wAItbar((n*nframes+(f-1))/(length(trials)*nframes),wh);
              %   catch
           %   msgbox('User canceled. Please recalculate.')
           %   Message(me,'');
           %   return
           % end
        
            if calc_timecourse
               Message(me,sprintf('Trial %d frame %d',j,f));
               
                % read the right frames
                range = (f-1)*stack + (1:stack); 
                raw = AviRead(filename,range,'avg');
           else
               Message(me,sprintf('Trial %d',j));
           end
           drawnow
           
           % calculate background values
           exper.Blob.image_mean(j,f) = mean2(raw);
           exper.Blob.roi_mean(j,f) = mean2(raw(bgd_roi));
           
           high_image = gaussian2(high,raw);
           low_image = gaussian2(low,raw);
           
           % loop over Blobs
           for k=Blob_ind
               exper.Blob.roi(k).raw(j,f) = mean(raw(find(roi{k})));
               if high > 0
                   exper.Blob.roi(k).high(j,f) = mean(high_image(find(roi{k})));
               else
                   exper.Blob.roi(k).high(j,f) = 0;
               end
               if low > 0
                   exper.Blob.roi(k).low(j,f) = mean(low_image(find(roi{k})));
               else
                   exper.Blob.roi(k).low(j,f) = 0;
               end
           end
           
       end
       
       n=n+1;
    end
    
    % This code deals with uneven frame numbers in different trials, 
    % which may not happen often but can cause unwanted surprises if not dealt with
    
    % loop over Blobs
    max_nframes = max(exper.Blob.nframes);
    for k=1:length(exper.Blob.roi)
        
        % this may not be necessary in general:
        % trim the matrices to the length of the longest image
        exper.Blob.roi(k).high = exper.Blob.roi(k).high(:,1:max_nframes);
        exper.Blob.roi(k).low = exper.Blob.roi(k).low(:,1:max_nframes);
        exper.Blob.roi(k).raw = exper.Blob.roi(k).raw(:,1:max_nframes);

        % loop over trials
        % get rid of fake 0's in the matrix due to differing trial lengths
        % replace with NaNs
        for j=1:size(exper.Blob.roi(k).raw,1)
            nframes = exper.Blob.nframes(j);
            for i=(nframes+1):max_nframes
                exper.Blob.roi(k).high(j,i) = NaN;        
                exper.Blob.roi(k).low(j,i) = NaN;        
                exper.Blob.roi(k).raw(j,i) = NaN;        
            end
        end
    end
    
    close(wh);
    Message(me,'');
   

function [X, SX, Y, SY, Blobs] = get_Blob_matrix(Groups,Blobs,filter,bgd_subtract,measure,normalize,base,resp)
% extract values from the Blob calculation
% [X, SX, Y, SY, Blobs] = get_Blob_matrix(Groups,Blobs,filter,bgd_subtract,measure,normalize,base,resp)
%
% Input variables:
% Note. All parameters are gotten from the Blob and Opt gui's if not passed.
%   GroupS is either
%       A cell array of strings corresponding to trial indices for analysis Groups.
%       E.g. {'1 2 3','4 5 6','8'}
%       in this case, each Groups is averaged to obtAIn a single value.
%       OR
%       A numeric array of trial numbers, in which case no averaging is done and no std are calculated.
%   BlobS is an array of Blob indices.
%       An empty array [] specifies all Blobs.
%   FILTER is one of {'bandpass','highpass','lowpass','none'}, meaning
%       'none': unfiltered ratio
%       'bandpass': bandpass filtered, calculated from [lowpass - highpass]
%       'lowpass': gaussian filtered ratio, smaller kernel
%       'highpass': gaussian filtered ratio, larger kernel
%   BGD_SUBTRACT is one of {'none','roi mean','image mean'}
%       'none': no background subtraction
%       'image mean': subtract the average value of the ratio image computed across the whole image
%       'roi mean': ditto ... computed across the region of interest (ROI)
%   MEASURE is one of {'ratio','ratio_time','abs_time'}, meaning
%       'ratio': computed using ratio = resp / (base-resp)
%       'ratio_time': as for ratio but with entire time course returned (arrays have an additional dimention)
%       'abs_time': asolute values returned (arrays have an additional dimention)
%   NORMALIZE is one of {'none','Blob','Group','Blob_sel'}
%       'none': no normalization
%       'Blob': normalize each Blob to the maximum for that Blob across all Groups
%       'Group': normalize each Group to the maximum for all Blobs within that Group
%       'Blob_sel': normalize each Group to the Blob selected in the gui
%  BASE,RESP
%       each is an array of frame numbers that specifies the frames to average when calculating base and response
%
% Output variables:
%   X(Groups,Blobs) is mean values
%   SX(Groups,Blobs) is stdev values
%   Y(Groups,Blobs) is normalized mean values
%   SY(Groups,Blobs) is normalized stdev values
%   Blob is the corresponding Blob indices
%
	
	global exper
	
	% GroupS
	if nargin < 1
        % get the Groups
        Groups = Group('all'); 
        Groups = Groups(2:end);
        
        if isempty(Groups)
            Message(me,'Please add Groups!','error');
            return;
        else
            Message(me,'')
        end
	else
        % if Groups is passed as an array then convert to a cell array of
        % single values
        if ~iscell(Groups)
            for n=1:length(Groups)
                g{n} = num2str(Groups(n)); 
            end
            Groups = g;
        end
	end
	
	
	% BlobS
	if nargin < 2
        active = GetParam(me,'active');
        if ~isempty(active)
            Blobs = str2num(active);
        else 
            Blobs = 1:length(exper.Blob.roi);
        end
	end
	
	timecourse_avAIlable = 0;
	
	% Has the time course been calculated?
	if isfield(exper.Blob,'stack')
        stack = exper.Blob.stack;
        if stack > 0
            timecourse_avAIlable = 1;
        end
    else
        Message(me,'Calculate first','error');
        return
    end
	
	% FILTER SETTINGS must be checked
 
    if nargin < 3
        filter = GetPopupmenuItem('filter',findobj('type','figure','tag','Opt'));
    end

	if isfield(exper.Blob,'highpass')
        if exper.Blob.highpass ~= GetParam('Opt','highpass') | ...
                exper.Blob.lowpass ~=GetParam('Opt','lowpass')
            %warndlg(sprintf('Current Blobs are filtered at(%d %d).\nTo change, you must recalculate.',...
            %    exper.Blob.lowpass,exper.Blob.highpass),'Blob calculation warning','modal');
            Message(me,'Warning: Blob filters changed');
        end
	end
    
    % BACKGROUND SUBTRACTION
    if nargin < 4
        bgd_subtract = GetPopupmenuItem('bgd_subtract',findobj('type','figure','tag','Opt'));
    end
    
    
	% MEASURE
	if nargin < 5, measure = GetPopupmenuItem('measure'); end
	if strcmp(measure,'ratio_time') | strcmp(measure,'abs_time')
        if ~timecourse_avAIlable
            Message(me,sprintf('%s requires timecourse',measure),'error');
           return;
       else
           timecourse = 1;
       end
   else
       timecourse = 0;
   end
   
   if strcmp(measure,'abs_time')
       ratio = 0
   else
       ratio = 1;
   end
              
   % NORMALIZE
   if nargin < 6, normalize = GetPopupmenuItem('normalize'); end
   
   
   % BASE & RESP
   if nargin < 7
       if timecourse_avAIlable
           % if so, then we can compute the ratio for any base and resp
           % windows, so we can use the settings in Opt.
           base_del = GetParam('Opt','base_del');
           base_dur = GetParam('Opt','base_dur');
           
           resp_del = GetParam('Opt','resp_del');
           resp_dur = GetParam('Opt','resp_dur');
           
           exper.Blob.base_del = base_del;
           exper.Blob.base_dur = base_dur;
           exper.Blob.resp_del = resp_del;
           exper.Blob.resp_dur = resp_dur;
           
           % make sure the durations leave at least one frame
           if base_dur < stack
               warn_str = sprintf('Base duration set to minimum of %d.',stack);
               warn_h = warndlg(warn_str,'Blob get_Blob_matrix function warning');
               base_dur = stack; 
           end
           if resp_dur < stack
               warn_str = sprintf('Response duration set to minimum of %d.',stack);
               warn_h = warndlg(warn_str,'Blob get_Blob_matrix function warning');
               resp_dur = stack; 
           end
           
           resp = (resp_del/stack+1):((resp_del+resp_dur)/stack);
           base = (base_del/stack+1):((base_del+base_dur)/stack);    
       end
   end
   
   
   % FILTER & MEASURE
 
 
   warn_h = [];
   omitted_trials = [];
   om_c=0;
   
   for n=1:length(Groups)
       if timecourse_avAIlable
           check_trials = str2num(Groups{n});
           
           % make sure all the trials are actually as long as the measurement windows
           c=0;
           trials = [];
           for ch=1:length(check_trials)
               tr = check_trials(ch);
               nframes = exper.Blob.nframes(tr);
               if max(resp) <= nframes & max(base) <= nframes
                   c = c+1;
                   trials(c) = check_trials(ch);
               else
                   om_c = om_c+1;
                   omitted_trials(om_c) = check_trials(ch);
                   if ishandle(warn_h)
                       delete(warn_h);
                   end
                   warn_str = ['Omitted trials: ' sprintf('%d ',omitted_trials) 'due to base or resp windows outside valid frames!'];
                   warn_h = warndlg(warn_str,'Blob get_Blob_matrix function warning');
               end
           end
       else
           trials = str2num(Groups{n});
       end
       
       if isempty(trials)
           X(n,:,:) = NaN;
           SX(n,:,:) = NaN;
       else
           % calculate the background measurements, which are the same for all Blobs
           switch bgd_subtract
           case 'image mean'
               bgd_data = exper.Blob.image_mean;
           case 'roi mean'
               bgd_data = exper.Blob.roi_mean;
           end
           switch bgd_subtract
           case {'image mean', 'roi mean'}
               if ratio
                   if timecourse
                       denom = mean(bgd_data(trials,base),2);
                       for j=1:length(trials)
                           bgd(j,:) = bgd_data(trials(j),:) / denom(j) - 1;
                       end
                   else
                       if timecourse_avAIlable
                           bgd = mean(bgd_data(trials,resp),2) ./ mean(bgd_data(trials,base),2) - 1;
                       else
                           % in this case we are already dealing with the ratio!
                           bgd = bgd_data(trials);
                       end
                   end
               else
                   % absolute measurement (timecourse only)
                   bgd = bgd_data(trials,:);
               end
           end
           
           
           ki = 1;
           for k=Blobs
               
               switch filter
               case 'none'
                   data = exper.Blob.roi(k).raw;
               case 'bandpass'
                   data_low = exper.Blob.roi(k).low;
                   data_high = exper.Blob.roi(k).high;
                   % note, this is only used for the absolute measurement, since
                   % when computing the ratio, we do the subtraction AFTER the ratio
                   data = data_low - data_high;
               case 'highpass'
                   data = exper.Blob.roi(k).high;
               case 'lowpass'
                   data = exper.Blob.roi(k).low;
               end
               
               if ratio
                   % take the average first over the measurement windows 
                   % then compute the ratio
                   
                   if timecourse
                       if strcmp(filter,'bandpass')
                           % note, we subtract after calculating the ratio, not before
                           denom_low = mean(data_low(trials,base),2);
                           denom_high = mean(data_high(trials,base),2);
                           for j=1:length(trials)
                               meas_low(j,:) = data_low(trials(j),:) / denom_low(j) - 1;
                               meas_high(j,:) = data_high(trials(j),:) / denom_high(j) - 1;
                           end
                           meas = meas_low - meas_high;
                       else
                           denom = mean(data(trials,base),2);
                           for j=1:length(trials)
                               meas(j,:) = data(trials(j),:) / denom(j) - 1;
                           end
                       end
                   else
                       if timecourse_avAIlable
                           if strcmp(filter,'bandpass')
                               meas_high = mean(data_high(trials,resp),2) ./ mean(data_high(trials,base),2) - 1;
                               meas_low = mean(data_low(trials,resp),2) ./ mean(data_low(trials,base),2) - 1;
                               meas = meas_low - meas_high;
                           else
                               meas = mean(data(trials,resp),2) ./ mean(data(trials,base),2) - 1;
                           end
                       else
                           % in this case we are already dealing with the ratio!
                           meas = data(trials);
                       end
                   end
               else
                   % absolute measurement (timecourse only)
                   meas = data(trials,resp,:);
               end
               
               % do the background subtraction
               switch bgd_subtract
               case {'image mean', 'roi mean'}
                   meas = meas - bgd;
               otherwise
               end
               
               % now mean and SD are computed over trials
               if length(meas) > 1
                   X(n,ki,:) = mean(meas,1);
                   SX(n,ki,:) = std(meas,1);
               else
                   X(n,ki) = meas;
                   SX(n,ki) = NaN;
               end
                   
               ki=ki+1;
           end
       end
   end
   
  
   % NORMALIZATION
   switch normalize 
   case 'none'
       Y = X;
       SY = SX; 
   case 'Blob'
       for n=1:size(X,2)
           % normalize by the largest signal
           norm = max(abs(X(:,n)));
           Y(:,n) = X(:,n)/norm;
           SY(:,n) = SX(:,n)/norm;
       end
   case 'Group'
       for n=1:size(X,1)
           if ~isempty(Groups{n})
               % normalize by the largest signal
               norm = max(abs(X(n,:)));
               Y(n,:) = X(n,:)/norm;
               SY(n,:) = SX(n,:)/norm;
           end
       end
   case 'Blob_sel'
       g = str2num(GetParamList(me,'select'));
       gi = find(g==ind);
       if ~isempty(gi)
           for n=1:size(X,1)
               if ~isempty(Groups{n})
                   % normalize by a given Blob
                   norm = abs(X(n,gi));
                   Y(n,:) = X(n,:)/norm;
                   SY(n,:) = SX(n,:)/norm;
               end
           end
       end
   end  
   Message(me,'');
   
  
   
function [m, s] = calc_ratio(tr,x,y) % return mean and variance
global exper
% this function needs to be updated

    image = exper.Opt.trial(tr(1)).rawratio.byteimage;
    roi = flipud(roipoly(image,y,x));
    k = 1;
    for j=tr
        image = exper.Opt.trial(j).rawratio.byteimage;
        q = double(image(find(roi)));
        r(k) = mean(q)/exper.Opt.trial(j).rawratio.scale+exper.Opt.trial(j).rawratio.floor;
        k=k+1;
    end
    m = mean(r);
    s = std(r);
    

function update_x_plot
global exper

    module = GetParamList(me,'x_module');
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
    
    SetParam(me,'x_param','list',params,'value',1);
    str = sprintf('R(%s %s)',module,GetParamList(me,'x_param'));
    set(findobj('tag','x_plot','style','pushbutton'),'string',str);
    
    
    
function update_Groups
global exper

    SetParam(me,'s1','list',GetParam('Group','Group','list'),'value',1);
    SetParam(me,'s2','list',GetParam('Group','Group','list'),'value',1);
   
    

