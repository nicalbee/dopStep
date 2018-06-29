function [dop,okay,msg] = dopEpochScreenChange(dop_input,varargin)
% dopOSCCI3: dopScreenChange
%
% notes:
% basic structure of a function to save time when creating a new one
%
% * not yet implemented (29-Jun-2018)
%
% Use:
%
% [dop,okay,msg] = dopEpochScreenChange(dop,[]);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 29-June-2018 NAB
% Last edit:


[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        inputs.turnOn = {'plot'};
        inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'act_change_plot',0,...
            'screen_event',1,...
            'showmsg',1,...
            'wait_warn',0,...
            'act_change',15,... % change relative to mean/baseline
            'act_change_index','pct',... 'iqr'
            'act_change_window',0.5,... % window in seconds
            'signal_channels',[],...
            'event_channels',[], ...
            'epoch',[], ...
            'sample_rate',[] ...
            );
        inputs.defaults.ch_labels = {'Left','Right'};
        inputs.required = [];
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        if okay
            
            if size(dop.tmp.data,3) == 1
                dop.tmp.data_type = 'continuous';
                msg{end+1} = 'Continuous data (i.e., not epoched) inputted';
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                
                msg{end+1} = sprintf(['data %u columns, assuming first',...
                    ' 2 are left and right channels'],...
                    size(dop.tmp.data,2));
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                
                [dop,okay,msg] = dopEventMarkers(dop,okay,msg);
                % refresh the data if necessary
                [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                
            elseif size(dop.tmp.data,3) > 1
                dop.tmp.data_type = 'epoched';
                msg{end+1} = 'Epoched data inputted';
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            else
                okay = 0;
                msg{end+1} = ['Data type unknown: expecting continuous or'...
                    'epoched. Can''t continue function'];
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
            
        end
        
        %% main code
        if okay
            if strcmp(dop.tmp.data_type,'continuous')
                dop.tmp.n_epochs = dop.event(dop.tmp.screen_event).n;
            elseif strcmp(dop.tmp.data_type,'epoched')
                dop.tmp.n_epochs = size(dop.tmp.data,2);
            end
            dop.epoch.change = ones(dop.tmp.n_epochs,1);
            
            % some descriptives
            dop.epoch.act_change_descriptives = {'mean','std','median','iqr','min','max'};
            for i = 1 : numel(dop.epoch.act_change_descriptives)
                dop.epoch.(['act_change_',dop.epoch.act_change_descriptives{i},'_ep']) = ones(dop.tmp.n_epochs,2);
            end
            %             dop.epoch.act_change_mean_ep = dop.epoch.change;
            %             dop.epoch.act_change_sd_ep = dop.epoch.change;
            %             dop.epoch.act_change_median_ep = dop.epoch.change;
            %             dop.epoch.act_change_iqr_ep = dop.epoch.change;
            %             dop.epoch.act_change_min_ep = dop.epoch.change;
            %             dop.epoch.act_change_max_ep = dop.epoch.change;
            dop.tmp.loop = {'descriptives','exclusions'};
            % if we run the calculations first then exclusions could be
            % based on the actually data
            
            % and we need to create a bunch of 'little' epochs within the epoch - let's
            % call them windows
            % these could be side by side of have an overlap of x samples/seconds. I
            % don't think it's necessary to have the sample by sample check but perhaps
            % half of the window size would do it
            dop.tmp.window = dop.tmp.act_change_window*dop.tmp.sample_rate; % in samples
            dop.tmp.window_starts = 1:dop.tmp.act_change_window*dop.tmp.sample_rate*.5:size(dop.tmp.data,1)-dop.tmp.act_change_window*dop.tmp.sample_rate;
            
            for jj = 1 : numel(dop.tmp.loop)
                for j = 1 : dop.tmp.n_epochs
                    switch dop.tmp.data_type
                        case 'continuous'
                            dop.tmp.filt_limits = dop.event(dop.tmp.screen_event).samples(j) + dop.tmp.epoch/(1/dop.tmp.sample_rate);
                            if dop.tmp.filt_limits(1) < 1
                                msg{end+1} = sprintf(['Epoch %u is short by'...
                                    ' %u samples (%3.2f secs). Checking avialable'],...
                                    j,abs(dop.tmp.filt_limits(1)),...
                                    dop.tmp.filt_limits(1)*(1/dop.tmp.sample_rate));
                                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                                dop.tmp.filt_limits(1) = 1;
                            end
                            if dop.tmp.filt_limits(2) > size(dop.tmp.data,1)
                                msg{end+1} = sprintf(['Epoch %u is short by'...
                                    ' %u samples (%3.2f secs). Checking avialable'],...
                                    j,size(dop.tmp.data,1) - dop.tmp.filt_limits(2),...
                                    (size(dop.tmp.data,1)-dop.tmp.filt_limits(2))*(1/dop.tmp.sample_rate));
                                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                                dop.tmp.filt_limits(2) = size(dop.tmp.data,1);
                            end
                            dop.tmp.filt = dop.tmp.filt_limits(1) : dop.tmp.filt_limits(2);
                            dop.tmp.filt_data = dop.tmp.data(dop.tmp.filt,1:2);
                        case 'epoched'
                            dop.tmp.filt = 1 : size(dop.tmp.data,1);
                            dop.tmp.filt_data = dop.tmp.data(:,j,1:2);
                    end
                    % not looking at the difference for the change - it's
                    % raw left and right
                    %                     dop.tmp.diff = dop.tmp.filt_data(:,1) - dop.tmp.filt_data(:,2); %,dop.tmp.act_range_values(1,:));
                    dop.tmp.window_data = zeros(numel(dop.tmp.window_starts),2);
                    dop.tmp.window_diffs = dop.tmp.window_data;
                    for i = 1 : numel(dop.tmp.window_starts)
                        
                        dop.tmp.window_data = dop.tmp.filt_data(dop.tmp.window_starts(i):dop.tmp.window_starts(i)+dop.tmp.window-1,1,1:2);
                        % get the maximum difference for each little window
                        dop.tmp.window_diffs(i,:) = max(dop.tmp.window_data) - min(dop.tmp.window_data);
                        % then if any of these changes are greater than we want, reject
                    end
                    if dop.tmp.plot || dop.tmp.act_change_plot
                        % old 'hist' function works nicely for visualising this
                        % - new one doesn't... and 'hist' isn't recommended so
                        % I'm worried they'll drop 'hist' is future releases...
                        % but: https://au.mathworks.com/matlabcentral/answers/288261-how-to-get-multiple-groups-plotted-with-histogram
                        if j == 1
                            dop.tmp.h = figure('Name',sprintf('Activation change (%s)',mfilename),'units','Normalized','position',[.1 .3 .8 .5]);
                            dop.tmp.subplot = [ceil(sqrt(dop.tmp.n_epochs))*2 ceil(dop.tmp.n_epochs/ceil(sqrt(dop.tmp.n_epochs)))];
                            dop.tmp.subplot_count = 0;
                        end
                        dop.tmp.subplot_count = dop.tmp.subplot_count + 1;
                        dop.tmp.times = 1:size(dop.tmp.data,1)*dop.tmp.sample_rate;
                        subplot(dop.tmp.subplot(1),dop.tmp.subplot(2),dop.tmp.subplot_count);
                        % left an right channels first
                        plot(dop.tmp.filt_data(:,1),'r'); hold; plot(dop.tmp.filt_data(:,2),'b');
                        
                        dop.tmp.subplot_count = dop.tmp.subplot_count + 1;
                        subplot(dop.tmp.subplot(1),dop.tmp.subplot(2),dop.tmp.subplot_count);
                        dop.tmp.h0edges = floor(min(dop.tmp.window_diffs)):.5:ceil(max(dop.tmp.window_diffs));
                        dop.tmp.h1left = histcounts(dop.tmp.window_diffs(:,1),dop.tmp.h0edges);
                        dop.tmp.h2right = histcounts(dop.tmp.window_diffs(:,2),dop.tmp.h0edges);
                        
                        dop.tmp.b = bar(dop.tmp.h0edges(1:end-1),[dop.tmp.h1left;dop.tmp.h2right]');
                        set(dop.tmp.b(1),'FaceColor','b');
                        set(dop.tmp.b(2),'FaceColor','r');
                        %                     histogram(dop.tmp.window_diffs(:,1),'FaceColor','b'); hold;
                        %                     histogram(dop.tmp.window_diffs(:,2),'FaceColor','r');
                        legend('left','right');
                        legend 'boxoff'
                    end
                    switch dop.tmp.loop{jj}
                        case 'descriptives'
                            % descriptive calculations
                            for i = 1 : numel(dop.epoch.act_change_descriptives)
                                dop.epoch.(['act_change_',dop.epoch.act_change_descriptives{i},'_ep'])(j,:) = ...
                                    eval(sprintf('%s(abs(dop.tmp.window_diffs))',dop.epoch.act_change_descriptives{i}));
                            end
                            if j == dop.tmp.n_epochs
                                % not sure about this being summarised as means
                                
                                for i = 1 : numel(dop.epoch.act_change_descriptives)
                                    dop.epoch.(['act_change_',dop.epoch.act_change_descriptives{i}]) = ...
                                        eval(sprintf('mean(dop.epoch.([''act_change_'',''%s'',''_ep'']))',dop.epoch.act_change_descriptives{i}));
                                end
                            end
                        case 'exclusions'
                            % exclusion calculations
                            switch dop.tmp.act_change_index
                                case 'pct'
                                    dop.tmp.value = dop.tmp.act_change;
                                case 'iqr'
                                    %                                     each epoch data
                                    %                                     dop.tmp.abs_diffs = abs(dop.tmp.diff);
                                    %                                     dop.tmp.value = median(dop.tmp.abs_diffs) + iqr(dop.tmp.abs_diffs) * dop.tmp.act_change;
                                    dop.tmp.value = dop.epoch.act_change_median + dop.epoch.act_change_iqr * dop.tmp.act_change;
                            end
                            dop.save.act_change_use = dop.tmp.value;
                            
                            
                            % check if the windows are greater than a critical value
                            dop.tmp.all = bsxfun(@gt,dop.tmp.window_diffs,dop.tmp.value);
                            % not relevant for change
                            % determine the percentage of sample above critical value
%                             dop.tmp.pct = 100*(sum(dop.tmp.all == 0)/numel(dop.tmp.diff));
                            dop.tmp.pct_windows = 100*(sum(dop.tmp.all == 1)./size(dop.tmp.window_diffs,1));
                            dop.epoch.change(j) = sum(sum(dop.tmp.all) == 0) == 2;
                            if ~dop.epoch.change(j)
%                                 if dop.tmp.pct <= dop.tmp.act_change_pct
%                                     dop.epoch.change(j) = 1;
%                                     msg{end+1} = sprintf(['Epoch %u. %u samples have difference',...
%                                         ' greater than %3.2f (%3.2f%%) but %% is < %1.1f%%,',...
%                                         ' therefore not excluding'],...
%                                         j,sum(dop.tmp.all == 0),dop.tmp.value,dop.tmp.pct,...
%                                         dop.tmp.act_change_pct);
%                                 else
                                    msg{end+1} = sprintf(['Epoch %u. has a change',...
                                        ' greater than %3.2f (%% of %3.2f-second windows: left = %3.2f%%, right = %3.2f%%), therefore excluded'],...
                                        j,dop.tmp.value, dop.tmp.act_change_window,dop.tmp.pct_windows);
%                                 end
                                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                            end
                    end
                end
            end
            
            dop.epoch.change_note = sprintf(['logical variable denoting epochs',...
                ' with left or right activation change less than %3.2f (%s)'],...
                dop.save.act_change_use,...
                dop.tmp.act_change_index);
            msg{end+1} = dop.epoch.change_note;
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            
            dop.epoch.change = logical(dop.epoch.change);
            dop.epoch.act_change_removed = sum(dop.epoch.change == 0);
            
            
            
            %%  msg
            msg{end+1} = sprintf(['%u epochs with change greater than %3.2f\n',...
                'Descriptives of absolute differences, averaged across epochs:\n',...
                '- mean (SD) = Left %3.2f, Right %3.2f (%3.2f, %3.2f)\n',...
                '- median (IQR) = Left %3.2f, Right %3.2f (%3.2f, %3.2f)\n',...
                '- min = Left %3.2f, Right %3.2f, max = Left %3.2f, Right %3.2f\n'],...
                dop.epoch.act_change_removed,dop.tmp.value,...
                dop.epoch.act_change_mean,dop.epoch.act_change_std,...
                dop.epoch.act_change_median,dop.epoch.act_change_iqr,...
                dop.epoch.act_change_min,dop.epoch.act_change_max);
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            
            
            msg{end+1} = sprintf(['To include this information in data file add the following '...
                'to the dop.save.extras variable:\n',...
                '\t- ''act_change_removed'' = number epochs removed greater than %u\n',...
                '\t- ''act_change_*'' = variable of interest, e.g., ''act_change_mean''\n',...
                '\t- * alternatives are: mean, sd, median, iqr, min, max'],...
                dop.tmp.act_change);
        end
        
        dop.step.(mfilename) = 1;
        
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end