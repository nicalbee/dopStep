function [dop,okay,msg] = dopHeartCycle(dop_input,varargin)
% dopOSCCI3: dopHeartCycleCorrect
%
% notes:
% finds and averages over the heart cycle to remove this from the data
%
%
% Use:
%
% dop = dopHeartCycle(dop_input);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
% Created: 18-Dec-2013 NAB
% Last edit:
% 18-Aug-2014 NAB
% 27-Aug-2014 NAB fixed skipping end cycle correction
% 31-Aug-2014 NAB keep all columns of data, not just first 3
% 31-Aug-2014 NAB fixed first and last events as could be incomplete, using
%   next and previous values respectively
% 04-Sep-2014 NAB msg & warn_wait updates
% 20-May-2015 NAB added 'showmsg'

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);
try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        inputs.turnOn = {'plot','filter'};
        inputs.turnOff = {'comment'};%,'correct','linspace'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'showmsg',1,...
            'wait_warn',0,...
            'sample_rate',[], ...
            'signal_channels',[2 3],...
            'event_channels',[],... % really need to keep event data somewhere
            'type','linspace',... % 'correct'
            'window',3, ... % number of samples to look for peak of
            'plot_range',[500 700] ... % 2 numbers and plot will be created
            );
        inputs.required = ...
            {'sample_rate','signal_channels','event_channels'}; %
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        %% data check
        % need to have event data
        if size(dop.tmp.data,3) > 1
            okay = 0;
            msg{end+1} = 'Data already epoched. Reset data to pre-epoched; e.g., dop.data.raw or dop.data.down or dop.data.norm (with ''overall'' method)';
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        elseif size(dop.tmp.data,2) >= max(dop.tmp.event_channels) && numel(unique(dop.tmp.data(:,dop.tmp.event_channels(1)))) > 2
            [dop,okay,msg] = dopChannelExtract(dop,okay,msg);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);          
        elseif size(dop.tmp.data,2) == numel(dop.data.channel_labels) || ...
                size(dop.tmp.data,2) == numel([dop.tmp.signal_channels,dop.tmp.event_channels]) ...
                || numel(unique(dop.tmp.data(:,dop.tmp.event_channels(1)))) == 2
            msg{end+1} = 'Event channels in ''dop.tmp.data''';
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        else
            okay = 0;
            msg{end+1} = sprintf(['Can''t create ''dop.data.event'' variable, as data'...
                ' doesn''t have suitable number of columns:\n\t%u and max' ...
                ' event channel is %u\n\tThis is likely to be a problem at' ...
                ' some point down the track - e.g, dopEpoch.'],...
                size(dop.tmp.data,2),max(dop.tmp.event_channels));
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        end
        
        %     if okay && or(size(dop.tmp.data,2) > 2, size(dop.tmp.data,3) > 1)
        %         if size(dop.tmp.data,2) > 2 && size(dop.tmp.data,3) == 1
        %         dop.tmp.in_data = dop.tmp.data;
        %         dop.tmp.data = dop.tmp.data(:,dop.tmp.signal_channels);
        %         msg{end+1} = 'Pulling out the signal channels';
        %         dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        %         elseif size(dop.tmp.data,3) > 1
        %             okay = 0;
        %             msg{end+1} = 'Data already epoched. Reset data to pre-epoched; e.g., dop.data.raw or dop.data.down or dop.data.norm (with ''overall'' method)';
        %         dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        %         end
        %     end
        if okay
            %     dop.tmp.sample_rate = dop.dop.tmp.sample_rate; % default is 25 Hz
            %     dop.tmp.data = dop.data.raw(:,dop.def.signal_channels(1));
            %     if isfield(dop.data,'down');
            %         dop.tmp.data = dop.data.down(:,dop.def.signal_channels(1));
            %     end
            %     plot_range = []; %[0 500]+length(dop.tmp.data)*.5;
            
            %% >> find dop.tmp.systolic
            % dop.tmp.systolic=1; % treat first point as peak, even though it might not be
            dop.tmp.systolic = [];
            %     dop.tmp.window = 3; % formerly 10, July 2010...some people's heart beats are weird...
            % dop.tmp.use_data = dop.tmp.data;
            % filter window, screening for heart cycles
            
            
            
            dop.tmp.use_data = dop.tmp.data;
            
            %% filter data?
            % I no longer think this is helpful but it might be for some particular
            % data files 10-Aug-2014
            if dop.tmp.filter
                dop.tmp.use_data(:,1:2) = filter(ones(1,dop.tmp.window)/dop.tmp.window,1,dop.tmp.data(:,1:2));
            end
            % this strange number came from trial and error...
            dop.tmp.range = round(dop.tmp.sample_rate/3.7879); % search range/windows
            
            for i = 2 : dop.tmp.range*2+1
                if dop.tmp.use_data(i-1,1) >= dop.tmp.use_data(i-i+1:i,1)
                    if dop.tmp.use_data(i-1,1) >= dop.tmp.use_data(i:i+dop.tmp.range,1)
                        dop.tmp.systolic(end+1) = i-1; %dop.tmp.systolic holds times of dop.tmp.systolic
                    end
                end
            end
            for i = 1 + dop.tmp.range : size(dop.tmp.data,1)-1-dop.tmp.range
                if isempty(dop.tmp.systolic)
                    if and(dop.tmp.use_data(i,1) >= dop.tmp.use_data(i-dop.tmp.range:i-1,1),dop.tmp.use_data(i) >= dop.tmp.use_data(i+1:i+dop.tmp.range,1))
                        dop.tmp.systolic(end+1) = i; %dop.tmp.systolic holds times of dop.tmp.systolic
                    end
                else
                    if and(and(dop.tmp.use_data(i,1) >= dop.tmp.use_data(i-dop.tmp.range:i-1,1),dop.tmp.use_data(i)>=dop.tmp.use_data(i+1:i+dop.tmp.range,1)),...
                            (i-max(dop.tmp.systolic)) > dop.tmp.range) %find a peak
                        dop.tmp.systolic(end+1) = i; %dop.tmp.systolic holds times of dop.tmp.systolic
                    end
                end
            end
            % don't think the last one needs to be one
            %     dop.tmp.systolic = [dop.tmp.systolic size(dop.tmp.data,1)]; % last one needs to be one as well
            %     for i = 1 : length(dop.tmp.systolic)
            %         hc_diastolic(i) =
            %     end
            dop.data.hc_events = zeros(size(dop.tmp.data,1),1);
            dop.data.hc_events(dop.tmp.systolic) = 1;
            
            %% correct?
            switch dop.tmp.type % if dop.tmp.correct || dop.tmp.smooth
                case {'correct','linspace'}
                    if strcmp(dop.tmp.type,'correct')
                        msg{end+1} = 'Correcting for heart cycles using deppe method';
                       dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                    end
                    % might be an elegant way to do this but I'm not sure
                    dop.tmp.hc_correct = zeros(size(dop.tmp.data));
                    dop.tmp.hc_correct(:,3:end) = dop.tmp.data(:,3:end); % strcmp(dop.data.channel_labels,'event')
                    
                    if strcmp(dop.tmp.type,'linspace')
                        msg{end+1} = 'Correcting for heart cycles using deppe method + ''linspace'' adjustment';
                       dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                        dop.tmp.hc_linspace = dop.tmp.hc_correct;
                    end
                    for i = 2 : numel(dop.tmp.systolic)+1
                        if i <= numel(dop.tmp.systolic)%+2
