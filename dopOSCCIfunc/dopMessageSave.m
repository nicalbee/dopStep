function [dop,okay,msg] = dopMessageSave(dop_input,varargin)
% dopOSCCI3: dopMessageSave
%
% [dop,okay,msg] = dopMessageSave(dop_input,[okay],[msg],...)
%
% notes:
% saves a delimited version of the messages that accumulate during the call
% to dopOSCCI functions
%
% Use:
%
% [dop,okay,msg] = dopMessageSave(dop_input,[okay],[msg],...)
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
% Created: XX-Sep-2014 NAB
% Edits:
% 08-Sep-2014 NAB - continually updating list of input help information
% 19-Nov-2014 NAB - continuing
% 19-May-2015 NAB - added some help information on finding msgbox handles
% 18-Aug-2016 NAB - back to this...
% 13-Nov-2017 NAB added dop.step.(mfilename) = 1;

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
            'message_fullfile',[],...
            'message_file','dopOSCCI',... 'task_name','dopSave',...
            'message_ext','.dat',...
            'message_dir',[],...
            'message',1, ...
            'delim','\t', ...
            'error','',... % add error flag to individual file name
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        inputs.required = []; %...
%             {'epoch'};
if ~okay
    inputs.defaults.error = 'e';
end
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% save file name
        if okay && or(isempty(dop.tmp.message_file),strcmp(dop.tmp.message_file,dop.tmp.defaults.message_file))
            if ~isfield(dop,'def') ...
                    || ~isfield(dop.def,'task_name') ...
                    || isempty(dop.def.task_name)
                
                dop.def.task_name = dop.tmp.defaults.message_file;
            end
            dop.tmp.message_file = sprintf('%sMessageData%s',dop.def.task_name,dop.tmp.message_ext);
        end
        if okay && or(isempty(dop.tmp.message_dir),strcmp(dop.tmp.message_dir,dop.tmp.defaults.message_dir))
            if isfield(dop,'save') && isfield(dop.save,'save_dir') && ~isempty(dop.save.save_dir)
                dop.tmp.message_dir = fullfile(dop.save.save_dir,'messages');
            else
                dop.tmp.message_dir = fullfile(dopSaveDir(dop),'messages');
            end
        end
        if okay 
            if isempty(dop.tmp.message_fullfile)
            dop.tmp.message_fullfile = fullfile(dop.tmp.message_dir,dop.tmp.message_file);
            end
            [dop.tmp.message_dir,dop.tmp.message_file_noext,dop.tmp.ext] = fileparts(dop.tmp.message_fullfile);
            dop.tmp.message_file = [dop.tmp.message_file_noext,dop.tmp.ext];
            msg{end+1} = ...
                sprintf('Message data to be saved to: %s (dir = %s)',...
                dop.tmp.message_file,dop.tmp.message_dir);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            if ~exist(dop.tmp.message_dir,'dir')
                mkdir(dop.tmp.message_dir);
                msg{end+1} = sprintf('Creating directory = %s)',...
                    dop.tmp.message_dir);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            if ~isempty(dop.tmp.file)
                [~,dop.tmp.message_file_id] = fileparts(dop.tmp.file);
                dop.tmp.message_file_ind = strrep(...
                    dop.tmp.message_fullfile,dop.tmp.message_ext,...
                    sprintf('_%s%s',dop.tmp.message_file_id,dop.tmp.message_ext));
            else
                dop.tmp.message_file_id = 0;
                dop.tmp.message_file_ind = strrep(...
                    dop.tmp.message_fullfile,dop.tmp.message_ext,...
                    sprintf('_%i_%s',dop.tmp.message_file_id,dop.tmp.message_ext));
            end
            dop.tmp.message_fullfiles = {dop.tmp.message_fullfile,...
                dop.tmp.message_file_ind};
            if isnumeric(dop.tmp.message_file_id)
                while 1
                    dop.tmp.message_file_id = dop.tmp.message_file_id + 1;
                    dop.tmp.message_file_ind = strrep(...
                        dop.tmp.message_file_ind,num2str(dop.tmp.message_file_id-1),...
                        num2str(dop.tmp.message_file_id));
                    if ~exist(dop.tmp.message_file_ind,'file')
                        dop.tmp.message_file_id = num2str(dop.tmp.message_file_id);
                        break
                    end
                end
            end
        end
               
        %% main code
        if okay && ~isempty(msg) && iscell(msg)
            for j = 1 : numel(dop.tmp.message_fullfiles)
                if ~exist(dop.tmp.message_fullfiles{j},'file')
                    dop.tmp.fid = fopen(dop.tmp.message_fullfiles{j},'w');
                    dop.tmp.labels = {'number','file','message'};
                    for i = 1 : numel(dop.tmp.labels)
                        if i < numel(dop.tmp.labels)
                            fprintf(dop.tmp.fid,['%s',dop.tmp.delim],dop.tmp.labels{i});
                        else
                            fprintf(dop.tmp.fid,'%s\n',dop.tmp.labels{i});
                        end
                    end
                    fclose(dop.tmp.fid);
                end
                dop.tmp.fid = fopen(dop.tmp.message_fullfiles{j},'a');
                k = 0;
                for i = 1 : numel(msg)
                    use_msg = msg(i);
                    newlines = regexp(msg{i},'\n');
                    if ~isempty(newlines)
                        newlines = [1 newlines length(use_msg{1})];
                        tmp_msg = [];
                        for ii = 2 : numel(newlines)
                            tmp_msg{ii-1} = use_msg{1}(newlines(ii-1):newlines(ii));
                        end
                        use_msg = tmp_msg;
                    end
                    for ii = 1 : numel(use_msg)
                        k = k + 1;
                    fprintf(dop.tmp.fid,sprintf('%%i%s%%s%s%%s\\n',dop.tmp.delim,dop.tmp.delim),...
                        k,dop.tmp.message_file_id,regexprep(use_msg{ii},'\n',''));
                    end
%                         
                end
                fclose(dop.tmp.fid);
                
            end
            %% might be helpful
%             allHandle = allchild(0);
%             allTag = get(allHandle, 'Tag');
%             isMsgbox = strncmp(allTag, 'Msgbox_', 7);
%             delete(allHandle(isMsgbox));
%             
%             If you have a newer Matlab version, FINDOBJ can apply regular expression, which allows for a more compact version:
%             delete(findobj(allchild(0), '-regexp', 'Tag', '^Msgbox_'))
        else
            msg{end+1} = sprintf('Some issue with message saving (%s)',mfilename);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end

        dop.step.(mfilename) = 1;
        
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
%     end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end