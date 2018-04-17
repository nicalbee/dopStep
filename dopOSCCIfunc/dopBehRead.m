function [dop,okay,msg] = dopBehRead(dop_input,varargin)
% dopOSCCI3: dopBehRead
%
% [dop,okay,msg] = dopBehRead(dop_input,[okay],[msg],...)
%
% notes:
%   reads behavioural screening file = 3+ column text file with list of file
%   names then [x1 ... x2] [y1 ... y2] etc.
%   (to be converted to numbers using 'eval')
%
% Use:
%
% [dop,okay,msg] = dopBehCreate(dop_input,[okay],[msg],...)
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
% - 'file_list':
%   > e.g., dopFunction(dop_input,okay,msg,...,'file_list',list_var,...)
%   cell variable with a list of file names to be added as the first column
%   of the screening file.
%
% - 'beh_file':
%   > e.g., dopFunction(dop_input,okay,msg,...,'beh_file','C:\my_dir\beh_exclude.dat',...)
%   string variable setting the file name for a text file indicating for
%   each file, which epoch numbers should be excluded.
%   14-Sep-2014 still thinking about format but
%   Two columns:
%       file_name       exclude_string
%       'my_file.EXP    [4 6 7]
%   Or
%       'my_file.EXP    ~4~6~7
%
%   Or file_name    exclude_epoch#
%   > containing column for each epoch number and logical (1 = exclude, 0 =
%   keep) value for each epoch.
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
% Created: 17-Feb-2017 (from dopEpochScreenManualRead.m 15-Sep-2014 NAB)
% Edits:
% 07-Mar-2017 updated/finished
% 14-Mar-2017 updated for [] cell input file
% 24-Apr-2017 remove rows with NaN if they exist
% note: current labelling of columns only copes with up to 9 conditions
% 17-Apr-2018 having trouble with the import

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        inputs.turnOn = {'overwrite'};
        inputs.turnOff = {'update_save'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'beh_file',[], ... %
            'beh_dir',[],...
            'beh_fullfile',[],...
            'delim','\t',...
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        inputs.defaults.column_labels = {'file_name','exclude_string'};
        %         inputs.required = ...
        %             {'file_list'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        if okay
            dop.tmp.import_data = [];
            switch dopInputCheck(dop_input)
                case 'dop'
                    if ~isempty(dop.tmp.beh_file) && ~isempty(dop.tmp.beh_dir) ...
                            && exist(dop.tmp.beh_dir,'dir') ...
                            && exist(fullfile(dop.tmp.beh_dir,dop.tmp.beh_file),'file')
                        if exist('readtable','file')
                            dop.tmp.import_data = readtable(fullfile(dop.tmp.beh_dir,dop.tmp.beh_file),...
                                'delimiter',dop.tmp.delim);
                        else
                            dop.tmp.import_data = importdata(fullfile(dop.tmp.beh_dir,dop.tmp.beh_file));
                        end
                    elseif ~isempty(dop.tmp.beh_fullfile) && exist(dop.tmp.beh_fullfile,'file')
                        dop.tmp.import_data = importdata(dop.tmp.beh_fullfile);
                    else
                        okay = 0;
                        msg{end+1} = sprintf('input not recognised\n\t(%s: %s)',...
                            mfilename,dop.tmp.file);
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    end
                case 'file'
                    %                     dop.tmp.beh_fullfile = dop_input;
                    if exist('readtable','file')
                        dop.tmp.import_data = readtable(dop_input,...
                            'delimiter',dop.tmp.delim);
                    else
                        dop.tmp.import_data = importdata(dop_input);
                    end
                otherwise
                    okay = 0;
                    msg{end+1} = sprintf('Can''t find file\n\t(%s: %s)',...
                        mfilename,dop.tmp.file);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            %% check the import
            if isstruct(dop.tmp.import_data)
                % might have an issue here...
                okay = 0;
                msg{end+1} = sprintf('Import problem - not as expected\n\t(%s: %s)',...
                    mfilename,dop.tmp.file);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            %% get the data
            if okay && ~isempty(dop.tmp.import_data)
                if exist('istable','file') && istable(dop.tmp.import_data)
                    % remove rows and columns with in NaN or empty values -
                    % sometimes happens with conversion from excel
                    dop.tmp.import_data = dop.tmp.import_data(~ismissing(dop.tmp.import_data(:,1)),:);
                    dop.tmp.import_data = dop.tmp.import_data(:,~any(ismissing(dop.tmp.import_data),1));
                    dop.tmp.beh_list = table2cell(dop.tmp.import_data(:,1));
                    
                    dop.tmp.beh_data = table2array(dop.tmp.import_data(:,2:end));
                    if isnumeric(dop.tmp.beh_data(1,1))
                        % have to be careful here, if there's a row that's
                        % fine but if it's a column, we lose everything
%                         dop.tmp.beh_list(any(isnan(dop.tmp.beh_data),2),:) = [];
%                         % need to do the same for the list surely - above
%                         % remove NaN, if they're there - these bugger it up
%                         dop.tmp.beh_data(any(isnan(dop.tmp.beh_data),2),:) = [];
                        
                        dop.tmp.tmp_data = dop.tmp.beh_data;
                        dop.tmp.conds = unique(dop.tmp.beh_data);
                        dop.tmp.var_nums = 1:numel(dop.tmp.conds);
                        dop.tmp.var_names = cellstr([repmat('beh',numel(dop.tmp.conds),1),num2str(dop.tmp.var_nums')]);
                        
                        dop.tmp.beh_data = ...
                            cell2table(...
                            cell(size(dop.tmp.tmp_data,1),numel(dop.tmp.conds)),...
                            'VariableNames',dop.tmp.var_names');
                        for i = 1 : size(dop.tmp.tmp_data,1)
                            for j = 1 : numel(dop.tmp.conds)
                                dop.tmp.beh_data{i,j} = {sprintf('[%s]',num2str(find(dop.tmp.tmp_data(i,:) == dop.tmp.conds(j))))};
                            end
                        end
                    else
                        % most likely already in [] form
                        dop.tmp.conds = 1 : size(dop.tmp.beh_data,2);
                        % might need to make sure the column labels are
                        % correct
                        dop.tmp.var_nums = 1:numel(dop.tmp.conds);
                        dop.tmp.var_names = cellstr([repmat('beh',numel(dop.tmp.conds),1),num2str(dop.tmp.var_nums')]);
                        dop.tmp.beh_data = cell2table(dop.tmp.beh_data,...
                            'VariableNames',dop.tmp.var_names); %
                        dop.tmp.cond_names = dop.tmp.import_data.Properties.VariableNames(2:end);
                    end
                    
                    
                    % from manual screening function
                    %                     dop.tmp.beh_exclude = table2cell(dop.tmp.import_data(:,2));
                    %                     % check for ~ or [] type of entries
                    %                     for i = 1 : numel(dop.tmp.beh_exclude)
                    %                         dop.tmp.beh_exclude{i} = checkManualString(dop.tmp.beh_exclude{i});
                    %                     end
                else
                    % check this later
                    %                     dop.tmp.beh_list = cell(size(dop.tmp.import_data,1)-1,1); % minus 1 = assume header
                    %                     dop.tmp.beh_exclude = cell(size(dop.tmp.import_data,1)-1,1); % minus 1 = assume header
                    %                     for i = 2 : size(dop.tmp.import_data,1)
                    %                         dop.tmp.row = textscan(dop.tmp.import_data{i},'%s%s','delimiter',dop.tmp.delim);
                    %                         dop.tmp.beh_list{i-1} = char(dop.tmp.row{1});
                    %                         dop.tmp.beh_exclude{i-1} = char(dop.tmp.row{2});
                    %
                    %
                    %                     end
                    
                    
                end
                dop.epoch.beh_list = dop.tmp.beh_list;
                dop.epoch.beh_select = dop.tmp.beh_data;
                dop.epoch.beh_names = dop.epoch.beh_select.Properties.VariableNames;
                if dop.tmp.update_save
                    dop.save.epochs(end:end+size(dop.epoch.beh_select,2)-1) = dop.epoch.beh_select.Properties.VariableNames;
                    msg{end+1} = sprintf(['dop.save.epochs ',...
                        'variable update for behavioural epoch ',...
                        'selection based on\n\t%s (%s)\n\t',...
                        'Now includes: ',dopVarType(dop.save.epochs)],...
                        dop.tmp.beh_file,dop.tmp.beh_dir,dop.save.epochs{:});
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    
                end
            else
                okay = 0;
                msg{end+1} = sprintf('Behavioural epoch selection file is empty\n\t(%s: %s)',...
                    mfilename,dop.tmp.file);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);                
            end
        end
        switch dopInputCheck(dop_input)
            case 'dop'
                dop.okay = okay;
                dop.msg = msg;
            case 'file'
                dop.beh_list = dop.tmp.beh_list;
                dop.beh_exclude = dop.tmp.beh_exclude;
        end
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end
%% embedded function
function number_out = checkManualString(string_in)
number_out = []; % empty
if iscell(string_in)
    string_in = string_in{1};
end
if ~isempty(strfind(string_in,'['))
    number_out = eval(char(string_in));
elseif ~isempty(sum(strfind(string_in,'~')))
    dop.tmp.tilda = strfind(string_in,'~');
    dop.tmp.epochs = zeros(1,numel(dop.tmp.tilda));
    dop.tmp.row2 = char(string_in);
    for j = 1 : numel(dop.tmp.tilda)
        switch j
            case 1
                if dop.tmp.tilda(j) > 1
                    dop.tmp.epochs(j) = str2double(dop.tmp.row2(1:dop.tmp.tilda(j)-1));
                end
                % else skip
                %                                 case numel(dop.tmp.tilda)
                %                                     if dop.tmp.tilda(end) <= numel(dop.tmp.row2)
                %                                         dop.tmp.epochs(j) = str2double(dop.tmp.row2(dop.tmp.tilda(j-1)+1:dop.tmp.tilda(j)-1));
                %                                     end
            otherwise
                dop.tmp.epochs(j) = str2double(dop.tmp.row2(dop.tmp.tilda(j-1)+1:dop.tmp.tilda(j)-1));
        end
    end
    number_out = dop.tmp.epochs;
end
end