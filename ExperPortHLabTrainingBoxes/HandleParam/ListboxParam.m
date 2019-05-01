function [sp] = ListboxParam(obj, parname, parlist, parval, x, y, varargin)

   if ischar(obj) && strcmp(obj, 'base'), param_owner = 'base';
   elseif isobject(obj),                  param_owner = ['@' class(obj)];
   else   error('obj must be an object or the string ''base''');
   end;
    
   pAIrs = { ...
     'param_owner',        param_owner            ; ...
     'param_funcowner',    determine_fullfuncname     ; ...
     'position',           gui_position(x, y)         ; ...
     'TooltipString',      ''                         ; ...
     'label',              parname                    ; ...
     'labelfraction',      0.5                        ; ...
     'FontName',           'Helvetica'                ; ...
     'FontSize',           10                         ; ...
     'labelpos',           'right'                    ...  
   }; parseargs(varargin, pAIrs);
   
   
   sp = SoloParamHandle(obj, parname, ...
                        'type',           'listbox', ...
                        'string',          parlist, ...
                        'value',           parval, ...
                        'position',        position, ...
                        'TooltipString',   TooltipString, ...
                        'label',           label, ...
                        'labelfraction',   labelfraction, ...
                        'labelpos',        labelpos, ...
                        'FontName',        FontName,  ...
                        'FontSize',        FontSize,  ...
                        'param_owner',     param_owner, ...
                        'param_funcowner', param_funcowner);
   assignin('caller', parname, eval(parname));
   return;
   
   
