function [dop,okay,msg] = dopGetFileList(dop_input,varargin)
% dopOSCCI3: dopFileList
%
% [dop,okay,msg] = dopFileList(dop,[okay],[msg],...);
%
% notes:
% Searches dop.data_dir or inputted data directory for recognised doppler
% data files (see 'dopFileTypes') and returns a cell variable
% (dop.file_list or first output if only data directory inputted).
%
% Use:
%
% [dop,okay,msg] = dopFileList(dop_input,[okay],[msg],...);
%
%
% where:
%--- Inputs ---
% - dop_input: dop matlab structure (including 'dop.data_dir') or data directory
%   e.g.,
%       dop = dopGetFileList(dop);
%       > returns dop.file_list cell variable within the dop structure
%   or
%       file_list = dopGetFileList('C:\my_data_directory\');
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
% - 'type':
%   > e.g., dopFunction(dop_input,okay,msg,...,'type','.EXP',...)
%   Sets the 'type' of file (i.e., file extension) to search for. This is
%   empty by default and all recognised Doppler data files are searched for
%   (see 'dopFileTypes') but .TX and .EXP.
%
% - 'dir':
%   > e.g., dopGetFileList(dop,okay,msg,...'dir','C:\my_data_directory\',...)
%   Sets the data directory that will be searched. If it exists the
%   'dop.data_dir' variable will be ignored.
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
% Created: 05-Sep-2014 NAB
% Edits:
% 09-Sep-2014 NAB updated documentation/help information
% 17-Sep-2014 NAB adjusted output if problem
% 10-Nov-2014 NAB added '.txt' to switch to avoid confusion with .TX files
% 19-May-2015 NAB updated to pull 'type' inputted list out of structure
%   array, into cell array.
% 20-May-2015 NAB changed 'folder' to 'dir' as input - more intuitive
% 07-Jul-2015 NAB set dop.def.data_dir or dop.data_dir to be options

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
            'type',[],...
            'dir',[],...
            'file',[],... % for error reporting mostly
            'showmsg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        %         inputs.defaults.types = dopFileTypes;
        %         inputs.required = ...
        %             {'epoch'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        switch dopInputCheck(dop_input)
            case 'dop'
                if isempty(dop.tmp.dir)
                    if isfield(dop,'data_dir') && ~isempty(dop.data_dir)
                        dop.tmp.dir = dop.data_dir;
                    elseif isfield(dop,'def') && isfield(dop.def,'data_dir') && ~isempty(dop.def.data_dir)
                        dop.tmp.dir = dop.def.data_dir;
                    else
                        okay = 0;
                        msg{end+1} = sprintf(['No data directory'...
                            ' inputted or available in ''dop.tmp.dir''\n\t(%s)'],...
                            mfilename);
                        dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                    end
                end
            case 'dir'%,'folder'}
                dop.tmp.dir = dop_input;
            otherwise
                okay = 0;
                msg{end+1} = sprintf('Input not recognised\n\t(%s)',...
                    mfilename);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        end
        %         %% tmp check
        %         [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        
        %% main code
        if okay
            dop.file_list = [];
            dop.use.file_list = [];
            if ~isempty(dop.tmp.type)
                switch dop.tmp.type
                    case {'.TW','.TX'}%,'.tx','.tw'}
                        % these tend to have a number after the
                        % extension - quite annoying really!
                        dop.file_list = dir(fullfile(dop.tmp.dir,sprintf('*%s*',dop.tmp.type)));
                    otherwise
                        dop.file_list = dir(fullfile(dop.tmp.dir,sprintf('*%s',dop.tmp.type)));
                end
            else
                dop.tmp.types = upper(dopFileTypes);
                % stupid case sensitivity....
                dop.tmp.types = unique(upper(dop.tmp.types));
 dop.file_lists = cell(1,numel(dop.tmp.types));
                for i = 1 : numel(dop.tmp.types)
                    switch dop.tmp.types{i}
%                         case {'.TXT','.txt'}
% %                             for j = 1 : numel(dop.file_lists{i})
% %                                 if ~isempty(strfind(dop.file_lists{i}(j).name,'.txt'))
% %                                     dop.file_lists{i}(j) = [];
% %                                 end
% %                             end
% dop.file_lists{i} = dir(fullfile(dop.tmp.dir,sprintf('*%s*',dop.tmp.types{i})));
                        case '.TX'%,'.tx','.tw'}
                            % these tend to have a number after the
                            % extension - quite annoying really!
                            dop.file_lists{i} = dir(fullfile(dop.tmp.dir,sprintf('*%s*',dop.tmp.types{i})));
                            dop.tmp.txt_files = zeros(1,numel(dop.file_lists{i}));
                            for j = 1 : numel(dop.tmp.txt_files)
                                if ~isempty(strfind(dop.file_lists{i}(j).name,'.txt'))
                                    dop.tmp.txt_files(j) = 1;
                                end
                            end
                            if sum(dop.tmp.txt_files) == numel(dop.tmp.txt_files)
                                dop.file_lists{i} = [];
                            elseif sum(dop.tmp.txt_files)
                                dop.file_lists{i}(logical(dop.tmp.txt_files)) = [];
                            end
                                
                        otherwise
                            dop.file_lists{i} = dir(fullfile(dop.tmp.dir,sprintf('*%s',dop.tmp.types{i})));
                    end
                    if ~isempty(dop.file_lists{i})
                        msg{end+1} = sprintf('Found %u %s files\n',...
                            numel(dop.file_lists{i}),dop.tmp.types{i});
                        dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                        for j = 1 : numel(dop.file_lists{i})
                            dop.file_list{end+1} = fullfile(dop.tmp.dir,dop.file_lists{i}(j).name);
                        end
                    end
                end
            end
            if ~isempty(dop.file_list) && isstruct(dop.file_list)
                % pull the list out of the structure
                dop.tmp.file_list = dop.file_list;
                dop.file_list = cell(1,numel(dop.tmp.file_list));
                for i = 1 : numel(dop.file_list)
                    dop.file_list{i} = fullfile(dop.tmp.dir,dop.tmp.file_list(i).name);
                end
            end
            msg{end+1} = sprintf('Found %u files in total\n',...
                numel(dop.file_list));
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        end
        
        %% save okay & msg to 'dop' structure
        switch dopInputCheck(dop_input)
            case 'dop'
                dop.okay = okay;
                dop.msg = msg;
                dop.use.file_list = [];
                if okay
                    dop.use.file_list = dop.file_list;
                end
            case 'folder'
                dop = dop.file_list;
        end
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end

% try
% %     fl.fileList=[];
% %     fl.report=[];
% %     fl.fileType='TX';
% %     fl.comment=1;
% %     fl.folder=folder;
% %     if ~isempty(varargin) && isnumeric(varargin{1}) && varargin{1}<=1
% %         fl.comment=varargin{1};
% %     end
% %     if ~strcmp(fl.folder(end),'/')
% %         fl.folder=[fl.folder,'/'];
% %     end
%     [fl.fileList fl.report]=getTXfileList(fl.folder,fl.comment);
%     disp(fl.report)
%     if isempty(fl.fileList)
%         % EXP check
%         fl.fileType='EXP';
%         [fl.fileList fl.report]=getEXPfileList(fl.folder,fl.comment);
%         disp(fl.report)
%     end
%
%     varargout{1}=fl.fileList;
%     varargout{2}=fl.report;
%     varargout{3}=fl.fileType;
% catch err
%     %% catch dopOSCCI error
%     save(dopOSCCIdebug(mfilename));rethrow(err);
% end