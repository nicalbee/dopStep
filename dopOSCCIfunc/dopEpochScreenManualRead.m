function [dop,okay,msg] = dopEpochScreenManualRead(dop_input,varargin)
% dopOSCCI3: dopEpochScreenManualRead
%
% [dop,okay,msg] = dopEpochScreenManualRead(dop_input,[okay],[msg],...)
%
% notes:
%   reads manual screening file = two column text file with list of file
%   names and [x1 ... x2] array (to be converted to numbers using 'eval')
%
% Use:
%
% [dop,okay,msg] = dopEpochScreenManualCreate(dop_input,[okay],[msg],...)
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
% - 'manual_file':
%   > e.g., dopFunction(dop_input,okay,msg,...,'manual_file','C:\my_dir\manual_exclude.dat',...)
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
% Created: 15-Sep-2014 NAB
% Edits:
% 21-Nov-2014 NAB fixed old tilda (~) delimiter read
% 06-Jul-2015 NAB added readtable function use - import data wasn't always
%   working

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        inputs.turnOn = {'overwrite'};
        %         inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'manual_file',[], ... %
            'manual_dir',[],...
            'manual_fullfile',[],...
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
                    if ~isempty(dop.tmp.manual_fullfile) && exist(dop.tmp.manual_fullfile,'file')
                        dop.tmp.import_data = importdata(dop.tmp.manual_fullfile);
                    elseif ~isempty(dop.tmp.manual_file) && ~isempty(dop.tmp.manual_dir) ...
                            && exist(dop.tmp.manual_dir,'dir') ...
                            && exist(fullfile(dop.tmp.manual_dir,dop.tmp.manual_file),'file')
                        if exist('readtable','file')
                            dop.tmp.import_data = readtable(fullfile(dop.tmp.manual_dir,dop.tmp.manual_file),...
                                'delimiter',dop.tmp.delim);
                        else
                            dop.tmp.import_data = importdata(fullfile(dop.tmp.manual_dir,dop.tmp.manual_file));
                        end
                    else
                        okay = 0;
                        msg{end+1} = sprintf('input not recognised\n\t(%s: %s)',...
                            mfilename,dop.tmp.file);
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    end
                case 'file'
                    %                     dop.tmp.manual_fullfile = dop_input;
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
                    dop.tmp.manual_list = table2cell(dop.tmp.import_data(:,1));
                    dop.tmp.manual_exclude = table2cell(dop.tmp.import_data(:,2));
                    % check for ~ or [] type of entries
                    for i = 1 : numel(dop.tmp.manual_exclude)
                        dop.tmp.manual_exclude{i} = checkManualString(dop.tmp.manual_exclude{i});
                    end
                else
                    dop.tmp.manual_list = cell(size(dop.tmp.import_data,1)-1,1); % minus 1 = assume header
                    dop.tmp.manual_exclude = cell(size(dop.tmp.import_data,1)-1,1); % minus 1 = assume header
                    for i = 2 : size(dop.tmp.import_data,1)
                        dop.tmp.row = textscan(dop.tmp.import_data{i},'%s%s','delimiter',dop.tmp.delim);
                        dop.tmp.manual_list{i-1} = char(dop.tmp.row{1});
                        dop.tmp.manual_exclude{i-1} = char(dop.tmp.row{2});
                        
                        %                     if ~isempty(strfind(dop.tmp.manual_exclude{i-1},'['));
                        %                         dop.tmp.manual_exclude{i-1} = eval(char(dop.tmp.row{2}));
                        %                     elseif ~isempty(sum(strfind(dop.tmp.manual_exclude{i-1},'~')));
                        %                         dop.tmp.tilda = strfind(dop.tmp.manual_exclude{i-1},'~');
                        %                         dop.tmp.epochs = zeros(1,numel(dop.tmp.tilda));
                        %                         dop.tmp.row2 = char(dop.tmp.row{2});
                        %                         for j = 1 : numel(dop.tmp.tilda)
                        %                             switch j
                        %                                 case 1
                        %                                     if dop.tmp.tilda(j) > 1
                        %                                         dop.tmp.epochs(j) = str2double(dop.tmp.row2(1:dop.tmp.tilda(j)-1));
                        %                                     end
                        %                                     % else skip
                        %                                     %                                 case numel(dop.tmp.tilda)
                        %                                     %                                     if dop.tmp.tilda(end) <= numel(dop.tmp.row2)
                        %                                     %                                         dop.tmp.epochs(j) = str2double(dop.tmp.row2(dop.tmp.tilda(j-1)+1:dop.tmp.tilda(j)-1));
                        %                                     %                                     end
                        %                                 otherwise
                        %                                     dop.tmp.epochs(j) = str2double(dop.tmp.row2(dop.tmp.tilda(j-1)+1:dop.tmp.tilda(j)-1));
                        %                             end
                        %                         end
                        %                         dop.tmp.manual_exclude{i-1} = dop.tmp.epochs;
                        %                     end
                    end
                    
                    dop.epoch.manual_list = dop.tmp.manual_list;
                    dop.epoch.manual_exclude = dop.tmp.manual_exclude;
                end
            else
                okay = 0;
                msg{end+1} = sprintf('Manual screen file is empty\n\t(%s: %s)',...
                    mfilename,dop.tmp.file);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
        end
        switch dopInputCheck(dop_input)
            case 'dop'
                dop.okay = okay;
                dop.msg = msg;
            case 'file'
                dop.manual_list = dop.tmp.manual_list;
                dop.manual_exclude = dop.tmp.manual_exclude;
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
if ~isempty(strfind(string_in,'['));
    number_out = eval(char(string_in));
elseif ~isempty(sum(strfind(string_in,'~')));
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