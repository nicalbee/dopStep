function fig = dopPlotComponents(fig_h,varargin)
% dopOSCCI3: dopPlotComponents
%
% create buttons to change the range of the X-axis for a plot
%
% Created: 25-Aug-2014 NAB
% Last edit:
% 25-Aug-2014 NAB
% 08-Sep-2014 NAB move y-axis components further to the left to avoid
%   interfering with y title
% 04-Dec-2016 NAB added 'poi_select',0/1 ... input for manual selection of
%   period of interest
% 03-Aug-2016 NAB added hold checkbox for y-axis during epoch scrolling

fig.h = fig_h; %figure;
dop = get(fig.h,'UserData');
fig.axes.pos = [.2 .3];
fig.axes.size = [.6 .6];

fig.axes.position = [fig.axes.pos fig.axes.size];
fig.axes.h = axes('parent',fig.h,'units','normalized',...
    'Position',fig.axes.position,...
    'TickDir','out');

% thinking about a panel but not sure
% fig.panel.x.pos = [fig.axes.pos(1)-.1 .05];
% fig.panel.x.size = [fig.axes.size(1)+.2 .1];
% fig.panel.x.position = [fig.panel.x.pos fig.panel.x.size];
% fig.panel.x.h = uipanel('parent',fig.h,...
%     'Position',fig.panel.x.position ...
%     );

%% X axis adjustment
xoff = 0;
if ~isempty(varargin) && sum(strcmp(varargin,'xoff'))
    xoff = 1;
end
fig.xbut.size = [.1 .075]; % used for y as well
if ~xoff %&& ~isempty(varargin) && ~sum(strcmp(varargin,'epoch'))
    fig.xbut.pos.x = [.15 .25 .75 .85];
    
    fig.xbut.pos.y = ones(1,numel(fig.xbut.pos.x))*(fig.axes.pos(2)-fig.xbut.size(2)-.175);
    % fig.xbut.pos(1,:) = [fig.axes.pos(1)-fig.xbut.size(1)*.5 fig.axes.pos(2)-fig.axes.pos(2)*.5];
    % fig.xbut.pos(2,:) = [sum(fig.axes.position([1 3]))-fig.xbut.size(1)*.5 fig.xbut.pos(1,2)];
    
    fig.xbut.text = {'<<','<','>','>>'};
    fig.xbut.tags = {'lowerEnd','down','up','upperEnd'};
    fig.xbut.tips = {...
        'Click to plot from the start of the data',...
        'Click to plot earlier data',...
        'Click to plot later data',...
        'Click to plot from the end of the end'};
    if ~isempty(varargin) && sum(strcmp(varargin,'epoch'))
        fig.xbut.pos.x(2:3) = [];
        tmp = {'text','tags','tips'};
        for i = 1 : numel(tmp)
            fig.xbut.(tmp{i})([1 4]) = [];
        end
    end
    for i = 1 : numel(fig.xbut.pos.x)
        fig.xbut.position(i,:) = [fig.xbut.pos.x(i)-fig.xbut.size(1)*.5 fig.xbut.pos.y(i) fig.xbut.size];
        fig.xbut.h(i) = uicontrol('parent',fig.h,'units','normalized',...
            'style','pushbutton',...
            'string',fig.xbut.text{i},...
            'tag',fig.xbut.tags{i},...
            'CallBack',@dopPlotAxesAdjust,...@dopPlotXadjust,...
            'ToolTipString',fig.xbut.tips{i},...
            'position',fig.xbut.position(i,:));
        if ~isempty(varargin) && sum(strcmp(varargin,'epoch'))
            set(fig.xbut.h(i),'CallBack', @dopPlotEpochAxesAdjust);
        end
    end
    
    fig.xedit.size = [.1 fig.xbut.size(2)];
    fig.xedit.pos.x = [.375 .5 .625];
    fig.xedit.pos.y = ones(1,numel(fig.xedit.pos.x))*fig.xbut.pos.y(1);
    
    % fig.xedit.text([1 3]) = get(fig.axes.h,'Xlim');
    % fig.xedit.text(2) = diff(fig.xedit.text([1 3]));
    fig.xedit.tags = {'lower','diff','upper'};
    fig.xedit.tips = {...
        'Enter the left/earliest point of the data to plot (in seconds)',...
        'Enter the range of the data to be plotted (in seconds) or type ''all'' as a string to display all the data (no inverted commas)',...
        'Enter the right/latest point of the data to plot (in seconds)'};
    fig.xedit.default_data([1 3]) = [(1/dop.tmp.sample_rate) size(dop.tmp.data,1)*(1/dop.tmp.sample_rate)];
    fig.xedit.default_data(2) = diff(fig.xedit.default_data([1 3]));
    % set(fig.axes.h,'Xlim',fig.xedit.default_data([1 3]),'Ylim',[-50 200]);
    if ~isempty(varargin) && sum(strcmp(varargin,'epoch'))
        fig.xedit.pos.x = .5; % fig.xedit.pos.x([1 3]) = [];
        fig.xedit.tags = {'display'};
        fig.xedit.default_data = {'mean'};
        fig.xedit.tips = {'adjust to change the data displayed'};
        %         for i = 1 : numel(tmp)
        %             fig.xbut.(tmp{i})() = [];
        %         end
    end
    
    for i = 1 : numel(fig.xedit.tags)
        fig.xedit.position(i,:) = [fig.xedit.pos.x(i)-fig.xedit.size(1)*.5 fig.xedit.pos.y(i) fig.xedit.size];
        fig.xedit.h(i) = uicontrol('parent',fig.h,'units','normalized',...
            'style','edit',...
            'string',fig.xedit.default_data(i),...
            'tag',fig.xedit.tags{i},...
            'CallBack',@dopPlotAxesAdjust,...@dopPlotXadjust,...
            'ToolTipString',fig.xedit.tips{i},...
            'UserData',fig.xedit.default_data(i),...
            'position',fig.xedit.position(i,:));
        if ~isempty(varargin) && sum(strcmp(varargin,'epoch'))
            set(fig.xedit.h(i),'CallBack', @dopPlotEpochAxesAdjust);
        end
    end
