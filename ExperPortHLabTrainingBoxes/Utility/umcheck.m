function state = umcheck(uimenu_handle)
%umcheck  Check the "checked" status of uimenu object.
%  umcheck(U) returns 1 if the status is 'on' and 0
%  if the status is 'off'.
%
% See also UMTOGGLE

%  Author: Z. MAInen 6-3-02
%  Copyleft Z.F. MAInen 2002

state = strcmp(get(uimenu_handle,'checked'),'on');