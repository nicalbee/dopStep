function [dop,okay,msg] = dopEpochScreenSep(dop_input,varargin)
% dopOSCCI3: dopScreenSep
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
% Created: 18-Aug-2014 NAB
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
            'act_separation',20,...
            'act_separation_pct',1.5,...
            'signal_channels',[],...
            'event_channels',[], ...
            'epoch',[], ...
            'sample_rate',[] ...
            );
        inputs.defaults.ch_labels = {'Left','Right'};
        inputs.required = [];
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        if okay
            
            if size(dop.tmp.data,3) == 1
                dop.tmp.data_type = 'continuous';
                msg{end+1} = 'Continuous data (i.e., not epoched) inputted';
               dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                
                msg{end+1} = sprintf(['data %u columns, assuming first',...
                    ' 2 are left and right channels'],...
                    size(dop.tmp.data,2));
               dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                
                [dop,okay,msg] = dopEventMarkers(dop,okay,msg);
                % refresh the data if necessary
                [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                
            elseif size(dop.tmp.data,3) > 1
                dop.tmp.data_type = 'epoched';
                msg{end+1} = 'Epoched data inputted';
               dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            else
                okay = 0;
                msg{end+1} = ['Data type unknown: expecting continuous or'...
                    'epoched. Can''t continue function'];
               dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            
        end
        
        %% main code
        if okay
            if strcmp(dop.tmp.data_type,'continuous')
                dop.tmp.n_epochs = dop.event.n;
            elseif strcmp(dop.tmp.data_type,'epoched')
                dop.tmp.n_epochs = size(dop.tmp.data,2);
            end
            dop.epoch.sep_note = sprintf(['logical variable denoting epochs',...
                ' with <= %1.1f%% left minus right activation less than %u'],...
                dop.tmp.act_separation_pct,dop.tmp.act_separation);
            msg{end+1} = dop.epoch.sep_note;
           dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            dop.epoch.sep = ones(1,dop.tmp.n_epochs);
            for j = 1 : dop.tmp.n_epochs
                switch dop.tmp.data_type
                    case 'continuous'
                        dop.tmp.filt_limits = dop.event.samples(j) + dop.tmp.epoch/(1/dop.tmp.sample_rate);
                        if dop.tmp.filt_limits(1) < 1
                            msg{end+1} = sprintf(['Epoch %u is short by'...
                                ' %u samples (%3.2f secs). Checking avialable'],...
                                j,abs(dop.tmp.filt_limits(1)),...
                                dop.tmp.filt_limits(1)*(1/dop.tmp.sample_rate));
                           dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                            dop.tmp.filt_limits(1) = 1;
                        end
                        if dop.tmp.filt_limits(2) > size(dop.tmp.data,1)
                            msg{end+1} = sprintf(['Epoch %u is short by'...
                                ' %u samples (%3.2f secs). Checking avialable'],...
                                j,size(dop.tmp.data,1) - dop.tmp.filt_limits(2),...
                                (size(dop.tmp.data,1)-dop.tmp.filt_limits(2))*(1/dop.tmp.sample_rate));
                           dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                            dop.tmp.filt_limits(2) = size(dop.tmp.data,1);
                        end
                        dop.tmp.filt = dop.tmp.filt_limits(1) : dop.tmp.filt_limits(2);
                        dop.tmp.filt_data = dop.tmp.data(dop.tmp.filt,1:2);
                    case 'epoched'
                        dop.tmp.filt = 1 : size(dop.tmp.data,1);
                        dop.tmp.filt_data = dop.tmp.data(:,j,1:2);
                end
                dop.tmp.diff = dop.tmp.filt_data(:,1) - dop.tmp.filt_data(:,2); %,dop.tmp.act_range_values(1,:));
                dop.tmp.all = bsxfun(@lt,dop.tmp.diff ,dop.tmp.act_separation);
                dop.tmp.pct = 100*(sum(dop.tmp.all == 0)/numel(dop.tmp.diff));
                
                dop.epoch.sep(j) = sum(dop.tmp.all) == numel(dop.tmp.diff);
                if ~dop.epoch.sep(j)
                    if dop.tmp.pct <= dop.tmp.act_separation_pct
                        dop.epoch.sep(j) = 1;
                        msg{end+1} = sprintf(['Epoch %u. %u samples have difference',...
                            ' greater than %u (%3.2f%%) but %% is < %1.1f%%,',...
                            ' therefore not excluding'],...
                            j,sum(dop.tmp.all == 0),dop.tmp.act_separation,dop.tmp.pct,...
                            dop.tmp.act_separation_pct);
                    else
                        msg{end+1} = sprintf(['Epoch %u. %u samples have difference',...
                            ' greater than %u (%3.2f%%)'],...
                            j,sum(dop.tmp.all == 0),dop.tmp.act_separation,dop.tmp.pct);
                    end
                   dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
                
            end
            dop.epoch.sep = logical(dop.epoch.sep);
            
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