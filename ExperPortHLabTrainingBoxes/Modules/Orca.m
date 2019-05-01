function out = Orca(varargin)
% Orca
% A module for video acquisition using the MATROX MIL-Lite 
% interface for the Hammamatsu Orca. Based on milmex.
%
% If MIL-Lite was installed with the correct default board,
% then the following is unnecessary!
%
% User should modify 'c:\program files\matrox imaging\mil\include\milsetup.h'
% to reflect the installed board
% define M_DEF_SYSTEM_TYPE          M_SYSTEM_PULSAR
% or
% define M_DEF_SYSTEM_TYPE          M_SYSTEM_ORION
% or
% define M_DEF_SYSTEM_TYPE          M_SYSTEM_METEOR_II_DIG
%
% and recompile milmex.
% 
% Also, set the Environemnt Variable (System Properties->Advanced->Environment Variables)
% MatroxBoard 
% to 
%
% MeteorIIDig
% Pulsar
% Orion
%
% as appropriate.


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
	
	SetParam(me,'priority',5);
	ModuleNeeds(me,{'Opt'});
    
	hs = 60;
	h = 5;
	vs = 20;
	n = 0;
    

	InitParam(me,'init');
	InitParam(me,'ImageBits','value',14);
	InitParam(me,'FrameRate');
	InitParam(me,'XSize');
	InitParam(me,'YSize');
	InitParam(me,'Frames');
    InitParam(me,'Board','list',{'meteor','orion'},'value',2);
    InitParam(me,'DCFPath','value',[matlabroot '\work\milmex\dcf']);
    if ~isdir(GetParam(me,'DCFPath')) & exist('milmex')
        path = uigetfolder('Select folder for DCF files...');
        SetParam(me,'DCFPath',path);
    end
    
    InitParam(me,'info');
    % this parameter is set to an array of parameter
    % values to be saved with the current .avi
    % this is done by calling Orca('set_info',ind,val) [see below]
    
    switch getenv('MatroxBoard')
    case 'MeteorIIDig'
        SetParam(me,'Board','value',1);
    otherwise
        SetParam(me,'Board','value',2);    
    end
    
    InitParam(me,'display','ui','popupmenu','list',' ','value',1,'pos',[h n*vs hs vs]); n=n+1;
    
	InitParam(me,'autoscale','ui','checkbox','value',0,'pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'thresh','ui','edit','value',0.9,'range',[0 1],'pos',[h n*vs hs vs]); n=n+1;
	InitParam(me,'imagemax');
    InitParam(me,'gAIn','ui','popupmenu','value',2,'list',{'low','normal','high'},'pos',[h n*vs hs vs],'save',1); n=n+1;
	InitParam(me,'mode','ui','popupmenu','value',4,'list',{'f1','f2','f4','f8','s1','s2','s4','s8'},'pos',[h n*vs hs vs],'save',1); n=n+1;
	InitParam(me,'hwtrigger','value',0,'pos',[h n*vs hs vs]);
    InitParam(me,'stack','ui','popupmenu','value',1,'list',{1,2,4,8,16},'pos',[h n*vs hs vs],'save',1); n=n+1;
	InitParam(me,'bin','ui','popupmenu','value',1,'list',{1,2,4,8},'pos',[h n*vs hs vs],'save',1); n=n+1;
%	InitParam(me,'exposure','ui','popupmenu','value',1,'list',{0,1,2,4,8,16,32},'pos',[h n*vs hs vs],'save',1); n=n+1;
%   InitParam(me,'exposure','value',1,'list',{0,1,2,4,8,16,32},'pos',[h n*vs hs vs],'save',1); n=n+1;

    InitParam(me,'subregion','value',[],'data',[],'save',1,'ui','edit','pos',[h n*vs hs vs]); n=n+1;

    if strcmp(action,'init')
        InitParam(me,'Acquire','ui','togglebutton','value',1,'pos',[h n*vs hs vs]); 
    	SetParamUI(me,'Acquire','string','Acquire','background',[0 1 0],'label','','pref',0);
    end

   	InitParam(me,'Overlay','ui','togglebutton','value',0,'pos',[h+hs n*vs hs vs]); n=n+1;
	SetParamUI(me,'Overlay','string','Overlay','label','','pref',0);

    if strcmp(action,'init')
    	InitParam(me,'Focus','ui','togglebutton','pos',[h+hs n*vs hs vs])
    	SetParamUI(me,'Focus','string','Focus','pref',0);
    
        uiControl(fig,'style','pushbutton','tag','grab','string','Grab',...
            'callback',[me ';'],'pos',[h n*vs hs vs]); n=n+1
    end
    
	hf = uimenu(fig,'label','File');
    uimenu(hf,'label','Open...','tag','open','callback',[me ';']);	
    
    % Message box
    uiControl('parent',fig,'tag','Message','style','edit',...
        'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1;
    
    if ~GetParam(me,'init') & strcmp(action,'init')
        milmex('init');
        SetParam(me,'init',1);
    end
    
	set(fig,'pos',[142 480-n*vs 128 n*vs],'visible','on');

    
    if strcmp(action,'init')
        if GetParam(me,'board','value') == 2
            SetParamUI(me,'gAIn','enable','off');
            SetParamUI(me,'mode','enable','off');
            Orca('mode');
        else
            Orca('mode','s1');
        end
    end
    
    
    
case 'slice'
	
case 'trialready'

    
case 'trialend'
	if GetParam(me,'Acquire')
		rate = 1/mean(diff(exper.Opt.t));
        if GetParamList(me,'bin') > 1
            exper.Opt.im = bin3(exper.Opt.im,[GetParamList(me,'bin') GetParamList(me,'bin') 1])/GetParamList(me,'stack');
        else
            if GetParamList(me,'stack') > 1
                exper.Opt.im = double(exper.Opt.im)/GetParamList(me,'stack');
            else
                exper.Opt.im = double(exper.Opt.im);
            end
        end
        save_image;
		Message(me,sprintf('%d frames, %.2f fps',length(exper.Opt.t),rate));
	end
	SaveParamsTrial(me);
    
    
case 'trialreview'
    
    
case 'trigger'
	% this is going to block Control, so should be called last
    Message(me,'Check code slice rate');
    
%    Orca('slicerate'); % ZFM ??? do we need to check slice rate here???
%    ZFM 10-02-03
    
    if ~ExistParam(me,'open') return; end
	if GetParam(me,'acquire') & GetParam(me,'open')
		Message(me,sprintf('Triggered %s',datestr(now,13)));
		f = GetParam(me,'Frames');
      [im,t] = milmex('grabframes',GetParam(me,'xsize'),GetParam(me,'ysize'),f,0,GetParamList(me,'stack'));
      subreg = GetParam(me,'subregion','rot');
      exper.Opt.im = im(subreg(1):subreg(2),subreg(3):subreg(4),:);
		exper.Opt.t = t; 
	end

		
case 'close'
    close(findobj('tag','Orca_fig'));
	Orca('quit');
	
case 'load'
    LoadParams(me);

    
% functions for reviewing data


	
% handle UI parameter callbacks


case 'bin'
    make_subregion;
    

case 'thresh'
	draw_image;
	

case 'hwtrigger'
	com1 = get_com1;
	if GetParam(me,'hwtrigger')
		fprintf(com1,'AMD E');	
	else
		fprintf(com1,'AMD N');	
	end
	
case 'gAIn'
	switch GetParamList(me,'mode')
	case {'s1'}
		com1 = get_com1;
		str = sprintf('CEG %d',GetParam(me,'GAIn','value')-1);
		fprintf(com1,str);
	otherwise
	end
	
case 'exposure'
    expos = GetParamList(me,'exposure');
	 if expos == 0
		 expos = 0.002;
	 end
    sec = floor(expos);
    msec = (expos - sec)*1000;
    minutes = floor(sec/60);
    sec = sec-minutes;
    str = sprintf('AET %d:%02d.%03d',minutes,sec,msec);
    Message(me,str);  
	fprintf(get_com1,str);

case 'slicerate'
    f = floor(GetParam('Control','trialdur')*GetParam(me,'framerate'));
	SetParam(me,'Frames',f);	
    SetParam('Opt','frames',f/GetParamList(me,'stack'));
	 
case 'autoscale'
	 if ~GetParam(me,'focus')
		 draw_image;
	 end

		
case 'mode'
    
    if GetParam(me,'board','value') == 2
        
        % pulsar or orion board
        
        path = GetParam(me,'dcfpath');
        %    base = 'rs170';
        %    base = 'TeliPulsar10bit';
        base = 'TeliPulsar';
        
%         dim = milmex('dcf',sprintf('%s\\%s.dcf',path,base));
        dim = [640,480];
        SetParam(me,'ImageBits',8);
        SetParam(me,'FrameRate',30);
        SetParam('Opt','FrameRate',30);
        Message(me,'640x480 30 fps');
        SetParam(me,'stack','list',{1,15},'value',2);
        
        SetParam(me,'Xsize',dim(1));
        SetParam(me,'Ysize',dim(2));
        SetParam(me,'subregion',[1 dim(1) 1 dim(2)]);
        SetParam(me,'Frames',floor(GetParam('Control','trialdur')*GetParam(me,'framerate')));
        SetParam(me,'ImageMax',2^GetParam(me,'ImageBits'));
%        SetParam('Opt','framerate',GetParam(me,'framerate')/GetParamList(me,'stack'));
        
    else
        % Orca board
        
        com1 = get_com1;
        path = GetParam(me,'dcfpath');
            
        base = 'g4742';
        
        % called by gui
        mode = GetParamList(me,'mode');
        
        switch mode
        case 'f1'
            dim = milmex('dcf',sprintf('%s\\%s%s.dcf',path,base,mode));
            fprintf(com1,'INI\nSSP H');
            SetParam(me,'ImageBits',12);
            SetParam(me,'FrameRate',5);
            Message(me,'Fast scan, 1280x1024');
        case 'f2'
            dim = milmex('dcf',sprintf('%s\\%s%s.dcf',path,base,mode));
            fprintf(com1,'INI\nSSP H\nSMD S\nSPX 2');
            SetParam(me,'ImageBits',12);
            SetParam(me,'FrameRate',10);
            Message(me,'Fast scan, 640x512');
        case 'f4'
            dim = milmex('dcf',sprintf('%s\\%s%s.dcf',path,base,mode));
            fprintf(com1,'INI\nSSP H\nSMD S\nSPX 4');			
            SetParam(me,'ImageBits',12);
            SetParam(me,'FrameRate',15);
            Message(me,'Fast scan, 320x256');
        case 'f8'
            dim = milmex('dcf',sprintf('%s\\%s%s.dcf',path,base,mode));
            fprintf(com1,'INI\nSSP H\nSMD S\nSPX 8');			
            SetParam(me,'ImageBits',12);
            SetParam(me,'FrameRate',30);
            Message(me,'Fast scan, 160x128');
        case 's1'
            dim = milmex('dcf',sprintf('%s\\%s%s.dcf',path,base,mode));
            fprintf(com1,'INI\nSSP S\nSMD S\nSPX 1');			
            str = sprintf('CEG %d',GetParam(me,'GAIn','value')-1);
            fprintf(com1,str);
            SetParam(me,'ImageBits',14);
            SetParam(me,'FrameRate',0.82);
            Message(me,'Slow scan, 1280x1024');
        case 's2'
            dim = milmex('dcf',sprintf('%s\\%s%s.dcf',path,base,mode));
            fprintf(com1,'INI\nSSP S\nSMD S\nSPX 2');			
            str = sprintf('CEG %d',GetParam(me,'GAIn','value')-1);
            fprintf(com1,str);
            SetParam(me,'ImageBits',14);
            SetParam(me,'FrameRate',1.6);
            Message(me,'Slow scan, 640x512');
        case 's4'
            dim = milmex('dcf',sprintf('%s\\%s%s.dcf',path,base,mode));
            fprintf(com1,'INI\nSSP S\nSMD S\nSPX 4');			
            str = sprintf('CEG %d',GetParam(me,'GAIn','value')-1);
            fprintf(com1,str);
            SetParam(me,'ImageBits',14);
            SetParam(me,'FrameRate',3.0);
            Message(me,'Slow scan, 320x256');
        case 's8'
            dim = milmex('dcf',sprintf('%s\\%s%s.dcf',path,base,mode));
            fprintf(com1,'INI\nSSP S\nSMD S\nSPX 8');			
            str = sprintf('CEG %d',GetParam(me,'GAIn','value')-1);
            fprintf(com1,str);
            SetParam(me,'ImageBits',14);
            SetParam(me,'FrameRate',5.2);
            Message(me,'Slow scan, 160x128');
          otherwise
        end
    end
    
	SetParam(me,'Xsize',dim(1));
	SetParam(me,'Ysize',dim(2));
	SetParam(me,'subregion',[1 dim(1) 1 dim(2)]);
	SetParam(me,'Frames',floor(GetParam('Control','trialdur')*GetParam(me,'framerate')));
	SetParam(me,'ImageMax',2^GetParam(me,'ImageBits'));
    make_subregion;
    Orca('slicerate');
    Opt('slicerate');

		

% handle UI button callbacks


case 'open'
	prompt = 'Open tif file...';
	filetype = '*.tif';
	filterspec = [GetParam('Control','datapath') '\' filetype];
	[filename, pathname] = uigetfile(filterspec, prompt);
	if filename == 0 return; end

	exper.Opt.grab = double(imread([pathname filename]));
	draw_image;
    SetParam(me,'subregion','value',[1 size(exper.Opt.grab,1) 1 size(exper.Opt.grab,2)]);
    make_subregion;	
	

case 'focus'
	if nargin > 1
		SetParam(me,'focus',varargin{2});
	end
	if GetParam(me,'focus')
        make_subregion;
		SetParamUI(me,'focus','BackgroundColor',[1 0 0]);
        SetParamUI(me,'gAIn','Enable','off');
        SetParamUI(me,'mode','Enable','off');
        if ExistParam('Till')
            Till('on',1);
        end
		focus;
	else
		close(findobj('type','figure','tag','Orcafocus','name','Focus'));
		SetParamUI(me,'focus','BackgroundColor',get(gcf,'Color'));
%        if GetParam(me,'board','board') == 2
        if GetParam(me,'board','value') == 1
            SetParamUI(me,'gAIn','Enable','on');
            SetParamUI(me,'mode','Enable','on');
        end
        if ExistParam('Till')
            Till('on',0);
        end
	end
	
	
case 'acquire'
	if nargin > 1
		SetParam(me,'acquire',varargin{2});
	end
	if GetParam(me,'acquire') 
		SetParamUI(me,'acquire','background',[0 1 0]);
	else
		SetParamUI(me,'acquire','background',get(gcf,'color'));
	end
	
case 'overlay'
	if nargin > 1
		SetParam(me,'overlay',varargin{2});
	end
	if GetParam(me,'overlay') 
		SetParamUI(me,'overlay','background',[0 1 0]);
	else
		SetParamUI(me,'overlay','background',get(gcf,'color'));
	end
	if ~GetParam(me,'focus')
		draw_image;
	   if ~isempty(exper.Opt.ratio)
			Opt('draw_ratio');
		end
	end

	
case 'subregion'
    % called from the edit box
    subreg = str2num(get(gcbo,'string'));
    SetParam(me,'subregion','value',subreg);    
    make_subregion;
    
case 'subreg_set'
    ax = findobj('tag','Orca_axes');
    subx = round(get(ax,'xlim'))*GetParamList(me,'bin');
    suby = round(get(ax,'ylim'))*GetParamList(me,'bin');
    subx(2) = subx(2)+1;
    suby(2) = suby(2)+1;
    SetParam(me,'subregion','value',[subx suby]);
    make_subregion;
    
case 'subreg_clear'
    set(gcbo,'checked','off');
    SetParam(me,'subregion','value',[1 GetParam(me,'xsize') 1 GetParam(me,'ysize')]);
    make_subregion;
    
case 'grab'
   make_subregion;
   grab_image;
   store_image;
   
case 'draw'
    draw_image;
	
	
% external functions

case 'set_info'
    % used to save parameter values 
    % called as 
    % Orca('set_info',index,value)
    
    index = varargin{2};
    value = varargin{3};
    % at the moment we cannot deal with arrays as paramters!
    if length(value) > 1
        value = value(1);
    end
    info = GetParam(me,'info');
    info(index) = value;
    SetParam(me,'info',info);

case 'reset'
	Orca('mode');
   ClearParamTrials(me);
   SetParam(me,'display','list','','value',1);

	Message(me,'');


case 'com'
		com1 = get_com1;
		fprintf(com1,varargin{2});
		varargout{1} = fscanf(com1)

case 'dcf'
		milmex('dcf',varargin{2});
		
case 'display'
	recall_image(str2num(GetParamList(me,'display')));
   draw_image;
	
otherwise
	
end

% begin local functions

function out = me
	out = lower(mfilename); 
	
function out = callback
	out = [lower(mfilename) ';'];

function h=focus
global exper

    h=findobj('type','figure','name','Orca','tag','Orca_fig');

    [im,t0] = milmex('grabframes',GetParam(me,'xsize'),GetParam(me,'ysize'),1);
    subreg = GetParam(me,'subregion','rot');
    im = im(subreg(1):subreg(2),subreg(3):subreg(4));

	[img, a] = draw_image(double(im));
	
	while GetParam(me,'focus')
      [im,t1] = milmex('grabframes',GetParam(me,'xsize'),GetParam(me,'ysize'),1,1);
      im = double(im(subreg(1):subreg(2),subreg(3):subreg(4)));
		if GetParamList(me,'bin') > 1
			im = bin2(im,GetParamList(me,'bin'));
		end
		if GetParam(me,'autoscale')
			clim = [0 max2(im)];
		else
			clim = [0 GetParam(me,'ImageMax')];
		end
		set(a,'clim',clim);
    
		if GetParam(me,'overlay')
			mask = find(im > GetParam(me,'thresh')*max2(im));
			im(mask) = clim(2);
		end
		set(img,'cdata',rot90(im,-1),'parent',a,'tag','Orca_image','cdatamapping','scaled');
		dt = t1-t0;
		t0 = t1;
		Message(me,sprintf('%02.4g fps',1/dt));
	end
    
function grab_image
global exper
%    if GetParam(me,'review')
%        return
%    end
	Message(me,sprintf('Grabbing %d...',GetParamList(me,'stack')));
	subreg = GetParam(me,'subregion','rot');
	im = milmex('grabframes',GetParam(me,'xsize'),GetParam(me,'ysize'),GetParamList(me,'stack'),0,GetParamList(me,'stack'));
	exper.Opt.im = im(subreg(1):subreg(2),subreg(3):subreg(4));
	if GetParamList(me,'bin') > 1
		exper.Opt.im = bin2(exper.Opt.im,GetParamList(me,'bin'));
	end
	exper.Opt.grab = double(exper.Opt.im) / GetParamList(me,'stack');
	Message(me,'done.');

	draw_image;
	
	
function [img, a, h] = draw_image(im)
global exper

	if nargin < 1
		im = exper.Opt.grab;
	end
	
	h=findobj('type','figure','name','Orca','tag','Orca_fig');
	if isempty(h)
		[h,a] = make_Orca_fig;
	else
        a = findobj(h,'tag','Orca_axes');
    end
	if isempty(a)
		delete(h);
		[h, a] = make_ratio_fig;
	end
	
	img = findobj(a,'tag','Orca_image');
	if isempty(img)
		img = image('parent',a,'tag','Orca_image');
	end
	
 	if GetParam(me,'autoscale')
		clim = [min2(im) max2(im)];
	else
		clim = [0 GetParam(me,'imagemax')];
	end
	set(a,'clim',clim);
	if GetParam(me,'overlay')
		
%		exper.Opt.mask = 1 - makemask(im, GetParam(me,'thresh'));
%		im = im + exper.Opt.mask .* clim(2);
%		im(im > GetParam(me,'thresh')) = clim(2);
		exper.Opt.mask = find(im > GetParam(me,'thresh')*max2(im));
		im(exper.Opt.mask) = clim(2);
    end
    
    set(img,'cdata',rot90(im,-1),'parent',a,'tag','Orca_image','cdatamapping','scaled');

    subreg = GetParam(me,'subregion')/GetParamList(me,'bin');
    set(a,'xtickmode','auto','ytickmode','auto');
  	set(a,'xlim',[1 subreg(2)-subreg(1)],'ylim',[1 subreg(4)-subreg(3)]);
    set(a,'xticklabel',(get(a,'xtick')+subreg(1))*GetParamList(me,'bin')-1);
    set(a,'yticklabel',(get(a,'ytick')+subreg(3))*GetParamList(me,'bin')-1);


function store_image
global exper
    exper.Opt.trial(GetParam('Control','trial')).grab = compress(exper.Opt.grab,'uint16');
	update_display_list;
	
	letter = 97; % a
	filename = sprintf('%s\\%s%03d%s.tif',GetParam('Control','datapath'),GetParam('Control','expid'),GetParam('Control','trial'),letter);
    fid = fopen(filename);
	while fid > -1      
		letter = letter+1;        
		if letter > 122
			Message(me,'File NOT saved','error');
			return
		end
        fclose(fid);
		filename = sprintf('%s\\%s%03d%s.tif',GetParam('Control','datapath'),GetParam('Control','expid'),GetParam('Control','trial'),letter);
        fid = fopen(filename);
	end
	imwrite(uint16(exper.Opt.grab),filename,'tiff','compression','none');
	Message(me,sprintf('%s',filename));

    
function [h, a] = make_Orca_fig
    h = figure('name','Orca','tag','Orca_fig','number','off','doublebuffer','on','deletefcn',[me '(''focus'',0);']);
	 a = axes('climmode','manual','DataAspectRatioMode','manual','visible','on','tag','Orca_axes',...
        'position',[0.05 0.05 0.95 0.95]);
	 colormap(gray_plus_red);
    m1 = uimenu(h,'label','Orca');
    m2 = uimenu(m1,'label','Subregion set','tag','subreg_menu','callback',[me '(''subreg_set'');']);
    m2 = uimenu(m1,'label','Subregion reset','tag','subreg_menu','callback',[me '(''subreg_clear'');']);

	 
function recall_image(trial)
global exper
	read_file = 1;
	if trial <= length(exper.Opt.trial)
		if ~isempty(exper.Opt.trial(trial).grab)
	    	exper.Opt.grab = expand(exper.Opt.trial(trial).grab);
			read_file = 0;
			Message(me,sprintf('%d',trial));
		end
	end
	if read_file
		filename = sprintf('%s\\%s%03d.avi',GetParam('Control','datapath'),...
			GetParam('Control','expid'),GetParam('Orca','display'));
	
		f = fopen(filename);
		if f == -1
			Message(me,'No such image','error');
			return;
		end
		fclose(f);
		exper.Opt.grab = double(imread(f));
		exper.Opt.trial(trial).grab = compress(exper.Opt.grab,'uint16');
		update_display_list;
		Message(me,filename);
	end
	
	draw_image;
    
    
function make_subregion
global exper

    subval = GetParam(me,'subregion');
    if isempty(subval)
        subval = [1 GetParam(me,'xsize') 1 GetParam(me,'ysize')];
    end

    subval = max(subval,1);
    subval(2) = min(subval(2),GetParam(me,'xsize'));
	subval(4) = min(subval(4),GetParam(me,'ysize'));
    
    subval(2) = subval(2) - mod(subval(2)-subval(1)+1,8*GetParamList(me,'bin'));
    subval(4) = subval(4) - mod(subval(4)-subval(3)+1,8*GetParamList(me,'bin'));

    SetParam(me,'subregion',subval);
    
    rot_subreg = subval;
    rot_subreg(1) = GetParam(me,'xsize')-subval(2)+1;
    rot_subreg(2) = GetParam(me,'xsize')-subval(1)+1;
    
    SetParam(me,'subregion','rot',rot_subreg);

%    grab_image;
 
    subval = subval/GetParamList(me,'bin');

    xlim = [subval(1) subval(2)];
    ylim = [subval(3) subval(4)];
    
    
    a1 = findobj('tag','Orca_axes');
    set(a1,'xlim',xlim,'ylim',ylim);
    a2 = findobj('tag','Opt_axes');
    set(a2,'xlim',xlim,'ylim',ylim);
    
    Orcaf = findobj('tag','Orca_fig');
    Optf = findobj('tag','Opt_ratio_fig');
    p = get(Orcaf,'pos');
    if ~isempty(p)
        p(1:2) = p(1:2)-50;
        set(Optf,'pos',p);
    end
     
            
function save_image
global exper
	info.rate = 1/mean(diff(exper.Opt.t));
	info.avg = 1;
	info.vec = zeros(1,256);
    s = min(256,length(exper.Opt.t));
	info.vec(1:s) = exper.Opt.t(1:s);
   
    p = GetParam(me,'info');
    info.param = zeros(1,256);
    info.param(1,1:length(p)) = p;
    
	% now write compressed movie
	filename = sprintf('%s\\%s%03d.avi',GetParam('Control','datapath'),...
	GetParam('Control','expid'),...
	    GetParam('Control','trial'));
	
	Message(me,sprintf('Writing %s%03d.avi...',GetParam('Control','expid'),...
		GetParam('Control','trial')));
	AviWrite(exper.Opt.im,filename,info);   
	Message(me,'');

            
	
function update_display_list
global exper
	k=1;
    list = '';
	if length(exper.Opt.trial) 
 		for n=1:length(exper.Opt.trial)
			if isfield(exper.Opt.trial(n),'grab')
                if ~isempty(exper.Opt.trial(n).grab)
    				list{k} = sprintf('%d',n);
				    k=k+1;
                end
			end
		end
		SetParam(me,'display','list',list,'value',GetParam('Control','trial'));
    else
        SetParam(me,'display','list',' ','value',1);
    end
	 
    
function b = bin_image(a)

    if GetParamList(me,'bin') > 1
        if size(a,3) > 1
            b = bin3(a,[GetParamList(me,'bin') GetParamList(me,'bin') GetParamList(me,'stack')]);
        else
            b = bin2(a,GetParamList(me,'bin'));
        end
    else
        if GetParamList(me,'stack') > 1
            b = stack(a,GetParamList(me,'stack'));
        else
            b = a;
        end
    end

	 
function out = makemask(inimage, cutoff)

% makemask takes a uint16 tif image and converts it into a binary bitmap
% where brightest values are set to zero
% cutoff is 0 to 1

dimage = double(inimage)/255;  % converto uint16 to double

m2 = min2(dimage);
scaledimage = (dimage-min(min(dimage)))./((max(max(dimage))-min(min(dimage))));


out = -(double(im2bw(scaledimage,cutoff))-1);

	 

function com1 = get_com1	
	com1 = [];
		c = instrfind('tag','Orca');
		for n=1:length(c)
			if strcmp(get(c(n),'status'),'open')
				com1 = c(n);
			end
		end
		if isempty(com1)
			com1 = serial('com1','tag','Orca','terminator','cr');	
			fopen(com1);
		end
	