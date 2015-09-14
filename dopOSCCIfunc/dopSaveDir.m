function [dop,okay,msg] = dopSaveDir(dop_input,varargin)
% dopOSCCI3: dopSaveDir
%
% [dop_output,okay,msg] = dopSaveDir(dop_input,[okay],[msg],...)
%
% notes:
% creates a directory based on the location of 'dopOSCCI' (uses the folder
% and appends 'Data' to it so as not to create/change folders in the
% dopOSCCI directory.
%
% if the dop structure is inputted, the dop output will include
% dop.save.save_dir.
% if a ...,'dir_only',1,... input is included after the dop strucutre as
% inputs, then the output will just be the directory. Need to be careful
% with this, you dop structure will be overwritten if you ouput is in the
% standard form: [dop,okay,msg] = dopSaveDir(dop,'dir_only',1).
% > this is because the first output will be the save directory string.
%
% An alternative to these is to not include any inputs. In this instance,
% just a directory string will be outputted in the form of
% 'a_task/yyyymmddTHHMMSS'. This uses MATLAB's 'datestr' function,
% specifically datestr(now,30).
%
% Another alternative is to set the first input as empty and then include
% various options that will automatically create the directory name:
% e.g.,
%   save_name = dopSaveDir([],'epoch',[-10 20],'dir_out',1);
%
% the input 'name_variables' sets which variables are included. Currently
% (18-Sep-2014) will only work with 2 number variables (epoch, baseline,
% and poi) but probably be updated at some point.
%
% Use:
%
% [dop_output,okay,msg] = dopSaveDir(dop_input,[okay],[msg],...)
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
% - 'prefix' or 'suffix':
%   > e.g., dopFunction(dop_input,okay,msg,...,'prefix','mynote',...)
%   Inclues variable before (prefix) or after (suffix) the directory name.
%   e.g., mynote_ep-10to20_base-10to-5_poi10to20_act_sep10
%   or
%   e.g., ep-10to20_base-10to-5_poi10to20_act_sep10_mynote
%
% - 'name_variables':
%   > e.g., dopFunction(dop_input,okay,msg,...,'name_variables',{'epoch','baseline','poi'},...)
%   sets which variables are included in the directory name
%   inlucded in the form of '_abbreviation#to#' e.g., _ep-10to20
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
% Created: 18-Sep-2014 NAB
% Edits:
% 27-Jan-2015 NAB separating task name from settings in directory structure
%   + added activation separation to the labelling by default (act_sep)
% 27-Jan-2015 NAB added prefix and suffix options
% 15-Sep-2015 NAB allowed for multiple rows of period - denoted with
%   'Multiple' string in folder name, rather than #to#

if ~exist('dop_input','var')
    dop_input = [];
end
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
            'task_name','a_task',...
            'epoch',[], ... % [lower upper] limits in seconds
            'baseline',[],...
            'poi',[],...
            'act_separation',[],...
            'prefix',[],... % string to add before the variables/folder name
            'suffix',[],... % string to add after the variables/folder name
            'dir_out',0,...
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        inputs.defaults.name_variables = {'epoch','baseline','poi','act_separation'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        
        
        %% main code
        if exist('dopOSCCI','file')
            dop_fullfile = which('dopOSCCI');
            dop_dir = fileparts(dop_fullfile);
            msg{end+1} = sprintf(['Using ''dopOSCCI'' function location'...
                ' as base for directory: %s'],dop_dir);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        else
            mfile_fullfile = which(mfilename);
            mfile_dir = fileparts(mfile_fullfile);
            current_dir = pwd;
            cd(fullfile(mfile_dir,'..','..'));
            dop_dir = pwd;
            cd(current_dir); % change back to where the path was set
            msg{end+1} = sprintf(['Setting base directory 2 levels up'...
                ' from mfile location: %s'],dop_dir);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        dop.tmp.base_dir = [dop_dir,'Data'];
        dop.tmp.save_name = []; %datestr(now,30); %dop.tmp.task_name;
        dop.tmp.var_found = 0;
        for i = 1 : numel(dop.tmp.name_variables)
            dop.tmp.vn = dop.tmp.name_variables{i}; % variable name
            if isfield(dop.tmp,dop.tmp.vn) && ~isempty(dop.tmp.(dop.tmp.vn));
                dop.tmp.var_found = dop.tmp.var_found + 1;
                %                 if isempty(dop.tmp.save_name)
                dop.tmp.programmed = 1;
                switch numel(dop.tmp.(dop.tmp.vn))
                    case 1
                        dop.tmp.save_name = sprintf('%s_%s%i',dop.tmp.save_name,...
                            dopSaveAbbreviations(dop.tmp.vn),dop.tmp.(dop.tmp.vn));
                    case 2
                        dop.tmp.save_name = sprintf('%s_%s%ito%i',dop.tmp.save_name,...
                            dopSaveAbbreviations(dop.tmp.vn),dop.tmp.(dop.tmp.vn));
                    otherwise
                        if size(dop.tmp.(dop.tmp.vn),1) > 1
                            dop.tmp.save_name = sprintf('%s_%sMultiple',dop.tmp.save_name,...
                            dopSaveAbbreviations(dop.tmp.vn));
                        else
                        dop.tmp.programmed = 0;
                        msg{end+1} = sprintf(['''%s'' variable not',...
                            ' included in directory name: not setup for %u item variables'],...
                            dop.tmp.vn, numel(dop.tmp.(dop.tmp.vn)));
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        end
                end
                if dop.tmp.programmed
                    msg{end+1} = sprintf('''%s'' variable included in directory name: %s',...
                        dop.tmp.vn,dop.tmp.save_name);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
            end
        end
        if isempty(dop.tmp.save_name) %datestr(now,30);
            dop.tmp.save_name = datestr(now,30);
        else
            % add a prefix
            dop.tmp.amendments = {'prefix','suffix'};
            for i = 1 : numel(dop.tmp.amendments)
                dop.tmp.vn = dop.tmp.amendments{i};
                if ~isempty(dop.tmp.(dop.tmp.vn))
                    switch dop.tmp.vn
                        case 'prefix'
                            dop.tmp.save_name = sprintf([dopVarType(dop.tmp.(dop.tmp.vn)),'_%s'],...
                        dop.tmp.(dop.tmp.vn),dop.tmp.save_name);
                        case 'suffix'
                            dop.tmp.save_name = sprintf(['%s_',dopVarType(dop.tmp.(dop.tmp.vn))],...
                        dop.tmp.save_name,dop.tmp.(dop.tmp.vn));
                    end
                    
                    msg{end+1} = sprintf(['%s (''',...
                        dopVarType(dop.tmp.(dop.tmp.vn)),''') added to directory name: %s'],...
                        dop.tmp.vn,dop.tmp.(dop.tmp.vn),dop.tmp.save_name);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
            end
            % if the first character an underscore?
            if strncmp(dop.tmp.save_name(1),'_',1)
                dop.tmp.save_name = dop.tmp.save_name(2:end);
            end
            % add a 'suffix'
        end
        %         if ~dop.tmp.var_found
        %             dop.tmp.save_name = sprintf('%s',);
        %         end
        %         if ~isempty(dop.tmp.epoch)
        %             dop.tmp.save_name = sprintf('%s_ep%ito%i',dop.tmp.task_name,dop.tmp.epoch);
        %         end
        %         if ~isempty(dop.tmp.baseline)
        %             dop.tmp.save_name = sprintf('%s_base%ito%i',dop.tmp.save_name,dop.tmp.baseline);
        %         end
        %         if ~isempty(dop.tmp.poi)
        %             dop.tmp.save_name = sprintf('%s_poi%ito%i',dop.tmp.save_name,dop.tmp.poi);
        %         end
        
        while 1
            dop.tmp.save_dir = fullfile(dop.tmp.base_dir,dop.tmp.task_name,dop.tmp.save_name);
            if ~exist(dop.tmp.save_dir,'dir')
                break
            end
            dop.tmp.save_name = [dop.tmp.save_name,'+'];
        end
        dop.save.save_dir = fullfile(dop.tmp.base_dir,dop.tmp.task_name,dop.tmp.save_name);%dop.tmp.save_dir;
        msg{end+1} = sprintf('Original directory name: %s',...
            dop.save.save_dir);
        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        if isempty(dop_input) || dop.tmp.dir_out
            dop = dop.tmp.save_dir;
        end
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end