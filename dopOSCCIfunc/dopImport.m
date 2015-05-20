function [dop,okay,msg] = dopImport(dop_input,varargin)
% dopOSCCI3: dopImport
%
% [dop,okay,msg] = dopImport(dop_input,[okay],[msg],...)
%
% Imports functional Transcranial Doppler Ultrasound (fTCD) data files for
% summarising.
%
% Use:
%
% [dop,okay,msg] = dopImport(dop_input,okay,msg,'file','my_file.EXP','dir','C:\data_dir\')
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
%   file name of the data file to be imported.
%   The default value is empty.
%
% - 'dir':
%   > e.g., dopFunction(dop_input,okay,msg,...,'dir','C:\my_data_dir\',...)
%   directory of the data file to be imported.
%   The default value is empty.
%
% - 'showmsg':
%   > e.g., dopFunction(dop_input,okay,msg,...,'msg',1,...)
%       or
%           dopFunction(dop_input,okay,msg,...,'msg',0,...)
%   This is a logical variable (1 = on, 0 = off) setting whether or not
%   messages about the progress of the processing are printed to the MATLAB
%   command window.
%   The default value is 1 = on, messages are printed
%
%--- Optional, Text only:
%
% - 'nomat':
%   > e.g., dopFunction(dop_input,okay,msg,...,'nomat')
%   Even if a .mat file exists, it will not be imported
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
% Created 22-Apr-2013
% Edits:
% 19-Aug-2014 NAB
% 09-Sep-2014 NAB updated documentation

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('Running %s:\n',mfilename);
        %% Inputs
        inputs.turnOn = {'nomat'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'file',[], ...
            'dir',[], ...
            'showmsg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        inputs.required = ...
            {'file'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% check for existing data
        if okay && isfield(dop,'data')
            dop = rmfield(dop,'data');
        end
        
        %% check file
        if okay && exist(dop.tmp.file,'file')
            dop.tmp.fullfile = dop.tmp.file;
            msg{end+1} = 'Full path to file inputted';
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        elseif okay && ~isempty(dop.tmp.dir) && exist(fullfile(dop.tmp.dir,dop.tmp.file),'file')
            dop.tmp.fullfile = fullfile(dop.tmp.dir,dop.tmp.file);
            msg{end+1} = 'Combined ''dir'' and ''file'' inputs for full path to file';
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        elseif okay
            okay = 0;
            msg{end+1} = sprintf(['''file'' input (''%s'') needs to be a full' ...
                ' file path or on MATLAB paths\n\t',...
                'OR ''dir'' + ''file'' inputs needs to give a full file path'],...
                dop.tmp.file);
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        end
        
        %% > check file
        if okay
            [dop,okay,msg] = dopFileParts(dop,okay,msg,dop.tmp.fullfile);
        end
        %% > ready to import?
        if okay
            dop.use.file = dop.file;
            dop.use.fullfile = dop.fullfile;
            dop.use.dir = dop.dir;
            
            
            msg{end+1} = sprintf(['> Importing:\n\tFile = %s\n\t'...
                'Dir = %s\n\tExtension = %s\n\n'],...
                dop.use.file,dop.use.dir,dop.file_ext);
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            %             tmp_file,tmp_dir,tmp_ext);
            % check for a mat file first
            dop.tmp.mat_dir = dop.dir;
            dop.tmp.mat_file = [dop.file_name,'.mat'];
            dop.tmp.mat_fullfile = fullfile(dop.tmp.mat_dir,dop.tmp.mat_file);
            
            if exist(dop.tmp.mat_fullfile,'file') == 2 && ~dop.tmp.nomat
                %             current_dop = dop;
                % add the mat information to the file details
                dop.mat.info = '.mat file details for quicker import etc.';
                dop.mat.dir = dop.tmp.mat_dir;
                dop.mat.file = dop.tmp.mat_file;
                dop.mat.fullfile = dop.tmp.mat_fullfile;
                
                msg{end+1} = sprintf('''.mat'' file found, importing:\n\t\t%s',dop.mat.fullfile);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                [dop,okay,msg] = dopMATread(dop,'mat_file',dop.mat.fullfile);
                %             load(dop.tmp.mat_fullfile);
                if ~okay
                    [dop,okay,msg] = dopImport(dop,'nomat');
                end
            elseif isTX(dop.fullfile)
                [dop.data.raw,dop.file_info] = readTWfromTX(dop.fullfile);
            elseif isEXP(dop.fullfile)
                [dop.data.raw,dop.file_info] = dopEXPread(dop.fullfile);
            else
                msg{end+1} = sprintf(['> File type not recognised:'...
                    '\n\tExtension = %s\n\t'...
                    'Expected ''.EXP'' or ''.TX'''],dop.file_ext);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
            if isfield(dop,'data') && isfield(dop.data,'raw')
                % update the sample rate - this will change after downsampling
                if isfield(dop.file_info,'sampleRate')
                    dop.use.sample_rate = dop.file_info.sampleRate;
                elseif isfield(dop.file_info,'sample_rate')
                dop.use.sample_rate = dop.file_info.sample_rate;
                else
                    okay = 0;
                    msg{end+1} = 'Sample rate information not found: this is a problem';
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                end
                [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'raw');
%                 if dop.tmp.extract
%                     [dop,okay,msg] = dopChannelExtract(dop,okay,msg);
%                 end
            end
        end
        
        dop.msg = msg;
        dop.okay = okay;
        dopOSCCIindent('done');
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end

