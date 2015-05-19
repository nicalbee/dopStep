function [input_type,okay,msg] = dopInputCheck(dop_input,varargin)
% dopOSCCI3: dopInputCheck ~ 16-Dec-2013 (last edit)
%
% notes:
% basic structure of a function to save time when creating a new one
%
% * not yet implemented (07-Aug-2013)
%
% Use:
%
% [input_type, okay, msg] = dopInputCheck(dop_input);
%
% where:
% > Inputs:
% - dop_input = dopOSCCI structure or doppler data file or data folder
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - input_type =
%   > 'dop' = dopOSCCI matlab structure
%   > 'data' = 'TX/TW','EXP','MAT' files
%   *> 'folder = data directory
%   > 'other' = not recognised for dopOSCCI processing
%
% - okay = logical (0 or 1) okay for dopOSCCI to use
% - msg = string describing whether input known or unknown to dopOSCCI
%
% Created: 07-Aug-2013 NAB
% Edits:
% 05-Sep-2014 NAB folder input given the okay = 1
% 10-Nov-2014 NAB added '.txt' to acceptable inputs
% 20-May-2015 NAB changed 'folder' to 'dir' as input - more intuitive

input_type = [];
okay = 0;
msg = {sprintf('Run: %s',mfilename)};
try
    comment = 0;
    if ~isempty(varargin) %~exist('comment','var') && isempty(comment)
        comment = varargin{1};
    end
    if comment; dopOSCCIindent; end%fprintf('Running %s\n',mfilename);
    
    %% default settings
    input_type = 'other';
    
    msg{end+1} = 'Input is not known to dopOSCCI';
    % known data file types
    file_types = dopFileTypes;
    
    %% check input
    % check if the 'dop' structure has been included:
    if ~exist('dop_input','var')
        input_type = 'no_input';
        okay = 0;
    elseif iscell(dop_input)
        input_type = 'msg';
        okay = 1;
    elseif isstruct(dop_input) && isfield(dop_input,'struc_name') && strcmp(dop_input.struc_name,'dop')
        input_type = 'dop';
        okay = 1;
    elseif isstruct(dop_input)
        input_type = 'dop'; % maybe...
        msg{end+1} = 'Might be dopOSCCI structure - not sure';
        if comment; fprintf('\t%s\n',msg{end}); end;
        okay = 1;
    elseif isnumeric(dop_input)
        if numel(dop_input) == 1
            input_type = 'number';
            okay = 1;
        elseif isvector(dop_input)
            input_type = 'vector';
            okay = 1;
        elseif ismatrix(dop_input)
            input_type = 'matrix';
            okay = 1;
        end
    elseif exist(dop_input,'file') == 2
        % get the file parts - most important is extension
        try
            [~,~,tmp_ext] = fileparts(dop_input);
        catch
            [tmp_dir,tmp_file,tmp_ext] = fileparts(dop_input);
        end
        clear tmp_dir tmp_file
        
        % check if the extension is known:
        switch tmp_ext
            case file_types
                input_type = 'file';%tmp_ext;
                okay = 1;
            case '.txt'
                input_type = 'file';
                okay = 1; % could be a text file
            otherwise
                % maybe it's one of the old Multidop files...
                if numel(tmp_ext) == 4
                    switch  tmp_ext(1:3)
                        case '.TX'
                            input_type = '.TX'; okay = 1;
                        case '.TW'
                            input_type = '.TW'; okay = 1;
                    end
                    % note: used text here rather than reference file_types
                    % variable in case that is changed
                end
        end
        
    elseif exist(dop_input,'dir') == 7
        okay = 1;
        input_type = 'dir';%'folder';
        % note: not sure what we'll do with this yet (7-Aug-2013) so not
        % okay at this stage
        % 05-Sep-2014 needed for the dopGetFileList function NAB
        
        
    end
    
    if okay
        msg{end+1} = strrep(msg,'not','');
    end
    if comment; fprintf('\t%s\n\tinput type = %s\n',msg{end},input_type); end
    
    %% set outputs
    %     varargout{1} = input_type;
    %     varargout{2} = okay;
    %     varargout{3} = msg;
    
    if comment; dopOSCCIindent('done'); end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end