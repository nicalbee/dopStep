function [dop,okay,msg] = dopBaseCorrect(dop_input,varargin)
% dopOSCCI3: dopBaseCorrect
%
% notes:
% subtracts the mean of the baseline period from all of the data within the
% epoch for each each separately.
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
% Created: 14-Aug-2014 NAB
% Last edit:
% 18-Aug-2014 NAB
% 01-Sep-2014 NAB fixed dopSetBasicInputs
% 04-Sep-2014 NAB msg & wait_warn updates

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
            'baseline',[], ... %
            'sample_rate',[],...
            'epoch',[],... % + needed for dopEpoch
            'event_height',[],... % needed for dopEventMarkers
            'event_channels',[] ... % needed for dopEventMarkers
            );
        inputs.required = ...
            {'baseline','sample_rate','epoch'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        %% data checks
        if okay && or(size(dop.tmp.data,3) == 1, ~isfield(dop,'epoch'))
            msg{end+1} = 'Data hasn''t been epoched - let''s do that';
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            [dop,okay,msg] = dopEpoch(dop,okay,msg);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        end
        %% tmp variable check
        if okay && isfield(dop,mfilename)
            msg{end+1} = ['Multiple functions running with setGetInputs,'...
                ' updating ''dop.tmp'' variable'];
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            % make sure the dop.tmp variable is correct: with multiple
            % functions within functions this is required.
            dop.tmp = dop.(mfilename);
            dop = rmfield(dop,mfilename);
            dop.tmp.data = dop.data.use;
        end
        %% main code
        if okay
            %         dop.tmp.data = dop.data.epoch; % this will be overwritten
            dop.tmp.base = zeros(size(dop.tmp.data));
            dop.tmp.base_filt = (-dop.tmp.epoch(1) + dop.tmp.baseline)*dop.tmp.sample_rate;
            if dop.tmp.base_filt(1) < 1
                
                if dop.tmp.base_filt(1) < 0
                    dop.epoch.notes{end+1} = sprintf(...
                        ['start of baseline period set to sample 1, %i secs' ...
                        ' corresponded to %i samples'],...
                        dop.tmp.baseline(1),dop.tmp.base_filt(1));
                    msg{end+1} = dop.epoch.notes{end};
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
                dop.tmp.base_filt(1) = 1;
            end
            dop.epoch.notes{end+1} = sprintf(...
                'baseline period: %i %i samples (%i %i secs)',...
                dop.tmp.base_filt,dop.tmp.baseline);
            msg{end+1} = dop.epoch.notes{end};
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            for i = 1 : numel(dop.event.samples)
                if dop.epoch.length(i)
                    % need baseline in samples relative to
                    % the start of the epoch, not
                    % zero/event marker
                    
                    dop.tmp.base(:,i,:) = bsxfun(@minus,dop.tmp.data(:,i,:),mean(dop.tmp.data(dop.tmp.base_filt(1):dop.tmp.base_filt(2),i,:)));
                    
                end
            end
            dop.tmp.base(:,i,3) = dop.tmp.base(:,i,1) - dop.tmp.base(:,i,2);
            dop.tmp.base(:,i,4) = mean(dop.tmp.base(:,i,1:2),3);
            dop.data.base = dop.tmp.base;
            
            if ~isfield(dop.epoch,'notes')
                dop.epoch.notes = [];
            end
            dop.epoch.notes{end+1} = sprintf(...
                'epoch data baseline corrected using %i %i period',...
                dop.tmp.baseline);
            msg{end+1} = dop.epoch.notes{end};
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            
            [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'base');
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