%                             switch i
%                                 case 1 % first event, need to average before this point
%                                     % but if not a whole cycle, average is
%                                     % low - so changing this to be average
%                                     % of next cycle
%                                     dop.tmp.filt = 1 : dop.tmp.systolic(i)-1;
%                                 case numel(dop.tmp.systolic)+1
%                                     dop.tmp.filt = dop.tmp.systolic(i-1) : size(dop.tmp.data,1);
%                                 otherwise
                                    dop.tmp.filt = dop.tmp.systolic(i-1) : dop.tmp.systolic(i)-1;
%                             end
                            dop.tmp.hc_correct(dop.tmp.filt,1:2) = bsxfun(@times,ones(numel(dop.tmp.filt),2),mean(dop.tmp.use_data(dop.tmp.filt,1:2)));
                            if i == 2
                                % first interval may not be complete so use next interval
                                dop.tmp.filt1 = 1 : dop.tmp.systolic(1)-1; % start to point before first hc event
                                dop.tmp.hc_correct(dop.tmp.filt1,1:2) = bsxfun(@times,ones(numel(dop.tmp.filt1),2),mean(dop.tmp.hc_correct(dop.tmp.filt,1:2)));
                            elseif i == numel(dop.tmp.systolic)
                                % last interval may not be complete so use previous interval
                                dop.tmp.filt1 = dop.tmp.systolic(end) : size(dop.tmp.data,1);
                                dop.tmp.hc_correct(dop.tmp.filt1,1:2) = bsxfun(@times,ones(numel(dop.tmp.filt1),2),mean(dop.tmp.hc_correct(dop.tmp.filt,1:2)));
                            end
                        end
                        %% > linspace smoothing
                        if i > 2 && strcmp(dop.tmp.type,'linspace') && exist('linspace','file')
