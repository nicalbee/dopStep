function dopPlotSetAxes(dop)
% dopOSCCI3: dopPlotSetAxes
%
% dopPlotSetAxes(dop);
%
% notes:
% Set the limits of the x axis to match the data and set the values of the
% y axis components to match the data
%
% Created: 02-Sep-2014 NAB
% Last edit:
% 02-Sep-2014 NAB

% figure out the X limits of the data, not the axes - usually a gap at
% either end that we want to remove
dop.fig.ax = get(dop.fig.h,'CurrentAxes');
dop.fig.ax_ch = get(dop.fig.ax,'Children');

% need to figure out the xdata on the graph - look for the data that's a
% line with the maximum length
len = zeros(1,numel(dop.fig.ax_ch));
for i = 1 : numel(dop.fig.ax_ch)
    % loop through each of the children on the figure axes
    if strcmp(get(dop.fig.ax_ch(i),'Type'),'line')
        % if the 'Type' property is a 'line'
        % then record the length of the XData
        len(i) = size(get(dop.fig.ax_ch(i),'XData'),2);
    end
end
% find the element that has the max length
i = find(len == max(len),1,'first');
% and use this to determine the extent of the xdata
xdata = get(dop.fig.ax_ch(i),'XData');
% then set the X limits based on the minimum and maximum of this xdata
set(dop.fig.ax,'Xlim',[min(xdata) max(xdata)],'TickDir','out');

% check to see if the figure has y axis adjustment edit boxes - if so,
% adjust the string values displayed to be the updated values
dop.fig.ch = get(dop.fig.h,'Children');
if ~isempty(strcmp(get(dop.fig.ch,'Type'),'uicontrol')) ...
        && ~isempty(strcmp(get(dop.fig.ch,'Tag'),'ylower'))
    ylim = get(dop.fig.ax,'Ylim');
    set(dop.fig.ch(and(strcmp(get(dop.fig.ch,'Type'),'uicontrol'),...
        strcmp(get(dop.fig.ch,'Tag'),'ylower'))),'string',ylim(1));
    set(dop.fig.ch(and(strcmp(get(dop.fig.ch,'Type'),'uicontrol'),...
        strcmp(get(dop.fig.ch,'Tag'),'yupper'))),'string',ylim(2));
end