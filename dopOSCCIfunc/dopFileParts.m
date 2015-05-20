function [dop,okay,msg] = dopFileParts(dop_input,varargin)
% dopOSCCI3: dopFileParts
%
% notes:
% extract:
% - data directory
% - file name
% - extension
%
% * not yet implemented (07-Aug-2013)
%
% Use:
%
% dop = dopFileParts(dop_input,[okay],[msg],[doppler data file]);
%
% where:
% > Inputs:
% - dop_inputs = dop matlab structure
%   OR doppler data file (.EXP or .TX/.TF)
%
% - if dop matlab structure, then assumes the second input is a doppler
% data file name. Full path (file name location) is best.
%
% > Outputs:
% - dop = dop matlab sructure
%
%
% Created: 07-Aug-2013 NAB
% Last edit
% 07-Aug-2014 NAB
% 01-Sep-2014 NAB fixed dopSetBasicInputs
% 08-Sep-2014 NAB output issues

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;
        
        switch dopInputCheck(dop_input)
            case 'dop'
                dop = dop_input;
                if numel(varargin) > 0
                    dop_file = varargin{1};
                    okay = 1;
                elseif isfield(dop,'fullfile') && ~isempty(dop.fullfile)
                    dop_file = dop.fullfile;
                    msg{end+1} = '''dop.fullfile'' variable found';
                    fprintf('\t%s\n',msg{end});
                elseif isfield(dop,'file') && ~isempty(dop.file) ...
                        && ~exist(dop.file,'file') ...
                        && isfield(dop,'dir') && ~isempty(dop,'dir')
                    
                    dop_file = fullfile(dop.dir,dop.file);
                    msg{end+1} = sprintf(['Combining ''dop.dir'' and'...
                        ' ''dop.file'': %s'],dop_file);
                    fprintf('\t%s\n',msg{end});
                elseif isfield(dop,'file') && ~isempty(dop.file)
                    dop_file = dop.file;
                    msg{end+1} = '''dop.file'' variable found - we''ll see if it works';
                    fprintf('\t%s\n',msg{end});
                else
                    okay = 0;
                    msg{end+1} = 'Can''t find file information in ''dop'' structure';
                    fprintf('\t%s\n',msg{end});
                end
                
            case 'file' %dopFileTypes
                dop_file = dop_input;
                okay = 1;
            otherwise
                msg{end+1} = 'input not recognised';
                    fprintf('\t%s\n',msg{end});
               okay = 0;
        end
        
        
        if ~okay
            msg{end+1} = 'Something not recognised...';
            fprintf('\t%s\n',msg{end});
        else
            [tmp_dir,tmp_file,tmp_ext] = fileparts(which(dop_file));
            if isempty(tmp_ext)
                % might be full file name location (full path)
                % check this - 2014-Aug-07
                [tmp_dir,tmp_file,tmp_ext] = fileparts(dop_file);
            end
            if isTX(dop_file)
                full_ext = tmp_ext;
                tmp_ext = tmp_ext(1:end-1);
            end
            switch tmp_ext
                case dopFileTypes
                    if ~isstruct(dop)
                        dop = [];
                    end
                    dop.dir = tmp_dir;
                    dop.file_ext = tmp_ext;
                    if isTX(dop_file)
                        dop.file_ext = full_ext;
                    end
                    dop.file_name = tmp_file;
                    dop.file = [dop.file_name,dop.file_ext];
                    % fullfile (MATLAB function) creates Operating System
                    % appropriate file path - see help fullfile for more
                    % details.
                    % in current case, the tmp_dir variable will be
                    % appropriately delineated from the file name [with
                    % extension] to provide the full path for the file.
                    dop.fullfile = fullfile(dop.dir,dop.file);
                    okay = 1;
                    msg{end+1} = sprintf('File found: %s',dop.fullfile);
                    fprintf('\t%s\n',msg{end});
                otherwise
                    msg{end+1} = 'File type not recognised or empty';
                    fprintf('\t%s\n',msg{end});
            end
        end
        % set dop info
%         dop.okay = okay;
%         dop.msg = msg;
        dopOSCCIindent('done');
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end