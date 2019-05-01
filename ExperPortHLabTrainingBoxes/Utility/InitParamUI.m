function h = InitParamUI(module,param,style,fig)
% InitParamUI
% Create a ui associated with a PARAM and MODULE.
%
% H = InitParamUI(MODULE,PARAM,STYLE,[FIG])
%
% Can handle most of the uiControle types and
% also uimenus (both single items and lists).
% PARAM and MODULE are strings
% STYLE is a string that corresponds to one of the
% uiControl types:
% pushbutton | togglebutton | raDiobutton | checkbox 
% edit | slider | listbox | popupmenu
% or 
% disp (which is like edit, but inactive, for display)
% or
% menu (which is another way of handling a LIST type param)
%
%
% ZF MAINEN, CSHL, 8/00
% LH TAI Modified 092102
% CD Brody Modified 13-Aug-05
%
   
global exper

if nargin < 4
    figs = findobj('tag',module,'type','figure');
    if isempty(figs)
    	fig = ModuleFigure(module);	
    else
    	fig = figs(1); % only work on the first figure found
    end
end
bc = get(fig,'color');
p = GetP(sprintf('exper.%s.param.%s',module,param));
hP = findobj(fig, 'Tag', 'ContAInerPanel');
if strcmp(style,'menu')
	% we have a uimenu rather than a uiControl
	% a list sets the entire menu list
	h = uimenu(fig,'label',p.name);
	sf = sprintf('exper.%s.param.%s',module,param);
	SetP(sf,'h',h);
	for x=1:length(p.list)
		uimenu(h,'tag',p.name,'label',p.list{x},'callback','FigHandler;','parent',h);
	end 
else
	switch style
	case 'edit'
		h = uiControl('style','edit','horizontal','right','backgroundcolor',[1 1 1], 'Parent', hP);
	case 'disp'
		h = uiControl('style','edit','enable','inactive','horizontal','right','background',bc, 'Parent', hP);
	case {'toggle', 'togglebutton'}
		h = uiControl('style','togglebutton','string',param, 'Parent', hP);		
	case 'checkbox'
		h = uiControl('style','checkbox','background',bc, 'Parent', hP);
	case 'listbox'
		h = uiControl('style','listbox', 'Parent', hP);			
	case 'popupmenu'
		h = uiControl('style','popupmenu','background',[1 1 1], 'Parent', hP);
	case 'slider'                                                       %010303 by Lung-HAO TAI
%         h = uiControl('style','slider','max',p.range(2),'min',p.range(1));
        h = uiControl('style','slider', 'Parent', hP);
    case 'pushbutton'                                                   %092102 by Lung-HAO TAI
        h=uiControl('style','pushbutton','background',bc, 'Parent', hP);
    case 'raDiobutton'                                                  %092102 by Lung-HAO TAI
        h=uiControl('style','raDiobutton','background',bc, 'Parent', hP);
    otherwise;
		Message(sprintf('Style %s not implmented for paramui''s',style),'error');
	end
	set(h,'tag',param,'callback','FigHandler;');

% add a preference editor
    hhp=uiControl('parent',hP,'style','pushbutton','tag',param,...
		'callback','EditParam','user',h,'background',bc);
	
% add a label 
switch param
case 'Sequence'
	ht=uiControl('parent',hP,'string',param,'style','text',...
		'horiz','left','user',h,'background',bc);
otherwise
	ht=uiControl('parent',hP,'string',param,'style','text',...
		'horiz','left','user',h,'background',bc);
end
	
end
sf = sprintf('exper.%s.param.%s',module,param);
SetP(sf,'h',h);


