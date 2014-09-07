function dopPlotAxesAdjust(handle,~)
% dopOSCCI3: dopPlotAxesAdjust
%
% dopPlotAxesAdjust(handle,event);
%
% notes:
% handles the plotting for x and y axes adjustments for the dopPlot
% continuous data (i.e., not epoched). It's a CallBack function for the
% buttons and edit boxes. So, provided there aren't any problems with it,
% it's not something that people need to worry about.
%
% Created: ??-Aug-2014 NAB
% Last edit:
% 29-Aug-2014 NAB
% 02-Sep-2014 NAB adjusted zoom to be traditional
% 08-Sep-2014 NAB fixed empty patch checkbox issue

value = str2double(get(handle,'string'));

if ~isnumeric(value) && ~strcmp(get(handle,'tag'),'diff')
    warndlg('Input needs to be numeric')
    set(handle,'string',get(handle,'UserData'));
    return
elseif isnan(value) && strcmp(get(handle,'tag'),'diff')
    value = get(handle,'string');
    if ~strcmp(value,'all')
        warndlg('Only ''all'' accepted as string input');
        set(handle,'string',get(handle,'UserData'));
    end
end
fig_h = get(handle,'parent');
ch = get(fig_h,'children');
axes_h = ch(strcmp(get(ch,'Type'),'axes'));
diff_h = ch(and(strcmp(get(ch,'Type'),'uicontrol'), strcmp(get(ch,'Tag'),'diff')));
lower_xh = ch(and(strcmp(get(ch,'Type'),'uicontrol'), strcmp(get(ch,'Tag'),'lower')));
upper_xh = ch(and(strcmp(get(ch,'Type'),'uicontrol'), strcmp(get(ch,'Tag'),'upper')));
lower_yh = ch(and(strcmp(get(ch,'Type'),'uicontrol'), strcmp(get(ch,'Tag'),'ylower')));
upper_yh = ch(and(strcmp(get(ch,'Type'),'uicontrol'), strcmp(get(ch,'Tag'),'yupper')));
xlim = get(axes_h,'Xlim');
ylim = get(axes_h,'ylim');
dop = get(fig_h,'UserData');
switch get(handle,'tag')
    case 'lower'
        if value < xlim(2)
            xlim(1) = value;
            xlim(2) = xlim(1) + str2double(get(diff_h,'string'));
        else
            warndlg('Lower value needs to be less than the upper value');
            return;
        end
    case 'diff'
        % if the difference is changed, keep the lower limit the same and
        % adjust the upper
        if isnumeric(value)
            max_diff = [get(lower_xh,'UserData') get(upper_xh,'UserData')];
            if value > diff(max_diff)
                value = max_diff;
            end
            xlim(2) = xlim(1) + value;
            if xlim(2) > size(dop.tmp.data,1)*(1/dop.tmp.sample_rate)
                xlim(2) = size(dop.tmp.data,1)*(1/dop.tmp.sample_rate);
                xlim(1) = xlim(2) - str2double(get(diff_h,'string'));
            end
        elseif strcmp(value,'all')
            xlim = [1*(1/dop.tmp.sample_rate) size(dop.tmp.data,1)*(1/dop.tmp.sample_rate)];
            set(handle,'string',diff(xlim));
        end
    case 'upper'
        if value > xlim(1)
            if value < size(dop.tmp.data,1)*(1/dop.tmp.sample_rate)
                xlim(2) = value;
                xlim(1) = xlim(2) - str2double(get(diff_h,'string'));
            else
                warndlg('Value is beyond the end of the data');
                return
            end
        else
            warndlg('Upper value needs to be greater than the lower value');
            return
        end
    case 'lowerEnd'
        xlim(1) = 1*(1/dop.tmp.sample_rate);
        xlim(2) = xlim(1) + str2double(get(diff_h,'string'));
        
    case 'down'
        xlim = xlim-str2double(get(diff_h,'string'));
        
    case 'up'
        xlim = xlim + str2double(get(diff_h,'string'));
        
    case 'upperEnd'
        
        xlim(2) = size(dop.tmp.data,1)*(1/dop.tmp.sample_rate);
        xlim(1) = xlim(2) - str2double(get(diff_h,'string'));
    case 'ylower'
        if value < ylim(2)
            ylim(1) = value;
        else
            warndlg('Lower value needs to be less than the upper value');
            return;
        end
    case 'yupper'
        if value > ylim(1)
            ylim(2) = value;
        else
            warndlg('Upper value needs to be higher than the lower value');
            return;
        end
        %     case 'zoomin'
        %         ylim(2) = ylim(1) + diff(ylim)*.5;
        %     case 'zoomout'
        %         ylim(2) = ylim(1) + diff(ylim)*2;
    case 'zoomin'
        ylim = round([ylim(1) + diff(ylim)*.25 ylim(2) - diff(ylim)*.25]);
    case 'zoomout'
        ylim = round([ylim(1) - diff(ylim) ylim(2) + diff(ylim)]);
