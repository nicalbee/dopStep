function [dop,okay,msg] = dopGetFileList(dop_input,varargin)
% dopOSCCI3: dopFileList
%
% [dop,okay,msg] = dopFileList(dop,[okay],[msg],...);
%
% notes:
%
%
% Use:
%
% [dop,okay,msg] = dopFileList(dop_input,[okay],[msg],...);
%
%
% where:
% > Inputs
% - dop_input: dop matlab structure or data matrix*
%
%   Optional:
% - okay:
%   logical (0 or 1) for problem, 0 = no problem, 1 = problem. This can be
%   carried through from previously run functions. If set to 1, the
%   function will not be implemented.
% - msg:
%   cell variable with a history of messages from previously run functions.
%   New messages are appended to the end of the array and can be reported
%   to examine the processing steps using 'dopMessage':
%   e.g. dopMessage(msg) or dopMessage(dop);
%
%   Text only:
% - 'nomsg':
%   By default, messages about the processing will be reported to the
%   MATLAB command window. If included as an input, 'nomsg' will turn off
%   these messages. note: they will continue to be collected in the 'msg'
%   variable.
% - 'plot':
%   If included as an input a plot will be produced at the conclusion of
%   the function. The function will wait (see 'uiwait') until the figure
%   has been closed to complete its operations.
%
%
% > Outputs: (note, optional)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 05-Sep-2014 NAB
% Edits:
% XX-Sep-2014 NAB

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
            'msg',1,... % show messages
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
                    if ~isfield(dop,'data_dir') || isempty(dop.data_dir) || ~exist(dop.data_dir,'dir')
                        okay = 0;
                        msg{end+1} = sprintf(['No data directory'...
                            ' inputted or available in ''dop.tmp.dir''\n\t(%s)'],...
                            mfilename);
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    else
                        dop.tmp.dir = dop.data_dir;
                    end
                end
            case 'folder'
                dop.tmp.dir = dop_input;
            otherwise
                okay = 0;
                msg{end+1} = sprintf('Input not recognised\n\t(%s)',...
                    mfilename);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        %         %% tmp check
        %         [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        
        %% main code
        if okay
            dop.file_list = [];
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
                dop.tmp.types = dopFileTypes;
                % stupid case sensitivity....
                dop.tmp.types = unique(upper(dop.tmp.types));
                dop.file_lists = cell(1,numel(dop.tmp.types));
                for i = 1 : numel(dop.tmp.types)
                    switch dop.tmp.types{i}
                        case '.TX'%,'.tx','.tw'}
                            % these tend to have a number after the
                            % extension - quite annoying really!
                            dop.file_lists{i} = dir(fullfile(dop.tmp.dir,sprintf('*%s*',dop.tmp.types{i})));
                        otherwise
                            dop.file_lists{i} = dir(fullfile(dop.tmp.dir,sprintf('*%s',dop.tmp.types{i})));
                    end
                    if ~isempty(dop.file_lists{i})
                        msg{end+1} = sprintf('Found %u %s files\n',...
                            numel(dop.file_lists{i}),dop.tmp.types{i});
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        for j = 1 : numel(dop.file_lists{i})
                            dop.file_list{end+1} = fullfile(dop.tmp.dir,dop.file_lists{i}(j).name);
                        end
                    end
                end
            end
            msg{end+1} = sprintf('Found %u files in total\n',...
                numel(dop.file_list));
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        
        %% save okay & msg to 'dop' structure
        switch dopInputCheck(dop_input)
            case 'dop'
                dop.okay = okay;
                dop.msg = msg;
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