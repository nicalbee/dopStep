function [dop,okay,msg] = dopMethodText(dop_input,varargin)
% dopOSCCI3: dopMethodText
%
% [dop,okay,msg] = dopMethodText(dop,[okay],[msg],...)
%
% notes:
% creates a methods report for the settings/definition and steps used.
% Reports to the command window and saves to a file. Variables are
% generally borrowed from the definition information - more details of
% these included in the specified functions.
%
% Use:
%
% [dop,okay,msg] = dopMethodText(dop,[okay],[msg],...)
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
% - 'epoch':
%   > e.g., dopFunction(dop_input,okay,msg,...,'epoch',[-15 30],...)
%   Lower and Upper epoch values in seconds used to divide the data
%   surrounding the event markers.
%
% - 'baseline':
%   > e.g., dopFunction(dop_input,okay,msg,...,'baseline',[-15 -5],...)
%   Lower and Upper baseline period values in seconds. The mean of this
%   period is subtracted from the rest of the data within the epoch (left
%   and right channels separately) to perform baseline correction (see
%   dopBaseCorrect).
%
% - 'poi':
%   > e.g., dopFunction(dop_input,okay,msg,...,'epoch',[10 25],...)
%   Lower and Upper period of interest values in seconds within which to
%   search for peak left minus right difference for calculation of the
%   lateralisation index.
%
% - 'sample_rate':
%   > e.g., dopFunction(dop_input,okay,msg,...,'sample_rate',25,...)
%   The sampling rate of the data in Hertz. This is used to convert the
%   'epoch' variable seconds to samples to divide the data into epochs.
%   note: After dopDownsample is run, this value should be the downsampled
%   sample rate.
%
% - 'event_channels':
%   > e.g., dopFunction(dop_input,okay,msg,...,'event_channels',13,...)
%   Column number of data which holds the event information. Typically
%   square signal data.
%   note: 'event_channels' is used within this function as an input for
%   dopEvent Markers if it hasn't previously been called. That is,
%   'dop.event' structure variable is not found
%
% - 'event_height':
%   > e.g., dopFunction(dop_input,okay,msg,...,'event_height',1000,...)
%   Number above which activity in the event channel/column data will be
%   detected as an event marker.
%   note: 'event_height' is used within this function as an input for
%   dopEvent Markers if it hasn't previously been called. That is,
%   'dop.event' structure variable is not found
%
% - 'file':
%   > e.g., dopFunction(dop_input,okay,msg,...,'file','subjectX.exp',...)
%   file name of the data file currently being summarised. This is used for
%   error reporting. Typically this variable is automatically populated in
%   the 'dopSetGetInputs' function by searching the 'dop' structure
%   variables: dop.save, dop.use, dop.def, dop.file_info.
%   The default value is empty.
%
% - 'msg':
%   > e.g., dopFunction(dop_input,okay,msg,...,'msg',1,...)
%       or
%           dopFunction(dop_input,okay,msg,...,'msg',0,...)
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
% Created: 13-Nov-2017 NAB
% Edits:


