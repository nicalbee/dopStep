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
% 12-Sep-2014 NAB absolute difference: negatives were getting through!
% 19-May-2015 NAB adding some descriptives to look at
% 20-May-2015 NAB added 'showmsg' & sep_remove output variable
% 21-May-2015 NAB updated descriptives
% 22-May-2015 NAB fixed descriptive calculation

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
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                
                msg{end+1} = sprintf(['data %u columns, assuming first',...
                    ' 2 are left and right channels'],...
                    size(dop.tmp.data,2));
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                
                [dop,okay,msg] = dopEventMarkers(dop,okay,msg);
                % refresh the data if necessary
                [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                
            elseif size(dop.tmp.data,3) > 1
                dop.tmp.data_type = 'epoched';
                msg{end+1} = 'Epoched data inputted';
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            else
                okay = 0;
                msg{end+1} = ['Data type unknown: expecting continuous or'...
                    'epoched. Can''t continue function'];
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
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
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            dop.epoch.sep = ones(1,dop.tmp.n_epochs);
            
            % some descriptives
            dop.epoch.act_sep_descriptives = {'mean','std','median','iqr','min','max'};
            for i = 1 : numel(dop.epoch.act_sep_descriptives)
                dop.epoch.(['act_sep_',dop.epoch.act_sep_descriptives{i},'_ep']) = dop.epoch.sep;
            end
            %             dop.epoch.act_sep_mean_ep = dop.epoch.sep;
            %             dop.epoch.act_sep_sd_ep = dop.epoch.sep;
            %             dop.epoch.act_sep_median_ep = dop.epoch.sep;
            %             dop.epoch.act_sep_iqr_ep = dop.epoch.sep;
            %             dop.epoch.act_sep_min_ep = dop.epoch.sep;
            %             dop.epoch.act_sep_max_ep = dop.epoch.sep;
            
            for j = 1 : dop.tmp.n_epochs
                switch dop.tmp.data_type
                    case 'continuous'
                        dop.tmp.filt_limits = dop.event.samples(j) + dop.tmp.epoch/(1/dop.tmp.sample_rate);
                        if dop.tmp.filt_limits(1) < 1
                            msg{end+1} = sprintf(['Epoch %u is short by'...
                                ' %u samples (%3.2f secs). Checking avialable'],...
                                j,abs(dop.tmp.filt_limits(1)),...
                                dop.tmp.filt_limits(1)*(1/dop.tmp.sample_rate));
                            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                            dop.tmp.filt_limits(1) = 1;
                        end
                        if dop.tmp.filt_limits(2) > size(dop.tmp.data,1)
                            msg{end+1} = sprintf(['Epoch %u is short by'...
                                ' %u samples (%3.2f secs). Checking avialable'],...
                                j,size(dop.tmp.data,1) - dop.tmp.filt_limits(2),...
                                (size(dop.tmp.data,1)-dop.tmp.filt_limits(2))*(1/dop.tmp.sample_rate));
                            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                            dop.tmp.filt_limits(2) = size(dop.tmp.data,1);
                        end
                        dop.tmp.filt = dop.tmp.filt_limits(1) : dop.tmp.filt_limits(2);
                        dop.tmp.filt_data = dop.tmp.data(dop.tmp.filt,1:2);
                    case 'epoched'
                        dop.tmp.filt = 1 : size(dop.tmp.data,1);
                        dop.tmp.filt_data = dop.tmp.data(:,j,1:2);
                end
                dop.tmp.diff = dop.tmp.filt_data(:,1) - dop.tmp.filt_data(:,2); %,dop.tmp.act_range_values(1,:));
                dop.tmp.all = bsxfun(@lt,abs(dop.tmp.diff) ,dop.tmp.act_separation);
                dop.tmp.pct = 100*(sum(dop.tmp.all == 0)/numel(dop.tmp.diff));
                
                
                for i = 1 : numel(dop.epoch.act_sep_descriptives)
                    dop.epoch.(['act_sep_',dop.epoch.act_sep_descriptives{i},'_ep'])(j) = ...
                        eval(sprintf('%s(abs(dop.tmp.diff))',dop.epoch.act_sep_descriptives{i}));
                end
                %                 dop.epoch.act_sep_mean_ep(j) = mean(abs(dop.tmp.diff));
                %                 dop.epoch.act_sep_sd_ep(j) = std(abs(dop.tmp.diff));
                %                 dop.epoch.act_sep_median_ep(j) = median(abs(dop.tmp.diff));
                %                 dop.epoch.act_sep_iqr_ep(j) = iqr(abs(dop.tmp.diff));
                %                 dop.epoch.act_sep_min_ep(j) = min(abs(dop.tmp.diff));
                %                 dop.epoch.act_sep_max_ep(j) = max(abs(dop.tmp.diff));
                
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
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                end
                
            end
            dop.epoch.sep = logical(dop.epoch.sep);
            dop.epoch.act_sep_removed = sum(dop.epoch.sep == 0);
            
            % not sure about this being summarised as means
            
            for i = 1 : numel(dop.epoch.act_sep_descriptives)
                dop.epoch.(['act_sep_',dop.epoch.act_sep_descriptives{i}]) = ...
                    eval(sprintf('mean(dop.epoch.([''act_sep_'',''%s'',''_ep'']))',dop.epoch.act_sep_descriptives{i}));
            end
            %             dop.epoch.act_sep_mean = mean(dop.epoch.act_sep_mean_ep);
            %             dop.epoch.act_sep_sd = mean(dop.epoch.act_sep_sd_ep);
            %             dop.epoch.act_sep_median = mean(dop.epoch.act_sep_median_ep);
            %             dop.epoch.act_sep_iqr = mean(dop.epoch.act_sep_iqr_ep);
            %             dop.epoch.act_sep_min = mean(dop.epoch.act_sep_min_ep);
            %             dop.epoch.act_sep_max = mean(dop.epoch.act_sep_max_ep);
            
            %%  msg
            msg{end+1} = sprintf(['%u epochs with separation greater than %u\n',...
                'Descriptives of absolute differences, averaged across epochs:\n',...
                '- mean (SD) = %3.2f (%3.2f)\n',...
                '- median (IQR) = %3.2f (%3.2f)\n',...
                '- min = %3.2f, max = %3.2f\n'],...
                dop.epoch.act_sep_removed,dop.tmp.act_separation,...
                dop.epoch.act_sep_mean,dop.epoch.act_sep_std,...
                dop.epoch.act_sep_median,dop.epoch.act_sep_iqr,...
                dop.epoch.act_sep_min,dop.epoch.act_sep_max);
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            
            
            msg{end+1} = sprintf(['To include this information in data file add the following '...
                'to the dop.save.extras variable:\n',...
                '\t- ''act_sep_removed'' = number epochs removed greater than %u\n',...
                '\t- ''act_sep_*'' = variable of interest, e.g., ''act_sep_mean''\n',...
                '\t- * alternatives are: mean, sd, median, iqr, min, max'],...
                dop.tmp.act_separation);
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