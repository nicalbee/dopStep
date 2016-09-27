function [dop,okay,msg] = dopEpochScreenAct(dop_input,varargin)
% dopOSCCI3: dopEpochScreenAct
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
% 20-Aug-2014 NAB
% 01-Sep-2014 NAB fixed dopSetBasicInputs
% 04-Sep-2014 NAB msg & wait_warn updates
% 20-May-2015 NAB added 'showmsg' & act_remove output variable
% 21-May-2015 NAB added descriptives

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
        %% activation range check
        if okay
            if  mean(median(dop.tmp.data(:,dop.epoch.length))) > dop.tmp.act_range(1) ...
                    && mean(median(dop.tmp.data(:,dop.epoch.length))) < dop.tmp.act_range(2)
                
                %                 if mean(dop.tmp.data(:,1)) < 90 || mean(dop.tmp.data(:,1)) > 110
                %                     okay = 0;
                %                     msg{end+1} = sprintf(['Data should be normalised for these values,',...
                %                         ' doesn''t look like this is the case:\n\t',...
                %                         'means are  %3.2f (left channel)'],mean(dop.tmp.data(:,1)));
                %                     dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                %                 else
                msg{end+1} = sprintf(['Checking for data points below %i',...
                    ' and above %i'],dop.tmp.act_range);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                % activation_range_values for the left and right channels
                % left = row 1, right = row 2
                dop.tmp.act_range_values = repmat(dop.tmp.act_range,2,1);
                %                 end
                %             else % if dop.tmp.act_range(1) < 0 && dop.tmp.act_range(2) > 0
                %                 okay = 0;
                %                 msg{end+1} = sprintf(['Means of data (%3.2f & %3.2f)',...
                %                     ' aren''t with activation range (%3.2f : %3.2f).\n\t'
                %                     'Check the activation range values'],...
                %                     mean(squeeze(dop.tmp.data(:,:,1:2))),...
                %                     dop.tmp.act_range);
                %                 dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                
                %                 dop.tmp.range_type = 'sd';
                %                 msg{end+1} = sprintf(['Checking for data points below %i',...
                %                     ' and above %i standard deviations of mean.'],...
                %                     dop.tmp.act_range);
                %                 dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                %                 % activation_range_values for the left and right channels
                %                 % left = row 1, right = row 2
                %                 if size(dop.tmp.data,3) == 1
                %                     dop.tmp.act_mean = mean(dop.tmp.data(:,1:2));
                %                     dop.tmp.act_std = std(dop.tmp.data(:,1:2));
                %                 else
                %                     dop.tmp.act_mean = squeeze(mean(mean(dop.tmp.data(:,:,1:2))));
                %                     dop.tmp.act_std = squeeze(mean(std(dop.tmp.data(:,:,1:2))));
                %                 end
                %                 dop.tmp.act_range_values(1,:) = dop.tmp.act_mean + dop.tmp.act_std*dop.tmp.act_range(1);
                %                 dop.tmp.act_range_values(2,:) = dop.tmp.act_mean + dop.tmp.act_std*dop.tmp.act_range(2);
            else
                okay = 0;
                msg{end+1} = sprintf(['Seems to be a mismatch between the',...
                    ' activation range inputted [%3.2f %3.2f] and the mean of'...
                    ' the left channel (e.g., %3.2f)\n\texpected mean to be',...
                    ' with the activation range: check values'],...
                    dop.tmp.act_range,mean(dop.tmp.data(:,1)));
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
        end
        %% main code
        if okay
            if strcmp(dop.tmp.data_type,'continuous') %&& dop.tmp.correct_by_epoch
                dop.tmp.n_epochs = dop.event.n;
            elseif strcmp(dop.tmp.data_type,'epoched')
                dop.tmp.n_epochs = size(dop.tmp.data,2);
            end
            dop.epoch.act_note = sprintf(['logical variable denoting epochs',...
                ' with activation within acceptable range:\n\t',...
                'Left values < %3.2f or > %3.2f and',...
                ' Right values < %3.2f or > %3.2f'],...
                dop.tmp.act_range_values(1,:),dop.tmp.act_range_values(2,:));
            msg{end+1} = dop.epoch.act_note;
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            
            dop.epoch.act = ones(1,dop.tmp.n_epochs);
            
            % some descriptives
            dop.epoch.act_descriptives = {'mean','std','median','iqr','min','max'};
            for i = 1 : numel(dop.epoch.act_descriptives)
                dop.epoch.(['act_',dop.epoch.act_descriptives{i},'_ep']) = dop.epoch.act;
            end
            %             dop.epoch.act_sd_ep = dop.epoch.act;
            %             dop.epoch.act_median_ep = dop.epoch.act;
            %             dop.epoch.act_iqr_ep = dop.epoch.act;
            %             dop.epoch.act_min_ep = dop.epoch.act;
            %             dop.epoch.act_max_ep = dop.epoch.act;
            
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
                dop.tmp.under = bsxfun(@lt,dop.tmp.filt_data(:,1:2),dop.tmp.act_range_values(:,1)');
                dop.tmp.over = bsxfun(@gt,dop.tmp.filt_data(:,1:2), dop.tmp.act_range_values(:,2)');
                dop.tmp.all = bsxfun(@plus,dop.tmp.under,dop.tmp.over);
                dop.tmp.pct = sum(dop.tmp.all)/numel(dop.tmp.all)*100;
                %                 dop.tmp.adjust = dop.tmp.pct <= dop.tmp.act_correct;
                
                % really should be separated by left and right, rather than
                % mean
                for i = 1 : numel(dop.epoch.act_descriptives)
                    dop.epoch.(['act_',dop.epoch.act_descriptives{i},'_ep'])(j) = ...
                        eval(sprintf('mean(%s(dop.tmp.filt_data(:,1:2)))',dop.epoch.act_descriptives{i}));
                end
                %                 dop.epoch.act_mean_ep(j) = mean(mean(dop.tmp.filt_data(:,1:2)));
                %                 dop.epoch.act_sd_ep(j) = mean(std(dop.tmp.filt_data(:,1:2)));
                %                 dop.epoch.act_median_ep(j) = mean(median(dop.tmp.filt_data(:,1:2)));
                %                 dop.epoch.act_iqr_ep(j) = mean(iqr(dop.tmp.filt_data(:,1:2)));
                %                 dop.epoch.act_min_ep(j) = mean(min(dop.tmp.filt_data(:,1:2)));
                %                 dop.epoch.act_max_ep(j) = mean(max(dop.tmp.filt_data(:,1:2)));
                
                for i = 1 : numel(dop.tmp.pct)
                    %                     if dop.tmp.correct && dop.tmp.adjust(i) && dop.tmp.pct(i) % can't be zero
                    %                         dop.epoch.act_correct(j) = 1;
                    %
                    %                         dop.tmp.replace_value = eval([dop.tmp.act_replace,'(dop.tmp.filt_data(:,i))']);
                    %                         msg{end+1} = sprintf(['Correcting %u samples',...
                    %                             ' (%3.2f%%) in %s channel to %3.2f:',...
                    %                             ' values < %3.2f or > %3.2f'],...
                    %                             sum(dop.tmp.all(:,i)),dop.tmp.pct(i),...
                    %                             dop.tmp.ch_labels{i},dop.tmp.replace_value,...
                    %                             dop.tmp.act_range_values(i,:));
                    %                         if or(and(strcmp(dop.tmp.data_type,'continuous'),dop.tmp.correct_by_epoch),...
                    %                                 strcmp(dop.tmp.data_type,'epoch'))
                    %                             msg{end} = strrep(msg{end},'Correcting',...
                    %                                 sprintf('Epoch %u: Correcting',j));
                    %                         end
                    %                         dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                    %                         dop.tmp.filt_data(logical(dop.tmp.all(:,i)),i) = ...
                    %                             eval([dop.tmp.act_replace,'(dop.tmp.filt_data(:,i))']);
                    %                     else
                    if dop.tmp.pct(i)
                        dop.epoch.act(j) = 0;
                        msg{end+1} = sprintf(['Epoch %u. %u samples',...
                            ' (%3.2f%%) in %s channel outside range'],...
                            j,sum(dop.tmp.all(:,i)),dop.tmp.pct(i),...
                            dop.tmp.ch_labels{i});
                        dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                    end
                end
                %                 %% put the corrected data into the new matrix
                %                 if dop.tmp.correct
                %                     switch dop.tmp.data_type
                %                         case 'continuous'
                %                             dop.data.act_correct(dop.tmp.filt,1:2) = dop.tmp.filt_data;
                %                         case 'epoch'
                %                             dop.data.act_correct(dop.tmp.filt,j,1:2) = dop.tmp.filt_data;
                %                     end
                %                 end
            end
            dop.epoch.act = logical(dop.epoch.act);
            dop.epoch.act_removed = sum(dop.epoch.act == 0);
            
            % not sure about this being summarised as means
            
            for i = 1 : numel(dop.epoch.act_descriptives)
                dop.epoch.(['act_',dop.epoch.act_descriptives{i}]) = ...
                    eval(sprintf('mean(dop.epoch.([''act_'',''%s'',''_ep'']))',dop.epoch.act_descriptives{i}));
            end
            %             dop.epoch.act_mean = mean(dop.epoch.act_mean_ep);
            %             dop.epoch.act_sd = mean(dop.epoch.act_sd_ep);
            %             dop.epoch.act_median = mean(dop.epoch.act_median_ep);
            %             dop.epoch.act_iqr = mean(dop.epoch.act_iqr_ep);
            %             dop.epoch.act_min = mean(dop.epoch.act_min_ep);
            %             dop.epoch.act_max = mean(dop.epoch.act_max_ep);
            
            %% msg
            msg{end+1} = sprintf(['%u epochs with activation outside range (%u %u)\n',...
                'Descriptives of activiated, averaged across left & right channels and epochs:\n',...
                '- mean (SD) = %3.2f (%3.2f)\n',...
                '- median (IQR) = %3.2f (%3.2f)\n',...
                '- min = %3.2f, max = %3.2f\n'],...
                dop.epoch.act_removed,dop.tmp.act_range,...
                dop.epoch.act_mean,dop.epoch.act_std,...
                dop.epoch.act_median,dop.epoch.act_iqr,...
                dop.epoch.act_min,dop.epoch.act_max);
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            msg{end+1} = sprintf(['To include this information in data file add the following '...
                'to the dop.save.extras variable:\n',...
                '\t- ''act_sep_removed'' = number epochs removed outside range (%u %u)\n',...
                '\t- ''act_sep_*'' = variable of interest, e.g., ''act_sep_mean''\n',...
                '\t- * alternatives are: mean, sd, median, iqr, min, max'],...
                dop.tmp.act_range);
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