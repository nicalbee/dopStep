function [dop,okay,msg] = dop2mat(dop_input,varargin)
% dopOSCCI3: dop2mat
%
% [dop,okay,msg] = dop2mat(dop_input,[okay],[msg],...)
%
% notes:
%
% opens raw doppler file and saves a .mat file. Completed for single or
% folders of files.
%
% Use:
%
% [dop,okay,msg] = dop2mat(dop_input,[okay],[msg],...)
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
% Created: 20-May-2015 NAB
% Edits:
% 20-May-2015 NAB work in progress...
% 20-May-2015 NAB working for directory
% 21-May-2015 NAB included progress waitbar - just for fun

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        %         inputs.turnOn = {'nomsg'};
        %         inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'mat_file',[], ...
            'mat_dir',[], ...
            'mat_fullfile',[], ...
            'mat_dir_ext','_mat',... % add this to the end of regular directory
            'dir',[],...
            'file',[],... % for error reporting mostly
            'showmsg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        inputs.required = {};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        %% input check & main code
        switch dopInputCheck(dop_input)
            case 'dop'
                % check for file information and mat_file information
            case 'file'
                % must be full file or on the path - based on dopInputCheck
                [dop.tmp.dir,dop.tmp.file_noext,dop.tmp.ext] = fileparts(dop_input);
                if ~isempty(dop.tmp.dir)
                    dop.data_dir = dop.tmp.dir;
                    dop.fullfile = dop_input;
                end
                dop.file = [dop.tmp.file_noext,dop.tmp.ext];
                
                if ischar(varargin{1}) && ...
                        or(~isempty(strfind(varargin{1},'.mat')),...
                        ~isempty(strfind(varargin{1},'.MAT')))
                    if ~isempty(strfind(varargin{1},filesep))
                        % there's some folder information in here - assume
                        % that it's the full path
                        dop.tmp.mat_fullfile = varargin{1};
                        [dop.tmp.mat_dir,dop.tmp.file_noext,dop.tmp.ext] = fileparts(dop.tmp.mat_fullfile);
                        dop.tmp.mat_file = [dop.tmp.file_noext,dop.tmp.ext];
                        msg{end+1} = 'fullfile with .mat extension found as second input';
                        dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                    else
                        dop.tmp.mat_file = varargin{1};
                    end
                elseif isempty(varargin)
                    dop.tmp.mat_file = strrep(dop.file,dop.tmp.ext,'.mat');
                end
                
            case 'dir'
                dop.data_dir = dop_input;
                if ~exist(dop.data_dir,'dir')
                    okay = 0;
                    msg{end+1} = sprintf('inputted direcotry doesn''t exist, can''t continue (%s)',dop.tmp.dir);
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                else
                    [dop,okay,msg] = dopGetFileList(dop,okay,msg);
                    [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                end
                if okay
                    if ischar(varargin{1}) && ~isempty(strfind(varargin{1},filesep))
                        % it's a character array and has a filesep
                        dop.tmp.mat_dir = varargin{1};
                    elseif isempty(varargin{1})
                        % set mat directory
                        if ~isempty(strcmp(dop.data_dir(end),filesep))
                            dop.tmp.mat_dir = [dop.data_dir(1:end-1),dop.tmp.mat_dir_ext];
                        else
                            dop.tmp.mat_dir = [dop.data_dir,dop.tmp.mat_dir_ext];
                        end
                    end
                    if ~exist(dop.tmp.mat_dir,'dir')
                        mkdir(dop.tmp.mat_dir);
                    end
                    for i = 1 : numel(dop.file_list)
                        dop.file = dop.file_list{i};
                        [dop,okay,msg] = dopImport(dop,'file',dop.file);
                        [dop,~,msg] = dopMultiFuncTmpCheck(dop,1,msg);
                        [dop,okay,msg] = dopMATsave(dop,okay,msg,'mat_dir',dop.tmp.mat_dir);
                        if okay
                        dop.mat_file = dop.tmp.mat_file;
                        dop.mat_dir = dop.tmp.mat_dir;
                        end
                        [dop,~,msg] = dopMultiFuncTmpCheck(dop,1,msg);
                        if okay
                            msg{end+1} = sprintf('%s saved to %s (%s)',dop.file_list{i},dop.mat_file,dop.mat_dir);
                            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                        else
                            %                             okay = 1; % don't need to abort though... probably
                            msg{end+1} = sprintf('Problem with %s: couldn''t save as .mat file',dop.file_list{i});
                            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                        end
                        dop = dopProgress(dop);
                    end
                end
            otherwise
                okay = 0;
                msg{end+1} = sprtinf('Input not recognised: ''%s'' aborted',mfilename);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
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