function [dop,okay,msg] = dopEpochScreen(dop_input,varargin)
% dopOSCCI3: dopEpochScreen
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
% 20-Aug-2014 NAB
% 01-Sep-2014 NAB fixed dopSetBasicInputs

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'msg',1,...
            'wait_warn',0,...
            'act_range',[50 150],...
            'act_separation',20, ...
            'act_separation_pct',1, ...
            'epoch',[],... % needed for dopEpoch
            'sample_rate',[], ... % needed for dopEpoch
            'event_height',[],... % needed for dopEventMarkers - in dopEpoch
            'event_channels',[] ... % needed for dopEventMarkers - in dopEpoch
            );
        inputs.defaults.screen = {'length','act','sep'};
%         inputs.required = ...
%             {'screen','act_range','act_separation'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        %% data check
        if okay && or(size(dop.tmp.data,3) == 1, ~isfield(dop,'epoch'))
            msg{end+1} = 'Data hasn''t been epoched - let''s do that';
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            [dop,okay,msg] = dopEpoch(dop,okay,msg,...
                'epoch',dop.tmp.epoch,'sample_rate',dop.tmp.sample_rate,...
                'event_height',dop.tmp.event_height,...
                'event_channels',dop.tmp.event_channels);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        end
        
        %% run screening functions
        %% > dopEpochScreenAct
        if okay
            [dop,okay,msg] = dopEpochScreenAct(dop,okay,msg,...
                'act_range',dop.tmp.act_range);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        end
        %% > dopEpochScreenSep
        if okay
            [dop,okay,msg] = dopEpochScreenSep(dop,okay,msg,...
                'act_separation',dop.tmp.act_separation,...
                'act_separation_pct',dop.tmp.act_separation_pct);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        end
        %% main code
        % accept everything to begin with
        dop.epoch.screen = ones(1,size(dop.tmp.data,2));
        dop.epoch.all = dop.epoch.screen;
        if okay
            msg{end+1} = sprintf(['Combining screens: ',...
                repmat('%s ',1,numel(dop.tmp.screen))],dop.tmp.screen{:});
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            % matrix with screen # rows & epoch # columns
            dop.tmp.screens = ones(numel(dop.tmp.screen),size(dop.tmp.data,2));
            for i = 1 : numel(dop.tmp.screen)
                if isfield(dop,'epoch') && isfield(dop.epoch,dop.tmp.screen{i})
                    dop.tmp.screens(i,:) = dop.epoch.(dop.tmp.screen{i});
                else
                    msg{end+1} = sprintf(['''dop.epoch.%s'' variable not' ...
                        'found, therefore not used'],dop.tmp.screen{i});
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
            end
            dop.epoch.screen = sum(dop.tmp.screens) == size(dop.tmp.screens,1);
            if size(dop.epoch.screen) == 1
                dop.epoch.screen = logical(dop.epoch.all);
            end
            %         dop.epoch.screen = logical(dop.epoch.screen);
            % report acceptable
            msg{end+1} = sprintf(['%u acceptable epochs of %u, based on: ' ...
                repmat('%s ',1,numel(dop.tmp.screen))],...
                sum(dop.epoch.screen),numel(dop.epoch.screen),...
                dop.tmp.screen{:});
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            % report unnaceptable
            if numel(dop.epoch.screen) ~= sum(dop.epoch.screen)
                msg{end+1} = sprintf(['unnacceptable epoch number/s = ' ...
                    repmat('%u ',1,numel(dop.epoch.screen) - sum(dop.epoch.screen))], ...
                    find(~dop.epoch.screen));
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
        end
        dop.epoch.screen = logical(dop.epoch.screen);
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end