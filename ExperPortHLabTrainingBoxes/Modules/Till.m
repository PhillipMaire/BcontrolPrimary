function out = Till(varargin)
% Till
% RS232 communication with Till Polychrome
% to select wavelength
%

global exper

out = lower(mfilename);
if nargin > 0
	action = lower(varargin{1});
else
	action = lower(get(gcbo,'tag'));
end

switch action
	
case 'init'
	
	fig = ModuleFigure(me,'visible','off');	
	
	SetParam(me,'priority',1);

	hs = 60;
	h = 5;
	vs = 20;
	n = 0;

    % 
    InitParam(me,'com','value',1,'list',{'com1','com2'},'ui','popupmenu','pos',[h n*vs hs vs]); n=n+1;;
    
    
    InitParam(me,'lambda','ui','edit','value',630,'save',1,'pos',[h n*vs hs vs]); n=n+1;
    
    % Message box
    uiControl('parent',fig,'tag','Message','style','edit',...
        'enable','inact','horiz','left','pos',[h n*vs hs*2 vs]); n=n+1;
    
	set(fig,'pos',[142 480-n*vs 128 n*vs],'visible','on');

case 'slice'
	
case 'trigger'
    
case 'trialend'
   	SaveParamsTrial(me);
    
case 'close'
	
case 'load'
    LoadParams(me);
	
% handle UI parameter callbacks

case 'lambda'
    set_lambda(GetParam(me,'lambda'));	
   
case 'com'
    c = instrfind('tag','Till');
    if ~isempty(c)
        fclose(c);
        delete(c);
    end
   
	   
	
otherwise
	
end

% begin local functions

function out = me
	out = lower(mfilename); 
	
function out = callback
	out = [lower(mfilename) ';'];

    
function set_lambda(x)
   	com = get_com(GetParamList(me,'com'));
    Till_str = sprintf('wl,%d;',x);
	fprintf(com,Till_str);	
    resp = fscanf(com);
    [t,r]= strtok(resp,'!');
    if isempty(t)
        Message(me,'Till did not respond','error');
    else
        Message(me,t);
        lambda = str2num(t(4:end));
        if lambda > 0
            SetParam(me,'lambda',lambda);
        end
    end
%    fclose(com);

function com = get_com(port)
	com = [];
	c = instrfind('tag','Till');
	for n=1:length(c)
		if strcmp(get(c(n),'status'),'open')
			com = c(n);
		end
	end
	if isempty(com)
%		com = serial(port,'tag','Till','terminator','cr','baudrate',19200);	
		com = serial(port,'tag','Till','baudrate',19200);	
		fopen(com);
	end
	