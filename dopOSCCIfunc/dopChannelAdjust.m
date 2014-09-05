function [dop,okay,msg] = dopChannelAdjust(dop_input,okay,msg,varargin)
% dopOSCCI3: dopChannelAdjust
%
% notes:
% if it's an EXP file, then there's an extra text column at the start of
% the data file (in most cases). Therefore, when using matlab's importdata
% function, the indata.data matrix is has one less column than the original
% data file. If the dop.def.signal_channels and dop.def.event_channels are
% defined based on the columns in the data file (recommended), then these
% need to be reduced by one in order to correct for this. That is what this
% function does!
%
% * not yet implemented (19-Dec-2013)
%
% Use:
%
% dop = dopNew(dop,[]);
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
% 19-Dec-2013 NAB
% 04-Sep-2014 NAB msg & wait_warn updates + dopSetBasicInputs

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% Inputs
        %         inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'msg',1,... % show messages
            'wait_warn',0,... % wait to close warning dialogs
            'signal_channels',[],... %
            'event_channels',[] ... %
            );
        inputs.required = ...
            {'signal_channels','event_channels'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        if okay
            switch dopInputCheck(dop_input)
                case 'dop'
                    %% signal channels
                    dop.use.signal_channels = dop.tmp.signal_channels;
                    dop.use.event_channels = dop.tmp.event_channels;
                    % the .EXP files tend to have a string column at the start
                    % which means the data matrix has a different number of columns
                    % and as column numbers are used to denote where the data is,
                    % these need to be adjusted (typically minus 1)
                    if isfield(dop.file_info,'columnLabels') && isfield(dop.file_info,'dataLabels') %...
                            if numel(dop.file_info.columnLabels) > numel(dop.file_info.dataLabels)
                            dop.use.signal_channels = dop.def.signal_channels - ...
                                (numel(dop.file_info.columnLabels) - numel(dop.file_info.dataLabels));
                            msg{end+1} = ...
                                sprintf(['Adjusting the signal channel columns from: ' ...
                                repmat('%u ',1,numel(dop.def.signal_channels)) ...
                                'to: ',repmat('%u ',1,numel(dop.use.signal_channels))],...
                                dop.def.signal_channels,dop.use.signal_channels);
                            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                            %                 dop.def.use_signal_channels = dop.use.signal_channels;
                            
                            end
                            
                            if numel(dop.file_info.columnLabels) > numel(dop.file_info.dataLabels)
                                dop.use.event_channels = dop.def.event_channels - ...
                                    (numel(dop.file_info.columnLabels) - numel(dop.file_info.dataLabels));
                                msg{end+1} = ...
                                    sprintf(['Adjusting the event channel columns from: ' ...
                                    repmat('%u ',1,numel(dop.def.event_channels)) ...
                                    'to: ',repmat('%u ',1,numel(dop.use.event_channels))],...
                                    dop.def.event_channels,dop.use.event_channels);
                                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                                okay = 1;
                                %                 dop.def.use_event_channels = dop.use.event_channels;
                            end
                    end
                otherwise
                    msg{end+1} = 'Function not yet programmed for that input...';
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
        end
        
        %     end
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end