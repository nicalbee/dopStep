function [dop,okay,msg] = dopEpoch(dop_input,varargin)
% dopOSCCI3: dopEpoch
%
% [dop,okay,msg] = dopEpoch(dop_input,[okay],[msg],...)
%
% notes:
% Segment the continuous data into multiple divisions based upon epoch
% values surrounding event markers. The 'dop.data.epoch' out matrix is a
% 3-dimentional matrix with samples/time x number of epochs x data type. Data
% type relates to left and right activation, the left minus right
% difference, and the average of the left and right channels.
%
% also sets dop.epoch.screen to dop.epoch.length - epochs are excluded if
% there is not enough data before the first or after the last event marker
% for the specified epoch.
%
% Use:
%
% [dop,okay,msg] = dopEpoch(dop_input,[okay],[msg],...)
%
% where:
%--- Inputs ---
% - dop_input: dop matlab structure or data matrix, file name, or data
%   directory, depending on the function. Other than 'dop' structure is
%   currently not well tested 07-Sep-2014 NAB
%
%--- Optional, data only:
%   > e.g., ...,0,... or ...,'string',... or ...,cell,...
% - okay:
%   e.g., dopFunction(dop_input,1,...) or dopFunction(dop_input,0,...)
%       or dopFunction(dop_input,[],...)
%   logical (0 or 1) for problem, 0 = no problem, 1 = problem. This can be
%   carried through from previously run functions. If set to 0, the
%   function will not be implemented - designed to skip functions if there
%   is a problem with the data or variable settings.
%
% - msg:
%   > e.g., dopFunction(dop_input,1,msg,...)
%       or dopFunction(dop_input,1,[],...)
%   Cell variable with a history of messages from previously run functions.
%   New messages are appended to the end of the array and can be reported
%   to examine the processing steps using 'dopMessage':
%   e.g. dopMessage(msg) or dopMessage(dop);
%
%   note: okay and msg will only be recognised as the 1st and 2nd inputs
%   after the dop_input variable and only in this order.
%       e.g., dopFunction(dop,okay,msg,...)
%   If run without, e.g., dopFunction(dop,...), okay and msg will be reset
%   to 1 (i.e., no problem) and empty (i.e., []) respectively.
%
%--- Optional, Text + value:
%   > e.g., ...,'variable_name',X,...
%   note: ... indicates that other inputs can be included before or
%   after. The inputs can be included in any order.
%
% - 'epoch':
%   > e.g., dopFunction(dop_input,okay,msg,...,'epoch',[-15 30],...)
%   Lower and Upper epoch values in seconds used to divide the data
%   surrounding the event markers.
%
% - 'sample_rate':
%   > e.g., dopFunction(dop_input,okay,msg,...,'sample_rate',25,...)
%   The sampling rate of the data in Hertz. This is used to convert the
%   'epoch' variable seconds to samples to divide the data into epochs.
%   note: After dopDownsample is run, this value should be the downsampled
%   sample rate.
%
% - 'event_channels':
%   > e.g., dopFunction(dop_input,okay,msg,...,'event_channels',13,...)
%   Column number of data which holds the event information. Typically
%   square signal data.
%   note: 'event_channels' is used within this function as an input for
%   dopEvent Markers if it hasn't previously been called. That is,
%   'dop.event' structure variable is not found
%
% - 'event_height':
%   > e.g., dopFunction(dop_input,okay,msg,...,'event_height',1000,...)
%   Number above which activity in the event channel/column data will be
%   detected as an event marker.
%   note: 'event_height' is used within this function as an input for
%   dopEvent Markers if it hasn't previously been called. That is,
%   'dop.event' structure variable is not found
%   
% - 'file':
%   > e.g., dopFunction(dop_input,okay,msg,...,'file','subjectX.exp',...)
%   file name of the data file currently being summarised. This is used for
%   error reporting. Typically this variable is automatically populated in
%   the 'dopSetGetInputs' function by searching the 'dop' structure
%   variables: dop.save, dop.use, dop.def, dop.file_info.
%   The default value is empty.
%
% - 'msg':
%   > e.g., dopFunction(dop_input,okay,msg,...,'msg',1,...)
%       or
%           dopFunction(dop_input,okay,msg,...,'msg',0,...)
%   This is a logical variable (1 = on, 0 = off) setting whether or not
%   messages about the progress of the processing are printed to the MATLAB
%   command window.
%   The default value is 1 = on, messages are printed
%
% - 'wait_warn': e.g., ...,'wait_warn',1,... or ....,'wait_warn',0,...
%   This is a logical variable (1 = on, 0 = off) setting whether or not,
%   when 'okay' changes to 0 (i.e. an error), progress through the scripts
%   waits for the warning dialog popup to be closed.
%
%--- Outputs ---
%   note: outputs are optional, included at the left hand side of the call
%   to a function. The order is fixed
%   > e.g.,
%       dop = dopFunction(...);
%   or
%       [dop,okay] = dopFunction(...);
%   or
%       [dop,okay,msg] = dopFunction(...);
%
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 8-Aug-2014 NAB
% Edits:
% 10-Aug-2014 NAB
% 01-Sep-2014 NAB fixed dopSetBasicInputs
% 04-Sep-2014 NAB msg & wait_warn updates
% 06-Sep-2014 NAB basic description - varargin still needed
% 07-Sep-2014 NAB completed input descriptions
% 07-Oct-2014 NAB updated dop.data.epoch assignment to be compatiable with
%   negative or positive epoch numbers

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'file',[],...
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
            msg{end+1} = sprintf(['Data already epoched. Reset dop.tmp.data to' ...
                ' pre-epoched data: e.g., ''raw'', ''down'', or ''norm''',...
                '\n\t(%s: %s)'],mfilename,dop.tmp.file);
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
            dop.data.epoch = zeros(numel(dop.epoch.times),numel(dop.event.samples),numel(dop.data.epoch_labels));
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
            dop.epoch.screen = dop.epoch.length;
            
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