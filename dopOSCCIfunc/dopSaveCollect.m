function [dop,okay,msg] = dopSaveCollect(dop_input,varargin)
% dopOSCCI3: dopSaveCollect
%
% [dop,okay,msg] = dopSaveCollect(dop_input,[okay],[msg],...)
%
% notes:
%
% Use:
%
% [dop,okay,msg] = dopSaveCollect(dop_input,[okay],[msg],...)
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
% 19-Oct-2014 NAB - updating the dop.tmp.times variable to look for and use
%   dop.epoch.times if it exists.
% 26-June-2015 NAB 'sprintf' mistype

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
            'collect_file','dopCollect',...
            'collect_dir',[],...
            'collect_fullfile',[],...
            'type','use',...
            'delim','\t',...
            'overwrite',1,...
            'times',[],...
            'sample_rate',[], ... % not critical for dopEventMarkers
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        %         inputs.required = ...
        %             {'epoch'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        if isfield(dop,'collect')
            if isfield(dop.collect,dop.tmp.type) && isfield(dop.collect.(dop.tmp.type),'data')
                dop.tmp.data = dop.collect.(dop.tmp.type).data;
            elseif strcmp(dop.tmp.type,'use') && isfield(dop,'data') ...
                    && isfield(dop.data,'use_type') && ~isempty(dop.data.use_type)
                dop.tmp.type = dop.data.use_type;
                dop.tmp.data = dop.collect.(dop.tmp.type).data;
            elseif strcmp(dop.tmp.type,'use')
                okay = 0;
                msg{end+1} = sprtinf(['Default data type (dop.data.use)'...
                    ' is not known (dop.data.use_type), can''t be saved\n\t(%s)'],...
                    dop.tmp.type,mfilename);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            elseif ~isfield(dop.collect,dop.tmp.type)
                okay = 0;
                msg{end+1} = sprintf(['Requested data type (%s) does not exist in'...
                    ' ''dop.collect'' variable, can''t be saved\n\t(%s)'],...
                    dop.tmp.type,mfilename);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            
        elseif ~isfield(dop,'collect')
            okay = 0;
            msg{end+1} = sprintf(['''dop.collect'' variable does not exist: no data'...
                ' has been collected, therefore can''t be saved\n\t(%s)'],...
                mfilename);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            
        end
        if okay && isempty(dop.tmp.times)
            if isfield(dop,'epoch') && isfield(dop.epoch,'times') && ~isempty(dop.epoch.times)
                dop.tmp.times = dop.epoch.times;
            else
                dop.tmp.times = (1:size(dop.tmp.data,1))*(1/dop.tmp.sample_rate);
            end
        end
        %% check save directory
        if okay
            % make sure we've got a save directory
            if ~isempty(dop.tmp.collect_fullfile)
                [dop.tmp.collect_dir,dop.tmp.tmp_file,dop.tmp.tmp_ext] = ...
                    fileparts(dop.tmp.collect_fullfile);
                dop.tmp.collect_file = [dop.tmp.tmp_file,dop.tmp.tmp_ext];
            elseif isempty(dop.tmp.collect_dir) && isfield(dop,'save') ...
                    && isfield(dop.save,'save_dir')
                dop.tmp.collect_dir = dop.save.save_dir;
            end
            if ~exist(dop.tmp.collect_dir,'dir')
                mkdir(dop.tmp.collect_dir);
            end
            
            %% check save file
            
            if or(isempty(dop.tmp.collect_file),strcmp(dop.tmp.collect_file,dop.tmp.defaults.collect_file))
                if ~isfield(dop,'def') ...
                        || ~isfield(dop.def,'task_name') ...
                        || isempty(dop.def.task_name)
                    
                    dop.def.task_name = dop.tmp.defaults.collect_file;
                end
                dop.tmp.collect_file = sprintf('%sCollect_%sData.dat',...
                    dop.def.task_name,dop.tmp.type);
                dop.tmp.collect_fullfile = fullfile(dop.tmp.collect_dir,dop.tmp.collect_file);
            end
            if ~dop.tmp.overwrite
                k = 0;
                [tmp_dir,tmp_file,tmp_ext] = fileparts(dop.tmp.collect_fullfile);
                while exist(dop.tmp.collect_fullfile,'file')
                    k = k + 1;
                    dop.tmp.collect_file = sprintf('%s%u%s',tmp_file,k,tmp_ext);
                    dop.tmp.collect_fullfile = fullfile(tmp_dir,dop.tmp.collect_file);
                end
            end
        end
        %% main code
        if okay
            %% > labels
            dop.tmp.delims = {dop.tmp.delim,'\n',1};
            % open the file for writing
            dop.tmp.fid = fopen(dop.tmp.collect_fullfile,'w+');
            fprintf(dop.tmp.fid,['%s',dop.tmp.delims{dop.tmp.delims{3}}],'time');
            k = 0;
            for i = 1 : size(dop.tmp.data,3)
                dop.tmp.var = sprintf('var%u',i);
                if isfield(dop,'data')  && isfield(dop.data,'epoch_labels') ...
                        && size(dop.tmp.data,3) == numel(dop.data.epoch_labels)
                    dop.tmp.var = dop.data.epoch_labels{i};
                end
                for j = 1 : numel(dop.collect.(dop.tmp.type).files)
                    k = k + 1;
                    if k == numel(dop.collect.(dop.tmp.type).files) * size(dop.tmp.data,3)
                        dop.tmp.delims{3} = 2;
                    end
                    fprintf(dop.tmp.fid,['%s',dop.tmp.delims{dop.tmp.delims{3}}],...
                        [dop.tmp.var,dop.collect.(dop.tmp.type).files{j}]);
                end
            end
            fclose(dop.tmp.fid); % close the file
            %% > and the data
            dlmwrite(dop.tmp.collect_fullfile,...
                [dop.tmp.times' reshape(dop.tmp.data,size(dop.tmp.data,1),size(dop.tmp.data,2)*size(dop.tmp.data,3))],...
                'delimiter',dop.tmp.delim,'-append');
            msg{end+1} = sprintf(['''dop.collect'' data saved to:'...
                '\n\tFile: %s\n\tDir: %s'],...
                dop.tmp.collect_file,dop.tmp.collect_dir);
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