end

if xlim(1) < (1/dop.tmp.sample_rate)
    xlim(1) = (1/dop.tmp.sample_rate);
    xlim(2) = xlim(1) + str2double(get(diff_h,'string'));
end
if xlim(2) > size(dop.tmp.data,1)*(1/dop.tmp.sample_rate)
    xlim(2) = size(dop.tmp.data,1)*(1/dop.tmp.sample_rate);
    xlim(1) = xlim(2) - str2double(get(diff_h,'string'));
end
xsamples = round(xlim/(1/dop.tmp.sample_rate));
xdata = (xsamples)*(1/dop.tmp.sample_rate);
% 
% % need to update the legend checkbox UserData for the new data
% % handles
ch = get(fig_h,'children');
legend_h = ch(strcmp(get(ch,'Tag'),'legend'));
legend_ch = get(legend_h,'children');
% 
% if size(dop.tmp.data,2) == numel(dop.data.channel_labels)
%     if ~isfield(dop,'data') && ~isfield(dop.data,'channel_colours')
%         dop.data.channel_colours = {'b','r','g'};
%     end
%     tmp_vis = cell(1,size(dop.tmp.data,2));
%     check_h = zeros(1,size(dop.tmp.data,2));
%     for i = 1 : size(dop.tmp.data,2)
%         check_h(i) = legend_ch(strcmpi(get(legend_ch,'String'),dop.data.channel_labels{i}));
%         tmp_vis{i} = get(get(check_h(i),'UserData'),'Visible');
%     end
%     for i = 1 : size(dop.tmp.data,2)
%         if i == 1 && ishold(axes_h); hold; end
%         
%         dop.tmp.ev_plot = [dop.data.channel_labels{i},'_plot'];
%         if numel(unique(dop.tmp.data(:,i))) == 2 && ...
%                 isfield(dop.data,dop.tmp.ev_plot)
%             dop.tmp.events = find(dop.tmp.data(:,i));
% 
%             xdata_ev = dop.data.(dop.tmp.ev_plot)(:,2)*(1/dop.tmp.sample_rate);
%             ydata_ev = dop.data.(dop.tmp.ev_plot)(:,1)*max(ylim);
%             filt_ev = and(xdata_ev >= xdata(1),xdata_ev <= xdata(2));
% 
%             line_h = plot(axes_h,xdata_ev(filt_ev),...
%                 ydata_ev(filt_ev),...
%                 'color',dopPlotColours(dop.data.channel_labels{i}),...dop.data.channel_colours{i},...
%                 'Tag',dop.data.channel_labels{i},...
%                 'DisplayName',dop.data.channel_labels{i});
%             
%         else
%             
%             line_h = plot(axes_h,xdata(1):(1/dop.tmp.sample_rate):xdata(2),...
%                 dop.tmp.data(xsamples(1):xsamples(2),i),...
%                 'color',dopPlotColours(dop.data.channel_labels{i}),...dop.data.channel_colours{i},...
%                 'Visible',tmp_vis{i});
%             
%         end
%         set(check_h(i),'UserData',line_h);
%         if i == 1; hold; end
%     end
% else
%     plot(axes_h,xdata(1):(1/dop.tmp.sample_rate):xdata(2),...
%         dop.tmp.data(xsamples(1):xsamples(2),:));
% end
set(axes_h,'Xlim',xlim,'Ylim',ylim);

set(lower_xh,'string',xdata(1));
set(upper_xh,'string',xdata(2));
set(lower_yh,'string',ylim(1));
set(upper_yh,'string',ylim(2));

% patches
tmp_labels = {'epoch','baseline','poi'};
%         tmp_vis = cell(1,numel(tmp_labels));%size(dop.tmp.data,2));
        check_h = zeros(1,numel(tmp_labels));%size(dop.tmp.data,2));
        for i = 1 : numel(tmp_labels); % numel(dop.data.epoch_labels)
            if sum(strcmpi(get(legend_ch,'Tag'),[tmp_labels{i},'_check']))
            check_h(i) = legend_ch(strcmpi(get(legend_ch,'Tag'),[tmp_labels{i},'_check']));%dop.data.epoch_labels{i}));
            if ~isempty(check_h(i)) && check_h(i) && strcmp(get(get(check_h(i),'UserData'),'Type'),'patch')
                switch tmp_labels{i}
                    case {'epoch','baseline','poi'}
                        ydata = ones(4,size(get(get(check_h(i),'UserData'),'YData'),2));
                         ydata = bsxfun(@times,ydata,[ones(1,2)*max(ylim) ones(1,2)*min(ylim)]');
                        set(get(check_h(i),'UserData'),'YData', ydata);
%                     case 'peak'
%                         set(get(check_h(i),'UserData'),'YData', ylim);
                end
            end
%             if iscell(tmp_vis{i})
%                 tmp_vis{i} = tmp_vis{i}{1};
%             end
            end
        end
% end
