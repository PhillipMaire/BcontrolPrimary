function [aAOut1, AOut2] = lunghAO1_gui_AOutchange_callback(lh1, varargin)

    fignum = get(lh1, 'UserData');
    udata = get(fignum, 'UserData');
    for i=1:size(udata,1),
        eval([udata{i,1} ' = udata{i,2};']);
    end;
    
    AOut1 = GetTagVal(lh1, 'AOut1');
    AOut2 = GetTagVal(lh1, 'AOut2');
    
    set(AOutbutton, 'String', sprintf('AOut= %.1f  %.1f', AOut1, AOut2));
    drawnow;

    if nargout>0, aAOut1 = AOut1; end;
 
        