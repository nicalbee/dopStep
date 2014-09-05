function [dop,okay,msg] = dopEpoch(dop_input,varargin)
% dopOSCCI3: dopEpoch
%
% notes:
% basic structure of a function to save time when creating a new one
%
% * not yet implemented (19-Dec-2013)
%
% Use:
%
% dop = dopEpoch(dop,[]);
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
% Created: 8-Aug-2014 NAB
% Last edit:
% 10-Aug-2014 NAB
% 01-Sep-2014 NAB fixed dopSetBasicInputs
% 04-Sep-2014 NAB msg & wait_warn updates

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'msg',1,...
            'wait_warn',0,...
            'epoch',[], ...
            'sample_rate',[], ...
            'event_height',[],... % needed for dopEventMarkers
            'event_channels',[] ... % needed for dopEventMarkers
            );
        inputs.required = ...
            {'epoch','sample_rate'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        %% refresh event markers
        if okay && size(dop.tmp.data,3) == 1 && ~isfield(dop,'event')
            % continuous data, refresh the event markers
            [dop,okay,msg] = dopEventMarkers(dop,okay,msg,...
                'event_height',dop.tmp.event_height,...
                'event_channels',dop.tmp.event_channels);
            
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        elseif isfield(dop,'event')
            msg{end+1} = dopEventExistMsg;
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        %% check the data for use
        dop.tmp.in_data = dop.tmp.data;
        if okay && size(dop.tmp.in_data,2) > 2 && size(dop.tmp.in_data,3) == 1
            dop.tmp.data = dop.tmp.in_data(:,1:2);
        elseif okay && size(dop.tmp.in_data,3) >= 2 && isfield(dop,'event')% diff and average
            okay = 0;
            msg{end+1} = ['Data already epoched. Reset dop.tmp.data to' ...
                ' pre-epoched data: e.g., ''raw'', ''down'', or ''norm'''];
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        if okay
            
            % x-axis data: lower epoch to upper epoch in Hz intervals
            dop.epoch.times_note = 'x axis values in seconds';
            dop.epoch.times = dop.tmp.epoch(1):(1/dop.tmp.sample_rate):dop.tmp.epoch(2);
            
            dop.epoch.samples = dop.tmp.epoch*dop.tmp.sample_rate;
            % create empty epoch data to begin with
            % rows = time, columns = epochs/trials, 3rd dim = hemisphere
            % (left/right)
            dop.data.epoch_labels = {'Left','Right','Difference','Average'};
            dop.data.epoch = zeros(sum(abs(dop.epoch.samples))+1,numel(dop.event.samples),numel(dop.data.epoch_labels));
            % consider keeping data in dop.epoch structure as well: 10-Aug-2014
            dop.epoch.length_note = 'logical variable denoting epochs of acceptable length';
            dop.epoch.length = zeros(1,numel(dop.event.samples));
            dop.epoch.notes = [];
            % considering that notes could be epoch specific... or screening
            % specific variables - currently not: 10-Aug-2014
            
            % possilbe that the inputted data won't be right
            
            
            %         if okay
            for i = 1 : numel(dop.event.samples)
                dop.tmp.i_epoch = dop.event.samples(i) + dop.epoch.samples;
                if dop.tmp.i_epoch(1) <= 0
                    
                    dop.epoch.notes{end+1} = sprintf(['Skipping epoch number %u: ' ...
                        'missing beginning data (%3.2f seconds)'], ...
                        i,dop.tmp.i_epoch(1)/dop.tmp.sample_rate);
                    msg{end+1} = dop.epoch.notes{end};
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                elseif dop.tmp.i_epoch(2) > size(dop.tmp.data,1)
                    dop.epoch.notes{end+1} = sprintf(['Skipping epoch number %u: ' ...
                        'missing end data (%3.2f seconds)'], ...
                        i,(dop.tmp.i_epoch(2)-size(dop.tmp.data,1))/dop.tmp.sample_rate);
                    msg{end+1} = dop.epoch.notes{end};
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                else
                    dop.epoch.length(i) = 1;
                    dop.data.epoch(:,i,1:2) = dop.tmp.data(dop.tmp.i_epoch(1):dop.tmp.i_epoch(2),:);
                end
            end
            dop.epoch.length = logical(dop.epoch.length); % convert to logical array
            
            dop.epoch.notes{end+1} = sprintf('%u epochs of suitable length found of %u available',...
                sum(dop.epoch.length),numel(dop.event.samples));
            msg{end+1} = dop.epoch.notes{end};
            fprintf('\n\t%s\n',msg{end});
            
            for i = 1 : dop.event.n
                dop.data.epoch(:,i,3) = squeeze(dop.data.epoch(:,i,1)) - squeeze(dop.data.epoch(:,i,2));
                dop.data.epoch(:,i,4) = mean(squeeze(dop.data.epoch(:,i,1:2)),2);
            end
            % set the dop.data.use = dop.data.epoch... not sure about this
            % 10-Aug-2014
            [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'epoch');
            % don't think I'll update the dop.tmp.data variable here, just
            % use dop.data.epoch when it's appropriate.
            %         otherwise
            %             fprintf('\tNot yet programmed...\n');
            %     end
            %         end
        end
        dop.okay = okay;
        dop.msg = msg;
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end