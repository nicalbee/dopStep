function [dop,okay,msg] = dopEventMarkers(dop_input,varargin) % ,downsample_rate)
% dopOSCCI3: dopEventMarkers
%
% notes:
% finds the event markers and creates the 'dop.event' variable
%
%
% Use:
%
% dop = dopEventMarkers(dop);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) okay for dopOSCCI to use
% - msg = message about success of function
%
% Created: 17-Dec-2013 NAB
% Last edit:
% 9-Aug-14 NAB
% 31-Aug-14 NAB should now work after dopEventChannels is called
% 04-Sep-14 NAB msg & wait_warn updates
% 05-Sep-14 NAB added dopPeriodCheck
% 03-Jul-15 NAB examining separation between events for outliers
% 30-Sep-16 NAB added data column to dop.event(x) structure for epoching -
%   multiple event processing/periods of interest
% 27-Mar-2017 NAB added input to remove from start or end if extra event
%   markers are found, more then dop.def.num_events
% 28-Apr-2017 NAB okay okay check to initial check
% 07-July-2017 NAB fixed remove_end option
% 13-Nov-2017 NAB added dop.step.(mfilename) = 1;
% 2021-Jan-11 NAB added 'remove_short' option to exclude event markers that
%   aren't separated enough
% 2021-June-22 NAB created dopIQR: MATLAB update has changed the IQR
%   function...

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent; % dopOSCCIindent('run',dop.tmp.comment);%fprintf('\nRunning %s:\n',mfilename);
        %         inputs.turnOff = {'comment'};
        inputs.turnOn = {'gui'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'file',[],...
            'msg',1,...
            'wait_warn',0,...
            'event_sep',[],...
            'outlier_type','iqr',... % or 'sd'
            'outlier_value',1.5,... % or 3 for sd
            'event_height',[],... % really needs to be specified but could set to 1000
            'event_channels',[], ... % could take last column by default
            'num_events',[],...
            'remove_start',0,...
            'remove_end',0,...
            'remove_short',0,...
            'sample_rate',[] ... % not critical
            );
        inputs.required = ...
            {'event_height','event_channels'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        %% remove start vs end
        if okay && dop.tmp.remove_start && dop.tmp.remove_end
            % this can't be true - can't have it both ways!
            dop.tmp.remove_end = 0;
            msg{end+1} = sprintf('\t!!! Remove start & end turned on/set to 1: this can''t happen. Defaulting to removing events from start.');
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        
        %% check inputs
        if okay && size(dop.tmp.data,3) > 1
            okay = 0;
            msg{end+1} = sprintf(['''dop.data.use'' variable has 3rd'...
                ' dimension - probably already epoched.'...
                'set ''dop.data.use'' to earlier data structure, ' ...
                'e.g., dop.data.raw or dop.data.down or dop.data.trim',...
                '\n(%s: %s)'], size(dop.tmp.data,3),mfilename,dop.file);
            
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        elseif okay && size(dop.tmp.data,2) == 2 && ~isfield(dop.data,'event')
            okay = 0;
            msg{end+1} = sprintf(['Only 2 data columns, assuming left & right' ...
                ' signal data, and ''dop.data.event'' doesn''t exist.' ...
                ' Need event data somewhere for %s function.',...
                '\n(%s: %s)'], mfilename,mfilename,dop.file);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            
        end
        
        
        if okay
            if isfield(dop.data,'event_plot')
                msg{end+1} = '''dop.data.event_plot'' found - better to run this before dopEventChannel';
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                % not sure it's worth doing this but after using
                % dopEventChannel this data is set to ones and zeros so the
                % marker height and difference calculations aren't needed
                % - I'm not sure whether dopEventChannel is a sensible
                % thing 27-Aug-2014 NAB
                dop.tmp.samples = find(dop.tmp.data(:,strcmp(dop.data.channel_labels,'event')));
                
                for j = 1 : numel(dop.data.channel_labels)
                    dop.event(j).samples = dop.tmp.samples(j);
                    if isempty(dop.event(j).samples)
                        okay = 0;
                        msg{end+1} = sprintf(['No events found in - could be that'...
                            ' you''ve changed the length of the data after'...
                            ' calling the ''dopEventChannels'' function\n(%s: %s)'],...
                            mfilename,dop.file);
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    end
                end
            elseif size(dop.tmp.data,2) >= max([dop.use.signal_channels dop.use.event_channels])
                dop.tmp.ev = dop.tmp.data(:,dop.tmp.event_channels) > dop.tmp.event_height;
            else
                % may or may not be multiple event channels, not sure this
                % is programmed to cope with it but perhaps eventually
                % 12-Aug-2014
                dop.tmp.ev_columns = find(strcmp(dop.data.channel_labels,'event'));
                dop.tmp.ev = dop.tmp.data(:,dop.tmp.ev_columns) > dop.tmp.event_height;
            end
            if ~isfield(dop.data,'event_plot')
                if ~sum(dop.tmp.ev)
                    okay = 0;
                    msg{end+1} = sprintf(['No events found greater than %u',...
                        '\n(%s: %s)'], dop.tmp.event_height,mfilename,dop.file);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
                if okay
                    % if point is wider than a single sample, there'll be heaps of points
                    % by subtracting point n from n+1, we'll get around this.
                    dop.tmp.ev_diff = diff(dop.tmp.ev,1) > 0;
                end
                if okay && ~sum(sum(dop.tmp.ev_diff)) % any of the events have missing markers
                    okay = 0;
                    msg{end+1} = sprintf(['No real events. Probably the case that' ...
                        ' the event signal was on at the start and was then' ...
                        ' reset by the program and then no markers were sent' ...
                        ' to this channel\n(%s: %s)'],mfilename,dop.file);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                elseif okay
                    % get the sample numbers
                    for j = 1 : size(dop.tmp.ev_diff,2)
                        dop.event(j).samples = find(dop.tmp.ev_diff(:,j),sum(dop.tmp.ev_diff(:,j)));
                    end
                end
            end
            if okay
                for j = 1 : size(dop.tmp.ev_diff,2)
                    dop.tmp.ev_columns = find(strcmp(dop.data.channel_labels,'event'));
                    dop.event(j).data = dop.tmp.data(:,dop.tmp.ev_columns(j));
                    
                    
                    dop.event(j).n = numel(dop.event(j).samples);
                    msg{end+1} = sprintf('\tFound %i events:',dop.event(j).n);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    % code to remove start or end event markers - if set
                    if dop.event(j).n ~= dop.tmp.num_events
                        msg{end+1} = sprintf('\tFound %i events: expected %i',dop.event(j).n,dop.tmp.num_events);
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        if dop.event(j).n > dop.tmp.num_events(j) && or(dop.tmp.remove_start,dop.tmp.remove_end)
                            dop.tmp.remove = [];
                            if dop.tmp.remove_start
                                msg{end+1} = sprintf('\t''Remove start'' turned on: extra events (> %i) will be removed earlist event makers',dop.tmp.num_events(j));
                                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                                dop.tmp.remove = 1 : diff([dop.tmp.num_events dop.event(j).n]);
                                
                            elseif dop.tmp.remove_end
                                msg{end+1} = sprintf('\t''Remove end'' turned on: extra events (> %i) will be removed from the later event makers',dop.tmp.num_events(j));
                                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                                dop.tmp.remove = (1+dop.event(j).n-diff([dop.tmp.num_events(j) dop.event(j).n])): dop.event(j).n;
                            end
                            if ~isempty(dop.tmp.remove)
                                dop.event(j).samples(dop.tmp.remove) = [];
                                msg{end+1} = sprintf(['\tRemoved: ',dopVarType(dop.tmp.remove)],dop.tmp.remove);
                                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                                
                                dop.event(j).n = numel(dop.event(j).samples);
                                msg{end+1} = sprintf('\tNow %i events:',dop.event(j).n);
                                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                            end
                        end
                        
                    end
                    dop.tmp.removed_short = 0;
%                     if ~dop.tmp.remove_short
%                         dop.tmp.removed_short = 1;
%                     end
                    while 1
                        %% > separation
                        dop.event(j).separation_samples = mean(diff(dop.event(j).samples));
                        dop.event(j).separation_samples_stdev = std(diff(dop.event(j).samples));
                        dop.event(j).separation_samples_min = min(diff(dop.event(j).samples));
                        dop.event(j).separation_samples_max = max(diff(dop.event(j).samples));
                        %% get the event times
                        if ~isempty(dop.tmp.sample_rate)
                            dop.event(j).times_sec = dop.event(j).samples*(1/dop.tmp.sample_rate);
                            dop.event(j).times_ms = dop.event(j).times_sec*1000;
                            dop.event(j).times_min = dop.event(j).times_sec/60;
                            
                            dop.event(j).separation_secs = diff(dop.event(j).samples*(1/dop.tmp.sample_rate));
                            dop.event(j).separation_secs_mean = mean(dop.event(j).separation_secs);
                            dop.event(j).separation_secs_median = median(dop.event(j).separation_secs);
                            dop.use.event_sep(j) = dop.event(j).separation_secs_mean; % update for auto use in dopSetGetInputs
                            dop.event(j).separation_secs_stdev = std(dop.event(j).separation_secs);
                            dop.event(j).separation_secs_min = min(dop.event(j).separation_secs);
                            dop.event(j).separation_secs_max = max(dop.event(j).separation_secs);
                            dop.event(j).separation_secs_iqr = dopIQR(dop.event(j).separation_secs);
                            
                            
%                             if license('test', 'statistics_toolbox')
%                                 dop.event(j).separation_secs_iqr = iqr(dop.event(j).separation_secs);
%                             end
                            %         dop.event(j).use_samples = dop.event.samples;
                            %         dop.event.downsamples = ones(dop.event.n,1)*-1; % make it negative when it's not available
                            %         if exist('downsample_rate','var') && ~isempty(downsample_rate) && ~isfield(dop.event,'downsamples')
                            %             dop.event.downsamples = round(dop.event.samples/...
                            %                 (sample_rate/downsample_rate));
                            %             dop.event.use_samples = dop.event.downsamples;
                            %         elseif ~isfield(dop.event,'downsamples')
                            %             fprintf('\t''dop.event.downsamples'' variable already exists, no correction required\n');
                            %             dop.event.downsamples = dop.event.sample;
                            %         end
                            
                            for i = 1 : dop.event(j).n
                                msg{end+1} = sprintf(['\t- %u:\t mins = %3.2f, secs = %3.2f, msecs = %.0f, ',...
                                    '[sample = %u]'],...
                                    i,dop.event(j).times_min(i),dop.event(j).times_sec(i),...
                                    dop.event(j).times_ms(i),dop.event(j).samples(i));
                                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                                %             fprintf(['\t- %u:\t min = %3.1f, sec = %3.1f, ms = %.0f, ',...
                                %                 '[sample = %u, down samples = %i]\n'],...
                                %                 i,dop.event(j).times_min(i),dop.event(j).times_sec(i),...
                                %                 dop.event(j).times_ms(i),dop.event(j).samples(i),...
                                %                 dop.event(j).downsamples(i));
                            end
                            
                            %% check the separation
                            if ~isempty(dop.tmp.event_sep)
                                switch dop.tmp.outlier_type
                                    case 'iqr' % interquartile range
                                        % assume normalish distribution and base
                                        % this cut-offs on 1.5*IQR beyond the
                                        % 25th & 75th percentiles
                                        dop.event(j).outliers_range = ...
                                            dop.event(j).separation_secs_median+ ...
                                            [-1 1]*dop.event(j).separation_secs_iqr*(1+dop.tmp.outlier_value);
                                    case 'sd' % standard deviation
                                        dop.event(j).outliers_range = ...
                                            dop.event(j).separation_secs_mean+ ...
                                            [-1 1]*dop.event(j).separation_secs_stdev*dop.tmp.outlier_value;
                                end
                                dop.event(j).outliers = or(dop.event(j).separation_secs < dop.event(j).outliers_range(1),...
                                    dop.event(j).separation_secs > dop.event(j).outliers_range(2));
                                dop.event(j).outliers_short = dop.event(j).separation_secs < dop.event(j).outliers_range(1);
                                dop.event(j).outliers_long = dop.event(j).separation_secs > dop.event(j).outliers_range(2);
                                
                                % these refer to the difference between events, so
                                % the affected events are the 'next' event based on
                                % the difference calcualtion:
                                % diff([3 5 6]) = [2 1];
                                % thefore, assume that the first event is okay
                                % and sum them while we're at it
                                
                                % do it in a loop because it's a little repetitive
                                dop.tmp.outlier_labels = {'','_short','_long'};
                                for i = 1 : numel(dop.tmp.outlier_labels)
                                    % add a 0 at the start of an array, assuming
                                    % that is a column/vertical vector
                                    dop.event(j).(['outliers',dop.tmp.outlier_labels{i}]) = ...
                                        logical([0;dop.event(j).(['outliers',dop.tmp.outlier_labels{i}])]);
                                    
                                    % sum the values to get the n affected
                                    dop.event(j).(['outliers',dop.tmp.outlier_labels{i},'_n']) = ...
                                        sum(dop.event(j).(['outliers',dop.tmp.outlier_labels{i}]));
                                end
                                
                                
                                %                         dop.event(j).outliers_n = sum(dop.event(j).outliers);
                                %                         dop.event(j).outliers_short_n = sum(dop.event(j).outliers_short);
                                %                         dop.event(j).outliers_long_n = sum(dop.event(j).outliers_long);
                                
                                msg{end+1} = sprintf(['%i events marked as potential ouliers based upon ',...
                                    'a temporal separation outside the range of ',...
                                    dopVarType(dop.event(j).outliers_range(1)),' to ',...
                                    dopVarType(dop.event(j).outliers_range(2)),' seconds, ',...
                                    dopVarType(dop.tmp.outlier_value),' based on %s. '...
                                    'Affected events: ',dopVarType(find(dop.event(j).outliers))],...
                                    dop.event(j).outliers_n,...
                                    dop.event(j).outliers_range,dop.tmp.outlier_value,...
                                    dop.tmp.outlier_type,find(dop.event(j).outliers));
                                %                         okay = 0; % to alert
                                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                                %                         okay = 1; % not dire...
                                % could/should screen these - perhaps there needs
                                % to be a dopEpochScreenEventSep function for
                                % this...
                                %                         dop.event.
                                
                                % quick look at the distribution
                                % figure;
                                % subplot(1,2,1);
                                % hist(dop.event.separation_secs);
                                % subplot(1,2,2);
                                % boxplot(dop.event.separation_secs);
                            else
                                msg{end+1} = sprintf(['''event_sep'' (event separation) '...
                                    'variable/input is empty. So can''t check for the '...
                                    'possibility of outliers.']);
                                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                            end
                            
                            %% Remove short epochs
                            % 2021-Jan-11
                            if ~dop.tmp.removed_short && dop.tmp.remove_short
                                dop.tmp.data = dop.event(j).data; % I think this needs to be updated too
                                dop.tmp.samples = dop.event(j).samples; % keep a copy
                                jj = 0;
                                while 1
                                    jj = jj + 1; % counter
                                    dop.tmp.sample_secs = dop.tmp.samples*(1/dop.tmp.sample_rate);
                                    dop.tmp.sep_secs = diff(dop.tmp.sample_secs);
                                    dop.tmp.sep_small = dop.tmp.sep_secs < dop.tmp.event_sep;
                                    if sum(dop.tmp.sep_small) % any too small
                                        % find the first one
                                        dop.tmp.sep_small_first = find(dop.tmp.sep_small,1,'first');
                                        
                                        msg{end+1} = sprintf(['Time between events %i and %i (%2.2f secs) ',...
                                            'is less than requested event separation (%2.2f secs), ',...
                                            'removing event.'],dop.tmp.sep_small_first, dop.tmp.sep_small_first+1, ...
                                            dop.tmp.sep_secs(dop.tmp.sep_small_first), dop.tmp.event_sep);
                                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                                        
                                        % update the data/remove the event
                                        dop.tmp.event_samples = dop.tmp.samples(dop.tmp.sep_small_first + 1): dop.tmp.samples(dop.tmp.sep_small_first + 1) + 10; % wider than we need but just to be sure
                                        dop.tmp.data(dop.tmp.event_samples) = 0;
                                        dop.tmp.samples(dop.tmp.sep_small_first + 1) = []; % remove it
                                    else
                                        break
                                    end
                                end
                                % update the data a redo the loop
                                dop.event(j).data = dop.tmp.data;
                                dop.event(j).samples = dop.tmp.samples;
                                dop.event(j).n = numel(dop.event(j).samples);
                                dop.tmp.removed_short = 1;
                                
                                msg{end+1} = sprintf(['%i events removed being ',...
                                    'less than requested event separation (%2.2f secs).'],...
                                    jj-1, dop.tmp.event_sep);
                                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                                
                            elseif dop.tmp.remove_short
                                fprintf('Short already removed.\n');
                                % should draw in the separation variable and warn if
                                % there is potentially overlap
                                [dop,~,msg] = dopPeriodChecks(dop,okay,msg);
                                [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                                break
                            else
                                % should draw in the separation variable and warn if
                                % there is potentially overlap
                                [dop,~,msg] = dopPeriodChecks(dop,okay,msg);
                                [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                                if ~dop.tmp.remove_short
                                    break
                                end
                            end
                        else
                            msg{end+1} = ['''dop.tmp.sample_rate'' variable not ',...
                                'specified. Sample times in seconds haven''t been calculated'];
                            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        end
                        %                         %% Remove short epochs
                        %                         % 2021-Jan-11
                        %                         if ~dop.tmp.removed_short && dop.tmp.remove_short
                        %                             dop.tmp.samples = dop.event(j).samples; % keep a copy
                        %                             jj = 0;
                        %                             while 1
                        %                                 jj = jj + 1; % counter
                        %                                 dop.tmp.sample_secs = dop.tmp.samples*(1/dop.tmp.sample_rate);
                        %                                 dop.tmp.sep_secs = diff(dop.tmp.sample_secs);
                        %                                 dop.tmp.sep_small = dop.tmp.sep_secs < dop.tmp.event_sep;
                        %                                 if sum(dop.tmp.sep_small) % any too small
                        %                                     % find the first one
                        %                                     dop.tmp.sep_small_first = find(dop.tmp.sep_small,1,'first');
                        %
                        %                                     msg{end+1} = sprintf(['Time between events %i and %i (%2.2f) ',...
                        %                                         'is less than requested event separation (%2.2f), ',...
                        %                                         'removing event.'],dop.tmp.sep_small_first, dop.tmp.sep_small_first+1, ...
                        %                                         dop.tmp.sep_secs(dop.tmp.sep_small_first), dop.tmp.event_sep);
                        %                                     dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        %                                     dop.tmp.samples(dop.tmp.sep_small_first + 1) = []; % remove it
                        %                                 else
                        %                                     break
                        %                                 end
                        %                             end
                        %                             % update the data a redo the loop
                        %                             dop.event(j).samples = dop.tmp.samples;
                        %                             dop.event(j).n = numel(dop.event(j).samples);
                        %                             dop.tmp.removed_short = 1;
                        %
                        %                             msg{end+1} = sprintf(['%jj events removed being ',...
                        %                                         'less than requested event separation (%2.2f).'],...
                        %                                         jj, dop.tmp.event_sep);
                        %                                     dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        %
                        %                         else
                        %                             fprintf('Short already removed.\n');
                        %                             break % break the while loop
                        %                         end
                    end
                end
            end
        end
        %         end
        dop.okay = okay;
        dop.msg = msg;
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
        %% specific output for gui (dopStep)
        if dop.tmp.gui
            dop.step.(mfilename) = 0;
            if okay
                dop.step.(mfilename) = 1;
                msg = sprintf(['''%s'' function run: %i events found.',...
                    '\n\nMedian separation = ',...
                    '%3.2f seconds (min = %3.2f, max = %3.2f)\n'],...
                    mfilename,...
                    dop.event(j).n,median(dop.event(j).separation_secs),...
                    min(dop.event(j).separation_secs),max(dop.event(j).separation_secs));
                
                %                 msg = [];% has it's own warning sprintf('Problem with channels: %s\n',dop.tmp.file);
            end
        else
            dop.step.(mfilename) = 1;
        end
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end