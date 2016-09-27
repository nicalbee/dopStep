function [dop_output,okay,msg,dop] = dopCalcSummary(dop_input,varargin)
% dopOSCCI3: dopCalcSummary
%
% notes:
% basic structure of a function to save time when creating a new one
%
% * not yet implemented (19-Dec-2013)
%
% Use:
%
% [dop,okay,msg] = dopCalcSummary(dop,[]);
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
% Created: 23-Aug-2014 NAB
% Last edit:
% 23-Aug-2014 NAB
% 04-Sep-2014 NAB msg & wait_warn updates
% 05-Sep-2014 NAB & HMP fixed period and peak calculations being the same -
%   again!
%   + concerned about calculations when samples outside of the period of
%   interest may be required. Happy about this now
% 04-Oct-2014 NAB on HMP tip, fixed the activation window definition
% 21-Oct-2014 NAB put 'ttest' exist check in, in case statistics toolbox
%   isn't there... hmm, still not working - might be a version issue for
%   Lisa in Adelaide.
% 27-Jan-2015 NAB zeroed latency samples: ie -1 + ...
% 01-Sep-2015 NAB sorted the epoch by epoch calculations, wasn't tested
%   previously...
% 11-Sep-2015 NAB playing with mean/sd labelling
% 14-Sep-2015 NAB fixed sd issue, still waiting for Heather on the
%   labelling...
% 30-Sep-2015 NAB issue with epoch calculation, not filtering properly with
%   different windows
% 14-Oct-2015 NAB removed period_mean_sd - don't think it's used anymore
% 30-Nov-2015 NAB fixed mismatch on dimensions with baseline epoch peak
%   calcualtions - rarely needed, playing with the Pinaya et al. method
% 04-Jan-2016 NAB added 'poi_select',0/1 ... input for manual selection of
%   period of interest
% 21-Jan-2016 NAB added poi_dir/file/fullfile inputs in case this ever
%   wanted to be run as inputs, rather than looking for dop.def variables
% 27-Sep-2016 NAB added t_p & t_sig to default and adjusted below for
%   single epoch processing (I think).

% start with dummy values in case there are problems
tmp_default = 999;
dop_output = struct(...
    'data',[],... [251x2 double]
    'peak_samples',tmp_default,...
    'peak_epochs',tmp_default,...
    'peak_mean',tmp_default,...
    'peak_sd',tmp_default,... 'peak_sd_note', 'This is the standard deviation of the means of the data',...
    'peak_sd_of_mean',tmp_default,...'peak_mean_sd',tmp_default,...
    'peak_sd_of_sd',tmp_default,...
    'period_samples',tmp_default,...
    'period_epochs',tmp_default,...
    'period_mean',tmp_default,...
    'period_sd',tmp_default,... 'period_mean_sd',tmp_default,...
    'period_sd_of_mean',tmp_default,...
    'period_sd_of_sd',tmp_default,...
    'peroid_mean_sd_note','Equal to standard deviation for epoch by epoch summary',...
    'peroid_sd_of_sd_note','Equal to standard deviation for epoch by epoch summary',...
    'period_n',tmp_default,...
    'peak_n',tmp_default,...
    'peak_latency_sample',tmp_default,...
    'peak_latency',tmp_default, ...
    't_value',tmp_default, ...
    't_p',tmp_default,...
    't_sig',tmp_default,...
    't_df',tmp_default, ...
    't_sd',tmp_default ...
    );



