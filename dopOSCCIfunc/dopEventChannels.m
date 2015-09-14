function [dop,okay,msg] = dopEventChannels(dop_input,varargin)
% dopOSCCI3: dopEventChannels
%
% [dop,okay,msg] = dopEventChannels(dop,[okay],[msg],[varargin]);
%
% notes:
% sets the event channel to be purely yes/no (1/0) event information
% + creates continuous epoch, baseline, and poi channels
% data appears in: dop.data.event
% + dop.data.*_plot
%
% That is:
% - dop.data.event_plot
% - dop.data.epoch_plot
% - dop.data.baseline_plot
% - dop.data.poi_plot
%
% Use:
%
% [dop,okay,msg] = dopEventChannel(dop,[okay],[msg],[varargin]);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
%   Optional inputs:
% - okay = logical (0 or 1) for problem, 1 = okay/no problem, 0 = not okay/problem
% - msg = message about progress/steps within function
%   note: 'okay' and 'msg' are optional inputs but must be included as the
%   first two inputs after the 'dop_input' variable
%
% > Outputs:
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 1 = okay/no problem, 0 = not okay/problem
% - msg = message about progress/steps within function
%
% Created: 27-Aug-2014 NAB
% Last edit:
% 27-Aug-2014 NAB
% 02-Sep-2014 NAB attempting to create 'patch' information
% 04-Sep-2014 NAB msg & wait_warn updates
% 27-Oct-2014 NAB fixed issue with multiple samples of the same value for k
%   line 128. Could be a one-off issue with the data file but I've made a
%   kludge
% 17-Nov-2014 NAB first epoch too short - not sure why this hasn't come up
%   before - negative numbers as indices fixed.
% 07-Jul-2015 NAB second element in first epoch too short, negative as
%   well, fixed
% 15-Sep-2015 NAB updating for periods with multiple rows

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        %         inputs.turnOn = {'manual'};
        inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'msg',1,...
            'wait_warn',0,...
            'epoch',[], ... %
            'baseline',[],...
            'poi',[],...
            'event_height',[],... % needed for dopEventMarkers
            'event_channels',[], ... % needed for dopEventMarkers
            'sample_rate',[] ...
            );
        inputs.required = ...
            {'epoch','baseline','poi','sample_rate'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        if size(dop.tmp.data,3) > 1
            okay = 0;
            msg{end+1} = ['Data already epoched. Use pre-epoch data:' ...
                ' set using e.g., ''dopUseDataOperations(dop,''norm''))'];
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        if okay && ~isfield(dop,'event')
            [dop,okay,msg] = dopEventMarkers(dop,okay,msg);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        end
        %% main code
        if okay
            dop.data.event = dop.tmp.data; % copy the data to new variable
            dop.data.event(:,strcmp(dop.data.channel_labels,'event')) = 0;
            dop.data.event(dop.event.samples,strcmp(dop.data.channel_labels,'event')) = 1;
            % need 3 points per sample for vertical lines in continuous
            % data: 0 1 0 at the same x value
            dop.data.event_plot = zeros(size(dop.data.event,1),2);% + numel(dop.event.samples)*2,2);
            dop.data.event_plot(:,2) = 1 : size(dop.data.event,1); % x sample data
            
            for i = 1 : numel(dop.event.samples)
                k = find(dop.data.event_plot(:,2) == dop.event.samples(i),1,'first');
                dop.data.event_plot = vertcat(dop.data.event_plot(1 : find(dop.data.event_plot(:,2) == k),:),...
                    [1 k],... % insert an extra k number
                    dop.data.event_plot(find(dop.data.event_plot(:,2) == k) : end,:));
            end
            dop.tmp.periods = {'epoch','baseline','poi'};
            dop.tmp.period_values = [.9 .8 .8]; % portion of y-value in graphs
            dop.tmp.prd_column = find(strcmp(dop.data.channel_labels,'event'));
            for i = 1 : numel(dop.tmp.periods)
                dop.tmp.prd = dop.tmp.periods{i};
                dop.tmp.prd_spec = dop.tmp.prd;
                for jjj = 1 : size(dop.tmp.(dop.tmp.prd),1)
                            dop.tmp.prd_spec = dopSaveSpecificLabel(dop.tmp.prd,dop.tmp.(dop.tmp.prd)(jjj,:));
                
                % patch (see patch function) is the block of colours on the
                % plots
                dop.data.([dop.tmp.prd_spec,'_patch']) = zeros(4,size(dop.tmp.data,2));
                
                dop.data.([dop.tmp.prd_spec,'_plot']) = zeros(size(dop.tmp.data,1),2);
                dop.data.([dop.tmp.prd_spec,'_plot'])(:,2) = 1 : size(dop.data.([dop.tmp.prd_spec,'_plot']),1);
                
                dop.data.event(:,dop.tmp.prd_column+i) = zeros(size(dop.data.event,1),1);
                dop.data.channel_labels{dop.tmp.prd_column+i} = dop.tmp.prd_spec;
                for j = 1 : numel(dop.event.samples)
                    % patch is much easier
                    prd_sec = dop.event.samples(j)*(1/dop.tmp.sample_rate) + dop.tmp.(dop.tmp.prd)(jjj,:);
                    dop.data.([dop.tmp.prd_spec,'_patch'])(:,j) = [prd_sec fliplr(prd_sec)];
                    %                     [dop.tmp.(dop.tmp.patches{i}) fliplr(dop.tmp.(dop.tmp.patches{i}))],...
                    %                             [ones(1,2)*max(get(dop.fig.ax,'Ylim')) ones(1,2)*min(get(dop.fig.ax,'Ylim'))]
                    % regular data first
                    kpt = dop.event.samples(j) + dop.tmp.(dop.tmp.prd)(jjj,:)/(1/dop.tmp.sample_rate);
                    
                    jj = 1;
                    if kpt(jj) < 1;
                        msg{end+1} = sprintf(['Epoch %u: lower bound' ...
                            ' for ''%s'' period is beyond data limits:'...
                            ' %i samples (%3.2f seconds)'],...
                            j,dop.tmp.prd(jjj,:),kpt(jj),kpt(jj)*(1/dop.tmp.sample_rate));
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        kpt(jj) = 1;
                    end
                    jj = 2;
                    if kpt(jj) > size(dop.data.([dop.tmp.prd_spec,'_plot']),1) %  % size(dop.data.event,1)+2;
                        d = kpt(jj) - size(dop.data.([dop.tmp.prd_spec,'_plot']),1);
                        msg{end+1} = sprintf(['Epoch %u: upper bound' ...
                            ' for ''%s'' period is beyond data limits:'...
                            ' %i samples (%3.2f seconds). note:'...
                            ' not a problem for ''epoch'' - likely'...
                            ' to be the last point or later due to procedure'],...
                            j,dop.tmp.prd_spec,d,d*(1/dop.tmp.sample_rate));
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        kpt(jj) = size(dop.data.([dop.tmp.prd_spec,'_plot']),1);
                    end
                    if kpt(jj) < 1
                        % completely missing first epoch
                        msg{end+1} = sprintf(['Epoch %u: upper bound' ...
                            ' for ''%s'' period is beyond data limits:'...
                            ' %i samples (%3.2f seconds). note:'...
                            ' essentially, first epoch is missing'],...
                            j,dop.tmp.prd_spec,kpt(jj),kpt(jj)*(1/dop.tmp.sample_rate));
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        kpt(jj) = 2;size(dop.data.([dop.tmp.prd_spec,'_plot']),1);
                    end
                    
                    dop.data.event(kpt,strcmp(dop.data.channel_labels,dop.tmp.prd_spec)) = 1;
                    % and now the plotting data
                    for jj = 1 : 2
                        
                        % get the index for the next sample value
                        k = find(dop.data.([dop.tmp.prd_spec,'_plot'])(:,2) == dop.event.samples(j));
                        % a kludge for multiple samples of the same
                        % value... might have been a one-off funny data
                        % file 27-Oct-2014 from Lisa Kurylowicz
                        if numel(k) > 1
                            k = k(1);
                        end
                        % lower & uppers points of period in samples
                        kpt(jj) = k + dop.tmp.(dop.tmp.prd)(jjj,jj)/(1/dop.tmp.sample_rate);
                        % make sure it's not outside the limits - all of
                        % this should already have been set and checked...
                        if kpt(jj) < 1;
