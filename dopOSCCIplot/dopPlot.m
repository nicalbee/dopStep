function [dop,okay,msg] = dopPlot(dop_input,varargin)
% dopOSCCI3: dopPlot
%
% [dop,okay,msg] = dopPlot(dop,[okay],[msg],varargin);
%
% notes:
% dopOSCCI plotting function - all currently (23-Aug-2014) handled by this
% function. This can be called at any point during the processing and it
% should produce a corresponding graph. For the 'continuous' (non-epoched)
% data this displays data from the start of the current data to the end,
% typically 3 channels (left, right, and events).
% After epoching, it's the average of of the 'dop.epoch.screen' selected
% epoched (by default, screened for length, activation extremes, and
% activation separation).
%
% Use:
%
% [dop,okay,msg] = dopPlot(dop,[...]);
%
% where:
% > Inputs:
% - dop_input = dop matlab structure
%
% Optional inputs:
% - okay = logical (0 or 1) for problem, 1 = okay/no problem, 0 = not okay/problem
% - msg = message about progress/steps within function
%   note: 'okay' and 'msg' are optional inputs but must be included as the
%   first two inputs after the 'dop_input' variable - otherwise they won't
%   be recognised
%
% Name + value inputs:
% note: if the variable name string is recognised as an input, the next
%   input will be set as its value. For example, ...,'name',value,...
%   These can be included in any order
%
% - 'type' = the data type that will be plotted, e.g., 'raw', 'channel',
%   'trim', 'norm', 'hc_correct', 'hc_linspace', 'epoch', or 'base'
%   By default (i.e., no 'type' input), the current data type will be used.
%   This is set by the 'dopUseDataOperations' function which sets the
%   'dop.data.use' and 'dop.data.use_type' variables.
%
% - 'epoch' = lower and upper epoch limits in seconds
%   e.g., ...,'epoch',[-15 30],...
%
% - 'poi' = lower and upper period of interest limits in seconds
%   e.g., ...,'poi',[5 20],...
%
% - 'baseline' = lower and upper baseline period limits in seconds
%   e.g., ...,'baseline',[-10 0],...
%
% - 'act_window' = activation window duration in seconds
%   e.g., ...,'act_window',2,...
%
% Turn On inputs:
% note: if included, the values for these variables will be 'turned on' to
%   1, otherwise their value will be 0.
%
% - 'collect' = included as a string this will plot the 'collected' data -
%   a copy of the average for each file when multiple files are looped
%   through. See the 'dopDataCollect' function
%
% > Outputs:
% - dop = dop matlab sructure
%   includes 'dop.fig.h' related to the 'dopPlot' function which
%   corresponds to the figure handle.
%
% - okay = logical (0 or 1) for problem, 1 = okay/no problem, 0 = not okay/problem
% - msg = message about progress/steps within function
%
% Created: 11-Aug-2014 NAB
% Last edit:
% 23-Aug-2014 NAB
% 01-Sep-2014 NAB updated default 'type' for 'use' - what ever the current
%   data type is
% 02-Sep-2014 NAB updated for epoch axes adjustment
% 04-Sep-2014 NAB msg & warn_wait
% 05-Sep-2014 NAB starting save routine
%   made sure 'collect' data is passed to the figure 'UserData'
% 10-Nov-2014 NAB updated to skip 'collect' plot if data doesn't exist
% 17-Nov-2014 NAB moved the dopPlotName above the 'epoch' check - caused a
%   labelling issue
% 27-Jan-2015 NAB fixed activation window when peak occurs at the end of
%   data: ie calculation was based on data earlier then the peak rather
%   than surrouding the peak
% 13-May-2015 NAB fixed defaulting to use_type instead of 'type' input
% 29-Jun-2015 NAB fixed up 'collect' + 'type' input
% 15-Sep-2015 NAB copes with multiple periods of interest (poi) but only by
%   using the last one = final row. Not perfectly sure how to do with this

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        inputs.turnOn = {'collect','save','wait'};
        %         inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'msg',1,... % show messages
            'wait_warn',0,... % wait to close warning dialogs
            'type','use',...
            'epoch',[], ... %
            'poi',[],... %
            'baseline',[],...
            'act_window',2,...
            'sample_rate',[], ... %
            'position',[.1 .3 .8 .3] ... % figure position
            );
        inputs.defaults.ep_vis = {'left','right','difference'};
        inputs.required = [];...
            %         {'data_type'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        %% which type
        if dop.tmp.collect
            if ~isfield(dop,'collect') || ~isfield(dop.collect,dop.tmp.type)
                okay = 0;
                msg{end+1} = sprintf('Can''t find ''dop.collect'' or ''dop.collect.%s variable',dop.tmp.type);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            else
                dop.tmp.data = dop.collect.(dop.tmp.type).data;
                msg{end+1} = sprintf('Plotting collected data, type ''%s'' set',dop.tmp.type);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
        elseif strcmp(dop.tmp.type,dop.tmp.defaults.type) && ...
                isfield(dop.data,'use_type')
            % dop.data.use_type is the currently used data variable
            dop.tmp.type = dop.data.use_type;
            dop.tmp.data = dop.data.use;
            msg{end+1} = sprintf('Default type variable ''%s'' set',dop.tmp.type);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        elseif ~strcmp(dop.tmp.type,dop.tmp.defaults.type) && isfield(dop.data,dop.tmp.type)
            dop.tmp.data = dop.data.(dop.tmp.type);
            %             dop.tmp.type = dop.data.use_type; % default data
            msg{end+1} = sprintf('Type variable inputted ''%s'' and data found',dop.tmp.type);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        elseif ~isempty(dop.tmp.type)
            okay = 0;
            msg{end+1} = sprintf('Can''t find ''dop.data.%s'' variable',dop.tmp.type);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        else
            okay = 0;
            msg{end+1} = '''dop.data.use_type'' variable unspecified - can''t identify the data';
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        
        if okay
            %             dop.tmp.data = dop.data.(dop.tmp.type);
            
            
            % open the figure
            dop.fig.h = figure('Units','Normalized',...
                'Position',dop.tmp.position,...
                'NumberTitle','off',...
                'Name',dopPlotName(dop),...
                'UserData',dop);
            % moved this below the dopPlotName function - 'epoch_norm'
            % doesn't exist in the data
            switch dop.tmp.type
                case 'norm'
                    if isfield(dop,'event') && size(dop.tmp.data,2) == dop.event.n
                        dop.tmp.type = 'epoch_norm';
                    end
            end
            %             dopPlotAxes(dop.fig.h);
            %             dopPlotXbuttons(dop.fig.h);
            
            switch dop.tmp.type
                case {'raw','channels','norm','down','trim','hc_data',...
                        'hc_correct','hc_linspace','act_correct','event',...
                        'act_correct_plot','clip'}
                    dopPlotComponents(dop.fig.h);
                    
                    dop.fig.ch = get(dop.fig.h,'children');
                    dop.fig.ax = dop.fig.ch(strcmp(get(dop.fig.ch,'Type'),'axes'));
                    dop.fig.xdata = (1/dop.tmp.sample_rate):(1/dop.tmp.sample_rate):size(dop.tmp.data,1)*(1/dop.tmp.sample_rate);
                    if isfield(dop,'data') && isfield(dop.data,'channel_labels') && size(dop.tmp.data,2) <= numel(dop.data.channel_labels);
                        if ~isfield(dop,'data') && ~isfield(dop.data,'channel_colours')
                            dop.data.channel_colours = {'b','r','g'};
                        end
                        for i = 1 : size(dop.tmp.data,2)
                            dop.tmp.ev_plot = [dop.data.channel_labels{i},'_plot'];
                            dop.tmp.ev_patch = [dop.data.channel_labels{i},'_patch'];
                            if numel(unique(dop.tmp.data(:,i))) == 2 && ...
                                    or(isfield(dop.data,dop.tmp.ev_plot),...
                                    isfield(dop.data,dop.tmp.ev_patch))
                                if isfield(dop.data,dop.tmp.ev_patch)
                                    ydata = ones(4,size(dop.data.(dop.tmp.ev_patch),2));
                                    ydata = bsxfun(@times,ydata,[ones(1,2)*max(get(dop.fig.ax,'Ylim')) ones(1,2)*min(get(dop.fig.ax,'Ylim'))]');
                                    patch(dop.data.(dop.tmp.ev_patch),...
                                        ydata,dopPlotColours(dop.data.channel_labels{i}),...
                                        'FaceAlpha',.3,'EdgeAlpha',0,...
                                        'Parent',dop.fig.ax,...
                                        'EdgeColor',dopPlotColours(dop.data.channel_labels{i}),...
                                        'Tag',dop.data.channel_labels{i},...
                                        'DisplayName',dop.data.channel_labels{i});
                                    
                                else
                                    % event data has been set to ones and zeros
                                    dop.tmp.events = find(dop.tmp.data(:,i));
                                    dop.tmp.ylim = get(dop.fig.ax,'Ylim');
                                    %                                 for j = 1 : numel(dop.tmp.events)
                                    plot(dop.data.(dop.tmp.ev_plot)(:,2)*(1/dop.tmp.sample_rate),...
                                        dop.data.(dop.tmp.ev_plot)(:,1)*max(dop.tmp.ylim),....
                                        'color',dopPlotColours(dop.data.channel_labels{i}),...dop.data.channel_colours{i},...
                                        'Tag',dop.data.channel_labels{i},...
                                        'DisplayName',dop.data.channel_labels{i});
                                    %                                 end
                                end
                            else
                                plot(dop.fig.xdata,...
                                    dop.tmp.data(:,i),...
                                    'color',dopPlotColours(dop.data.channel_labels{i}),...dop.data.channel_colours{i},...
                                    'Tag',dop.data.channel_labels{i},...
                                    'DisplayName',dop.data.channel_labels{i});
                            end
                            if i == 1; hold; end
                        end
                        dopPlotLegend(dop.fig.h);
                    else
                        
                        plot(dop.fig.ax,dop.fig.xdata,dop.tmp.data);
                        dop.tmp.ch = get(dop.fig.ax,'children');
                        for k = 1 : numel(dop.tmp.ch) % size(dop.tmp.data,2)
                            dop.tmp.diplay_name = sprintf('column_%u',k);
                            if isfield(dop.data,'file_info') && isfield(dop.data.file_info,'dataLabels') ...
                                    && numel(dop.data.file_info.dataLabels) >= k
                                dop.tmp.display_name = dop.data.file_info.dataLabels{k};
                            end
                            set(dop.tmp.ch(numel(dop.tmp.ch)+1-k),'DisplayName',dop.tmp.display_name);
                        end
                        dopPlotLegend(dop.fig.h);
                    end
                    set(get(dop.fig.ax,'YLabel'),'string','Blood Flow Velocity');
                    set(get(dop.fig.ax,'XLabel'),'string','Recording time in seconds');
                    dopPlotSetAxes(dop);
                    if dop.tmp.wait; uiwait(dop.fig.h); end
                    %% Epoched Plot
                case {'epoch','base','epoch_norm'};
                    dopPlotComponents(dop.fig.h,'epoch'); % needs more work
                    dop.fig.ax = get(dop.fig.h,'CurrentAxes');
                    
                    %% > check scaling of data is around zero
                    if dop.tmp.collect || ~isfield(dop,'epoch') || ~isfield(dop.epoch,'screen')
                       dop.plot.screen = true(1,size(dop.tmp.data,2));
                        msg{end+1} = 'No ''dop.epoch.screen'' variable - using all epochs';
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    else
                        dop.plot.screen = dop.epoch.screen;
                    end
                    switch sum(dop.plot.screen)
                        case 0
                            okay = 0;
                            msg{end+1} = sprintf(['No data available'...
                                ' after screening\n\t(%s: %s:)'],...
                                mfilename,dop.file);
                            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        case 1
                            dop.tmp.plot_data = mean(dop.tmp.data(:,dop.plot.screen,:),2);
                        otherwise
                            dop.tmp.plot_data = mean(squeeze(dop.tmp.data(:,dop.plot.screen,:)),2);
                    end
                    if okay && dop.tmp.collect && isfield(dop,'collect') && ...
                            isfield(dop.collect,dop.tmp.type) && ...
                            isfield(dop.collect.(dop.tmp.type),'data') && ...
                            ~isempty(dop.collect.(dop.tmp.type).data)
                        
                        dop.plot.screen = ones(1,size(dop.collect.(dop.tmp.type).data,2));
                        dop.plot.screen = logical(dop.plot.screen);
                        
                        % don't need to mean when it's just a single lot of data
                        dop.tmp.data = dop.collect.(dop.tmp.type).data;
                        set(dop.fig.h,'UserData',dop); % update the tmp data - amongst other things
                        dop.tmp.plot_data = squeeze(dop.collect.(dop.tmp.type).data(:,dop.plot.screen,:));
                        if numel(dop.plot.screen) > 1
                            dop.tmp.plot_data = mean(squeeze(dop.collect.(dop.tmp.type).data(:,dop.plot.screen,:)),2);
                        end
                    end
                    
                    if okay && mean(dop.tmp.plot_data(:,1)) > 30
                        msg{end+1} = sprintf(['Data mean > 30 (%3.2f : %3.2f). Subtrating',...
                            ' mean and recalculating diff + average to plot the data around zero'],...
                            mean(dop.tmp.plot_data(:,1:2)));
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        % scale the left and right channels
                        dop.tmp.plot_data(:,1:2) = bsxfun(@minus,dop.tmp.plot_data(:,1:2),mean(dop.tmp.plot_data(:,1:2)));
                        % difference
                        dop.tmp.plot_data(:,3) = dop.tmp.plot_data(:,1) - dop.tmp.plot_data(:,2);
                        % average
                        dop.tmp.plot_data(:,4) = mean(dop.tmp.plot_data(:,1:2),2);
                    end
                    
                    %% > add the main data
                    % left, right, difference, average
                    % collect the handles for easy stacking:
                    if okay
                        for i = 1 : numel(dop.data.epoch_labels) % size(dop.tmp.plot_data,3)
                            if i == 1 && ishold(dop.fig.h); hold; end
                            dop.tmp.name = dop.data.epoch_labels{i};
                            dop.tmp.(dop.tmp.name).h = plot(dop.epoch.times,...
                                mean(squeeze(dop.tmp.plot_data(:,i)),2),...
                                'color',dopPlotColours(lower(dop.tmp.name)),...
                                'DisplayName',dop.tmp.name,'linewidth',2,...
                                'Visible','off','Tag',dop.tmp.name);
                            if sum(strcmpi(dop.tmp.ep_vis,dop.tmp.name));
                                set(dop.tmp.(dop.tmp.name).h,'Visible','on');
                            end
                            dop.tmp.data_handles(i) = dop.tmp.(dop.tmp.name).h;
                        end
                        
                        
                        % 'baseline' and 'poi' (period of interest) blocks of
                        % colour - put in the activation window aswell
                        dop.tmp.patches = {'baseline','poi'};
                        for i = 1 : numel(dop.tmp.patches)
                            dop.tmp.([dop.tmp.patches{i},'h']) = ...
                                patch([dop.tmp.(dop.tmp.patches{i})(end,:) fliplr(dop.tmp.(dop.tmp.patches{i})(end,:))],...
                                [ones(1,2)*max(get(dop.fig.ax,'Ylim')) ones(1,2)*min(get(dop.fig.ax,'Ylim'))],...
                                dopPlotColours(dop.tmp.patches{i}),...
                                'FaceAlpha',.3,'EdgeAlpha',0,...
                                'Parent',dop.fig.ax,...
                                'EdgeColor',dopPlotColours(dop.tmp.patches{i}),...
                                'DisplayName',dop.tmp.patches{i},...
                                'Tag',dop.tmp.patches{i});
                        end
                        %% add the peak
                        [dop.tmp.sum,peak_okay] = dopCalcSummary(dop.tmp.plot_data(:,3),...
                            'period','poi',...
                            'epoch',dop.tmp.epoch,...
                            'act_window',dop.tmp.act_window,...
                            'sample_rate',dop.tmp.sample_rate,...
                            'poi',dop.tmp.poi(end,:));
                        if peak_okay
                            dop.tmp.act_values = [-dop.tmp.act_window*.5 dop.tmp.act_window*.5]+dop.tmp.sum.peak_latency;
                            % check if the peak is right at the end, adjust
                            % activation window accordingly
                            if dop.tmp.act_values(2) > dop.epoch.times(end)
                                dop.tmp.act_values = [-dop.tmp.act_window 0]+dop.epoch.times(end);
                            end
                            dop.tmp.act_windowh = ...
                                patch([dop.tmp.act_values fliplr(dop.tmp.act_values)],...
                                [ones(1,2)*max(get(dop.fig.ax,'Ylim')) ones(1,2)*min(get(dop.fig.ax,'Ylim'))],...
                                dopPlotColours('act_window'),...
                                'Parent',dop.fig.ax,...
                                'FaceAlpha',.3,'EdgeAlpha',0,...
                                'EdgeColor',dopPlotColours('act_window'),...
                                'DisplayName','act. window',...
                                'Tag','act_window');
                            
                            dop.tmp.latency.h = plot(dop.fig.ax,...
                                ones(1,2)*dop.tmp.sum.peak_latency,get(dop.fig.ax,'YLim'),...
                                'color',dopPlotColours('peak'),'Tag','peak',...
                                'LineWidth',2,...
                                'DisplayName','peak',...
                                'Tag','peak');
                        end
                        %% > legend
                        % do the legend at this point then it should only
                        % inclue the 4 data channels we want - actually, be
                        % good to have baseline, poi, and peak here as well...
                        dopPlotLegend(dop.fig.h);
                        % change which elements are 'on top'
                        uistack(dop.tmp.data_handles,'top');
                        
                        % zero lines
                        dop.tmp.zero.yh = plot(dop.epoch.times,...
                            zeros(size(dop.epoch.times)),...
                            'color',dopPlotColours('yzero'),...
                            'DisplayName','yzero','Tag','yzero');
                        %                     hold; % hold the plot so that first line isn't cleared when subsequent lines are plotted
                        dop.tmp.zero.xh = plot([0 0],get(dop.fig.ax,'Ylim'),...
                            'color',dopPlotColours('xzero'),...
                            'DisplayName','xzero','Tag','xzero');
                        uistack([dop.tmp.zero.yh,dop.tmp.zero.xh],'bottom');
                        % update the vertical zero
                        set(dop.tmp.zero.xh,'YData',get(dop.fig.ax,'YLim'));
                        dopPlotSetAxes(dop);
                        
                        % clean up the axes
                        % to find out the properties:
                        % get(dop.fig.ax)
                        %                     set(dop.fig.ax,'XLim',dop.tmp.epoch);
                        %                     set(dop.fig.ax,'XTick',dop.tmp.epoch(1):abs(dop.tmp.epoch(1))*.5:dop.tmp.epoch(2));
                        
                        % the XLabel is itself a handle, so need to get it and then set
                        % one if it's properties
                        set(get(dop.fig.ax,'YLabel'),'string','Blood Flow Velocity');
                        set(get(dop.fig.ax,'XLabel'),'string','Epoch time in seconds: 0 = Event Marker');
                        %                     [dop,okay,msg] = dopPlotSave(dop,okay,msg);
                        %                     dop.fig.legend = legend(dop.fig.ax); % turn on the legend, uses 'DisplayName' of lines
                        
                        %                     set(dop.fig.ax,'Xlim',[min(dop.fig.xdata) max(dop.fig.xdata)],'TickDir','out');
                        %                     dop.tmp.ylim = get(dop.fig.ax,'Ylim');
                        %                     set(dop.fig.ch(and(strcmp(get(dop.fig.ch,'Type'),'uicontrol'),...
                        %                         strcmp(get(dop.fig.ch,'Tag'),'ylower'))),'string',dop.tmp.ylim(1));
                        %                     set(dop.fig.ch(and(strcmp(get(dop.fig.ch,'Type'),'uicontrol'),...
                        %                         strcmp(get(dop.fig.ch,'Tag'),'yupper'))),'string',dop.tmp.ylim(2));
                    end
                    if dop.tmp.wait; uiwait(dop.fig.h); end
                otherwise
                    msg{end+1} = sprintf('''%s'' plot type not yet programmed',...
                        dop.tmp.type);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    close(dop.fig.h);
            end
        end
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end