%                             switch i
%                                 case 2
%                                     dop.tmp.filt = 1 : dop.tmp.systolic(i-1);
%                                 case numel(dop.tmp.systolic)+2
%                                     dop.tmp.filt = dop.tmp.systolic(i-2) : size(dop.tmp.data,1);
%                                 otherwise
                                    dop.tmp.filt = dop.tmp.systolic(i-2) : dop.tmp.systolic(i-1);
%                             end
                            dop.tmp.values = dop.tmp.hc_correct([min(dop.tmp.filt) max(dop.tmp.filt)],1:2);
                            dop.tmp.hc_linspace(dop.tmp.filt,1) =  linspace(dop.tmp.values(1,1),dop.tmp.values(2,1),numel(dop.tmp.filt));
                            dop.tmp.hc_linspace(dop.tmp.filt,2) = linspace(dop.tmp.values(1,2),dop.tmp.values(2,2),numel(dop.tmp.filt));
                            if i == 3
                                dop.tmp.filt1 = 1 : dop.tmp.systolic(1);
                                dop.tmp.hc_linspace(dop.tmp.filt1,1:2) = bsxfun(@times,ones(numel(dop.tmp.filt1),2),dop.tmp.hc_linspace(dop.tmp.filt1(end)+1,1:2));
                            elseif i == numel(dop.tmp.systolic)+1
                                dop.tmp.filt1 = dop.tmp.systolic(end) : size(dop.tmp.data,1);
                                dop.tmp.hc_linspace(dop.tmp.filt1,1:2) = bsxfun(@times,ones(numel(dop.tmp.filt1),2),dop.tmp.hc_linspace(dop.tmp.filt1(1)-1,1:2));
                            end
                        end
                    end
                    
                otherwise
                    okay = 0;
                    msg{end+1} = sprintf('''%s'' correction type not recognised',...
                        dop.tmp.type);
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
            
            %% look at the data?
            % probably create a gui for this at some point 10-Aug-2014
            % I'm thinking there's a way to incorporate this into the
            % current dopPlot operation as it's easy to navigate the data
            % with - creating a 'hcdata' dop.data.use is a solution - then
            % switching back - also updating the dop.data.channel_labels
            % for labelling
            
            % save a copy of the labels
            dop.tmp.channel_labels = dop.data.channel_labels;
            dop.data.hc_data = [dop.tmp.data(:,1:2),dop.data.hc_events*max(dop.tmp.data(:,1))*1.1];
            dop.data.channel_labels = {'rawleft','rawright','hc_events'};
            plot_okay = 1;
            if strcmp(dop.tmp.type,'linspace') && exist('linspace','file') && isfield(dop.tmp,'hc_linspace')
                dop.data.channel_labels(end+1:end+2) = {'correctleft','correctright'};
                dop.data.hc_data = [dop.data.hc_data,dop.tmp.hc_linspace(:,1:2)];
            elseif isfield(dop.tmp,'hc_correct')
                dop.data.hc_data = [dop.data.hc_data,dop.tmp.hc_correct(:,1:2)];
                dop.data.channel_labels(end+1:end+2) = {'correctleft','correctright'};
            else
                plot_okay = 0;
            end
            if okay && dop.tmp.plot && plot_okay
                [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'hc_data');
                [dop,okay,msg] = dopPlot(dop,okay,msg);
                %                 dopPlotLegend(dop.fig.h);
                uiwait(dop.fig.h);
                [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
            end
            dop.data.channel_labels = dop.tmp.channel_labels;
%             if okay  && ~isempty(dop.tmp.plot_range)
%                 dop.tmp.h = figure; %hold;
%                 dop.tmp.range_array = dop.tmp.plot_range(1) : dop.tmp.plot_range(2);
%                 plot(dop.data.hc_events(dop.tmp.range_array)*250,'k','DisplayName','Events'); hold;
%                 set(gca,'XLim',[1 diff(dop.tmp.plot_range)]);
%                 plot(dop.tmp.data(dop.tmp.range_array,1),'--b','linewidth',1,'DisplayName','Left');
%                 plot(dop.tmp.hc_correct(dop.tmp.range_array,1),'b','linewidth',2,'DisplayName','Left Correct');
%                 plot(dop.tmp.data(dop.tmp.range_array,2),'--r','linewidth',1,'DisplayName','Right');
%                 plot(dop.tmp.hc_correct(dop.tmp.range_array,2),'r','linewidth',2,'DisplayName','Right Correct');
%                 
%                 if dop.tmp.filter
%                     plot(dop.tmp.use_data(dop.tmp.range_array,1),'--c','DisplayName','Filtered');
%                 end
%                 if strcmp(dop.tmp.type,'linspace')
%                     plot(dop.tmp.hc_linspace(dop.tmp.range_array,1),'--g','linewidth',1,'DisplayName','Left Smooth');
%                     plot(dop.tmp.hc_linspace(dop.tmp.range_array,2),'--m','linewidth',1,'DisplayName','Right Smooth');
%                 end
%                 legend(get(dop.tmp.h,'CurrentAxes')); % doesn't always work...
%                 fprintf('Press any key to continue\n');
%                 pause;
%                 try; close(dop.tmp.h); end
%             end
            %% update 'dop.data.use'
            if okay
                switch dop.tmp.type
                        case 'correct'
                            dop.data.hc_correct = dop.tmp.hc_correct;
                            [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'hc_correct');
                        case 'linspace'
                            if exist('linspace','file')
                                msg{end+1} = 'Smoothing heart cycles corrected data (corrected using deppe method)';
                                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                                
                                dop.data.hc_linspace = dop.tmp.hc_linspace;
                                [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'hc_linspace');
                                
                            elseif ~exist('linspace','file')
                                msg{end+1} = ['Smoothing heart cycles requested but requires' ...
                                    '''linspace'' MATLAB function which is not on path'];
                                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                            end
                end
                [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
            end
            %% pulsitility
            % maybe one day... but then again, perhaps better for the machine to
            % record this 10-Aug-2014
        end
        %% outputs
        dop.okay = okay;
        dop.msg = msg;
        dopOSCCIindent('done',dop.tmp.comment);%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end