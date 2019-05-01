function [] = panel_resize_workaround(varargin)

   myhP = findobj(gcf, 'Tag', 'ContAInerPanel');
   set(myhP, 'Units', 'pixels');
   set(myhP, 'Units', 'normalized');
