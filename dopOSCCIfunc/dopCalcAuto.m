function [dop,okay,msg] = dopCalcAuto(dop_input,varargin)
% dopOSCCI3: dopCalcAuto
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
% Created: 13-Aug-2014 NAB
% Last edit:
% 23-Aug-2014 NAB
% 01-Sep-2014 NAB fixed dopSetBasicInputs
% 04-Sep-2014 NAB msg & wait_warn updates
% 05-Sep-2014 NAB added 'file' to inputs for error reporting
% 01-Sep-2015 NAB sorted the epoch by epoch calculations, wasn't tested
%   previously...
% 04-Jan-2016 NAB added 'poi_select',0/1 ... input for manual selection of
%   period of interest
% 21-Jan-2016 NAB adding dopManualPOI function inside this - used to just
%   be inside the dopCalcSummary function but some of the internal code
%   here over-rides that. Clues about this below if I ever need them.
%   Please email me if you're unsure!
% 09-Aug-2016 NAB added 'ttest' input to flow through into dopCalcSummary

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
            'file',[],...
            'msg',1,...
            'wait_warn',0,...
            'half_balance',1,... % spilt half balance epoch numbers in halves
            'epoch',[],...
            'baseline',[],...
            'poi',[], ... % % 'poi',[5 15];
            'poi_select',0, ... % manual selection of period of interest
            'poi_fullfile',[], ... %
            'poi_dir',[],...
            'poi_file',[],...
            'act_window',[], ... %
            'sample_rate',[], ...
            'ttest',1,...
            'clear',1 ... % remove previous ''dop.sum'' field/data
            );
        % cells don't work in struct function...
        inputs.defaults.summary = {'overall'};
        inputs.defaults.channels = {'Difference'};
        inputs.defaults.periods = {'poi'};
        inputs.defaults.epochs = {'screen'}; % 'screen','odd','even','all','act','sep'
        inputs.required = ...
            {'poi','baseline','act_window','sample_rate'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        if okay
        if isfield(dop.tmp,'data') && size(dop.tmp.data,3) == 1
            okay = 0;
            msg{end+1} = sprintf(['''dop.tmp.data'' doesn''t looked like' ...
                ' it''s been epoched yet. Do that first\n(%s: %s)'],...
                mfilename,dop.tmp.file);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            
        elseif isfield(dop.tmp,'data') && isempty(dop.tmp.data)
            okay = 0;
            msg{end+1} = sprintf('''dop.tmp.data'' is empty\n(%s: %s)',...
                mfilename,dop.tmp.file);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        elseif ~isfield(dop.tmp,'data')
            okay = 0;
            msg{end+1} = sprintf(['''dop.tmp.data'' doesn''t exist:'...
                ' i.e., no data inputted\n(%s: %s)'],...
                mfilename,dop.tmp.file);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        end
        %% tmp check
%         if okay && isfield(dop,mfilename)
%             make sure the dop.tmp variable is correct: with multiple
%             functions within functions this is required.
%             msg{end+1} = ['Multiple functions running with setGetInputs,'...
%                 ' updating ''dop.tmp'' variable'];
%             dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
%             dop.tmp = dop.(mfilename);
%             dop = rmfield(dop,mfilename);
%             current data set may have been updated also...
%             dop.tmp.data = dop.data.use;
%         end
% 21-Jan-2016 NAB added dopMultiFuncTmpCheck instead of above code
%         [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        % don't think that it's needed here... 03-Aug-2016
        %% clear previous data
        if okay && isfield(dop,'sum') && isfield(dop.tmp,'clear') && dop.tmp.clear
            dop = rmfield(dop,'sum');
            msg{end+1} = 'Cleared previous calculations: ''dop.sum'' field removed';
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        
        %% manual poi selection
        if okay && dop.tmp.poi_select
            [dop,okay,msg] = dopManualPOI(dop,okay,msg,...
                'poi_select',dop.tmp.poi_select,...
                'poi_fullfile',dop.tmp.poi_fullfile, ... 
                'poi_dir',dop.tmp.poi_dir,...
                'poi_file',dop.tmp.poi_file);
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
            
            dop.tmp.poi = dop.poi.use;
            dop.tmp.poi_select = 0;
            % this overides the later function - dopCalcSummary which could
            % still be used independently and would do the graphing if
            % required
            % I'll leave the code in there 21-Jan-2016 - originally
            % included incase people wanted to look at every graph -
            % overall, odd, even, etc.
        end
        
        %% main code
        if okay
            %         dop.calc.list = {'latency','LI','SD'};
            % shorten the variable names
            for i = 1 : numel(dop.tmp.summary) % numel(inputs.defaults.summary)
                dop.tmp.sum = dop.tmp.summary{i};
                for ii = 1 : numel(dop.tmp.channels)
                    dop.tmp.ch = dop.tmp.channels{ii};
                    for iii = 1 : numel(dop.tmp.periods)
                        dop.tmp.prd = dop.tmp.periods{iii};
                        dop.tmp.prd_spec = dop.tmp.prd;
                        for jjj = 1 : size(dop.tmp.(dop.tmp.prd),1)
                            dop.tmp.prd_spec = dopSaveSpecificLabel(dop.tmp.prd,dop.tmp.(dop.tmp.prd)(jjj,:));
%                             dop.tmp.prd_spec = sprintf('%s%ito%i',dop.tmp.prd,dop.tmp.(dop.tmp.prd)(jjj,:));
%                             dop.tmp.prd_spec = strrep(dop.tmp.prd_spec,'-','n');
                        for iiii = 1 : numel(dop.tmp.epochs)
                            dop.tmp.eps = dop.tmp.epochs{iiii};
                            if strcmp(dop.tmp.sum,'epoch')
                                dop.tmp.eps = 'all';
                            end
                            
                            msg{end+1} = sprintf([...
                                'Summary = ''%s'': Channel = ''%s'': '...
                                'Period =  ''%s'': Epochs = ''%s'''],...
                                dop.tmp.summary{i},...
                                dop.tmp.channels{ii},dop.tmp.periods{iii},...
                                dop.tmp.epochs{iiii});
                            % don't want this popping up as warn dialog
                            dopMessage(msg,dop.tmp.msg,1);%,sokay,dop.tmp.wait_warn);
                            
                            % 'all'
                            dop.tmp.ep_select = ones(1,size(dop.tmp.data,2));
                            switch dop.tmp.eps
                                case 'screen'
                                    dop.tmp.ep_select = dop.epoch.screen;
                                case {'odd','even'} % split half
                                    dop.tmp.epoch_n = 1 : size(dop.tmp.data,2); % number of epochs
                                    % odd + regular screen
                                    dop.tmp.ep_odd = and(dop.epoch.screen,mod(dop.tmp.epoch_n,2));
                                    dop.tmp.ep_even = and(dop.epoch.screen,~mod(dop.tmp.epoch_n,2));
                                    
                                    if dop.tmp.half_balance && sum(dop.tmp.ep_odd) ~= sum(dop.tmp.ep_even)
                                        dop.tmp.half_dif = sum(dop.tmp.ep_odd) - sum(dop.tmp.ep_even);
                                        if dop.tmp.half_dif < 0 % more in even
                                            dop.tmp.ep_even(find(dop.tmp.ep_even == 1,...
                                                abs(dop.tmp.half_dif),'first')) = 0;
                                            % %                         msg{end+1} = sprintf('Balancing for odd-even epoch numbers\n\t'
                                        else % more in odd
                                            dop.tmp.ep_odd(find(dop.tmp.ep_odd == 1,...
                                                abs(dop.tmp.half_dif),'first')) = 0;
                                        end
                                    end
                                    dop.tmp.ep_select = dop.tmp.ep_odd;
                                    if strcmp(dop.tmp.eps,'even')
                                        dop.tmp.ep_select = dop.tmp.ep_even;
                                    end
                                case 'all'
                                otherwise
                                    msg{end+1} = sprintf([...
                                        'Epochs selection ''%s'' not recognised.'...
                                        ' Default will be used'],dop.tmp.eps);
                                    dop.tmp.eps = 'screen';
                                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                                    
                            end
                            dop.tmp.ep_select = logical(dop.tmp.ep_select);
                            msg{end+1} = sprintf('Epoch select (%s): %u epochs',...
                                dop.tmp.eps, sum(dop.tmp.ep_select));
                            if dop.tmp.comment; fprintf('\t%s\n\n',msg{end}); end
                            % make sure it's logical
                            
                            
                            % create a bunch of empty arrays
                            %         for i = 1 : numel(dop.calc.list)
                            %             dop.epoch.(dop.calc.list{i}) = zeros(1,size(dop.tmp.data,2));
                            %         end
                            % specify the 'Difference' channel (# 3 of the z dimension)
                            dop.tmp.channel_filt = strcmp(dop.data.epoch_labels,dop.tmp.ch);
                            %                             dop.tmp.prd_filt = (-dop.tmp.epoch(1) + dop.tmp.(dop.tmp.prd))/(1/dop.tmp.sample_rate);
                            %                             if dop.tmp.prd_filt(1) < 1
                            %                                 dop.tmp.prd_filt = dop.tmp.prd_filt+1;
                            %                             end
                            %        for i = 1 : size(dop.tmp.data,2) % number of epochs
                            %            % define the epoch data to examine
                            %            dop.tmp.ep = squeeze(dop.tmp.data(:,i,dop.tmp.channel_filt));
                            %            dop.tmp.dat = dop.tmp.ep(dop.tmp.prd_filt(1):dop.tmp.prd_filt(2));
                            
                            % peak_n = number of epochs
                            switch dop.tmp.sum
                                case 'overall'
                                    %                                     dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).peak_n = ...
                                    %                                         size(dop.tmp.data(:,dop.tmp.ep_select,dop.tmp.channel_filt),2);
                                    dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd_spec).(dop.tmp.eps).data = squeeze(...
                                        dop.tmp.data(:,dop.tmp.ep_select,dop.tmp.channel_filt));
                                    %                                     dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).data_epochs = squeeze(...
                                    %                                         dop.tmp.data(:,dop.tmp.ep_select,dop.tmp.channel_filt));
                                    
                                case 'epoch'
                                    %                                     dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).peak_n = ...
                                    %                                         ones(1,size(dop.tmp.data(:,dop.tmp.ep_select,dop.tmp.channel_filt),2));
                                    dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd_spec).(dop.tmp.eps).data = squeeze(...
                                        dop.tmp.data(:,dop.tmp.ep_select,dop.tmp.channel_filt));
                            end
                            
                            
                            
                            
                            %                             %% > Period calculations
                            % %                             dop.tmp.use_data = dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).data(...
                            % %                                 dop.tmp.prd_filt(1):dop.tmp.prd_filt(2),:);
                            %
                            %
                            %                             dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).period = ...
                            %                                 dopCalcPeriod(dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).data,...
                            %                                 'period',dop.tmp.prd,...
                            %                                 'epoch',dop.tmp.epoch,...
                            %                                 'sample_rate',dop.tmp.sample_rate,...
                            %                                 'poi',dop.tmp.poi,...
                            %                                 'baseline',dop.tmp.baseline);
                            %                             [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                            %                             calculate summary statistcs of period
                            %                             dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).period_samples = ...
                            %                                 numel(dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).period_data);
                            %                             dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).period_mean = ...
                            %                                 mean(dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).period_data);
                            %                             dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).period_sd = ...
                            %                                 std(dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).period_data);
                            %                             if numel(dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).period_samples) == 1
                            %                             msg{end+1} = sprintf('Period: # samples %i, Mean = %3.2f (SD = %3.2f)',...
                            %                                     dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).period_samples,...
                            %                                     dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).period_mean,...
                            %                                     dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).period_sd);
                            %                             if dop.tmp.comment; fprintf('\t%s\n\n',msg{end}); end
                            
                            %% > summary statistics
                            [dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd_spec).(dop.tmp.eps),...
                                okay,msg] = dopCalcSummary(...
                                dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd_spec).(dop.tmp.eps).data,...
                                'summary',dop.tmp.sum,... % 'overall' or epoch'
                                'period',dop.tmp.prd,...
                                'epoch',dop.tmp.epoch,...
                                'act_window',dop.tmp.act_window,...
                                'sample_rate',dop.tmp.sample_rate,...
                                'poi',dop.tmp.poi(jjj,:),...
                                'baseline',dop.tmp.baseline,...
                                'file',dop.tmp.file,...
                                'ttest',dop.tmp.ttest,...
                                'poi_select',dop.tmp.poi_select);% manual selection of poi
                            % possibly don't need this here... 1-Aug-2016
%                             [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                            if strcmp(dop.tmp.sum,'epoch')
                                % only need to do this once - overall vs odd
                                % vs even makes no difference, defaults to
                                % selection of all epochs so single
                                % calculation will do it
                                break
                            end
                        end
                        end
                    end
%                     if or(strcmp(dop.tmp.eps,'screen'),strcmp(dop.tmp.eps,'all')) && strcmp(dop.tmp.sum,'epoch')
%                         break; % don't need to keep doing this loop
%                     end
                end
            end
        end
        
        
        
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        if dop.tmp.gui
            msg = sprintf('''%s'' function run successfully\n\n',...
                mfilename);
            dop.tmp.summary_check = ~cellfun('isempty',regexp(dop.msg,'^Summary of*'));
            if sum(dop.tmp.summary_check)
                for i = find(dop.tmp.summary_check,1,'last') : numel(dop.msg)
                    msg = sprintf('%s\t%s\n',msg,dop.msg{i});
                end
            end
            dop.step.(mfilename) = 1;
            if ~okay
                dop.step.(mfilename) = 0;
                msg = strrep(msg,'success','unsuccess');
                msg = strrep(msg,'Data baseline corrected','Baselined correction attempted');
            end
        end
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end