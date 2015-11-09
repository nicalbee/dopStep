function [dop,okay,msg]  =  dopSetGetInputs(dop_input,inputs,msg,report)
%% dopOSCCI3: dopSetGetInputs
%
% settings = setGetInputsStruct(dop_input,inputs,[msg],[report])
%
% function to set on/off inputs and place varargin info in a structure for
% use within a program
%
% * requires inputs stucture:
% inputs.varargin  =  varargin from calling function
% inputs.turnOn
% inputs.turnOff
% inputs.defaults - defaults for the settings
% - in format 'settings',value,...
% - e.g., .defaults = {'tester','name','codeNumber',999}
%
%
% For example:
% egFunction(varargin)
%
%   egFunction inputs
%       inputs.varargin = varargin;
%       inputs.turnOn = {'test'};
%       inputs.turnOff = {'report'};
%       inputs.defaults = struct('codeNumber',999,'gender',1);
%
%       settings = setGetInputs(inputs)
%
% - in the egFunction the setGetInputs will:
%      * set the 'test' value to 0 (i.e., starts off and is turned on)
%      * set the 'report' value to 1 (i.e., starts on and is turned off)
%      * set 'codeNumber' and 'gender' values to 999 and 1 respectively
%      * then it will examine the inputs.varargin variable for the presence
%       of the turnOn, turnOff, and settings strings.
%       - the presence of the turnOn or turnOff strings toggles their
%       values
%       - the settings values will be set to the i+1 value of varargin
%       e.g., inputs.varargin = {'codeNumber',555,'gender',2} results in:
%           codeNumber = 555;
%           gender = 2;
%        == > this is similar to the defaults arrangements
%
% Created: ??-???-???? NAB
% Last edit:
% 22-Aug-2014 NAB added 'created' and 'last edit' details...
% 05-Sep-2014 NAB changed 'comment' to 'report'

% set default outputs
dop = [];
okay = 1; % don't think there's too much that can go wrong in this but want to keep the output variables constant
if ~exist('msg','var')
    msg = [];
else
    msg{end+1} = sprintf('> %s',mfilename);
end

if ~exist('report','var') || isempty(report)
    report = 0;
end

