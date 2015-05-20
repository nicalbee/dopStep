function [dop,okay,msg] = dopMATsave(dop_input,varargin)
% dopOSCCI3: dopMATsave
%
% notes:
% saves dop structure to a '.mat' file. This allows for
% the data to be imported (using dopMATread) more efficiently (quickly).
%
%
% Use:
%
% [dop,okay,msg] = dopMATsave(dop,[okay],[msg],varargin);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 07-Aug-2013 NAB
% Edits:
% 19-Aug-2014 NAB
% 06-Sep-2014 NAB updated to current dopSetBasics & removed embedded
%   function
% 19-May-2015 NAB haven't really tested this before, giving it a go today
%   using the whatbox files
% 19-May-2015 NAB was older than I thought - old input check removed

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;
        %% inputs
        %     inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'file',[],...
            'showmsg',1,...
            'wait_warn',0,...
            'mat_file',[], ... 
            'mat_dir',[], ...
            'mat_fullfile',[] ...
            );
        inputs.defaults.save_variables = {'data','file_info'};
        inputs.required = [];
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
%         switch dopInputCheck(dop_input)
%             case 'dop'
%                 msg{end+1} = '''dop'' structure input recognised:';
%                 dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
%                 dop = dop_input;
%             case dopFileTypes
%                 msg{end+1} = 'Doppler data file input recognised,importing';
%                 dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
%                 [dop,okay,msg] = dopImport(dop_input,okay,msg);
%                 [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
%             otherwise
%                 okay = 0;
%                 msg{end+1} = 'Input not recognised';
%                 dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
%         end
        
        %% create file names
        if okay
            if isempty(dop.tmp.mat_file) && or(isfield(dop,'fullfile'),isfield(dop,'file'))
                if isfield(dop,'file') && ~isempty(dop.file)
                    [~,~,tmp_ext] = fileparts(dop.file);
                    dop.tmp.mat_file = strrep(dop.file,tmp_ext,'.mat');
                elseif isfield(dop,'fullfile') && ~isempty(dop.fullfile)
                    [~,tmp_file,tmp_ext] = fileparts(dop.fullfile);
                    dop.tmp.mat_fullfile = strrep(dop.fullfile,tmp_ext,'.mat'); % minus extension
                    dop.tmp.mat_file = dop.tmp.mat_fullfile(...
                        strfind(dop.tmp.mat_fullfile,tmp_file):end);
                else
                    okay = 0;
                    msg{end+1} = sprintf(['Can''t find ''dop.file'' or'...
                        '''dop.fullfile'' to name .mat file.\n\t(%s)'],...
                        mfilename);
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                end
            end
            if isempty(dop.tmp.mat_dir) && or(or(isfield(dop,'dir'),isfield(dop,'fullfile')),isfield(dop,'file'))
                if isfield(dop,'dir') && ~isempty(dop.dir) && exist(dop.dir,'dir')
                    dop.tmp.mat_dir = dop.dir;
                    msg{end+1} = sprintf(['''mat_dir'' empty, using ''dop.dir'''...
                        'for .mat file directory: %s'],dop.dir);
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                elseif isfield(dop,'fullfile') && ~isempty(dop.fullfile)
                    dop.tmp.mat_dir = dop.fullfile(...
                        1:strfind(dop.fullfile,tmp_file)-1);
                else
                    okay = 0;
                    msg{end+1} = sprintf(['Can''t find ''dop.dir'' or'...
                        '''dop.fullfile'' to get .mat save directory.\n\t(%s)'],...
                        mfilename);
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                end
            end
            if okay && isfield(dop.tmp,'mat_fullfile') && isempty(dop.tmp.mat_fullfile);
                dop.tmp.mat_fullfile = fullfile(dop.tmp.mat_dir,dop.tmp.mat_file);
            end
            if okay
%                 dop.tmp.save_variables = {'data','file_info'};
                dop_mat = [];
                for i = 1 : numel(dop.tmp.save_variables)
                    dop_mat.(dop.tmp.save_variables{i}) = dop.(dop.tmp.save_variables{i});
                end
                save(dop.tmp.mat_fullfile,'dop_mat');
                msg{end+1} = sprintf('''.mat'' file saved:\n\t%s',dop.tmp.mat_fullfile);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
        end
        
        %% set outputs
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end