[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    %     if okay % doesn't matter for this function - try to save anyway
    dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
    %% inputs
    %         inputs.turnOn = {'nomsg'};
    %         inputs.turnOff = {'comment'};
    inputs.varargin = varargin;
    inputs.defaults = struct(...
        'method_save',1,...
        'method_fullfile',[],...
        'method_file','dopOSCCImethod',... 'task_name','dopSave',...
        'method_ext','.txt',...
        'method_dir',[],...
        'epoch',[-15 35],...
        'baseline',[-15 -5],...
        'poi',[5 15], ... % % 'poi',[5 15];
        'act_window',2, ... %
        'sample_rate',[], ...
        'downsample_rate',[],...
        'steps',[],...
        'act_range',[50 150],...
        'correct_range',[-3 4],... lower and upper bounds in standard deviation units
        'correct_pct',5,...% correct if <= x% data outside range, otherwise no correction
        'correct_replace',[],...'linspace'; %,...'mean',... % 'median'
        'correct_linspace_seconds',[],...
        'act_separation',10,... % acceptable activation difference
        'act_separation_pct',5,... %.01; % reject epoch if >= x% data outside range, otherwise keep
        'act_separation_index','iqr',... %'pct'; % units for the act_separation variable
        'heart_cycle_type',[],...
        'event_height',[],...
        'event_sep',[],...
        'norm_method','overall',... % 'epoch' or 'deppe_epoch'
        'message',1, ...
        'delim','\t', ...
        'wrap_characters',70,...
        'error','',... % add error flag to individual file name
        'file',[],... % for error reporting mostly
        'msg',1,... % show messages
        'wait_warn',0 ... % wait to close warning dialogs
        );
    inputs.defaults.screen = {'length','act','sep'};
    inputs.required = []; %...
    %             {'epoch'};
    [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
    if okay
        %% save file name
        if okay && dop.tmp.method_save && or(isempty(dop.tmp.method_file),strcmp(dop.tmp.method_file,dop.tmp.defaults.method_file))
            if ~isfield(dop,'def') ...
                    || ~isfield(dop.def,'task_name') ...
                    || isempty(dop.def.task_name)
                
                dop.def.task_name = dop.tmp.defaults.method_file;
            end
            dop.tmp.method_file = sprintf('%sMethodText%s',dop.def.task_name,dop.tmp.method_ext);
        end
        if okay && or(isempty(dop.tmp.method_dir),strcmp(dop.tmp.method_dir,dop.tmp.defaults.method_dir))
            if isfield(dop,'save') && isfield(dop.save,'save_dir') && ~isempty(dop.save.save_dir)
                dop.tmp.method_dir = fullfile(dop.save.save_dir); %,'');
            else
                dop.tmp.method_dir = fullfile(dopSaveDir(dop)); %,'messages');
            end
        end
        if okay
            if isempty(dop.tmp.method_fullfile)
                dop.tmp.method_fullfile = fullfile(dop.tmp.method_dir,dop.tmp.method_file);
            end
            [dop.tmp.method_dir,dop.tmp.method_file_noext,dop.tmp.ext] = fileparts(dop.tmp.method_fullfile);
            dop.tmp.method_file = [dop.tmp.method_file_noext,dop.tmp.ext];
            msg{end+1} = ...
                sprintf('Message data to be saved to: %s (dir = %s)',...
                dop.tmp.method_file,dop.tmp.method_dir);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            if ~exist(dop.tmp.method_dir,'dir')
                mkdir(dop.tmp.method_dir);
                msg{end+1} = sprintf('Creating directory = %s)',...
                    dop.tmp.method_dir);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            if ~isempty(dop.tmp.file)
                [~,dop.tmp.method_file_id] = fileparts(dop.tmp.file);
                dop.tmp.method_file_ind = strrep(...
                    dop.tmp.method_fullfile,dop.tmp.method_ext,...
                    sprintf('_%s%s',dop.tmp.method_file_id,dop.tmp.method_ext));
            else
                dop.tmp.method_file_id = 0;
                dop.tmp.method_file_ind = strrep(...
                    dop.tmp.method_fullfile,dop.tmp.method_ext,...
                    sprintf('_%i_%s',dop.tmp.method_file_id,dop.tmp.method_ext));
            end
            dop.tmp.method_fullfiles = {dop.tmp.method_fullfile,...
                }; % dop.tmp.method_file_ind
            if isnumeric(dop.tmp.method_file_id)
                while 1
                    dop.tmp.method_file_id = dop.tmp.method_file_id + 1;
                    dop.tmp.method_file_ind = strrep(...
                        dop.tmp.method_file_ind,num2str(dop.tmp.method_file_id-1),...
                        num2str(dop.tmp.method_file_id));
                    if ~exist(dop.tmp.method_file_ind,'file')
                        dop.tmp.method_file_id = num2str(dop.tmp.method_file_id);
                        break
                    end
                end
            end
        end
        
        %% main code
        if okay
            if isempty(dop.tmp.steps) && isfield(dop,'step')
                dop.tmp.steps = fields(dop.step);
                dop.method.text = sprintf([...
                    'Note: step number and DOPOSCCI function included ',...
                    'before each step. DOPOSCCI version %s. '],...
                    dopOSCCIversion);
                dop.method.text_cell= {sprintf('DOPOSCCI version %s. ',...
                    dopOSCCIversion)};
                dop.method.step_number = 0;
                dop.method.step_name = {'version'};
                dop.tmp.data = [9999 9999];
                dop.tmp.step = 0;
                for i = 1 : numel(dop.tmp.steps)
                    dop.tmp.method_line = [];
                    switch dop.tmp.steps{i}
                        case 'dopPeriodChecks'
                        case 'dopChannelExtract'
                            dop.tmp.method_line = 'Data channels were extracted from the raw data, ';
                        case 'dopDownsample'
                            dop.tmp.method_line = sprintf('data downsampled to %i Hz, ',dop.tmp.downsample_rate);
                        case 'dopEventMarkers'
                            dop.tmp.method_line = sprintf('events markers with values greater than %i were extracted, ',dop.tmp.event_height);
                        case 'dopDataTrim'
                            dop.tmp.method_line = ...
                                ['data were trimmed at the ',...
                                'lower epoch before the first event ',...
                                'marker and upper epoch after the last ',...
                                'event marker, '];
                        case 'dopEventChannels'
                        case 'dopHeartCycle'
                            dop.tmp.method_line = ...
                                'heart cycle patterns were removed using a ';
                            switch dop.tmp.heart_cycle_type
                                case 'step'
                                    dop.tmp.method_line = sprintf(['%s',...
                                        'step correction as outlined by ',...
                                        'Deppe et al. (1997), '],...
                                        dop.tmp.method_line);
                                case 'linear'
                                    dop.tmp.method_line = sprintf(['%s',...
                                        'linear correction as outlined by ',...
                                        'Badcock et al. (2017), '],...
                                        dop.tmp.method_line);
                            end
                        case 'dopActCorrect'
                            %
                            %                             dop.def.correct_range = [-3 4]; % lower and upper bounds in standard deviation units
                            %                             dop.def.correct_pct = 5; % correct if <= x% data outside range, otherwise no correction
                            %                             dop.def.correct_replace = 'linspace'; %,...'mean',... % 'median'
                            %                             dop.def.correct_linspace_seconds = 1.5; % +/- X seconds either side
                            
                            dop.tmp.method_line = sprintf([ ...
                                'data with values beyond ',...
                                dopVarType(dop.tmp.correct_range(1)),...
                                ' and ',...
                                dopVarType(dop.tmp.correct_range(2)),...
                                ' standard deviations of mean activation ',...
                                'were replaced',...
                                ],dop.tmp.correct_range);
                            switch dop.tmp.correct_replace
                                case {'mean','median'}
                                    dop.tmp.method_line = sprintf(['%s ',...
                                        'by the %s value of the ',...
                                        'channel '],...
                                        dop.tmp.method_line,...
                                        dop.tmp.correct_replace ...
                                        );
                                case {'linspace','linear'}
                                    dop.tmp.method_line = sprintf(['%s ',...
                                        'using MATLAB''s ''linspace'' ',...
                                        'function to draw a straight line ',...
                                        'between points ',dopVarType(dop.tmp.correct_linspace_seconds),...
                                        ' seconds either ',...
                                        'side of the extreme value ',...
                                        ],...
                                        dop.tmp.method_line,...
                                        dop.tmp.correct_linspace_seconds ...
                                        );
                            end
                            dop.tmp.method_line = sprintf(['%s',...
                                'if less than ',...
                                dopVarType(dop.tmp.correct_pct),...
                                ' percent of the data were affected, '],...
                                dop.tmp.method_line,...
                                dop.tmp.correct_pct);
                        case {'dopEpoch','dopBaseCorrect'}
                            switch dop.tmp.steps{i}
                                case 'dopEpoch'
                                    dop.tmp.fill_text = 'epoched';
                                    dop.tmp.data = dop.tmp.epoch;
                                case 'dopBaseCorrect'
                                    dop.tmp.fill_text = 'baseline corrected';
                                    dop.tmp.data = dop.tmp.baseline;
                            end
                            
                            dop.tmp.method_line = sprintf([...
                                'the data were %s from ',...
                                dopVarType(dop.tmp.data(1)),...
                                ' to ',dopVarType(dop.tmp.data(2)),...
                                ' seconds relative to each event marker, ',...
                                ],dop.tmp.fill_text,dop.tmp.data ...
                                );
                        case 'dopNorm'
                            dop.tmp.method_line = [...
                                'data in the left and right channels ',...
                                'were normalised to a mean of 100 '];
                            switch dop.tmp.norm_method
                                case 'overall'
                                    dop.tmp.method_line = sprintf(['%s',...
                                        'accross all available data, '],...
                                        dop.tmp.method_line);
                                case {'epoch','deppe_epoch'}
                                    dop.tmp.method_line = sprintf(['%s',...
                                        'on an epoch by epoch basis, '],...
                                        dop.tmp.method_line);
                                    switch dop.tmp.norm_method
                                        case 'deppe_epoch'
                                            dop.tmp.method_line = sprintf(['%s',...
                                                'using the Deppe method ',...
                                                '(see Deppe et al., 1997), '],...
                                                dop.tmp.method_line);
                                    end
                                    
                            end
                        case 'dopEpochScreenManual'
                            dop.tmp.method_line = [...
                                'epochs were removed manually based on ',...
                                'behavioural observation during recording ',...
                                '(i.e., non-compliance of some kind - PLEASE SPECIFY)',...
                                ];
                        case 'dopEpochScreenAct'
                            
                            
                            dop.tmp.method_line = sprintf([...
                                'epochs with values beyond ',...
                                dopVarType(dop.tmp.act_range(1)),...
                                ' to ',dopVarType(dop.tmp.act_range(2)),...
                                ' were rejected from further analysis, ',...
                                ],dop.tmp.act_range ...
                                );
                        case 'dopEpochScreenSep'
                            
                            %                             'act_separation',10,... % acceptable activation difference
                            %                                 'act_separation_pct',5,... %.01; % reject epoch if >= x% data outside range, otherwise keep
                            %                                 'act_separation_index','iqr',... %'pct'; % units for the act_separation variable
                            
                            dop.tmp.method_line = sprintf([...
                                'epochs with a left minus right difference greater than ',...
                                dopVarType(dop.tmp.act_separation),...
                                ', if more than ',dopVarType(dop.tmp.act_separation_pct),...
                                ' were affected, ',...
                                ' were rejected from further analysis, ',...
                                ],...
                                dop.tmp.act_separation ,...
                                dop.tmp.act_separation_pct ...
                                );
                            switch dop.tmp.act_separation_index
                                case 'iqr'
                                    dop.tmp.method_line = strrep(dop.tmp.method_line,...
                                        [num2str(dop.tmp.act_separation),', '],...
                                        sprintf([dopVarType(dop.tmp.act_separation),...
                                        ' times the inter-quartile range, '],...
                                        dop.tmp.act_separation));
                                    
                            end
                        case 'dopEpochScreenCombine'
                            if ismember(dop.tmp.screen,'length')
                                dop.tmp.method_line = [ ...
                                    'first and last epochs with insufficient ',...
                                    'data for epoching were rejected from ',...
                                    'further analysis, ',...
                                    ];
                            end
                        case 'dopCalcAuto'
                            dop.tmp.method_line = sprintf([...
                                'the laterality index was calculated as ',...
                                'the mean left minus right difference within ',...
                                'a ',dopVarType(dop.tmp.act_window),...
                                ' second window centred on the absolute peak difference ',...
                                'within the period of interest (',...
                                dopVarType(dop.tmp.poi(1)),' to ',...
                                dopVarType(dop.tmp.poi(2)),...
                                ' seconds relative to the event marker), ',...
                                'positive numbers indicate left ',...
                                'lateralisation, negative numbers indicate right, ',...
                                ],...
                                dop.tmp.act_window ,...
                                dop.tmp.poi...
                                );
                            %                         case 'dopSave'
                            %                         case 'dopDataCollect'
                            %                         case 'dopMessageSave'
                            %                         case 'dopSaveCollect'
                            %                         case 'dopPlot'
                    end
                    
                    if ~isempty(dop.tmp.method_line)
                        dop.tmp.step = dop.tmp.step + 1;
                        dop.method.text = sprintf('%s(%i:%s) %s',...
                            dop.method.text,dop.tmp.step,dop.tmp.steps{i},dop.tmp.method_line);
                        dop.method.text_cell{dop.tmp.step+1} = dop.tmp.method_line;
                        dop.method.step_number(end+1) = dop.tmp.step;
                        dop.method.step_name{end+1} = dop.tmp.steps{i};
                    end
                end
                dop.method.text(end) = [];
                dop.method.text(end) = '.';
                dop.tmp.last_comma = find(dop.method.text == ',',1,'last');
                dop.method.text = [dop.method.text(1:dop.tmp.last_comma),...
                    ' and',dop.method.text(dop.tmp.last_comma+1:end)];
                
                %                 dop.method.text4wrap = [dop.method.text,...
                %                     repmat(' ',1,ceil(length(dop.method.text)/dop.tmp.wrap_characters)*dop.tmp.wrap_characters ...
                %                     - length(dop.method.text))];
                %                 dop.method.text_wrap = reshape(dop.method.text4wrap,...
                %                     ceil(length(dop.method.text)/dop.tmp.wrap_characters),dop.tmp.wrap_characters);
                for i = 1 : ceil(length(dop.method.text)/dop.tmp.wrap_characters) %size(dop.method.text_wrap,1)
                    dop.tmp.filt_lims = [1+(i-1)*dop.tmp.wrap_characters i*dop.tmp.wrap_characters];
                    
                    if i > 1
                        if dop.tmp.filt_last(2) > dop.tmp.filt_lims(1)
                            dop.tmp.filt_lims(1) = dop.tmp.filt_last(2);
                        end
                    end
                    while 1
                        if dop.tmp.filt_lims(2) > length(dop.method.text)
                            dop.tmp.filt_lims(2) = length(dop.method.text);
                        end
                        dop.tmp.text = dop.method.text(dop.tmp.filt_lims(1):dop.tmp.filt_lims(2));
                        if dop.tmp.filt_lims(2) >= length(dop.method.text) || strcmp(dop.method.text(dop.tmp.filt_lims(2)),' ') || dop.tmp.filt_lims(2) == length(dop.method.text)
                            break
                        elseif ~strcmp(dop.method.text(dop.tmp.filt_lims(2)),' ')
                            dop.tmp.filt_lims(2) = dop.tmp.filt_lims(2) + 1;
                        end
                    end
                    
                    fprintf('%s\n',dop.tmp.text);
                    dop.tmp.filt_last = dop.tmp.filt_lims;
                end
            else
                msg{end+1} = sprintf('No ''steps'' input of dop.step variable - can''t create method text (%s).',mfilename);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            %             && ~isempty(msg) && iscell(msg)
            if dop.tmp.method_save && ~isempty(dop.method.text_cell)
                
                
                for j = 1 : numel(dop.tmp.method_fullfiles)
                    if ~exist(dop.tmp.method_fullfiles{j},'file')
                        dop.tmp.fid = fopen(dop.tmp.method_fullfiles{j},'w');
                        dop.tmp.labels = {'number','function','description'};
                        for i = 1 : numel(dop.tmp.labels)
                            if i < numel(dop.tmp.labels)
                                fprintf(dop.tmp.fid,['%s',dop.tmp.delim],dop.tmp.labels{i});
                            else
                                fprintf(dop.tmp.fid,'%s\n',dop.tmp.labels{i});
                            end
                        end
                        fclose(dop.tmp.fid);
                    end
                    dop.tmp.fid = fopen(dop.tmp.method_fullfiles{j},'a');
