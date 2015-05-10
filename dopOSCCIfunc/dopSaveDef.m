function [dop,okay,msg] = dopSaveDef(dop_input,varargin)
% dopOSCCI3: dopSaveDef
%
% [dop,okay,msg] = dopSaveDef(dop_input,[okay],[msg],...)
%
% notes:
%   Saves processing definition information to data save directory
%
% Use:
%
% [dop,okay,msg] = dopSaveDef(dop_input,[okay],[msg],...)
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
% 05-May-2015 NAB unsure about setting okay to 1 even if issues - good to
%   be clearly alerted if you're not going to get a definition file
%   methinks

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
            'def_file','dop',... 'task_name','dopSave',...
            'save_dir',[],...
            'save_mat',0,...
            'save_txt',1, ...
            'delim','\t', ...
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        if ~isstruct(dop) || ~isfield(dop,'def')
            msg{end+1} = 'Input isn''t a structure or dop.def field doesn''t exist';
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            % set okay to 0 but it's not critical for the running of the
            % subsequent processing that this function runs so might change
            % this at the end of the script
            okay = 0;
        end
        %% save file name
        if okay && or(isempty(dop.tmp.def_file),strcmp(dop.tmp.def_file,dop.tmp.defaults.def_file))
            if ~isfield(dop.def,'task_name') ...
                    || isempty(dop.def.task_name)
                
                dop.def.task_name = dop.tmp.defaults.def_file;
            end
            dop.tmp.def_file = sprintf('%sDefinition.dat',dop.def.task_name);
        end
        %% main code
        if okay
            dop.tmp.delims = {dop.tmp.delim,'\n',1};
            
            %% save a mat file
            if isempty(strfind(dop.tmp.def_file,'.mat'))
                [~,~,tmp_ext] = fileparts(dop.tmp.def_file);
                dop.save.def_file = strrep(dop.tmp.def_file,tmp_ext,'.mat');
            end
            if isempty(dop.tmp.save_dir)
                [dop,okay,msg] = dopSaveDir(dop);
                dop.tmp.save_dir = dop.save.save_dir;
            end
            if ~exist(dop.tmp.save_dir,'dir')
                mkdir(dop.tmp.save_dir);
            end
            dop.save.fullfile_def_mat = fullfile(dop.tmp.save_dir,dop.save.def_file);
            if dop.tmp.save_mat
                save(dop.save.fullfile_def_mat,'dop');
                msg{end+1} = sprintf('''.mat'' file saved: %s',dop.save.fullfile_def_mat);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            % to load
            % load(dop.save.fullfile);
            
            dop.save.fullfile_def_txt = strrep(dop.save.fullfile_def_mat,'.mat','.txt');
           
            %% txt file
            if dop.tmp.save_txt
                dop.save.fid = fopen(dop.save.fullfile_def_txt,'w');
                dop.tmp.fields = fields(dop.def);
                for i = 1 : numel(dop.tmp.fields)
                    if iscell(dop.def.(dop.tmp.fields{i}))
                        if dop.tmp.msg; fprintf(['%s:',dop.tmp.delims{1}],dop.tmp.fields{i}); end
                        % save to file
                        fprintf(dop.save.fid,['%s:',dop.tmp.delims{1}],dop.tmp.fields{i});
                        for j = 1 : numel(dop.def.(dop.tmp.fields{i}))
                            dop.tmp.save_data = dop.def.(dop.tmp.fields{i}){j};
                            if j == numel(dop.def.(dop.tmp.fields{i}))
                                dop.tmp.delims{3} = 2;
                            end
                            if dop.tmp.msg; fprintf([dopVarType(dop.tmp.save_data),dop.tmp.delims{dop.tmp.delims{3}}],dop.tmp.save_data); end
                            % save to file
                            fprintf(dop.save.fid,[dopVarType(dop.tmp.save_data),dop.tmp.delims{dop.tmp.delims{3}}],dop.tmp.save_data);
                        end
                    else
                        if dop.tmp.msg; fprintf(['%s:',dop.tmp.delims{1},dopVarType(dop.def.(dop.tmp.fields{i})),'\n'],...
                                dop.tmp.fields{i},dop.def.(dop.tmp.fields{i})); end
                        % save to file
                        fprintf(dop.save.fid,['%s:',dop.tmp.delims{1},dopVarType(dop.def.(dop.tmp.fields{i})),'\n'],dop.tmp.fields{i},dop.def.(dop.tmp.fields{i}));
                    end
                end
                fclose(dop.save.fid);
                
                msg{end+1} = sprintf('''.txt'' file saved: %s',dop.save.fullfile_def_txt);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            %% set okay to 1
            % this function isn't necessary for processing so don't really
            % need the processing to stop because of it but it is good to
            % know that it's not going to work....
%             okay = 1; 
        end

        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end