%                             msg{end+1} = sprintf(['Epoch %u: lower bound' ...
%                                 ' for ''%s'' period is beyond data limits:'...
%                                 ' %i samples (%3.2f seconds)'],...
%                                 j,dop.tmp.prd,kpt(jj),kpt(jj)*(1/dop.tmp.sample_rate));
%                             dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                            kpt(jj) = 1;
                        end
                        if kpt(jj) > size(dop.data.([dop.tmp.prd_spec,'_plot']),1) %  % size(dop.data.event,1)+2;
                            d = kpt(jj) - size(dop.data.([dop.tmp.prd_spec,'_plot']),1);
%                             msg{end+1} = sprintf(['Epoch %u: upper bound' ...
%                                 ' for ''%s'' period is beyond data limits:'...
%                                 ' %i samples (%3.2f seconds). note:'...
%                                 ' not a problem for ''epoch'' - likely'...
%                                 ' to be the last point or later due to procedure'],...
%                                 j,dop.tmp.prd,d,d*(1/dop.tmp.sample_rate));
%                             dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                            kpt(jj) = size(dop.data.([dop.tmp.prd_spec,'_plot']),1);
                        end
                        %                         if jj == 1
                        dop.data.([dop.tmp.prd_spec,'_plot']) = vertcat(...
                            dop.data.([dop.tmp.prd_spec,'_plot'])(1 : kpt(jj),:),...
                            [dop.tmp.period_values(i) dop.data.([dop.tmp.prd_spec,'_plot'])(kpt(jj),2)],... % insert an extra k number
                            dop.data.([dop.tmp.prd_spec,'_plot'])(kpt(jj) : end,:));
                        %                         else
                        %                             dop.data.([dop.tmp.prd,'_plot']) = vertcat(dop.data.([dop.tmp.prd,'_plot'])(1 : kpt(jj),:),...
                        %                             [dop.tmp.period_values(i) kpt(jj)],... % insert an extra k number
                        %                             dop.data.([dop.tmp.prd,'_plot'])(kpt(jj) : end,:));
                        %                         end
                        % event data channel
                        
                        %
                    end
                    
                    dop.tmp.filt = [min(find(dop.data.([dop.tmp.prd_spec,'_plot'])(:,2) == ...
                        dop.data.([dop.tmp.prd_spec,'_plot'])(kpt(1),2),1,'first')),...
                        max(find(dop.data.([dop.tmp.prd_spec,'_plot'])(:,2) == ...
                        dop.data.([dop.tmp.prd_spec,'_plot'])(kpt(2),2),1,'last'))];
                    dop.data.([dop.tmp.prd_spec,'_plot'])(dop.tmp.filt(1)+1:dop.tmp.filt(2)-2,1) = dop.tmp.period_values(i);
                end
                end
            end
            
            % now they're set
            % can people do some selection?
            [dop,okay,msg] = dopUseDataOperations(dop,'event');
            
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