%                     k = 0;
%                     dop.method.text_cell{dop.tmp.step+1} = dop.tmp.method_line;
%                     dop.method.step_number(end+1) = dop.tmp.step;
%                     dop.method.step_name = dop.tmp.steps{i};
                    for i = 1 : numel(dop.method.text_cell)
                        %                                 use_msg = msg(i);
                        %                                 newlines = regexp(msg{i},'\n');
                        %                                 if ~isempty(newlines)
                        %                                     newlines = [1 newlines length(use_msg{1})];
                        %                                     tmp_msg = [];
                        %                                     for ii = 2 : numel(newlines)
                        %                                         tmp_msg{ii-1} = use_msg{1}(newlines(ii-1):newlines(ii));
                        %                                     end
                        %                                     use_msg = tmp_msg;
                        %                                 end
                        %                                 for ii = 1 : numel(use_msg)
                        %                                     k = k + 1;
                        fprintf(dop.tmp.fid,sprintf('%%i%s%%s%s%%s\\n',dop.tmp.delim,dop.tmp.delim),...
                            dop.method.step_number(i),dop.method.step_name{i},...
                            dop.method.text_cell{i});
                    end
                    %
                    
                    fclose(dop.tmp.fid);
                end
            end
            
        end
        %% might be helpful
        %             allHandle = allchild(0);
        %             allTag = get(allHandle, 'Tag');
        %             isMsgbox = strncmp(allTag, 'Msgbox_', 7);
        %             delete(allHandle(isMsgbox));
        %
        %             If you have a newer Matlab version, FINDOBJ can apply regular expression, which allows for a more compact version:
        %             delete(findobj(allchild(0), '-regexp', 'Tag', '^Msgbox_'))
        %         else
        %             msg{end+1} = sprintf('Some issue with method text (%s)',mfilename);
        %             dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
    end
    
    dop.step.(mfilename) = 1;
    
    %% save okay & msg to 'dop' structure
    dop.okay = okay;
    dop.msg = msg;
    
    dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    %     end
catch err
    rethrow(err);
    %     save(dopOSCCIdebug);rethrow(err);
end
end