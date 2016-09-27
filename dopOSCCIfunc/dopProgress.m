function [dop,okay,msg] = dopProgress(dop_input,varargin)

% dopOSCCI3: dopProgress
%
% [dop,okay,msg] = dopProgress(dop_input,[okay],[msg],...)
%
% notes:
%   Uses the MATLAB 'waitbar' function to display progress through folder
%   of files
% Use:
%
% [dop,okay,msg] = dopProgress(dop_input,[okay],[msg],...)
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
% Created: 05-May-2015 NAB
% Edits:
% 19-May-2015 NAB added validity check to handle (ie 'isvalid' function)
% 19-May-2015 NAB still some issues with this - problem when dopMATread was
%   importing old handle - it was openining something extra fixed by
%   reducing what is saved in the mat file to data and file_info (see
%   dopMATsave & dopMATread for more details)
% 29-Jun-2015 NAB changed the 'dim' = dimension input/default to be in
%   pixels as the waitbar seems better suited to absolute values rather
%   than portions of the screen


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
            'pos',[.1 .9],... % top left x & y portion of screen
            'dim',[360 70],...[.15 .07],... % x and y dimensions as portion of screen or pixels
            'file',[],... % for error reporting mostly
            'showmsg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );

        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        
        %% main code
        if okay
            if ~isfield(dop,'file_list') && isempty(dop.file_list)
                okay = 0;
                msg{end+1} = 'A progress bar isn''t necessary if you aren''t processing a list of files';
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
        end
        if okay
            dop.progress.current = find(ismember(dop.file_list,dop.file),1,'first');
            if isempty(dop.progress.current)
                dop.progress.current = find(ismember(dop.file_list,dop.fullfile),1,'first');
            end
            if isempty(dop.progress.current)
                okay = 0;
                msg{end+1} = sprintf('Can''t find current file (%s) in list so can''t update progress',dop.file);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
        end
        if okay
            if dop.progress.current == 1 || ~isfield(dop.progress,'h') || ~isvalid(dop.progress.h)
                % if not numeric, could be a string that indicates that
                % it's been deleted
                if isfield(dop.progress,'h')
                    pause;
                    dop.progress = rmfield(dop.progress,'h');
                end
                
                dop.progress.n = numel(dop.file_list);
                dop.progress.msg = 'dopOSSCI waitbar initialising...';
                dop.progress.screen_size = get(0,'ScreenSize');
                if dop.tmp.dim(1) <= 1
                    dop.progress.pos = [dop.tmp.pos dop.tmp.dim].* ...
                        repmat(dop.progress.screen_size([3 4]),1,2);
                else
                    % assuming dimensions in pixels
                    dop.progress.pos = [dop.tmp.pos.*dop.progress.screen_size([3 4])...
                        dop.tmp.dim];
                end
                dop.progress.h = waitbar(0,dop.progress.msg,...
                    'Position',dop.progress.pos,'Name','dopOSCCI Progress');
                % seems to need this done every time...
                dop.progress.h_axes = get(dop.progress.h,'CurrentAxes');
                dop.progress.h_title = get(dop.progress.h_axes,'Title');
                
            end
                dop.progress.portion = dop.progress.current/dop.progress.n;
            
            % could add task name to this
            dop.progress.msg = sprintf('dopOSCCI progress: %u%% (file %u of %u)',round(dop.progress.portion*100),dop.progress.current,dop.progress.n);
            waitbar(dop.progress.portion,dop.progress.h); % update the progress bar
            
            set(dop.progress.h_title,'String',dop.progress.msg); % update the message
            drawnow;
            figure(dop.progress.h); % bring to front to make sure it's on top
%             drawnow; % don't think this is needed
            if dop.progress.portion == 1
                close(dop.progress.h);
            end
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