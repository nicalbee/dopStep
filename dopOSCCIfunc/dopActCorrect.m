function [dop,okay,msg] = dopActCorrect(dop_input,varargin)
% dopOSCCI3: dopActCorrect
%
% % [dop,okay,msg] = dopActCorrect(dop,[okay],[msg],...);
%
% notes:
% dopActCorrect examines the current (dop.data.use) or inputted data for
% extreme samples and corrects the values to the mean, median, or using the
% 'linspace' function (default).
%
% Extreme values are based upon the 'correct_range' specified in standard
% deviation (SD) units. The default is [-3 4] = 3 SDs below the mean or 4
% SD above the means. These values are based on methods suggested by
% Dorothy Bishop.
%
% Samples are corrected if they constitute less than 'correct_pct' (default
% is 5) percent of the data.
%
% 'act_replace' variable:
% The default method, 'linspace' corrects the extreme samples by creating a
% linear sequence of values from samples either side of the extreme value.
% By default the samples either 'side' of the extreme value are 1.5 seconds
% before and after the extreme point ('linspace_seconds' variable). I have
% found these to be suitable for sensibly removing spikes and dropouts.
%
% The alternate methods are 'mean' or 'median'. These simply replace the
% single or multiple consecutive extreme samples with the mean or median of
% the period.
%
% 'by_epoch' variable
% By default, extreme values are only corrected within the samples utilised
% by the epoch settings. These can be specified as an input for this
% function but 'dopEventMarkers' will only be run if it has not previously
% been run. If the 'dop.event' variable is found, the existing event
% markers and therefore earlier specified epoch settings will be used.
%
% Use:
%
% [dop,okay,msg] = dopActCorrect(dop_input,[okay],[msg],...);
%
% * not yet implemented/tested 03-Sep-2014
%
% where:
% > Inputs
% - dop_input: dop matlab structure or data matrix*
%
%   Optional:
% - okay:
%   logical (0 or 1) for problem, 0 = no problem, 1 = problem. This can be
%   carried through from previously run functions. If set to 1, the
%   function will not be implemented.
% - msg:
%   cell variable with a history of messages from previously run functions.
%   New messages are appended to the end of the array and can be reported
%   to examine the processing steps using 'dopMessage':
%   e.g. dopMessage(msg) or dopMessage(dop);
%
%   Text only:
% - 'nomsg':
%   By default, messages about the processing will be reported to the
%   MATLAB command window. If included as an input, 'nomsg' will turn off
%   these messages. note: they will continue to be collected in the 'msg'
%   variable.
% - 'plot':
%   If included as an input a plot will be produced at the conclusion of
%   the function. The function will wait (see 'uiwait') until the figure
%   has been closed to complete its operations.
%
%
% > Outputs: (note, optional)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 18-Aug-2014 NAB
% Edits:
% 20-Aug-2014 NAB
% 28-Aug-2014 NAB linspace as default correction option
% 31-Aug-2014 NAB keep all columns of data, not just first 3
% 02-Sep-2014 NAB incorporated dopPlot continuous plotting
% 04-Sep-2014 NAB msg & wait_warn updates
% 22-May-2015 NAB summary statistics

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        inputs.turnOn = {'plot'};
        inputs.turnOff = {'nomsg'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'msg',1,...
            'wait_warn',0,...
            'correct',1,... % on by default
            'correct_range',[-3 4],...
            'correct_pct',5,...
            'by_epoch',1,...
            'act_replace','linspace',...'mean',... % 'median'
            'linspace_seconds',1.5,... +/- X seconds either side
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
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                msg{end+1} = sprintf(['data %u columns, assuming first',...
                    ' 2 are left and right channels'],...
                    size(dop.tmp.data,2));
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                if ~isfield(dop,'event')
                    [dop,okay,msg] = dopEventMarkers(dop,okay,msg);
                    % refresh the data if necessary
                    [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                else
                    msg{end+1} = dopEventExistMsg;
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
            elseif size(dop.tmp.data,3) > 1
                dop.tmp.data_type = 'epoched';
                msg{end+1} = 'Epoched data inputted';
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            else
                okay = 0;
                msg{end+1} = ['Data type unknown: expecting continuous or'...
                    'epoched. Can''t continue function'];
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            
        end
        %% activation range check
        if okay
            if dop.tmp.correct_range(1) < dop.tmp.correct_range(2)
                
                dop.tmp.range_type = 'sd';
                msg{end+1} = sprintf(['Checking for data points below %i',...
                    ' and above %i standard deviations of mean.'],...
                    dop.tmp.correct_range);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                % activation_range_values for the left and right channels
                % left = row 1, right = row 2
                if size(dop.tmp.data,3) == 1
                    dop.tmp.act_mean = mean(dop.tmp.data(:,1:2));
                    dop.tmp.act_std = std(dop.tmp.data(:,1:2));
                else
                    dop.tmp.act_mean = squeeze(mean(mean(dop.tmp.data(:,:,1:2))));
                    dop.tmp.act_std = squeeze(mean(std(dop.tmp.data(:,:,1:2))));
                end
                dop.tmp.correct_range_values(1,:) = dop.tmp.act_mean + dop.tmp.act_std*dop.tmp.correct_range(1);
                dop.tmp.correct_range_values(2,:) = dop.tmp.act_mean + dop.tmp.act_std*dop.tmp.correct_range(2);
            else
                okay = 0;
                msg{end+1} = sprintf(['Lower correct range (%3.2f) is',...
                    ' higher than the upper (%3.2f) - this won''t work!'],...
                    dop.tmp.correct_range);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
        end
        %% main code
        if okay
            dop.tmp.n_epochs = 1;
            dop.data.act_correct = dop.tmp.data; %dop.data.use;
            if strcmp(dop.tmp.data_type,'continuous') && dop.tmp.by_epoch
                dop.tmp.n_epochs = dop.event.n;
                dop.tmp.patch_k = 0;
                dop.data.act_correct_sample = zeros(size(dop.tmp.data,1),1);
                dop.data.act_correct_patch = []; % cue for plotting
            elseif strcmp(dop.tmp.data_type,'epoched')
                dop.tmp.n_epochs = size(dop.tmp.data,2);
            end
            dop.epoch.act_correct_note = sprintf(['logical variable denoting epochs',...
                ' with activation within acceptable range:\n\t',...
                'Left values < %3.2f or > %3.2f and',...
                ' Right values < %3.2f or > %3.2f'],...
                dop.tmp.correct_range_values(:,1),dop.tmp.correct_range_values(:,2));
            msg{end+1} = dop.epoch.act_correct_note;
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            
            dop.epoch.act_correct = ones(1,dop.tmp.n_epochs);
            
            for j = 1 : dop.tmp.n_epochs
                switch dop.tmp.data_type
                    case 'continuous'
                        dop.tmp.filt_limits = dop.event.samples(j) + dop.tmp.epoch/(1/dop.tmp.sample_rate);
                        if dop.tmp.filt_limits(1) < 1
                            msg{end+1} = sprintf(['Epoch %u is short by'...
                                ' %u samples (%3.2f secs). Checking available'],...
                                j,abs(dop.tmp.filt_limits(1)),...
                                dop.tmp.filt_limits(1)*(1/dop.tmp.sample_rate));
                            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                            dop.tmp.filt_limits(1) = 1;
                        end
                        if dop.tmp.filt_limits(2) > size(dop.tmp.data,1)
                            msg{end+1} = sprintf(['Epoch %u is short by'...
                                ' %u samples (%3.2f secs). Checking available'],...
                                j,size(dop.tmp.data,1) - dop.tmp.filt_limits(2),...
                                (size(dop.tmp.data,1)-dop.tmp.filt_limits(2))*(1/dop.tmp.sample_rate));
                            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                            dop.tmp.filt_limits(2) = size(dop.tmp.data,1);
                        end
                        dop.tmp.filt = dop.tmp.filt_limits(1) : dop.tmp.filt_limits(2);
                        dop.tmp.xdata = (1:size(dop.tmp.data,1))*(1/dop.tmp.sample_rate);
                        dop.tmp.filt_data = dop.tmp.data(dop.tmp.filt,1:2);
                    case 'epoched'
                        dop.tmp.filt = 1 : size(dop.tmp.data,1);
                        dop.tmp.filt_data = dop.tmp.data(:,j,1:2);
                end
                dop.tmp.under = bsxfun(@lt,dop.tmp.filt_data(:,1:2),dop.tmp.correct_range_values(1,:));
                dop.tmp.over = bsxfun(@gt,dop.tmp.filt_data(:,1:2), dop.tmp.correct_range_values(2,:));
                dop.tmp.all = bsxfun(@plus,dop.tmp.under,dop.tmp.over);
                dop.tmp.pct = sum(dop.tmp.all)/numel(dop.tmp.all)*100;
                dop.tmp.adjust = dop.tmp.pct <= dop.tmp.correct_pct;
                
                dop.epoch.act_cor_pct_left_over = sum(dop.tmp.over(:,1))/numel(dop.tmp.over(:,1))*100;
                dop.epoch.act_cor_pct_left_under = sum(dop.tmp.under(:,1))/numel(dop.tmp.under(:,1))*100;
                dop.epoch.act_cor_pct_right_over = sum(dop.tmp.over(:,2))/numel(dop.tmp.over(:,2))*100;
                dop.epoch.act_cor_pct_right_under = sum(dop.tmp.under(:,2))/numel(dop.tmp.under(:,2))*100;
                
                for i = 1 : numel(dop.tmp.adjust) % left and right channels
                    if dop.tmp.adjust(i) && dop.tmp.pct(i) % can't be zero
                        dop.epoch.act_correct(j) = 1;
                        % check if the method is okay
                        if isempty(strcmp({'mean','median','linspace'},dop.tmp.act_replace))
                            % adjusted from ~sum to isempty 22-May-2015 NAB
                            msg{end+1} = sprintf(['Activation' ...
                                ' correction method ''%s'' not'...
                                ' recognised: defaulting to ''%s'''],...
                                dop.defaults.act_replace);
%                             okay = 0;
                            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                            dop.tmp.act_replace = dop.defaults.act_replace;
                        end
%                         if okay % added 22-May-2015 NAB
                            msg{end+1} = sprintf(['Correcting %u samples',...
                                ' (%3.2f%%) in %s channel with ''%s'':',...
                                ' values < %3.2f or > %3.2f'],...
                                sum(dop.tmp.all(:,i)),dop.tmp.pct(i),...
                                dop.tmp.ch_labels{i},dop.tmp.act_replace,...
                                dop.tmp.correct_range_values(:,i));
                            
                            if ~strcmp(dop.tmp.act_replace,'linspace')
                                dop.tmp.replace_value = eval([dop.tmp.act_replace,'(dop.tmp.filt_data(:,i))']);
                                msg{end} = strrep(msg{end},sprintf('''%s''',dop.tmp.act_replace),...
                                    sprintf('''%s'' = %3.2f',dop.tmp.act_replace,...
                                    dop.tmp.replace_value));
                            end
                            % change the message to be appropriate for epoch
                            % correction
                            if or(and(strcmp(dop.tmp.data_type,'continuous'),dop.tmp.by_epoch),...
                                    strcmp(dop.tmp.data_type,'epoch'))
                                msg{end} = strrep(msg{end},'Correcting',...
                                    sprintf('Epoch %u: Correcting',j));
                            end
                            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                            % could plot at this point on the way through and
                            % possibly make decisions about whether or not you
                            % want this correction: 03-Sep-2014 not yet
                            % implemented
                            %                         if dop.tmp.plot
                            %                             dop.tmp.h = figure;
                            %                             dop.tmp.xdata = dop.tmp.filt*(1/dop.tmp.sample_rate);
                            %                             plot(dop.tmp.xdata,dop.tmp.filt_data(:,i),...
                            %                                 'DisplayName','original');
                            %                             hold;
                            %                         end
                            switch dop.tmp.act_replace
                                case {'mean','median'}
                                    dop.tmp.filt_data(logical(dop.tmp.all(:,i)),i) = ...
                                        eval([dop.tmp.act_replace,'(dop.tmp.filt_data(:,i))']);
                                    
                                case 'linspace'
                                    % need to look at sections of continuous
                                    % extremes
                                    dop.tmp.pts = find(dop.tmp.all(:,i));
                                    dop.tmp.pts_diff = diff(dop.tmp.pts);
                                    dop.tmp.consecutive = find(dop.tmp.pts_diff == 1);
                                    k = 0; % set counter
                                    while okay && k < numel(dop.tmp.pts)
                                        k = k + 1; % count up
                                        % single sample
                                        k1 = dop.tmp.pts(k) - ceil(dop.tmp.linspace_seconds/(1/dop.tmp.sample_rate)); % previous point
                                        k2 = dop.tmp.pts(k) + floor(dop.tmp.linspace_seconds/(1/dop.tmp.sample_rate)); % next point
                                        % check to see if there are consecutive
                                        % points
                                        if sum(dop.tmp.consecutive == k)
                                            n_consec = find(dop.tmp.pts_diff(k:end) ~= 1,1,'first');
                                            if isempty(n_consec)
                                                k = numel(dop.tmp.pts)-1;
                                            else
                                                k = k + n_consec-1; % increase k to skip consecutive points
                                            end
                                            if k2 < dop.tmp.pts(k)+1
                                                k2 = dop.tmp.pts(k)+1; % set end point for linspace to be the next point after new k position
                                            end
                                        end
                                        
                                        
                                        if k1 < 1
                                            k1 = 1;
                                            % could be big difference between
                                            % these points so use k2_value
                                            if k2 > size(dop.tmp.filt_data,1)
                                                okay = 0;
                                                msg{end+1} = 'Surprising problem with consecutive spiking or dropout';
                                                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                                            else
                                                k1_value = dop.tmp.filt_data(k2,i);
                                            end
                                        else
                                            k1_value = dop.tmp.filt_data(k1,i);
                                        end
                                        if okay
                                            if k2 > size(dop.tmp.filt_data,1)
                                                k2 = size(dop.tmp.filt_data,1);
                                                k2_value = k1_value;
                                            else
                                                k2_value = dop.tmp.filt_data(k2,i);
                                            end
                                            
                                            dop.tmp.filt_data(k1:k2,i) = ...
                                                linspace(k1_value,k2_value,numel(k1:k2));
                                            dop.tmp.patch_k = dop.tmp.patch_k + 1;
                                            % patch time in seconds
                                            dop.data.act_correct_sample(dop.tmp.filt(1)+[k1 k2]) = 1;
                                            dop.data.act_correct_patch(:,dop.tmp.patch_k) = (dop.tmp.filt(1)+[k1 k2 k2 k1])*(1/dop.tmp.sample_rate);%[dop.tmp.filt
                                        end
                                    end
                            end
%                         end % added 22-May-2015 NAB
                        %                         if dop.tmp.plot
                        %                             plot(dop.tmp.xdata,dop.tmp.filt_data(:,i),'m',...
                        %                                 'DisplayName','corrected');
                        %                             legend('original','correct');
                        %                             uiwait(dop.tmp.h);
                        %                         end
                    elseif dop.tmp.pct(i)
                        dop.epoch.act_correct(j) = -1;
                        msg{end+1} = sprintf(['Not correcting %u samples',...
                            ' (%3.2f%%) in %s channel outside range'],...
                            j,sum(dop.tmp.all(:,i)),dop.tmp.pct(i),...
                            dop.tmp.ch_labels{i});
                        if and(strcmp(dop.tmp.data_type,'continuous'),dop.tmp.by_epoch) ...
                                || strcmp(dop.tmp.data_type,'epoched')
                            
                            msg{end} = strrep(msg{end},'Not',...
                                sprintf('Epoch %u. Not',j));
                        end
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    end
                end
                %% put the corrected data into the new matrix
                if dop.tmp.correct
                    switch dop.tmp.data_type
                        case 'continuous'
                            dop.data.act_correct(dop.tmp.filt,1:2) = dop.tmp.filt_data;
                        case 'epoch'
                            dop.data.act_correct(dop.tmp.filt,j,1:2) = dop.tmp.filt_data;
                    end
                end
            end
            %% overall plot
            if dop.tmp.plot
                switch dop.tmp.data_type
                    case 'continuous'
                        dop.tmp.channel_labels = dop.data.channel_labels;
                        dop.data.channel_labels = [{'rawleft','rawright'},dop.data.channel_labels,'act_correct'];
                        dop.data.act_correct_plot = [dop.tmp.data(:,1:2),dop.data.act_correct,dop.data.act_correct_sample];
                        [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'act_correct_plot');
                        [dop,okay,msg] = dopPlot(dop,okay,msg);
                        
                        uiwait(dop.fig.h);
                        [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                        dop.data.channel_labels = dop.tmp.channel_labels;
                    case 'epoch'
                        msg{end+1} = 'Not sure about epoched plot yet';
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
            end
            %% create logical
            dop.epoch.act_correct = logical(dop.epoch.act_correct);
            if isfield(dop.data,'act_correct')
                [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'act_correct');
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