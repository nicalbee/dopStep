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
% 03-Aug-2016 NAB added gui message
% 10-May-2017 NAB code adjust to fix the variables when after the data has
%   been normalised and the screening is redone.
% 29-Jun-2018 NAB adding the single channel change in activation screening

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
            'showmsg',1,...
            'wait_warn',0,...
            'act_range',[50 150],...
            'act_separation',20, ...
            'act_separation_pct',1, ...
            'act_change',15,... 'act_change_pct',0,...
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
        if okay && sum(ismember(dop.tmp.screen,'manual'))
            [dop,okay,msg] = dopEpochScreenManual(dop,okay,msg);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        end
        %% > dopEpochScreenAct
        if okay  && sum(ismember(dop.tmp.screen,'act'))
            [dop,okay,msg] = dopEpochScreenAct(dop,okay,msg,...
                'act_range',dop.tmp.act_range);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        end
        %% > dopEpochScreenSep
        if okay  && sum(ismember(dop.tmp.screen,'sep'))
            [dop,okay,msg] = dopEpochScreenSep(dop,okay,msg,...
                'act_separation',dop.tmp.act_separation,...
                'act_separation_pct',dop.tmp.act_separation_pct);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        end
        %% > dopEpochScreenChange
        if okay  && sum(ismember(dop.tmp.screen,'change'))
            [dop,okay,msg] = dopEpochScreenChange(dop,okay,msg,...
                'act_change',dop.tmp.act_change); %'act_change_pct',dop.tmp.act_change_pct);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        end
        %% > combine the different options
        if okay
            [dop,okay,msg] = dopEpochScreenCombine(dop,okay,msg,...
                'screen',dop.tmp.screen);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        else
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        end
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        if isfield(dop.tmp,'gui') && dop.tmp.gui
            msg = sprintf(['''%s'' function run successfully:\n\n%i epochs ',...
                'screened with:'],mfilename,numel(dop.epoch.screen));
            for i = 1 : numel(dop.tmp.screen)
                msg = sprintf('%s\n\t- %s:\t%i okay',msg,dop.tmp.screen{i},sum(dop.epoch.(dop.tmp.screen{i})));
            end
            
             msg = sprintf('%s\n\n%i epochs screened/removed',msg,dop.epoch.screen_removed);
             dop.step.(mfilename) = 1;
            if ~okay
                dop.step.(mfilename) = 0;
                msg = strrep(msg,'success','unsuccess');
                msg = strrep(msg,'Data screened','Attempted to screen');
            end
        end
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end