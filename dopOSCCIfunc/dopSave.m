function [dop,okay,msg] = dopSave(dop_input,varargin)
% dopOSCCI3: dopSave
%
% [dop,okay,msg] = dopSave(dop,[okay],[msg],...);
%
% notes:
% save summary data to a text file that can be processed in SPSS or excel.
%
% Lots of options to tailor the variables saved. These can be inputed into
% the function as below. But they can also be set outside the function,
% similar to the defintion settings, and the function will automatically
% find them.
% e.g., the following settings would save the typically required laterality
%   index information, identified by the 'dop.file' extras variable:
%
%   dop.save.extras = {'file'}; % you can add your own variables to this, just need to be defined somewhere as dop.save.x = where x = variable name
%   dop.save.summary = {'overall'};
%   dop.save.channels = {'Difference'};
%   dop.save.periods = {'poi'};
%   dop.save.epochs = {'screen','odd','even'};
%   dop.save.variables = {'peak_n','peak_mean','peak_sd','peak_latency'};
%
%
% Use:
%
% [dop,okay,msg] = dopSave(dop,[okay],[msg],...);
%
% where:
%--- Inputs ---
% - dop_input: dop matlab structure or data matrix, file name, or data
%   directory, depending on the function. Other than 'dop' structure is
%   currently not well tested 07-Sep-2014 NAB
%
%--- Optional, data only:
%   > e.g., ...,0,... or ...,'string',... or ...,cell,...
% - okay:
%   e.g., dopFunction(dop_input,1,...) or dopFunction(dop_input,0,...)
%       or dopFunction(dop_input,[],...)
%   logical (0 or 1) for problem, 0 = no problem, 1 = problem. This can be
%   carried through from previously run functions. If set to 0, the
%   function will not be implemented - designed to skip functions if there
%   is a problem with the data or variable settings.
%
% - msg:
%   > e.g., dopFunction(dop_input,1,msg,...)
%       or dopFunction(dop_input,1,[],...)
%   Cell variable with a history of messages from previously run functions.
%   New messages are appended to the end of the array and can be reported
%   to examine the processing steps using 'dopMessage':
%   e.g. dopMessage(msg) or dopMessage(dop);
%
%   note: okay and msg will only be recognised as the 1st and 2nd inputs
%   after the dop_input variable and only in this order.
%       e.g., dopFunction(dop,okay,msg,...)
%   If run without, e.g., dopFunction(dop,...), okay and msg will be reset
%   to 1 (i.e., no problem) and empty (i.e., []) respectively.
%
%--- Optional, Text + value:
%   > e.g., ...,'variable_name',X,...
%   note: '...' indicates that other inputs can be included before or
%   after. The inputs can be included in any order.
%
% - 'save_file':
%   > e.g., dopFunction(dop_input,okay,msg,...,'save_file','dopOSCCIoutput',...)
%   default = 'dopOSCCIoutput'
%   Name of the data file into which the data will be saved
%
% - 'save_dir':
%   > e.g., dopFunction(dop_input,okay,msg,...,'save_dir','C:\my_ouput_dir\',...)
%   Name of the directory into which the data file will be saved
%
% - 'save_dat':
%   > e.g., dopFunction(dop_input,okay,msg,...,'save_dat',0,...)
%       or
%   dopFunction(dop_input,okay,msg,...,'save_dat',1,...)
%   Logical (0 = no, yes = 1) setting whether or not a '.dat' file of the
%   data will be saved
%
% - 'save_mat':
%   > e.g., dopFunction(dop_input,okay,msg,...,'save_mat',0,...)
%       or
%   dopFunction(dop_input,okay,msg,...,'save_mat',1,...)
%   Logical (0 = no, yes = 1) setting whether or not a '.mat' file of the
%   data will be saved
%
% - 'delim':
%   > e.g., dopSave(dop_input,okay,msg,...,'delim','\t',...)
%   sets how the saved data values will be separated in the save file
%   The default is tab = '\t'
%   09-Sep-2014 currently not tested for other options
%
% - 'extras':
%   > e.g., dopSave(dop_input,okay,msg,...,'extras',{'file','condition'},...)
%   sets 'extra' variables that will be saved as additional data columns at
%   the start of the data file.
%   These values will be retrieved from the 'dop.save' structured variable.
%   For example, if dop.save.file = 'my_file.EXP', this will be saved for
%   the in the first column. Any additional variables will need to be
%   defined by the user.
%   The default is 'file' as an identifier.
%
% - 'summary' = {'overall'};
%   > e.g., dopSave(dop_input,okay,msg,...,'summary',{'overall'},...)
%   sets which data summaries will be saved. Accepts 'overall' and 'epoch'.
%   note: can be used together, e.g., {'overall','epoch'}
%   The 'overall' setting will save values averaged across epochs.
%   The 'epoch' setting will save values for each individual epoch.
%   The default is 'overall'
%
% - 'channels':
%   > e.g., dopSave(dop_input,okay,msg,...,'channels',{'Difference','Average'},...)
%   sets which data channels are saved.
%   Options include:
%   'Left, 'Right','Difference', and 'Average'.
%   The default is 'Difference' as this relates to the commonly required
%   laterality index.
%
% - 'periods':
%   > e.g., dopSave(dop_input,okay,msg,...,'periods',{'poi','baseline'},...)
%   sets the periods for which the data will be saved.
%   Options include:
%   'epoch', 'baseline', and 'poi' (period of interest).
%   The default setting is 'poi' as this relates to the commonly required
%   laterality index.
%
% - 'epochs':
%   > e.g., dopSave(dop_input,okay,msg,...,'epochs',{'screen','odd','even'},...)
%   sets the selection of epochs that will be summarised.
%   Options include:
%   'all','screen','odd','even','length','act', and 'act_sep'
%   The availability of these options is dependent upon the calculations
%   conducted using the 'dopCalcAuto' or 'dopCalcSummary' functions
%
% - 'variables:
%   > e.g., dopSave(dop_input,okay,msg,...,'variables',{'n','mean','sd','latency'},...)
%   sets which variables will be saved for the above settings (i.e.,
%   'summary', 'periods', and 'epochs'
%   Options currently (10-Sep-2014) include:
%   'period_samples', 'period_mean', 'period_sd', 'period_latency',
%   'peak_n', 'peak_mean', 'peak_sd', and 'peak_latency'
%   peak variables are related to the laterality index
%
% - 'file':
%   > e.g., dopFunction(dop_input,okay,msg,...,'file','subjectX.exp',...)
%   file name of the data file currently being summarised. This is used for
%   error reporting. Typically this variable is automatically populated in
%   the 'dopSetGetInputs' function by searching the 'dop' structure
%   variables: dop.save, dop.use, dop.def, dop.file_info.
%   The default value is empty.
%
% - 'showmsg':
%   > e.g., dopFunction(dop_input,okay,msg,...,'showmsg',1,...)
%       or
%           dopFunction(dop_input,okay,msg,...,'showmsg',0,...)
%   This is a logical variable (1 = on, 0 = off) setting whether or not
%   messages about the progress of the processing are printed to the MATLAB
%   command window.
%   The default value is 1 = on, messages are printed
%
% - 'wait_warn': e.g., ...,'wait_warn',1,... or ....,'wait_warn',0,...
%   This is a logical variable (1 = on, 0 = off) setting whether or not,
%   when 'okay' changes to 0 (i.e. an error), progress through the scripts
%   waits for the warning dialog popup to be closed.
%
% - 'label_specs':
%   e.g., ...,'label_specs',...
%   Including this variable as an input will add period specificications to
%   the column labels for the data. For example, poi (period of interest)
%   would be labelled as 'poi5to15' for [5 15] settings.
%   Negative numbers are denoted by 'n'; for example, 'baselinen15ton5' for
%   a setting of [-15 -5]
%   This is automatically applied if multiple period of interests are
%   specified e.g., [0 5; 5 15; 15 25];
%   The script does this by checking for multiple rows
%
%--- Outputs ---
%   note: outputs are optional, included at the left hand side of the call
%   to a function. The order is fixed
%   > e.g.,
%       dop = dopFunction(...);
%   or
%       [dop,okay] = dopFunction(...);
%   or
%       [dop,okay,msg] = dopFunction(...);
%
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 14-Aug-2014 NAB
% Last edit:
% 20-Aug-2014 NAB
% 01-Sep-2014 NAB fixed dopSetBasicInputs
% 04-Sep-2014 NAB msg & wait_warn updates
% 06-Sep-2014 NAB updated save naming convention
% 08-Sep-2014 NAB fixed fileparts exclusion for naming
% 09-Sep-2014 NAB updated documentation
% 10-Sep-2014 NAB more documentation
% 17-Sep-2014 NAB save file name adjusted
% 18-Sep-2014 NAB save file name updated
% 05-May-2015 NAB added dopSaveDir in case not already created
% 19-May-2015 NAB added dopMultiFuncTmpCheck after dopSaveDir so that
%   dop.tmp variables carry on specific to dopSave function
% 19-May-2015 NAB inputs.defaults.variables changed the way it works...
%   very strange - not at all sure why but wants 'peak_*' now instead of
%   '*' which apparently worked yesterday...
%   > some of the definition information wasn't/isn't make it through
% 19-May-2015 NAB added 'epoch' stucture to look in for variables to save
% 01-Sep-2015 NAB sorted the epoch by epoch saving, wasn't tested
%   previously...
% 15-Sep-2015 NAB added period specific labels/data
% 14-Oct-2015 NAB added 'label_specs' input and default to add label
%   specifications for periods when multiple rows for that variable
% 04-Nov-2015 NAB dummy variable if can't find extra

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        inputs.turnOn = {'label_specs'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'save_file','dopSave',... 'task_name','dopSave',...
            'save_dir',[],...
            'save_mat',0,...
            'save_dat',1, ...
            'baseline',[],...
            'poi',[],...
            'epoch',[],...
            'num_events',[],... % required for epoch by epoch labelling etc.
            'delim','\t', ...
            'msg',[],... % 30-Sep-2015 not sure about adding this
            'file',[],...
            'showmsg',1,...
            'wait_warn',0 ...
            );
        inputs.defaults.extras = {'file'};
        inputs.defaults.summary = {'overall'};
        inputs.defaults.channels = {'Difference'};
        inputs.defaults.periods = {'poi'};
        inputs.defaults.epochs = {'screen'}; % 'screen','odd','even','all','act','sep'
        %         inputs.defaults.variables = {'n','mean','sd','latency'};
        inputs.defaults.variables = {'peak_n','peak_mean','peak_sd_of_mean','peak_latency'};
        %         inputs.required = ...
        %             {};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        dop.tmp.epoch_saved = 0;
        % only want to save the epoch by epoch LIs once and if the 'epochs'
        % setting has option more than 'all', don't want to repeat the save
        
        %% data check
        if okay && ~isfield(dop,'sum')
            okay = 0;
            msg{end+1} = sprintf(['There''s no ''dop.sum'' variable. You need to' ...
                ' run ''dopCalc'' to create summary variables otherwise' ...
                ' there''s nothing to save\n\t(%s: %s)'],...
                mfilename,dop.tmp.file);
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        end
        %% save file name
        if okay && or(isempty(dop.tmp.save_file),strcmp(dop.tmp.save_file,dop.tmp.defaults.save_file))
            if ~isfield(dop,'def') ...
                    || ~isfield(dop.def,'task_name') ...
                    || isempty(dop.def.task_name)
                
                dop.def.task_name = dop.tmp.defaults.save_file;
            end
            dop.tmp.save_file = sprintf('%sSummaryData.dat',dop.def.task_name);
        end
        %% main code
        if okay
            %% set variable abbreivations
            dop.save.abb = dopSaveAbbreviations;
            %             if iscell(dop.tmp.delim)
            %                 dop.tmp.delim = dop.tmp.delim{1};
            %             end
            dop.tmp.delims = {dop.tmp.delim,'\n',1};
            
            
            %% save a mat file
            if isempty(strfind(dop.tmp.save_file,'.mat'))
                [~,~,tmp_ext] = fileparts(dop.tmp.save_file);
                dop.save.save_file = strrep(dop.tmp.save_file,tmp_ext,'.mat');
            end
            if isempty(dop.tmp.save_dir)
                [dop,okay,msg] = dopSaveDir(dop);
                [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                dop.tmp.save_dir = dop.save.save_dir;
            end
            if ~exist(dop.tmp.save_dir,'dir')
                mkdir(dop.tmp.save_dir);
            end
            dop.save.fullfile_mat = fullfile(dop.tmp.save_dir,dop.save.save_file);
            if dop.tmp.save_mat
                save(dop.save.fullfile_mat,'dop');
                msg{end+1} = sprintf('''.mat'' file saved: %s',dop.save.fullfile_mat);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
            % to load
            % load(dop.save.fullfile);
            
            dop.save.fullfile_dat = strrep(dop.save.fullfile_mat,'.mat','.dat');
            
        end
        %% labels/headers
        if okay && ~isfield(dop.save,'labels')
            
            dop.save.labels = [];
            for i = 1 : numel(dop.tmp.extras)
                dop.save.labels{end+1} = dop.tmp.extras{i};
            end
            for i = 1 : numel(dop.tmp.summary)
                dop.tmp.sum = dop.save.abb.(dop.tmp.summary{i});
                
                for ii = 1 : numel(dop.tmp.channels)
                    dop.tmp.ch = dop.save.abb.(dop.tmp.channels{ii});
                    
                    for iii = 1 : numel(dop.tmp.periods)
                        dop.tmp.prd = dop.save.abb.(dop.tmp.periods{iii});
                        dop.tmp.prd_spec = dop.tmp.prd;
                        for jjj = 1 : size(dop.tmp.(dop.tmp.prd),1)
                            if size(dop.tmp.(dop.tmp.prd),1) > 1 || dop.tmp.label_specs
                                dop.tmp.prd_spec = dopSaveSpecificLabel(dop.tmp.prd,dop.tmp.(dop.tmp.prd)(jjj,:));
                            end
                            for iiii = 1 : numel(dop.tmp.epochs)
                                dop.tmp.eps = dop.save.abb.(dop.tmp.epochs{iiii});
                                
                                for iiiii = 1 : numel(dop.tmp.variables)
                                    dop.tmp.var = dop.save.abb.(dop.tmp.variables{iiiii});
                                    switch dop.tmp.summary{i}
                                        case 'overall'
                                            % overall data
                                            dop.save.labels{end+1} = sprintf('%s%s_%s_%s',...
                                                dop.tmp.var,dop.tmp.ch,dop.tmp.eps,...
                                                dop.tmp.prd_spec);
                                        case 'epoch'
                                            if iiii == 1 && ~strcmp(dop.tmp.var,'n')
                                                % n is redundant when it's just the one epoch, so exclude it
                                                
                                                % only need to do this once and
                                                % epoch screen
                                                % ('screen','odd','even') isn't
                                                % relevant to label
                                                if isempty(dop.tmp.num_events)
                                                    dop.tmp.num_events = dop.event.n;
                                                    msg{end+1} = sprintf(['''num_events'' variable is empty. ',...
                                                        'Using current number of events (%i) instead. ',...
                                                        'May result in variable labelling issues if this isn''t the maximum for all files.'],...
                                                        dop.event.n);
                                                    % set okay to zero here so
                                                    % there's a warning message
                                                    % as this is important
                                                    okay = 0;
                                                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                                                    okay = 1;
                                                    % not necessary to have the
                                                    % variable defined here but
                                                    % I think it helps to see
                                                    % what goes into the
                                                    % dopMessage function
                                                end
                                                for j = 1 : dop.tmp.num_events % dop.event.n % for the moment
                                                    dop.save.labels{end+1} = sprintf('%s_%s%u%s_%s',... % '%s_%s%u%s_%s_%s'
                                                        dop.tmp.var,dop.tmp.sum,j,dop.tmp.ch,...dop.tmp.eps,...
                                                        dop.tmp.prd_spec);
                                                end
                                            end
                                            
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        %% > write labels
        % only if the file doesn't exist
        if okay && ~exist(dop.save.fullfile_dat,'file')
            % write the labels
            dop.save.fid = fopen(dop.save.fullfile_dat,'w');
            dop.tmp.delims{3} = 1; % reset delimiter
            for i = 1 : numel(dop.save.labels)
                if i == numel(dop.save.labels)
                    dop.tmp.delims{3} = 2; % new line
                end
                fprintf(dop.save.fid,['%s',dop.tmp.delims{dop.tmp.delims{3}}],dop.save.labels{i});
            end
            fclose(dop.save.fid);
        end
        %% write the data
        if okay
            dop.save.fid = fopen(dop.save.fullfile_dat,'a');
            k = 0;
            dop.tmp.delims{3} = 1; % reset delimiter
            for i = 1 : numel(dop.tmp.extras)
                k = k + 1;
                dop.tmp.data_name = dop.tmp.extras{i};
                tmp.check = {'save','epoch','use','def','file_info'}; % order of these matters
                for j = 1 : numel(tmp.check)
                    if isfield(dop,tmp.check{j}) ...
                            && isfield(dop.(tmp.check{j}),dop.tmp.data_name)
                        dop.tmp.value = dop.(tmp.check{j}).(dop.tmp.data_name);
                        
                        fprintf(dop.save.fid,...
                            [dopVarType(dop.tmp.value),...
                            dop.tmp.delims{dop.tmp.delims{3}}],dop.tmp.value);
                        break
                    end
                    if j == numel(tmp.check)
                        % dummy value
                        dop.tmp.value = 999;
                        
                         fprintf(dop.save.fid,...
                            [dopVarType(dop.tmp.value),...
                            dop.tmp.delims{dop.tmp.delims{3}}],dop.tmp.value);
                        
                        msg{end+1} = sprintf(['''%s'' variable not ',...
                            'found: dummy value saved = %i'],...
                            dop.tmp.data_name,dop.tmp.value);
                        dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                    end
                end
            end
            for i = 1 : numel(dop.tmp.summary)
                dop.tmp.sum = dop.tmp.summary{i};
                
                for ii = 1 : numel(dop.tmp.channels)
                    dop.tmp.ch = dop.tmp.channels{ii};
                    
                    for iii = 1 : numel(dop.tmp.periods)
                        dop.tmp.prd = dop.tmp.periods{iii};
                        dop.tmp.prd_spec = dop.tmp.prd;
                        for jjj = 1 : size(dop.tmp.(dop.tmp.prd),1)
                            dop.tmp.prd_spec = dopSaveSpecificLabel(dop.tmp.prd,dop.tmp.(dop.tmp.prd)(jjj,:));
                            for iiii = 1 : numel(dop.tmp.epochs)
                                dop.tmp.eps = dop.tmp.epochs{iiii};
                                
                                for iiiii = 1 : numel(dop.tmp.variables)
                                    dop.tmp.var = dop.tmp.variables{iiiii};
                                    switch dop.tmp.summary{i}
                                        case 'overall'
                                            k = k + 1;
                                            if k == numel(dop.save.labels)
                                                dop.tmp.delims{3} = 2; % new line
                                            end
                                            % overall data
                                            dop.tmp.value = dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd_spec).(dop.tmp.eps).(dop.tmp.var);
                                            fprintf(dop.save.fid,...
                                                [dopVarType(dop.tmp.value),...
                                                dop.tmp.delims{dop.tmp.delims{3}}],dop.tmp.value);
                                            
                                        case 'epoch'
                                            if ~dop.tmp.epoch_saved && ~strcmp(dop.tmp.var,'peak_n')
                                                % n is redundant when it's just the one epoch, so exclude it
                                                
                                                if ~strcmp(dop.tmp.eps,'all')
                                                    dop.tmp.epoch_eps = 'all';
                                                end
                                                for j = 1 : dop.tmp.num_events % dop.event.n % for the moment
                                                    k = k + 1;
                                                    if k == numel(dop.save.labels)
                                                        dop.tmp.delims{3} = 2; % new line
                                                        dop.tmp.epoch_saved = 1;
                                                    end
                                                    dop.tmp.value = 999;
                                                    if numel(dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd_spec).(dop.tmp.epoch_eps).(dop.tmp.var)) >= j %dop.tmp.num_events
                                                        dop.tmp.value = dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd_spec).(dop.tmp.epoch_eps).(dop.tmp.var)(j);
                                                    end
                                                    fprintf(dop.save.fid,...
                                                        [dopVarType(dop.tmp.value),...
                                                        dop.tmp.delims{dop.tmp.delims{3}}],dop.tmp.value);
                                                end
                                            end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            fclose(dop.save.fid);
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