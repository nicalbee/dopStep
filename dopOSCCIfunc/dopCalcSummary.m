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
% Created: 23-Aug-2014 NAB
% Last edit:
% 23-Aug-2014 NAB
% 04-Sep-2014 NAB msg & wait_warn updates
% 05-Sep-2014 NAB & HMP fixed period and peak calculations being the same -
%   again!
%   + concerned about calculations when samples outside of the period of
%   interest may be required. Happy about this now
% 04-Oct-2014 NAB on HMP tip, fixed the activation window definition

% start with dummy values in case there are problems
tmp_default = 999;
dop_output = struct(...
    'data',[],... [251x2 double]
    'peak_samples',tmp_default,...
    'peak_epochs',tmp_default,...
    'peak_mean',tmp_default,...
    'peak_sd_note', 'This is the standard deviation of the means of the data',...
    'peak_sd',tmp_default,...
    'peak_mean_sd',tmp_default,...
    'peak_sd_of_sd',tmp_default,...
    'period_samples',tmp_default,...
    'period_epochs',tmp_default,...
    'period_mean',tmp_default,...
    'period_sd',tmp_default,...
    'period_mean_sd',tmp_default,...
    'period_sd_of_sd',tmp_default,...
    'period_n',tmp_default,...
    'peak_n',tmp_default,...
    'peak_latency_sample',tmp_default,...
    'peak_latency',tmp_default ...
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
            'poi',[] ...
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
            dop_output.period_n = dop_output.period_epochs;
            dop_output.period_mean = mean(mean(dop_output.data,2));
            % standard deviation is always related to the mean, doesn't
            % make any sense if there's a single epoch
            dop_output.period_sd = std(mean(dop_output.data,2));
            
            % it's possible people will want this information...
            % really defined in order to clarify the earlier mean & sd
            dop_output.period_mean_sd = mean(std(dop_output.data,1,2));
            dop_output.period_sd_of_sd = std(std(dop_output.data,1,2));
            
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
            dop_output.peak_n = dop_output.peak_epochs;
            
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
            if strcmp(dop.tmp.summary,'overall')
                % across all epochs (i.e., the average of all epochs)
                [dop.tmp.peak_value,dop.tmp.peak_sample] = ...
                    eval([dop.tmp.peak,'(mean(dop.tmp.peak_data,2))']); % could be min or max
            end
            dop_output.peak_latency_sample = dop.tmp.period_filt(1) + dop.tmp.peak_sample; % in samples
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
                    dop.tmp.window(j,:) = [1 (dop.tmp.act_window/(1/dop.tmp.sample_rate))];
                end
                if dop.tmp.window(j,2) > dop.tmp.n_pts
                    dop.tmp.window(j,:) = [dop.tmp.n_pts - (dop.tmp.act_window/(1/dop.tmp.sample_rate)) dop.tmp.n_pts];
                end
            end
%             if size(dop.tmp.window,1) == 1
%                 dop.tmp.window_data = dop.tmp.data(dop.tmp.window(1):dop.tmp.window(2),:);
%             else
                dop.tmp.window_data = dop.tmp.data(dop.tmp.window(:,1):dop.tmp.window(:,2),:);
%             end
            if strcmp(dop.tmp.summary,'overall')
                % across all epochs (i.e., the average of all epochs)
                dop.tmp.window_data = mean(dop.tmp.window_data,2);
            end
            
            dop_output.peak_mean = mean(mean(dop.tmp.window_data,2));
            % standard deviation is always related to the mean, doesn't
            % make any sense if there's a single epoch
            dop_output.peak_sd = std(mean(dop.tmp.window_data,2));
            
            % it's possible people will want this information...
            % really defined in order to clarify the earlier mean & sd
            dop_output.peak_mean_sd = mean(std(dop.tmp.window_data,1,2));
            dop_output.peak_sd_of_sd = std(std(dop.tmp.window_data,1,2));
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