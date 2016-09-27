function fig = dopPlotLegend(fig_h)
% dopOSCCI3: dopPlotLegend
%
% fig = dopPlotLegend(fig_h)
%
% Creates a 'dynamic legend' for the dopPlot graphs. Required the main
% figure handle in order to make reference to the current figure/plot, then
% creates a series of colour-coded checkbox uicontrols that toggle the
% 'Visible' property of the plotted data 'on' and 'off' dependent upon
% their status.
%
% Created: 25-Aug-2014 NAB
% Last edit:
% 29-Aug-2014 NAB

fig.h = fig_h; %figure;
% dop = get(fig.h,'UserData');

% get the axes as a reference point for the legend - probably make it a
% panel
fig.ch.h = get(fig.h,'children');
fig.axes.h = fig.ch.h(strcmp(get(fig.ch.h,'Type'),'axes'));
fig.axes.position = get(fig.axes.h,'position');
% put everything within a panel so that it's contained
fig.pan.pos = [sum(fig.axes.position([1 3]))+.015 fig.axes.position(2)];
fig.pan.size = [.125 fig.axes.position(4)];
fig.pan.position = [fig.pan.pos fig.pan.size];
fig.pan.h = uipanel('parent',fig.h,'Units','Normalized',...
    'position',[fig.pan.pos fig.pan.size],...
    'Tag','legend');

% plott data/line handles = the 'children' of the figures axes
fig.axes.ch = get(fig.axes.h,'children');

% should be 'Tag', 'DisplayName', and 'Color' properties to use
% note: 'leg' = short for 'legend' doesn't really matter what it is as the
% output is optional and isn't really needed so later reference will be
% made using the dopPlotDataToggle which is the CallBack function and
% automatically has access to the checkbox handles.
fig.leg.size = [.8 .1];
% loop through the number of lines plotted - may or may not all be visible
for i = 1 : numel(fig.axes.ch) 
    fig.leg.position(i,:) = [.1 (1/(numel(fig.axes.ch)+1))*i fig.leg.size]; % work from top down...
    
    fig.leg.h(i) = uicontrol('parent',fig.pan.h,...
        'Units','Normalized',...
        'Style','checkbox',...
        'Value',1,...
        'String',upper(get(fig.axes.ch(i),'DisplayName')),... % upper case display name
        'FontSize',12,...
        'Tag',[get(fig.axes.ch(i),'Tag'),'_check'],...
        'ForegroundColor','w',... % make the text white
        'ToolTipString',sprintf('Click to toggle visibility of ''%s'' data',get(fig.axes.ch(i),'Tag')),...
        'position',fig.leg.position(i,:),...
        'UserData',fig.axes.ch(i),... % handle for the line
        'Callback',@dopPlotDataToggle);
    % possible the line or patch will have its 'Visible' property set to
    % 'off' by default - if so, the value of the checkbox needs to be off
    % as well: i.e., set to zero.
    if strcmp(get(fig.axes.ch(i),'Visible'),'off')
        set(fig.leg.h(i),'Value',0);
    end
    % depending on the Type of component on the graph, the colour property
    % will have a different name, and, since we want the background for the
    % checkbox to match the colour of the component, we need to acess this
    % information differently
    switch get(fig.axes.ch(i),'Type')
        case 'line'
            set(fig.leg.h(i),'BackgroundColor',get(fig.axes.ch(i),'Color'));
        case 'patch'
            set(fig.leg.h(i),'BackgroundColor',get(fig.axes.ch(i),'FaceColor'));
    end
end