try
    
    dopOSCCIindent('run',report)
    if exist('dop_input','var') && ~isempty(dop_input)
        switch dopInputCheck(dop_input)
            case 'dop'
                dop = dop_input;
                tmp.stack = dbstack;
                if isfield(dop,'tmp')
                    if size(tmp.stack,1) > 2 && ~isfield(dop,tmp.stack(3).name)
                        dop.(tmp.stack(3).name) = dop.tmp;
                    end
                    msg{end+1} = '''dop.tmp'' variable found, clearing';
                    dopMessage(msg,report,1,okay)
                    dop = rmfield(dop,'tmp');
                    %                     end
                end
                if numel(tmp.stack.name) > 1; dop.tmp.func = tmp.stack(2).name; end
                if isfield(dop,'data') && isfield(dop.data,'use')
                    msg{end+1} = '''dop.data.use'' variable found: setting to ''dop.tmp.data''';
                    dopMessage(msg,report,1,okay)
                    dop.tmp.data = dop.data.use;
                else
                    msg{end+1} = '''dop.data.use'' variable not found';
                    dopMessage(msg,report,1,okay)
                end
            case 'matrix'
                msg{end+1} = 'matrix variable found';
                dopMessage(msg,report,1,okay)
                dop.tmp.data = dop_input;
                case 'vector'
                msg{end+1} = 'vector variable found';
                dopMessage(msg,report,1,okay)
                dop.tmp.data = dop_input;
            case 'file'
                msg{end+1} = 'file variable found';
                dopMessage(msg,report,1,okay)
                dop.tmp.file = dop_input;
                [tmp_dop,okay,tmp_msg] = dopFileParts(dop.tmp.file);
                msg{end+1} = tmp_msg;
                if okay && exist(dop.tmp.file,'file')
                    msg{end+1} = 'file exists or is on MATLAB path';
                    dopMessage(msg,report,1,okay)
                else
                    msg{end+1} = sprintf(['file doesn''t exist or isn''t'...
                        ' on the MATLAB path, can''t import: ''%s'''],...
                        dop.tmp.file);
                    okay = 0;
                    dopMessage(msg,report,1,okay)
                end
            otherwise % 'number'
                msg{end+1} = 'Option not yet programmed...';
                dopMessage(msg,report,1,okay)
        end
    else
        msg{end+1} = 'No ''dop_input'' variable found';
        dopMessage(msg,report,1,okay)
    end
    if okay && exist('inputs','var') && ~isempty(inputs)
        if isfield(inputs,'defaults')
            % set default values for the settings
            %             dop.tmp = inputs.defaults;
            dop.tmp.defaults = inputs.defaults; % shortcut using struct
            dop.tmp.settings = fieldnames(dop.tmp.defaults);
            dop.tmp.list = dop.tmp.settings;
            
            % below is old but I'm not sure why it's different to
            % settings... something to do with if defaults aren't found
            %             dop.tmp.list = [];
            %             for i = 1 : numel(dop.tmp.settings)
            %                 dop.tmp.list{end+1} = dop.tmp.settings{i};
            %             end
        else
            dop.tmp.list = [];
            msg{end+1} = 'No ''defaults'' input found.';
            dopMessage(msg,report,1,okay)
        end
        
        if isfield(inputs,'required')
            dop.tmp.required = inputs.required;
        else
            dop.tmp.required = [];
            msg{end+1} = 'No ''required'' input found.';
            dopMessage(msg,report,1,okay)
        end
        %% set turnOn/Off values
        tmp.on_off_labels = {'On','Off'};
        tmp.on_off_settings = {'Off','On'};
        for i = 1 : numel(tmp.on_off_labels)
            tmp.on_off = ['turn',tmp.on_off_labels{i}];
            if isfield(inputs,tmp.on_off)
                if ~isempty(inputs.(tmp.on_off))
                    for ii = 1 : length(inputs.(tmp.on_off))
                        dop.tmp.(inputs.(tmp.on_off){ii}) = i - 1; % starts on/off
                        msg{end+1} = sprintf('Turn %s - %s: set to %u (%s)',...
                            tmp.on_off_labels{i},inputs.(tmp.on_off){ii},i-1,tmp.on_off_settings{dop.tmp.(inputs.(tmp.on_off){ii})+1});
                        dopMessage(msg,report,1,okay)
                        dop.tmp.list{end+1} = inputs.(tmp.on_off){ii};
                    end
                end
            else
                msg{end+1} = sprintf('No %s input found.',tmp.on_off);
                dopMessage(msg,report,1,okay)
                inputs.(tmp.on_off) = []; % create empty version
            end
        end
        %% get inputs if there are any
        dop.tmp.found_list = [];
        
        if isfield(inputs,'varargin') && numel(inputs.varargin) >=1 && ~isempty(inputs.varargin{1})
            %             tmp.nIn = length(inputs.varargin);
            if numel(inputs.varargin) % tmp.nIn>0
                % check to see what sort of array we have
                if ~isempty(inputs.varargin{1}(1)) && iscell(inputs.varargin{1}(1))
                    msg{end+1} = 'cell array within a cell array - need to get it out';
                    if report;fprintf('\t%s\n',msg{end}); end
                    for i = 1 : numel(inputs.varargin{1})
                        try
                            inputs.tmp{i} = char(inputs.varargin{1}(i));
                        catch err_msg
                            inputs.msg = err_msg;
                            % can't/don't actually do anyting with this
                            % 9-Aug-2014 NAB
                            inputs.tmp{i} = inputs.varargin{1}{i};
                        end
                    end
                    inputs.varargin = inputs.tmp;
                    if ~isnan(str2double(inputs.tmp));
                        inputs.varargin = str2double(inputs.tmp);
                    end
                    %             display(inputs.varargin);
                    %                     tmp.nIn = numel(inputs.varargin);
                end
                %                 tmp.skip = 0;
                i = 0;
                while i < numel(inputs.varargin)
                    i = i + 1;
                    %                     if ~tmp.skip
                    tmp.var = inputs.varargin{i};
                    if report
                        msg{end+1} = sprintf('\tvarargin %u = %s\n',i,tmp.var);
                    end
                    tmp.okay = 0;
                    if sum(strcmp(tmp.var,inputs.turnOn)) % == 1
                        dop.tmp.(tmp.var) = 1;
                        tmp.okay = 1;
                    elseif sum(strcmp(tmp.var,inputs.turnOff)) % == 1
                        dop.tmp.(tmp.var) = 0;
                        tmp.okay = 1;
                    elseif sum(strcmp(tmp.var,dop.tmp.settings)) % == 1
                        dop.tmp.(tmp.var) = inputs.varargin{i+1};
                        tmp.okay = 1;
                        % looking for 'variable_name',variable_value
                        % form of inputs so if we find something, then
                        % need to skip ahead but 1.
                        i = i + 1; %tmp.skip = 1;
                    end
                    msg{end+1} = sprintf('varargin %u: %s = not a setting',i,tmp.var);
                    if tmp.okay
                        dop.tmp.found_list{end+1} = tmp.var;
                        if iscell(dop.tmp.(tmp.var))
                            msg{end} = sprintf(...
                                ['varargin %u: %s = ',dopVarType(dop.tmp.(tmp.var))],...
                                i,tmp.var,dop.tmp.(tmp.var){:});
                        else
                            msg{end} = sprintf(...
                                ['varargin %u: %s = ',dopVarType(dop.tmp.(tmp.var))],...
                                i,tmp.var,dop.tmp.(tmp.var));
                        end
                    end
                    
                    %                     end
                    %                     else
                    %                         tmp.skip = 0;
                    %                     end
                end
                
            end
        elseif isfield(inputs,'varargin') && numel(inputs.varargin) >= 1 ...
                && isempty(inputs.varargin{1})
            msg{end+1} = '''inputs.varargin'' is empty';
            dopMessage(msg,report,1);
        else
            % may or may not be an error
            msg{end+1} = ['Couldn''t find ''varargin'' inputs.',...
                ' If this surprises you, make sure everything is',...
                ' spelt correctly.'];
            dopMessage(msg,report,1);
        end
        %% find default values if not already found
        i = 0;
        while okay && i < numel(dop.tmp.settings); i = i + 1;
            tmp.var = dop.tmp.settings{i};
            if ~sum(strcmp(dop.tmp.found_list,tmp.var))
                if ~isfield(dop.tmp,(tmp.var))
                    dop.tmp.(tmp.var) = dop.tmp.defaults.(tmp.var);
                end
                tmp.find = 0;
                if isempty(dop.tmp.(tmp.var))
                    tmp.find = 1;
                elseif iscell(dop.tmp.(tmp.var))
                    tmp.find = 1;
                elseif isnumeric(dop.tmp.(tmp.var)) && sum(dop.tmp.(tmp.var) == inputs.defaults.(tmp.var))
                    tmp.find = 1;
                elseif strcmp(dop.tmp.(tmp.var),inputs.defaults.(tmp.var))
                    tmp.find = 1;
                end
                if tmp.find
                    %% > get empty values from 'dop' structure
                    % if it exists..
                    if exist('dop_input','var') && ~isempty(dop_input) ...
                            && strcmp(dopInputCheck(dop_input),'dop')
                        tmp.check = {'save','use','def','file_info'}; % order of these matters
                        for j = 1 : numel(tmp.check)
                            if isfield(dop,tmp.check{j}) ...
                                    && isfield(dop.(tmp.check{j}),tmp.var)
                                
                                dop.tmp.(tmp.var) = dop.(tmp.check{j}).(tmp.var);
                                if iscell(dop.tmp.(tmp.var))
                                    msg{end+1} = sprintf(...
                                        ['Using ''dop.%s'' settings for ''%s'' = ',...
                                        dopVarType(dop.tmp.(tmp.var))],...
                                        tmp.check{j},tmp.var,dop.tmp.(tmp.var){:});
                                else
                                    msg{end+1} = sprintf(...
                                        ['Using ''dop.%s'' settings for ''%s'' = ',...
                                        dopVarType(dop.tmp.(tmp.var))],...
                                        tmp.check{j},tmp.var,dop.tmp.(tmp.var));
                                end
                                dopMessage(msg,report,1,okay)
                                % if found in 'dop.use' (or earlier
                                % check) don't need to look further so
                                % break out of the loop
                                break
                                
                            end
                        end
                    end
                end
            end
            %                     if dop.tmp.report; fprintf('\tInput variables:\n'); end
            %     for i = 1 : numel(dop.tmp.settings)
            
            if okay && isempty(dop.tmp.(tmp.var))
                msg{end+1} = sprintf('''dop.tmp.%s'' variable is empty, this is required',tmp.var);
                okay = 0;
                if ~sum(strcmp(dop.tmp.required,tmp.var))
                    okay = 1;
                    msg{end} = strrep(msg{end},'this is required',...
                        ['non-critical but maybe useful, some variables might'...
                        ' not be able to be calculated without it']);
                end
                dopMessage(msg,report,1,okay)
            end
            if ~okay
                fprintf('\tAborting, missing required variable: %s\n',tmp.var);
            end
            %     end
        end
        
    else
        msg{end+1} = 'No ''inputs'' variable found';
        dopMessage(msg,report,1);
    end
    dop.okay = okay;
    dop.msg = msg;
    dopOSCCIindent('done',report);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
