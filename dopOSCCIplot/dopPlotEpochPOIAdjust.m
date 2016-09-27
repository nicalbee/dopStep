function dopPlotEpochPOIAdjust(handle,~)
% dopOSCCI3: dopPlotEpochPOIAdjust
%
% dopPlotEpochPOIAdjust(handle,event);
%
% notes:
% handles the plotting for period of interest adjustments for the dopPlot
% epoched data. It's a CallBack function for the
% buttons and edit boxes. So, provided there aren't any problems with it,
% it's not something that people need to worry about.
%
% Created: 04-Jan-2016 NAB
% Last edit:


% disp_options = {'all','median','mean'};
% if ~isnan(str2double(get(handle,'string')))
%     value = str2double(get(handle,'string'));
%     if
%     
% else
if isnan(str2double(get(handle,'string'))) % && strcmp(get(handle,'tag'),'display')
        h = warndlg('Unacceptable string input: setting to default','Input error:');
        set(handle,'string',char(get(handle,'UserData')));
        uiwait(h); % waiting for it to be deleted solves the issue
%         dopPlotEpochAxesAdjust(handle);
% something not working after it's been through here and I can't figure out
% what...
% warndlg was interferring with this... not sure why but seem to be default
% to the warndlg handle
%         return
else
    data = str2double(get(handle,'string'));
    element = 'min'; %lower
    if strfind(get(handle,'Tag'),'upper')
        element = 'max'; % upper
    end
    
end

fig_h = get(handle,'parent');
fig_data = get(fig_h,'UserData');
ch = get(fig_h,'children');

axes_h = ch(strcmp(get(ch,'Type'),'axes'));

axes_ch = get(axes_h,'children');

poi_h = axes_ch(strcmp(get(axes_ch,'Tag'),'poi'));
act_win_h = axes_ch(strcmp(get(axes_ch,'Tag'),'act_window'));
peak_h = axes_ch(strcmp(get(axes_ch,'Tag'),'peak'));
diff_h = axes_ch(strcmp(get(axes_ch,'Tag'),'Difference'));
% left_h = axes_ch(strcmp(get(axes_ch,'Tag'),'Left'));
% right_h = axes_ch(strcmp(get(axes_ch,'Tag'),'Right'));

% shift period of interest
poi_data = get(poi_h,'XData');
% get the minimum or maximum - doesn't need to be done with eval but it's
% nice to test your memory from time to time!
poi_value = eval(sprintf('%s([%u %u %u %u]);',element,poi_data));
poi_data(poi_value == poi_data) = data;
if min(poi_data) > max(poi_data) || max(poi_data) < min(poi_data)
    h = warndlg('Lower period of interest value needs to be less than upper value','Input error:');
        set(handle,'string',char(get(handle,'UserData')));
        uiwait(h); % waiting for it to be deleted solves the issue
    return
end
    
set(poi_h,'XData',poi_data); drawnow; % doesn't always work the first time...
fprintf('Period of interest manually set to: %i %i\n',min(poi_data),max(poi_data));

tmp_poi = [min(poi_data) max(poi_data)];

% need to put this in the plot function somehow - 
% as neat as these functions look, don't work in the current circumstances
% assignin('caller','poi_select',tmp_poi);
% assignin('base','poi_select',tmp_poi);
save('poi_select','tmp_poi');
% save it into a mat file at the current path, load, and then delete

% calculate laterality index
[dop.tmp.sum,peak_okay] = dopCalcSummary(get(diff_h,'YData')',...
    'period','poi',...
    'epoch',fig_data.tmp.epoch,...
    'act_window',fig_data.tmp.act_window,...
    'sample_rate',fig_data.tmp.sample_rate,...
    'poi',tmp_poi);
% shift peak and activation window
if peak_okay
    set(peak_h,'XData',ones(1,2)*dop.tmp.sum.peak_latency);
    
    dop.tmp.act_values = [-fig_data.tmp.act_window*.5 fig_data.tmp.act_window*.5]+dop.tmp.sum.peak_latency;
    % check if the peak is right at the end, adjust
    % activation window accordingly

    tmp.times = get(diff_h,'XData');                 
    if dop.tmp.act_values(2) > tmp.times(end)
        dop.tmp.act_values = [-dop.tmp.act_window 0]+tmp.times(end);
    end
    act_win_data = get(act_win_h,'XData');
    act_win_data(act_win_data == min(act_win_data)) = min(dop.tmp.act_values);
    act_win_data(act_win_data == max(act_win_data)) = max(dop.tmp.act_values);
    
    set(act_win_h,'XData',act_win_data);
else
    h = warndlg('Problem with peak calculation: plot can''t be adjusted','Calculation error:');
    set(handle,'string',char(get(handle,'UserData')));
    uiwait(h); % waiting for it to be deleted solves the issue
