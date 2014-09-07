function [dop,okay,msg] = dopImport(dop_input,varargin)
% dopImport: dopOSCCI3
%
% import functional Transcranial Doppler Ultrasound (fTCD) data files for
% interogation.
%
% Use:
%
% dop = dopImport(dop_input)
%
% where: dop_input = ...
% dop = dopOSCCI structure with setting information
% OR
% dop_file = file name or full path + file name for fTCD data
%
% note: dop_input is evaluated to determine which input type has been
% provided
%
% Returns:
% dop = dopOSCCI structure
%
% currently imports:
% - EXP files
%
% - TW/TX
% = mat (matlab files)
%
% Created 22-Apr-2013
% Last edit:
% 19-Aug-2014 NAB

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('Running %s:\n',mfilename);
        %% Inputs
        inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
                inputs.defaults = struct(...
            'msg',1,... % show messages
            'wait_warn',0,... % wait to close warning dialogs
            'file',[], ...
            'dir',[], ...
            'signal_channels',[],... %
            'event_channels',[] ... %
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
            dopMessage(msg,dop.tmp.comment,1,okay,dop.tmp.wait_warn);
        elseif okay && ~isempty(dop.tmp.dir) && exist(fullfile(dop.tmp.dir,dop.tmp.file),'file')
            dop.tmp.fullfile = fullfile(dop.tmp.dir,dop.tmp.file);
            msg{end+1} = 'Combined ''dir'' and ''file'' inputs for full path to file';
            dopMessage(msg,dop.tmp.comment,1,okay,dop.tmp.wait_warn);
        else
            okay = 0;
            msg{end+1} = sprintf(['''file'' input (''%s'') needs to be a full' ...
                ' file path or on MATLAB paths\n\t',...
                'OR ''dir'' + ''file'' inputs needs to give a full file path'],...
                dop.tmp.file);
            dopMessage(msg,dop.tmp.comment,1,okay,dop.tmp.wait_warn);
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
            dopMessage(msg,dop.tmp.comment,1,okay,dop.tmp.wait_warn);
            %             tmp_file,tmp_dir,tmp_ext);
            % check for a mat file first
            dop.tmp.mat_dir = dop.dir;
            dop.tmp.mat_file = [dop.file_name,'.mat'];
            dop.tmp.mat_fullfile = fullfile(dop.tmp.mat_dir,dop.tmp.mat_file);
            
            if exist(dop.tmp.mat_fullfile,'file') == 2
                %             current_dop = dop;
                % add the mat information to the file details
                dop.mat.info = '.mat file details for quicker import etc.';
                dop.mat.dir = dop.tmp.mat_dir;
                dop.mat.file = dop.tmp.mat_file;
                dop.mat.fullfile = dop.tmp.mat_fullfile;
                
                msg{end+1} = sprintf('''.mat'' file found, importing:\n\t\t%s',dop.mat.fullfile);
                dopMessage(msg,dop.tmp.comment,1,okay,dop.tmp.wait_warn);
                dop = dopMATread(dop.mat.fullfile,dop);
                %             load(dop.tmp.mat_fullfile);

            elseif isTX(dop.fullfile)
                [dop.data.raw,dop.file_info] = readTWfromTX(dop.fullfile);
            elseif isEXP(dop.fullfile)
                [dop.data.raw,dop.file_info] = dopEXPread(dop.fullfile);
            else
                msg{end+1} = sprintf(['> File type not recognised:'...
                    '\n\tExtension = %s\n\t'...
                    'Expected ''.EXP'' or ''.TX'''],dop.file_ext);
                dopMessage(msg,dop.tmp.comment,1,okay,dop.tmp.wait_warn);
            end
            if isfield(dop,'data') && isfield(dop.data,'raw')
                % update the sample rate - this will change after downsampling
                if isfield(dop.file_info,'sampleRate')
                    dop.use.sample_rate = dop.file_info.sampleRate;
                else
                dop.use.sample_rate = dop.file_info.sample_rate;
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