[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        %         inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'file',[],...
            'msg',1,...
            'wait_warn',0,...
            'summary','overall',... % 'epoch'
            'period','poi',...
            'epoch',[],...
            'act_window',[], ...
            'sample_rate',[], ...
            'peak','max',... % 'min'
            'value','abs', ... 'raw'
            'baseline',[],...
            'ttest',0,... % turn on the ttest, not by default
            'poi',[], ...
            'poi_select',0, ... % manual selection of period of interest
            'poi_fullfile',[], ... % could be entered as inputs
            'poi_dir',[],...
            'poi_file',[]...
            );
        % cells don't work in struct function...
        inputs.required = ...
            {'period_limits','epoch','act_window','sample_rate'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        if okay
            switch dopInputCheck(dop)
                case {'dop','matrix','vector'}
                    
                    if ~isfield(dop.tmp,'data') || isempty(dop.tmp.data)
                        okay = 0;
                        msg{end+1} = sprintf(['Inputted data is empty. Could be'...
                            ' to do with the screening of epochs,'...
                            ' especially if you''re doing odd & even for'...
                            ' split-half calculations\n(%s:%s)'],...
                            mfilename,dop.tmp.file);
                    else
                        msg{end+1} = 'Using inputted data';
                    end
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                otherwise
                    okay = 0;
                    msg{end+1} = sprintf(['Input doesn''t include recognised data',...
                        '\n(%s:%s)'],mfilename,dop.tmp.file);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
        end
        
        %% check for period information
        if isempty(dop.tmp.(dop.tmp.period))
            okay = 0;
            msg{end+1} = sprintf(['''%s'' timing has not been specified'...
                '\n(%s:%s)'],dop.tmp.period,mfilename,dop.tmp.file);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        
        %% main code
        if okay
            % manual selection of epoch available
            if dop.tmp.poi_select && strcmp(dop.tmp.period,'poi')
                poi_select = dopPlot(dop.tmp.data,'poi_select',1,...
                    'type','epoch',...
                    'epoch',dop.tmp.epoch, ... %
                    'poi',dop.tmp.poi,... %'
                    'baseline',dop.tmp.baseline,...
                    'act_window',dop.tmp.act_window,...
                    'sample_rate',dop.tmp.sample_rate,...
                    'file_name',dop.tmp.file,'wait');
                % 'poi_select' should be available in workspace
                % assignin function called in @dopPlotEpochPOIAdjust
                if exist('poi_select','var')
                    dop.tmp.(dop.tmp.period) = poi_select;
                end
            end
            
            
            %% > period filter
            dop.tmp.period_filt = (-dop.tmp.epoch(1) + dop.tmp.(dop.tmp.period))/(1/dop.tmp.sample_rate);
            if dop.tmp.period_filt(1) < 1
                dop.tmp.period_filt = dop.tmp.period_filt+1;
            end
            if dop.tmp.period_filt(2) > size(dop.tmp.data,1)
                dop.tmp.period_filt = (dop.tmp.epoch(2) + dop.tmp.(dop.tmp.period))/(1/dop.tmp.sample_rate);
            end
            
            %% > period calculations
            dop_output.data = dop.tmp.data(dop.tmp.period_filt(1):dop.tmp.period_filt(2),:); % keep a copy
            [dop_output.period_samples,dop_output.period_epochs] = size(dop_output.data);
            
            % for epoch calculations, one number per epoch
            dop_output.period_n = ones(1,dop_output.period_epochs);
            
            % by default, calculate for epochs, then take the summary (ie
            % mean or std) of these for overall
            
            dop_output.period_mean = mean(dop_output.data);
            % standard deviation is always related to the mean, doesn't
            % make any sense if there's a single epoch
            dop_output.period_sd = std(dop_output.data);
            
            % it's possible people will want this information...
            % really defined in order to clarify the earlier mean & sd
            % doesn't work for epoch by epoch calculations
            dop_output.period_sd_of_mean = dop_output.period_sd; %mean(std(dop_output.data,1,2));
            dop_output.period_sd_of_sd = dop_output.period_sd; %mean(std(dop_output.data,1,2));
            
            
            if ismember(dop.tmp.summary,{'overall'})
                % across all epochs (i.e., the average of all epochs)
                dop_output.period_n = dop_output.period_epochs;
                
                % it's possible people will want this information...
                % really defined in order to clarify the earlier mean & sd
                dop_output.period_sd_of_mean = std(dop_output.period_mean);
                dop_output.period_sd_of_sd = std(dop_output.period_sd);
                
                dop_output.period_mean = mean(dop_output.period_mean);
                % standard deviation is always related to the mean, doesn't
                % make any sense if there's a single epoch
                dop_output.period_sd = mean(dop_output.period_sd);
                
                
                
            end
            
            msg{end+1} = sprintf('Summary of samples %u, # epochs %u:',...
                dop_output.period_samples,dop_output.period_epochs);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            
            for i = 1 : numel(dop_output.period_mean)
                msg{end+1} = sprintf(...
                    'Period Mean = %3.2f (SD = %3.2f)',...
                    dop_output.period_mean(i),dop_output.period_sd(i));
                if numel(dop_output.period_mean) > 1
                    msg{end} = strrep(msg{end},'Mean',...
                        sprintf('Epoch %u. Mean',i));
                end
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            
            
            %% > peak calculations
            %                         dop_output.peak_data = dop_output.data; % keep a copy
            [dop_output.peak_samples,dop_output.peak_epochs] = size(dop_output.data);
            %             dop_output.peak_data = dop_output.data;
            %             if strcmp(dop.tmp.summary,'overall')
            %                 dop_output.peak_data = mean(dop_output.peak_data,2);
            %             end
            dop_output.peak_n = ones(1,dop_output.peak_epochs);
            
            % originally written for 'Difference' waveform, absolute maximum
            % doesn't necessarily make sense of other channels
            % updated 23-Aug-2014 to be accept inputs to alter whether it's
            % the 'abs' or 'raw' data used and (below) whether the 'min' or
            % 'max' is searched for
            dop.tmp.peak_data = dop_output.data;
            if strcmp(dop.tmp.value,'abs');
                dop.tmp.peak_data = abs(dop.tmp.peak_data);
            end
            
            
            % values for each epoch
            [dop.tmp.peak_value,dop.tmp.peak_sample] = ...
                eval([dop.tmp.peak,'(dop.tmp.peak_data)']); % could be min or max
            if ismember(dop.tmp.summary,{'overall'})
                dop.tmp.peak_data = dop_output.data;
                % there was an issue here with the numbers going into the
                % overall calculation 30-Sep-2015 NAB
                if strcmp(dop.tmp.value,'abs');
                    dop.tmp.peak_data = abs(mean(dop.tmp.peak_data,2));
                end
                % across all epochs (i.e., the average of all epochs)
                [dop.tmp.peak_value,dop.tmp.peak_sample] = ...
                    eval([dop.tmp.peak,'(dop.tmp.peak_data)']); % could be min or max
                %                 [dop.tmp.peak_value,dop.tmp.peak_sample] = ...
                %                     eval([dop.tmp.peak,'(mean(dop.tmp.peak_data,2))']); % could be min or max
            end
            dop_output.peak_latency_sample = -1 + dop.tmp.period_filt(1) + dop.tmp.peak_sample; % in samples
            % -1 here to 'zero' the latency 27-Jan-15 NAB
            dop_output.peak_latency = dop.tmp.epoch(1) + dop_output.peak_latency_sample*(1/dop.tmp.sample_rate);
            
            % calculate the activation window
            dop.tmp.window = [];
            dop.tmp.window(:,1) = dop_output.peak_latency_sample'-(dop.tmp.act_window*.5/(1/dop.tmp.sample_rate)); % lower limit
            dop.tmp.window(:,2) = dop_output.peak_latency_sample'+(dop.tmp.act_window*.5/(1/dop.tmp.sample_rate)); % upper limit
            
            
            % total number of sample points in an epoch
            dop.tmp.n_pts = size(dop.tmp.data,1);%size(dop_output.data,1);
            
            % loop for the epoch calculations
            for j = 1 : size(dop.tmp.window,1)
                if dop.tmp.window(j,1) < 1
                    dop.tmp.window(j,:) = [1 (dop.tmp.act_window/(1/dop.tmp.sample_rate))+1];
                end
                if dop.tmp.window(j,2) > dop.tmp.n_pts
                    dop.tmp.window(j,:) = [dop.tmp.n_pts - (dop.tmp.act_window/(1/dop.tmp.sample_rate)) dop.tmp.n_pts];
                end
            end
            %             if size(dop.tmp.window,1) == 1
            %                 dop.tmp.window_data = dop.tmp.data(dop.tmp.window(1):dop.tmp.window(2),:);
            %             else
            
            if size(dop.tmp.window,1) == 1
                dop.tmp.window_data = dop.tmp.data(dop.tmp.window(:,1):dop.tmp.window(:,2),:);
                % this isn't working for more than a single window - need to
                % create logical filters: 30-Sep-15 NAB
            else
                dop.tmp.window_data = zeros(length(dop.tmp.window(1,1):dop.tmp.window(1,2)),size(dop.tmp.data,2));
                for j = 1 : size(dop.tmp.window_data,2)
                    dop.tmp.window_data(:,j) = dop.tmp.data(dop.tmp.window(j,1):dop.tmp.window(j,2),j);
                end
            end
            
            
            %             end
            
            
            
            
            dop_output.peak_mean = mean(dop.tmp.window_data);% mean(mean(dop.tmp.window_data,2));
            % standard deviation is always related to the mean, doesn't
            % make any sense if there's a single epoch
            dop_output.peak_sd = std(dop.tmp.window_data); % std(mean(dop.tmp.window_data,2));
            
            % it's possible people will want this information...
            % really defined in order to clarify the earlier mean & sd
            dop_output.peak_sd_of_mean = dop_output.peak_sd;% mean(std(dop.tmp.window_data,1,2));
            dop_output.peak_sd_of_sd = dop_output.peak_sd; %std(std(dop.tmp.window_data,1,2));
            
            if ~strcmp(dop.tmp.summary,'overall')
                % might as well have multiples of these too
                dop_output.t_value = ones(1,dop_output.peak_epochs)*dop_output.t_value;
                dop_output.t_df = ones(1,dop_output.peak_epochs)*dop_output.t_df;
                dop_output.t_sd = ones(1,dop_output.peak_epochs)*dop_output.t_sd;
            end
            
            if exist('ttest','file') && dop.tmp.ttest
                
                [dop_output.t_sig,dop_output.t_p,...
                    dop_output.ci,dop_output.stats] = ttest(dop.tmp.window_data);
                
                if strcmp(dop.tmp.summary,'overall')
                    [dop_output.t_sig,dop_output.t_p,...
                        dop_output.ci,dop_output.stats] = ttest(dop_output.peak_mean); %ttest(dop.tmp.window_data);
                end
                
                dop_output.t_value = dop_output.stats.tstat;
                dop_output.t_df = dop_output.stats.df;
                dop_output.t_sd = dop_output.stats.sd;
                
                
                msg{end+1} = sprintf('t(%i) = %3.2f, p = %3.2f',dop_output.t_df,dop_output.t_value,dop_output.t_p);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            elseif ~dop.tmp.ttest
                msg{end+1} = '''ttest'' variable set to 0, not running';
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            else
                msg{end+1} = '''ttest'' function is not available - missing statistics toolbox';
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            
            if strcmp(dop.tmp.summary,'overall')
                
                %                 if ~strcmp(dop.tmp.summary,'overall')
                %                     % across all epochs (i.e., the average of all epochs)
                %                     dop.tmp.window_data = mean(dop.tmp.window_data,2);
                %                 end
                
                dop_output.peak_n = dop_output.peak_epochs;
                
                % it's possible people will want this information...
                % really defined in order to clarify the earlier mean & sd
                dop_output.peak_sd_of_mean = std(dop_output.peak_mean);
                dop_output.peak_sd_of_sd = std(dop_output.peak_sd);
                
                dop_output.peak_mean = mean(dop_output.peak_mean);
                % standard deviation is always related to the mean, doesn't
                % make any sense if there's a single epoch
                dop_output.peak_mean_of_sd = mean(dop_output.peak_sd);
                
                
            end
            %             msg{end+1} = sprintf('Peak: # samples %u, # epochs %u:',...
            %                 dop_output.peak_samples,dop_output.peak_epochs);
            %             dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            for i = 1 : numel(dop_output.peak_mean)
                msg{end+1} = sprintf(...
                    'Peak mean = %3.2f (SD = %3.2f), Latency = %3.2f (%3.2f samples)',...
                    dop_output.peak_mean(i),dop_output.peak_sd(i),...
                    dop_output.peak_latency(i),dop_output.peak_latency_sample(i));
                if numel(dop_output.peak_mean) > 1
                    msg{end} = strrep(msg{end},'Peak',...
                        sprintf('Epoch %u. Peak',i));
                end
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
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