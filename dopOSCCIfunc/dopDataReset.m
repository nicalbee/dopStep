function dop = dopDataReset(dop)
% dopOSCCI3: dopDataReset ~ 16-Dec-2013 (last edit)
%
% notes:
% reset the signal and event channels from the raw data
% > this will undo any processes carried out after import:
%   - downsampling
%   - heart cycle integration
%   - epoching
%   - baseline correction
%
% > currently (16-Dec-2013) the data from the subsequent steps will be
% still available for graphing etc. but will be overwritten when these
% processes are redone... actually, I don't think this is a good idea.
% >> Running this function will clear any steps made after import *
%
% * not yet implemented (16-Dec-2013)
%
% Use:
%
% dop = dopDataReset(dop)
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
% Created: 16-Dec-2013 NAB

try
    fprintf('\nRunning %s:\n',mfilename);
    % organize/reset the data into relevant fields
    if isfield(dop,'data') && isfield(dop.data,'raw') && ~isempty(dop.data.raw)
        if isfield(dop,'def') && isfield(dop.def,'signal_channels')
            dop.def.signal_channels_adj = dop.def.signal_channels;
            % the .EXP files tend to have a string column at the start
            % which means the data matrix has a different number of columns
            % and as column numbers are used to denote where the data is,
            % these need to be adjusted (typically minus 1)
            if numel(dop.file_info.columnLabels) > numel(dop.file_info.dataLabels)
                dop.def.signal_channels_adj = dop.def.signal_channels - ...
                    (numel(dop.file_info.columnLabels) - numel(dop.file_info.dataLabels));
                fprintf('\tadjusting the signal channel columns from: ');
                fprintf(repmat('%u ',1,numel(dop.def.signal_channels)),...
                    dop.def.signal_channels);
                fprintf(['to:',repmat('%u ',1,numel(dop.def.signal_channels)),'\n'],...
                    dop.def.signal_channels_adj);
            end
            dop.data.signals = dop.data.raw(:,dop.def.signal_channels_adj);
        end
        if isfield(dop,'def') && isfield(dop.def,'event_channels')
            % event markers
            dop.def.signal_event_adj = dop.def.event_channels;
            if numel(dop.file_info.columnLabels) > numel(dop.file_info.dataLabels)
                dop.def.event_channels_adj = dop.def.event_channels - ...
                    (numel(dop.file_info.columnLabels) - numel(dop.file_info.dataLabels));
                fprintf('\tadjusting the event channel columns from: ');
                fprintf(repmat('%u ',1,numel(dop.def.event_channels)),...
                    dop.def.event_channels);
                fprintf(['to: ',repmat('%u ',1,numel(dop.def.event_channels_adj)),'\n'],...
                    dop.def.event_channels_adj);
            end
            dop.data.events = dop.data.raw(:,dop.def.event_channels_adj);
        end
        dop = dopStep(dop);
%         dop.step.last = mfilename;
%         dop.step.hist = mfilename; % add to this each time
%         dop.step.count = 1; % counter
    end
    fprintf('\n');
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end

