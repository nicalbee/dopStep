function [dop,okay,msg] = dopChannelExtract(dop_input,varargin)
% dopOSCCI3: dopChannelExtract
%
% notes:
% basic structure of a function to save time when creating a new one
%
% * not yet implemented (19-Dec-2013)
%
% Use:
%
% [dop,okay,msg] = dopNew(dop,[]);
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
% Created: 12-Aug-2014 NAB
% Last edit:
% 12-Aug-2014 NAB
% 04-Sep-2014 NAB msg & wait_warn update
% 05-Nov-2015 NAB added 'gui' input so as not to adjust channel labels
% 06-Nov-2015 NAB added dop.step.(mfilename) check - don't want to do this
%   twice - unless after import

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        inputs.turnOn = {'gui'};
        inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'msg',1,... % show messages
            'file',[],... % useful for error reporting
            'wait_warn',0,... % wait to close warning dialogs
            'signal_channels',[],...
            'event_channels',[] ...
            );
        inputs.defaults.channel_labels = {'left','right'};
        inputs.defaults.channel_colours = {'b','r'};
        inputs.defaults.event_colours = {'g','c','m','k'};
        inputs.required = ...
            {'signal_channels','event_channels'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg,1);
        
        if isfield(dop,'step') && isfield(dop.step,mfilename) && dop.step.(mfilename)
            msg{end+1} = sprintf('''%s'' already run\n',mfilename);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        else
            %% main code
            if okay
                dop.use.signal_channels = dop.tmp.signal_channels;
                dop.use.event_channels = dop.tmp.event_channels;
                if ~dop.tmp.gui
                    [dop,okay,msg] = dopChannelAdjust(dop,okay,msg);
                    % refresh the data if necessary
                [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                end
            end
            if okay
                if size(dop.data.use,2) >= max([dop.use.signal_channels dop.use.event_channels])
                    dop.data.channel_labels = dop.tmp.channel_labels;%{'left','right'};
                    dop.data.channel_colours = dop.tmp.channel_colours; %{'b','r'};
                    %                 dop.tmp.event_colours = dop.tmp.event{'g','c','m','k'};
                    c = 0;
                    for i = 1 : numel(dop.use.event_channels)
                        dop.data.channel_labels{end+1} = 'event';
                        c = c + 1;
                        if c > numel(dop.tmp.event_colours)
                            c = numel(dop.tmp.event_colours);
                        end
                        dop.data.channel_colours{end+1} = dop.tmp.event_colours{c};
                    end
                    dop.data.channels = dop.data.use(:,[dop.use.signal_channels dop.use.event_channels]);
                    msg{end+1} = sprintf(['Created ''dop.data.channels'' '...
                        'variable with: '...
                        repmat('%u ',1,numel(dop.use.signal_channels)),...
                        'Signal channel columns\n\tAnd: '...
                        repmat('%u ',1,numel(dop.use.event_channels)),...
                        'Event channel columns'],...
                        dop.use.signal_channels,dop.use.event_channels);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    % set the current 'working' (dop.data.use) data set that will be used by
                    % default for things
                    [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'channels');
                    [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                else
                    okay = 0;
                    msg{end+1} = sprintf(['Too few data columns (n = %u) to'...
                        ' extract channels (max column = %u).n\tPerhaps it''s'...
                        ' already done?'],size(dop.data.use,2),...
                        max([dop.use.signal_channels dop.use.event_channels]));
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
                dop.step.(mfilename) = 1;
            end
        end
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
                %% specific output for gui (dopStep)
        if dop.tmp.gui
            msg = sprintf('Channels set: %s\n',dop.tmp.file);
            if ~okay
                msg = sprintf('Problem with channels: %s\n',dop.tmp.file);
            end
        end
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end