end
%% close button
fig.close.h = uicontrol('parent',fig.h,'units','normalized',...
            'style','pushbutton',...
            'string','Close',...
            'tag','close',...
            'CallBack',@dopPlotClose,...@dopPlotYadjust,...
            'ToolTipString','Click to close plot/figure',...
            'position',[.945 .015 .05 .1]);
        
        %% save button
fig.save.h = uicontrol('parent',fig.h,'units','normalized',...
            'style','pushbutton',...
            'string','Save',...
            'tag','save',...
            'CallBack',@dopPlotSave,...@dopPlotYadjust,...
            'ToolTipString','Click to save plot/figure as an image',...
            'position',[.945 .885 .05 .1]);
%% Y axis adjustment
yoff = 0;
if ~isempty(varargin) && sum(strcmp(varargin,'yoff'))
    yoff = 1;
end
if ~yoff
    fig.ybut.size = [.025 .05];
    fig.ybut.pos.x = [fig.axes.pos(1)-.12 fig.axes.pos(1)-.12+fig.ybut.size(1)*1.5];
    fig.ybut.pos.y = ones(1,numel(fig.ybut.pos.x))*(fig.axes.pos(1)+sum(fig.axes.position([1 3]))*.5);
    
    fig.ybut.text = {'+','-'};
    fig.ybut.tags = {'zoomin','zoomout'};
    fig.ybut.tips = {'Click to zoom in on the data',...
        'Click to zoom out from the data'};
    
    for i = 1 : numel(fig.ybut.text)
        fig.ybut.position(i,:) = [fig.ybut.pos.x(i) fig.ybut.pos.y(i) fig.ybut.size];
        fig.ybut.h(i) = uicontrol('parent',fig.h,'units','normalized',...
            'style','pushbutton',...
            'string',fig.ybut.text{i},...
            'tag',fig.ybut.tags{i},...
            'CallBack',@dopPlotAxesAdjust,...@dopPlotYadjust,...
            'ToolTipString',fig.ybut.tips{i},...
            'position',fig.ybut.position(i,:));
        if ~isempty(varargin) && sum(strcmp(varargin,'epoch'))
            set(fig.ybut.h(i),'CallBack', @dopPlotEpochAxesAdjust);
        end
    end
    
    fig.yedit.size = [.05 fig.xbut.size(2)];
    fig.yedit.pos.x = ones(1,2)*(fig.ybut.position(2,1) - diff([sum(fig.ybut.position(1,[1 3])) fig.ybut.position(2,1)])*.5);
    fig.yedit.pos.y = [fig.axes.position(2) sum(fig.axes.position([2 4]))];
    
    % fig.yedit.text([1 3]) = get(fig.axes.h,'Xlim');
    % fig.yedit.text(2) = diff(fig.yedit.text([1 3]));
    fig.yedit.tags = {'ylower','yupper'};
    fig.yedit.tips = {...
        'Enter the minimum value to be plotted for the y-axis',...
        'Enter the maximum value to be plotted for the y-axis'};
    fig.yedit.default_data = get(fig.axes.h,'Ylim');
    
    for i = 1 : numel(fig.yedit.tags)
        fig.yedit.position(i,:) = [fig.yedit.pos.x(i)-fig.yedit.size(1)*.5 ...
            fig.yedit.pos.y(i)-fig.yedit.size(2)*.5 fig.yedit.size];
        fig.yedit.h(i) = uicontrol('parent',fig.h,'units','normalized',...
            'style','edit',...
            'string',fig.yedit.default_data(i),...
            'tag',fig.yedit.tags{i},...
            'CallBack',@dopPlotAxesAdjust,...@dopPlotYadjust,...
            'ToolTipString',fig.yedit.tips{i},...
            'UserData',fig.yedit.default_data(i),...
            'position',fig.yedit.position(i,:));
        if ~isempty(varargin) && sum(strcmp(varargin,'epoch'))
            set(fig.yedit.h(i),'CallBack', @dopPlotEpochAxesAdjust);
        end
    end
    %% add a checkbox so that can hold y-axis between epoch scrolling
        fig.yhold.position = fig.yedit.position(1,:);
        fig.yhold.position(2) = fig.yedit.position(1,2)-.1;
        fig.yhold.h = uicontrol('parent',fig.h,'units','normalized',...
            'style','check',...
            'string','Hold y-axis',...
            'tag','yhold',...'CallBack',@dopPlotAxesAdjust,...@dopPlotYadjust,...
            'ToolTipString','Check to hold y-axis values between epoch scrolling - otherwise will adjust for the data range',...
            'position',fig.yhold.position);
        if isempty(varargin) || ~sum(strcmp(varargin,'epoch'))
            set(fig.yhold.h,'Visible','off');
        end
