function [dop,okay,msg] = dopEpochScreenManualCreate(dop_input,varargin)
% dopOSCCI3: dopEpochScreenManualCreate
%
% [dop,okay,msg] = dopEpochScreenManualCreate(dop_input,[okay],[msg],...)
%
% notes:
%   creates manual screening file = two column text file with list of file
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
% Created: 14-Sep-2014 NAB
% Edits:

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
            'manual_file','manualEpochScreen.dat', ... %
            'manual_dir',[],...
            'manual_fullfile',[],...
            'file_list',[],...
            'delim','\t',...
            'exclude_string','[2 3]',... '[]',...
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        inputs.defaults.column_labels = {'file_name','exclude_string'};
        inputs.required = ...
            {'file_list'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        if okay
            %% data check
            if isempty(dop.tmp.manual_fullfile)
                if isempty(dop.tmp.manual_dir) && ~exist(dop.tmp.manual_dir,'dir')
                    msg{end+1} = '''manual_dir'' variable is empty or doesn''t exist';
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    if isfield(dop,'data_dir') && ~isempty(dop.data_dir)
                        msg{end+1} = sprintf(['setting ''manual_dir'' to'...
                            ' ''dop.data_dir'' directory: %s'],dop.data_dir);
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        dop.tmp.manual_dir = dop.data_dir;
                    else
                        msg{end+1} = sprintf(['setting ''manual_dir'' to current'...
                            ' working directory: %s'],pwd);
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        % use current working directory
                        dop.tmp.manual_dir = pwd;
                    end
                    
%                 elseif exist(dop.tmp.manual_dir,'dir')
%                     dop.tmp.manual_fullfile = fullfile(dop.tmp.manual_dir,dop.tmp.manual_file);
                end
                if isempty(dop.tmp.manual_file)
                    dop.tmp.manual_file = dop.tmp.defaults.manual_file;
                    msg{end+1} = sprintf(['''manual_file'' variable'...
                        ' is empty, using default: %s'],dop.tmp.manual_file);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
                dop.tmp.manual_fullfile = ...
                    fullfile(dop.tmp.manual_dir,dop.tmp.manual_file);
            end
            %% overwrite?
            % if not, create new file name by adding a number before extension
            if ~dop.tmp.overwrite
                k = 0;
                [~,tmp_file,tmp_ext] = fileparts(dop.tmp.manual_fullfile);
                while exist(dop.tmp.manual_fullfile,'file')
                    k = k + 1;
                    dop.tmp.manual_fullfile = fullfile(dop.tmp.manual_dir,...
                        sprintf('%s%u%s',tmp_file,k,tmp_ext));
                end
            end
            %% write the labels
            dop.tmp.fid = fopen(dop.tmp.manual_fullfile,'w');
            fprintf(dop.tmp.fid,['%s',dop.tmp.delim,'%s\n',],dop.tmp.column_labels{:});
            % reset just in case
            %% write the data
            for i = 1 : numel(dop.tmp.file_list)
                fprintf(dop.tmp.fid,['%s',dop.tmp.delim,'%s\n'],...
                    dop.tmp.file_list{i},dop.tmp.exclude_string);
            end
            fclose(dop.tmp.fid);
            %% report
            msg{end+1} = sprintf(['Manual screening template saved to:'...
                '\n\tFile: %s\n\tDir: %s\n\tFullfile: %s'],...
                dop.tmp.manual_file,dop.tmp.manual_dir,dop.tmp.manual_fullfile);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            
            %% save to 'dop' structure
            % not sure whether to put these in 'def' or 'use' = sticking with
            % 'def'
            dop.def.manual_file = dop.tmp.manual_file;
            dop.def.manual_dir = dop.tmp.manual_dir;
            dop.def.manual_fullfile = dop.tmp.manual_fullfile;
        end
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end