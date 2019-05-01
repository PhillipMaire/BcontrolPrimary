function Message(module,text,type)

h = findobj(findobj('tag',module),'tag','Message');

% make clicking on the Message box clear it
set(h,'buttondownfcn','set(gcbo,''string'','''',''backgroundcolor'',get(gcf,''color''));');
if isempty(h)
   % if none exists, try to find a Message box for the general experiment
   h = findobj(findobj('tag','exper'),'tag','Message');
end

if nargin < 3 type = ''; end
if nargin < 2 text = ''; end

switch type
case 'clear'
   if ~isempty(h)
      set(h,'string','','backgroundcolor',get(findobj('tag',module),'color'));
   end   
case {'error','red'}
   if ~isempty(h)
      set(h,'string',text,'backgroundcolor',[1 0 0]);
   else
      disp(['Error (' module '): ' text]);
   end
case 'blue'
   if ~isempty(h)
      set(h,'string',text,'backgroundcolor',[0 0 1], 'foregroundcolor', [1 1 1]);
   else
      disp('Error: no Message box avAIlable');
   end
case 'cyan'
   if ~isempty(h)
      set(h,'string',text,'backgroundcolor',[0 1 1], 'foregroundcolor', [0 0 0]);
   else
      disp('Error: no Message box avAIlable');
   end
case 'green'
   if ~isempty(h)
      set(h,'string',text,'backgroundcolor',[0 1 0], 'foregroundcolor', [0 0 0]);
   else
      disp('Error: no Message box avAIlable');
   end
case 'normal'
   if ~isempty(h)
      set(h,'string',text,'backgroundcolor',get(findobj('tag',module),'color'), 'foregroundcolor', [0 0 0]);
   else
      disp('Error: no Message box avAIlable');
   end
   
otherwise
   if ~isempty(h)
      set(h,'string',text,'backgroundcolor',get(gcf,'color'));   
   else
      disp([text ': ' module]);
   end
end

drawnow

   
   
