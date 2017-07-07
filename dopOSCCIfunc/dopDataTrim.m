function [dop,okay,msg] = dopDataTrim(dop_input,varargin)
% dopOSCCI3: dopDataTrim
%
% notes:
% cuts the any extra data off the beginning and end of the data based upon
% the lower and upper epoch values and event markers
%
%
% Use:
%
% dop = dopDataTrim(dop,[okay],[msg]);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
%
% Created: 19-Dec-2013 NAB
% Last edit:
% 29-Aug-2014 NAB
% 04-Sep-2014 NAB msg & wait_warn updates
% 20-May-2015 NAB added 'showmsg'
% 25-Feb-2016 NAB added a 'manual_trim' which allows you to cut-off the
%   start and end of the data. In this case, used it to get rid of
%   erroneous event makers but might be useful for other things...
% 28-Sep-2016 NAB added trim event option so you can specify to trim the
%   data based on a specific event channel, if there are more than 1.
%   Defaults to the first.
% 27-July-2017 NAB adjusted to make sure we keep the first event marker
%   when the lower epoch value is >= 0

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        msg{end+1} = sprintf('Run: %s',mfilename);
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        
        inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'trim_event',1,...
            'showmsg',1,...
            'wait_warn',0,...
            'epoch',[], ... %
            'manual_trim',[],...
            'event_height',[],... % needed for dopEventMarkers
            'event_channels',[], ... % needed for dopEventMarkers
            'sample_rate',[] ... % not critical for dopEventMarkers - important for manual
            );
        inputs.required = ...
            {'epoch'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        if ~isfield(dop,'event')
            % get the latest event markers
            [dop,okay,msg] = dopEventMarkers(dop,okay,msg);
            % refresh the tmp data
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        else
            msg{end+1} = dopEventExistMsg;
        end
        if okay
            if ~isempty(dop.tmp.manual_trim)
                % I want to cut some of the start of the file 'manually'
                dop.tmp.sample_time = (1/dop.tmp.sample_rate);
                dop.tmp.samples = [1 size(dop.tmp.data,1)]; % no change
                dop.tmp.samples(1) = dop.tmp.manual_trim(1)/dop.tmp.sample_time;
                if numel(dop.tmp.manual_trim) == 2
                    dop.tmp.samples(2) = dop.tmp.manual_trim(2)/dop.tmp.sample_time;
                end
                msg{end+1} = sprintf(['Removing data before %3.2f & ',...
                    'after %3.2f seconds (full length = %3.2f seconds).'],...
                    dop.tmp.samples*(1/dop.tmp.sample_rate),dop.tmp.samples(2)*(1/dop.tmp.sample_rate));
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                
            else
            dop.tmp.events = dop.event(dop.tmp.trim_event).samples;
            % current in seconds, need to turn into samples/sample
            % points
            dop.tmp.epoch_samples = dop.tmp.epoch/(1/dop.tmp.sample_rate);
            
            % lower and uppper sample points of the collected data
            % need an extra sample either way to set the markers at 0
            dop.tmp.samples = [dop.tmp.events(1)+dop.tmp.epoch_samples(1) .... % lower point, should be negative
                dop.tmp.events(end)+dop.tmp.epoch_samples(2)]; % upper point
            % check to make sure there's enough data at the start to
            % trim
            if dop.tmp.samples(1) <= 0
                dop.tmp.samples(1) = 1;
                msg{end+1} = sprintf(['There is not enough data before the first '...
                    'event marker to trim\n\tat your specified lower '...
                    'epoch value (%i), so using all available data\n',...
                    '\tAvailable data: %5.2f seconds\n'],...
                    dop.tmp.epoch(1),dop.tmp.events(1)/dop.use.sample_rate);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            else
                msg{end+1} = sprintf(['There is enough data before the first '...
                    'event marker to trim\n\tat your specified lower '...
                    'epoch value (%i)\n',...
                    '\tAvailable data: %5.2f seconds\n'],...
                    dop.tmp.epoch(1),dop.tmp.events(1)/dop.use.sample_rate);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                if dop.tmp.epoch(1) >= 0
                    dop.tmp.samples(1) = 1;
                    % 07-July-2017 we need to keep the first event marker!
                end
            end
            
            % check to make sure there's enough data at the end to
            % trim
            if dop.tmp.samples(2) > size(dop.tmp.data,1)
                dop.tmp.samples(2) = size(dop.tmp.data,1);
                msg{end+1} = sprintf(['There''s not enough data after the last'...
                    'event marker to trim\n\tat your specified upper '...
                    'epoch value (%i), so using all available data\n',...
                    '\tAvailable data: %5.2f seconds'],...
                    dop.tmp.epoch(2),(size(dop.tmp.data,1) - dop.tmp.events(end))/dop.use.sample_rate);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            else
                msg{end+1} = sprintf(['There''s enough data after the last '...
                    'event marker to trim\n\tat your specified upper '...
                    'epoch value (%i)\n',...
                    '\tAvailable data: %5.2f seconds'],...
                    dop.tmp.epoch(2),(size(dop.tmp.data,1) - dop.tmp.events(end))/dop.use.sample_rate);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
            end
            dop.data.trim = dop.tmp.data(dop.tmp.samples(1):dop.tmp.samples(2),:);
            
            % update the use function for the dopEvent Marker update
            %                 dop.data.use = dop.data.trim;
            % update what's been done to the data
            [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'trim');
            % update the event markers to be inline with the trim
            [dop,okay,msg] = dopEventMarkers(dop,okay,msg);
            
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
            
        end
        
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end