end
% legend_h = ch(strcmp(get(ch,'Tag'),'legend'));
% legend_ch = get(legend_h,'children');
% 
% disp_h = ch(and(strcmp(get(ch,'Type'),'uicontrol'), strcmp(get(ch,'Tag'),'display')));
% lower_yh = ch(and(strcmp(get(ch,'Type'),'uicontrol'), strcmp(get(ch,'Tag'),'ylower')));
% upper_yh = ch(and(strcmp(get(ch,'Type'),'uicontrol'), strcmp(get(ch,'Tag'),'yupper')));
% xlim = get(axes_h,'Xlim');
% ylim = get(axes_h,'ylim');
% dop = get(fig_h,'UserData');
% switch get(handle,'tag')
%     %     case 'display'
%     %
%     %
%     case {'display','down','up'}
%         value = str2double(get(disp_h,'string'));
%         if isnan(value)
%             % have to figure out the order of other data
%             value = size(dop.tmp.data,2) + find(strcmp(get(disp_h,'string'),disp_options));
%         end
%         switch get(handle,'tag')
%             case 'down'  % left - whatever!
%                 value = value - 1;
%             case 'up' % right...
%                 value = value + 1;
%         end
%         if value > size(dop.tmp.data,2) + numel(disp_options)
%             value = 1;
%         elseif value < 1 || ...
%                 and(value > size(dop.tmp.data,2),value <= size(dop.tmp.data,2) + numel(disp_options))
%             if value < 1
%                 value = size(dop.tmp.data,2) + numel(disp_options);
%             end
%             value = disp_options{value - size(dop.tmp.data,2)};
%             %             value = 1;
%             %         elseif value <= size(dop.tmp.data,2) % this is okay
%         end
%         set(disp_h,'string',value);
%         
%         % screening
% %         if ~isfield(dop,'plot') || ~isfield(dop.plot,'screen')
%             dop.plot.screen = ones(1,size(dop.tmp.data,2));
%             dop.plot.screen = logical(dop.plot.screen);
% %         end
%         
%         if isnumeric(value) && ~isnan(value)
%             plot_data = squeeze(dop.tmp.data(:,value,:));
%         else
%             value = get(disp_h,'string');
%             if ~strcmp(disp_options,value)
%                 % default
%                 value = get(disp_h,'UserData');
%             end
%             switch char(value)
%                 case {'mean','median'}
%                     plot_data = eval(['squeeze(',value,'(dop.tmp.data(:,dop.plot.screen,:),2));']);
%                 case 'all'
%                     plot_data = dop.tmp.data;
%                     
%             end
%         end
% 
% %         ch = get(fig_h,'children');
% 
%         
%         % if size(plot_data,2) == numel(dop.data.epoch_labels)
%         tmp_labels = [dop.data.epoch_labels,{'baseline','poi','act_window','peak'}];
%         tmp_vis = cell(1,numel(tmp_labels));%size(dop.tmp.data,2));
%         check_h = zeros(1,numel(tmp_labels));%size(dop.tmp.data,2));
%         for i = 1 : numel(tmp_labels); % numel(dop.data.epoch_labels)
%             check_h(i) = legend_ch(strcmpi(get(legend_ch,'Tag'),[tmp_labels{i},'_check']));%dop.data.epoch_labels{i}));
%             tmp_vis{i} = get(get(check_h(i),'UserData'),'Visible');
%             if iscell(tmp_vis{i})
%                 tmp_vis{i} = tmp_vis{i}{1};
%             end
%         end
%         for i = 1 : numel(tmp_labels) %numel(dop.data.epoch_labels)
%             if i == 1 && ishold(axes_h); hold; end
%             switch tmp_labels{i}
%                 case dop.data.epoch_labels
%                     if size(plot_data,2) == numel(dop.data.epoch_labels)
%                         line_h = plot(axes_h,dop.epoch.times,plot_data(:,i),...
%                             'color',dopPlotColours(lower(dop.data.epoch_labels{i})),...
%                             'Visible',tmp_vis{i},'LineWidth',2);
%                     elseif size(plot_data,3) == numel(dop.data.epoch_labels)
%                         % multiple lines - not sure if this will work
%                         line_h = plot(axes_h,dop.epoch.times,squeeze(plot_data(:,:,i)),...
%                             'color',dopPlotColours(lower(dop.data.epoch_labels{i})),...
%                             'Visible',tmp_vis{i});
%                     end
%                 case {'baseline','poi'}
%                     line_h = ...
%                         patch([dop.tmp.(tmp_labels{i}) fliplr(dop.tmp.(tmp_labels{i}))],...
%                         [ones(1,2)*max(get(axes_h,'Ylim')) ones(1,2)*min(get(axes_h,'Ylim'))],...
%                         dopPlotColours(tmp_labels{i}),...
%                         'Parent',axes_h,...
%                         'FaceAlpha',.3,'EdgeAlpha',0,...
%                         'EdgeColor',dopPlotColours(tmp_labels{i}),...
%                         'DisplayName',tmp_labels{i},...
%                         'Tag',tmp_labels{i});
%                 case 'peak'
%                     
%                     if peak_okay
%                         line_h = plot(axes_h,...
%                             ones(1,2)*dop.tmp.sum.peak_latency,get(axes_h,'YLim'),...
%                             'color',dopPlotColours('peak'),'Tag','peak',...
%                             'LineWidth',2,...
%                             'DisplayName','peak',...
%                             'Tag','peak');
%                     end
%                 case 'act_window'
%                     calc_data = plot_data(:,3);
%                     if numel(size(plot_data)) == 3
%                         calc_data = squeeze(mean(plot_data(:,dop.plot.screen,3),2));
%                     end
%                     [dop.tmp.sum,peak_okay] = dopCalcSummary(calc_data,...
%                         'period','poi',...
%                         'epoch',dop.tmp.epoch,...
%                         'act_window',dop.tmp.act_window,...
%                         'sample_rate',dop.tmp.sample_rate,...
%                         'poi',dop.tmp.poi);
%                     if peak_okay
%                         dop.tmp.act_values = [-dop.tmp.act_window*.5 dop.tmp.act_window*.5]+dop.tmp.sum.peak_latency;
%                         line_h = ...
%                             patch([dop.tmp.act_values fliplr(dop.tmp.act_values)],...
%                             [ones(1,2)*max(get(axes_h,'Ylim')) ones(1,2)*min(get(axes_h,'Ylim'))],...
%                             dopPlotColours('act_window'),...
%                             'Parent',axes_h,...
%                             'FaceAlpha',.3,'EdgeAlpha',0,...
%                             'EdgeColor',dopPlotColours('act_window'),...
%                             'DisplayName','act. window',...
%                             'Tag','act_window');
%                     end
%             end
%             set(check_h(i),'UserData',line_h);
%             if i == 1; hold; end
%         end
%         ylim = get(axes_h,'Ylim'); % let the axes adjust themselves for the epoch
%         
%     case 'ylower'
%         value = str2double(get(handle,'string'));
%         if value < ylim(2)
%             ylim(1) = value;
%         else
%             warndlg('Lower value needs to be less than the upper value');
%             return;
%         end
%     case 'yupper'
%         value = str2double(get(handle,'string'));
%         if value > ylim(1)
%             ylim(2) = value;
%         else
%             warndlg('Upper value needs to be higher than the lower value');
%             return;
%         end
%     case 'zoomin'
%         ylim = round([ylim(1) + diff(ylim)*.25 ylim(2) - diff(ylim)*.25]);
%     case 'zoomout'
%         ylim = round([ylim(1) - diff(ylim) ylim(2) + diff(ylim)]);
%         % zoom out too far and the patches don't really the extremities...
%         tmp_labels = {'baseline','poi','act_window','peak'};
% %         tmp_vis = cell(1,numel(tmp_labels));%size(dop.tmp.data,2));
%         check_h = zeros(1,numel(tmp_labels));%size(dop.tmp.data,2));
%         for i = 1 : numel(tmp_labels); % numel(dop.data.epoch_labels)
%             check_h(i) = legend_ch(strcmpi(get(legend_ch,'Tag'),[tmp_labels{i},'_check']));%dop.data.epoch_labels{i}));
%             switch tmp_labels{i}
%                 case {'baseline','poi','act_window'}
%             set(get(check_h(i),'UserData'),'YData', [ones(1,2)*max(ylim) ones(1,2)*min(ylim)]);
%                 case 'peak'
%                     set(get(check_h(i),'UserData'),'YData', ylim);
%             end
% %             if iscell(tmp_vis{i})
% %                 tmp_vis{i} = tmp_vis{i}{1};
% %             end
%         end
% end
% 
% % if xlim(1) < (1/dop.tmp.sample_rate)
% %     xlim(1) = (1/dop.tmp.sample_rate);
% %     xlim(2) = xlim(1) + str2double(get(diff_h,'string'));
% % end
% % if xlim(2) > size(dop.tmp.data,1)*(1/dop.tmp.sample_rate)
% %     xlim(2) = size(dop.tmp.data,1)*(1/dop.tmp.sample_rate);
% %     xlim(1) = xlim(2) - str2double(get(diff_h,'string'));
% % end
% % xsamples = round(xlim/(1/dop.tmp.sample_rate));
% % xdata = (xsamples)*(1/dop.tmp.sample_rate);
% 
% % need to update the legend checkbox UserData for the new data
% % handles
% 
% % else
% %     for i = 1 : size(plot_data,2)
% %     plot(axes_h,dop.epoch.times,plot_data(:,i));
% %     end
% % elseif size(plot_data,3) == numel(dop.data.epoch_labels)
% 
% % else
% %     fprintf('!! Problem...\n');
% % end
% set(axes_h,'Xlim',xlim,'Ylim',ylim);
% set(lower_yh,'string',ylim(1));
% set(upper_yh,'string',ylim(2));
% end
end
