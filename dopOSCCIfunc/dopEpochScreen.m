function [dop,okay,msg] = dopEpochScreen(dop_input,varargin)
% dopOSCCI3: dopEpochScreen
%
% creates a dop.epoch.screen variable by running:
%
%   [dop,okay,msg] = dopEpochScreenManual(dop,okay,msg);
%
%   [dop,okay,msg] = dopEpochScreenAct(dop,okay,msg);
%
%   [dop,okay,msg] = dopEpochScreenSep(dop,okay,msg);
%
%   [dop,okay,msg] = dopEpochScreenCombine(dop,okay,msg);
%
% These can be run indpendently as well.
%
% Use:
%
% [dop,okay,msg] = dopEpochScreen(dop,[okay],[msg]...);
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
% 14-Sep-2014 NAB included dopEpochScreenCombine
% 16-Sep-2014 NAB added dopEpochScreenManual
% 20-May-2015 NAB added 'showmsg'

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'showmsg',1,...
            'wait_warn',0,...
            'act_range',[50 150],...
            'act_separation',20, ...
            'act_separation_pct',1, ...
            'epoch',[],... % needed for dopEpoch
            'sample_rate',[], ... % needed for dopEpoch
            'event_height',[],... % needed for dopEventMarkers - in dopEpoch
            'event_channels',[] ... % needed for dopEventMarkers - in dopEpoch
            );
        inputs.defaults.screen = {'manual','length','act','sep'};
%         inputs.required = ...
%             {'screen','act_range','act_separation'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        %% data check
        if okay && or(size(dop.tmp.data,3) == 1, ~isfield(dop,'epoch'))
            msg{end+1} = 'Data hasn''t been epoched - let''s do that';
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            [dop,okay,msg] = dopEpoch(dop,okay,msg,...
                'epoch',dop.tmp.epoch,'sample_rate',dop.tmp.sample_rate,...
                'event_height',dop.tmp.event_height,...
                'event_channels',dop.tmp.event_channels);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        end
        
        %% run screening functions
        %% > dopEpochScreenManual
        if okay
            [dop,okay,msg] = dopEpochScreenManual(dop,okay,msg);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        end
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
        %% > combine the different options
        if okay
            [dop,okay,msg] = dopEpochScreenCombine(dop,okay,msg,...
                'screen',dop.tmp.screen);
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