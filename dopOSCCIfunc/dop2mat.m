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
% Created: 20-May-2015 NAB
% Edits:
% 20-May-2015 NAB work in progress...

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
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
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
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    else
                        dop.tmp.mat_file = varargin{1};
                    end
                elseif isempty(varargin)
                    dop.tmp.mat_file = strrep(dop.file,dop.tmp.ext,'.mat');
                end
                
            case 'dir'
                dop.data_dir = dop_input;
                if ~exist(dop.tmp.dir,'dir')
                    okay = 0;
                    msg{end+1} = sprintf('inputted direcotry doesn''t exist, can''t continue (%s)',dop.tmp.dir);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                else
                    [dop,okay,msg] = dopGetFileList(dop,okay,msg);
                    [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                end
                if okay
                    if ischar(varargin{1}) && ~isempty(strfind(varargin{1},filesep))
                        % it's a character array and has a filesep
                        dop.tmp.mat_dir = varargin{1};
                    elseif isempty(varargin)
                        % set mat directory
                        if ~isempty(strcmp(dop.data_dir(end),filesep))
                            dop.tmp.mat_dir = [dop.data_dir(1:end-1),dop.tmp.mat_dir_ext];
                        else
                            dop.tmp.mat_dir = [dop.data_dir,dop.tmp.mat_dir_ext];
                        end
                    end
                    
                    for i = 1 : numel(dop.file_list)
                        [dop,okay,msg] = dopImport(dop,'fullfile',dop.file_list{i});
                        [dop,okay,msg] = dopMATsave(dop,okay,msg);
                    end
                end
            otherwise
                okay = 0;
                msg{end+1} = sprtinf('Input not recognised: ''%s'' aborted',mfilename);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
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