end
%% poi_select
if ~isempty(varargin) && sum(strcmp(varargin,'poi_select'))
    poi_select_n = find(strcmp(varargin,'poi_select'));
    poi_select_on = varargin{poi_select_n+1};
    if poi_select_on
        fig.ch.h = get(fig.h,'children');
        fig.axes.h = fig.ch.h(strcmp(get(fig.ch.h,'Type'),'axes'));
        fig.axes.position = get(fig.axes.h,'position');
        
        fig.poi_sel.pos.x = sum(fig.axes.position([1 3]))+.015;
        fig.poi_sel.pos.y = fig.axes.position(2)-.1;
        % this will be under the legend panel with dimensions:
        %   [.125 fig.axes.position(4)];
        fig.poi_sel.size = [.025 .05];% 

        
        % add two boxes for lower and upper poi
        fig.poi_sel.tags = {'poi_lower','poi_upper'};
        fig.poi_sel.tips = {...
            'Enter the lower period of interest value',...
            'Enter the upper period of interest value'};
        fig.user_data = get(fig.h,'UserData');
        
        fig.poi_sel.default_data = fig.user_data.tmp.poi;
        
        fig.poi_sel.text_h = uicontrol('parent',fig.h,'units','normalized',...
                'style','text',...
                'HorizontalAlignment','left',...
                'string','POI adjust:',...
                'position',[fig.poi_sel.pos.x fig.poi_sel.pos.y .1 .05]);
        
        for i = 1 : numel(fig.poi_sel.tags)
            fig.poi_sel.position(i,:) = [fig.poi_sel.pos.x + i*fig.poi_sel.size(1)*2 ...
                fig.poi_sel.pos.y fig.poi_sel.size];
%             fig.poi_sel.pos.y-fig.poi_sel.size(2)*.5 fig.poi_sel.size];
            fig.poi_sel.h(i) = uicontrol('parent',fig.h,'units','normalized',...
                'style','edit',...
                'string',fig.poi_sel.default_data(i),...
                'tag',fig.poi_sel.tags{i},...
                'CallBack',@dopPlotEpochPOIAdjust,...@dopPlotAxesAdjust,...@dopPlotYadjust,...
                'ToolTipString',fig.poi_sel.tips{i},...
                'UserData',fig.poi_sel.default_data(i),...
                'position',fig.poi_sel.position(i,:));
%             if ~isempty(varargin) && sum(strcmp(varargin,'epoch'))
%                 set(fig.poi_sel.h(i),'CallBack', @dopPlotEpochAxesAdjust);
%             end
        end
        
    end
end