function [dop,okay,msg] = dopMATsave(dop_input,okay,msg,varargin)
% dopOSCCI3: dopMATsave
%
% notes:
% saves dop structure to a '.mat' file which is. This allows for
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
% Last edit:
% 19-Aug-2014 NAB

dop = [];
if ~exist('okay','var') || isempty(okay)
    okay = 0;
end
if ~exist('msg','var')
    msg = [];
end
msg{end+1} = sprintf('Run: %s',mfilename);

try
    dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
    %% inputs
    inputs.turnOff = {'comment'};
    inputs.varargin = varargin;
    inputs.defaults = struct(...
        'fullfile',[], ... %
        'dir',[] ... 
        );
    inputs.required = [];
    [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
    
    switch dopInputCheck(dop_input)
        case 'dop'
            fprintf('> ''dop'' structure input recognised:\n');
            dop = dop_input;
            [dop,okay,msg] = save_dop(dop,okay,msg);
        case dopFileTypes
            [dop,okay,msg] = dopImport(dop_input,okay,msg);
            okay = save_dop(dop);
        otherwise
            msg{end+1} = '> input not recognised:';
            if dop.tmp.comment; fprintf('\t%s\n',msg{end}); end
    end
    if okay
        msg = '''.mat'' file saved.';
    end
    fprintf('%s\n\n',msg);
    
    %% set outputs
    dop.okay = okay;
    dop.msg = msg;
    
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end
function [dop,okay,msg] = save_dop(dop,okay,msg)
try
    if okay
        % note: file_name_loc = file name location (full path)
        if isfield(dop,'fullfile');
            [~,~,tmp_ext] = fileparts(dop.fullfile);
            dop.mat.fullfile = strrep(dop.fullfile,'.mat',tmp_ext); % minus extension
            save(dop.mat.fullfile,'dop');
            msg{end+1} = sprintf('\t''.mat'' file save:\n\t%s\n',dop.mat.fullfile);
            if dop.tmp.comment; fprintf('\t%s\n',msg{end}); end
        else
            okay = 0;
        end
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end