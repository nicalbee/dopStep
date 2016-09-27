function dopPlotDataToggle(handle,~)
% dopOSCCI3: dopPlotDataToggle
%
% dopPlotDataToggle(handle,event);
%
% notes:
% Handles the 'dynamic legend' for the dopPlot functions. Toggles the
% 'Visible' property 'on' and 'off' depending on it's status and checkbox
% uicontrol interaction.
%
% It's a CallBack function for the checkboxes.
% 
% So, provided there aren't any problems with it, it's not something that
% people need to worry about.
%
% Created: ??-Aug-2014 NAB
% Last edit:
% 29-Aug-2014 NAB

line_handle = get(handle,'UserData');
axes_h = get(line_handle,'parent');
if iscell(axes_h)
    axes_h = axes_h{1};
    line_handle = line_handle(:);
end
xlim = get(axes_h,'Xlim');
ylim = get(axes_h,'Ylim');
switch get(line_handle(1),'Visible')
    case 'on'
        set(line_handle,'Visible','off')
    case 'off'
        set(line_handle,'Visible','on')
end
% reset this to former size - setting certain lines to invisible,
% automatically changes the plot size
set(axes_h,'Xlim',xlim,'Ylim',ylim);