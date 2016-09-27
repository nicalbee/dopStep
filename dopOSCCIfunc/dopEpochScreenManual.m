function [dop,okay,msg] = dopEpochScreenManual(dop_input,varargin)
% dopOSCCI3: dopEpochScreenManual
%
% [dop,okay,msg] = dopEpochScreenManual(dop_input,[okay],[msg],...)
%
% notes:
%   created dop.epoch.manual which a logical (0 = exclude, 1 = use) index
%   indicating which epochs are acceptable.
%
% Use:
%
% [dop,okay,msg] = dopEpochScreenManual(dop_input,[okay],[msg],...)
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
% - 'exclude':
%   > e.g., dopFunction(dop_input,okay,msg,...,'exclude',[4 6 7],...)
%   numeric variable setting epoch numbers to be manually excluded
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
% 10-Nov-2014 NAB added '.txt' to acceptable inputs
% 10-Nov-2014 NAB updated exclude msg report
% 15-Nov-2014 NAB fixed check for exclusion of epochs greater than available
% 01-Apr-2015 HMP/NAB or statement in file name matching ~ line 207
% 08-May-2015 NAB/HMP added 'ismember' statmeent regarding file matching
% 20-May-2015 NAB added 'showmsg' & sep_remove output variable
% 06-Jul-2015 NAB playing with this before I've got data - the function
%   doesn't expect this...

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
            'exclude',[],...
            'manual_fullfile',[], ... %
            'manual_dir',[],...
            'manual_file',[],...
            'file',[],... % for error reporting mostly
            'showmsg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
%                 inputs.required = ...
%                     {'data'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        % need to know how many epochs there are
        if isfield(dop,'data') && size(dop.tmp.data,3) == 1
            % data hasn't been epoched - do this
            [dop,okay,msg] = dopEventMarkers(dop,okay,msg);
            % refresh the data if necessary
            [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        elseif ~isfield(dop,'data')
            okay = 0;
                msg{end+1} = sprintf(['There isn''t any data yet, ',...
                    'so can''t determine the number of epochs which is ',...
                    'important for this function'],mfilename,dop.tmp.file);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        end
        %% main code
        if okay
            % include all
            dop.epoch.manual = ones(1,dop.event.n);
            if ~isempty(dop.tmp.exclude) && isnumeric(dop.tmp.exclude) && ...
                    sum(dop.tmp.exclude <= dop.event.n) == numel(dop.tmp.exclude)
                if sum(dop.tmp.exclude == 0)
                    msg{end+1} = sprintf(['%u values in ''dop.tmp.exclude''' ...
                        ' variable are zero. These have been removed',...
                        '\n\t(%s: %s)'],sum(dop.tmp.exclude == 0),mfilename,dop.tmp.file);
                    if sum(dop.tmp.exclude == 0) == 1
                        msg{end} = strrep(msg{end},'values in ''dop.tmp.exclude'' variable are zero. These have',...
                            'value in ''dop.tmp.exclude'' variable is zero. This has');
                    end
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                    dop.tmp.exclude(dop.tmp.exclude == 0) = [];
                end
                % set the excluded values to zero - that is, not used
                dop.epoch.manual(dop.tmp.exclude) = 0;
                msg{end+1} = sprintf(['Manual exclusion of epochs: ' ...
                    dopVarType(dop.tmp.exclude)],dop.tmp.exclude);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            elseif ~isempty(dop.tmp.exclude) && ~isnumeric(dop.tmp.exclude)
                okay = 0;
                msg{end+1} = sprintf(['''exclude'' input variable for ''%s''',...
                    ' function must be numeric\n\t(%s)'],mfilename,dop.tmp.file);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
%             elseif ~isempty(dop.tmp.exclude) && ...
%                     sum(dop.tmp.exclude <= dop.event.n) ~= numel(dop.tmp.exclude)
%                 okay = 0;
%                 msg{end+1} = sprintf(['''exclude'' input variable (',...
%                     dopVarType(dop.tmp.exclude),...
%                     ' has values greater than the number of available epochs'...
%                     ' (%u)\n\t(%s: %s)'],dop.tmp.exclude,dop.event.n,...
%                     mfilename,dop.tmp.file);
%                 dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
%             else
            elseif ~isempty(dop.tmp.manual_fullfile) && exist(dop.tmp.manual_fullfile,'file')
                %                 warndlg('Not yet programmed!','Manual epoch file');
                [dop.tmp.man,okay,msg] = dopEpochScreenManualRead(dop.tmp.manual_fullfile,okay,msg);
            elseif ~isempty(dop.tmp.manual_file) && ~isempty(dop.tmp.manual_dir) ...
                    && exist(dop.tmp.manual_dir,'dir') ...
                    && exist(fullfile(dop.tmp.manual_dir,dop.tmp.manual_file),'file')
                [dop.tmp.man,okay,msg] = dopEpochScreenManualRead(...
                    fullfile(dop.tmp.manual_dir,dop.tmp.manual_file),okay,msg);
            elseif isempty(dop.tmp.manual_file)
                % may or may not be a problem so not saying it's not okay, just
                % might not have one
                msg{end+1} = '''dop.tmp.manual_file'' variable is empty';
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            elseif ~exist(dop.tmp.manual_file,'file')
                okay = 0;
                msg{end+1} = sprintf('''dop.tmp.manual_file'' does not exist: %s',dop.tmp.manual_file);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
            %% find the current file
            if isempty(dop.tmp.exclude) && isfield(dop.tmp,'man') ...
                    && isfield(dop.tmp.man,'manual_list') && isfield(dop.tmp.man,'manual_exclude') ...
                    && ~isempty(dop.file)
                
                
                dop.tmp.match = find(strcmp(dop.tmp.man.manual_list,dop.file),1,'first');
                if isempty(dop.tmp.match)
                    % first let's check if the extension is mat
                    [~,~,dop.tmp.manual_ext] = fileparts(dop.tmp.man.manual_list{1});
                    [~,~,dop.tmp.file_ext] = fileparts(dop.file);
                    if ismember(dop.tmp.file_ext,{'.mat','.MAT'}) && ...
                            ~strcmp(dop.tmp.manual_ext,dop.tmp.file_ext) && ...
                            find(strcmp(dop.tmp.man.manual_list,strrep(dop.file,dop.tmp.file_ext,dop.tmp.manual_ext)),1,'first')
                        
                        msg{end+1} = sprintf(['Assuming that %s files '...
                            'have been converted to %s files. Adjusted '...
                            'manual list to be %s files. Hope this is okay...'...
                            'If not, edit the ''%s'' function around line 210'],...
                            dop.tmp.manual_ext,dop.tmp.file_ext,dop.tmp.file_ext,...
                            mfilename);%dop.tmp.manual_file);
                        dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                        
                        for i = 1 : numel(dop.tmp.man.manual_list)
                            dop.tmp.man.manual_list{i} = strrep(dop.tmp.man.manual_list{i},dop.tmp.manual_ext,dop.tmp.file_ext);
                        end
                        % let's try again
                        dop.tmp.match = find(strcmp(dop.tmp.man.manual_list,dop.file),1,'first');
                    end
                    
                end
                
                if isempty(dop.tmp.match) % might be a full file list
                    i = 0;
                    while isempty(dop.tmp.match) && i < numel(dop.tmp.man.manual_list)
                        i = i + 1;
                        [~,tmp_file,tmp_ext] = fileparts(dop.tmp.man.manual_list{i});
                        if strcmp([tmp_file,tmp_ext],dop.file)
                            dop.tmp.match = i;
                        elseif  ismember(dop.tmp.man.manual_list,dop.file) %~isempty(strfind(dop.tmp.man.manual_list,dop.file))
                            % or from Heather Payne 01-Apr-2015
                            % update NAB 08-May-2015
                            dop.tmp.match = find(ismember(dop.tmp.man.manula_list,dop.file));
                            if isempty(dop.tmp.match)
                                dop.tmp.match = 0;
                            end
                        end
                    end
                end
                if isempty(dop.tmp.match) % not found
                    msg{end+1} = sprintf(['file (%s) not found in '...
                        'manual screening file: %s\n\t'...
                        'therefore, no epochs manually excluded'],dop.file,dop.tmp.manual_file);
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                else
                    dop.tmp.exclude = dop.tmp.man.manual_exclude{dop.tmp.match};
                    msg{end+1} = sprintf(['file (%s) found in'...
                        'manual screening file: %s\n\t'...
                        '%u epochs to exclude'],dop.file,dop.tmp.manual_file,numel(dop.tmp.exclude));
                    if numel(dop.tmp.exclude)
                        msg{end} = strrep(msg{end},'exclude',...
                            sprintf(['exclude: ',dopVarType(dop.tmp.exclude)],dop.tmp.exclude));
                    end
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                    
                end
            end
            %% check the exclusion fits within the current set of epochs
            if ~isempty(dop.tmp.exclude) && ...
                    sum(dop.tmp.exclude > dop.event.n)
                dop.tmp.greater = dop.tmp.exclude > dop.event.n;
                okay = 0;
                msg{end+1} = sprintf(['''exclude'' input variable (',...
                    dopVarType(dop.tmp.exclude),')',...
                    ' has %u values greater than the available epochs (%u).'...
                    ' \n\tThese will be ignored.',...
                    ' \n\t(%s: %s)'],...
                    dop.tmp.exclude,sum(dop.tmp.greater),dop.event.n,...
                    mfilename,dop.tmp.file);
                if sum(dop.tmp.greater) == 1
                    msg{end} = strrep(msg{end},'values','value');
                    msg{end} = strrep(msg{end},'These','This');
                end
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                okay = 1; % we can fix this, ignoring the greater values
                dop.tmp.exclude(dop.tmp.greater) = [];% % remove from list
            end
            %% exclude epochs
            if isfield(dop.tmp,'exclude') && ~isempty(dop.tmp.exclude)
                dop.epoch.manual(dop.tmp.exclude) = 0;
            end
            
            dop.epoch.manual = logical(dop.epoch.manual);
            dop.epoch.manual_removed = sum(dop.epoch.manual == 0);
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