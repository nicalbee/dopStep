function dop = dopHistory(dop)
% dopOSCCI3: dopHistory ~ 17-Dec-2013 (last edit)
%
% notes:
% keep a record of what processing has been done
%
%
% Use:
%
% dop = dopHistory(dop);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
%
% Created: 17-Dec-2013 NAB
% Edits:
% 13-Oct-2015 NAB: renamed to dopHistory

try
    fprintf('\nRunning %s:\n',mfilename);
    tmp  =  dbstack;
    invoking_mfile  =  tmp(2).name;
    dop.hist.last = invoking_mfile;
    % keep a record of everything that's been run... be nice if I could
    % collect the inputs as well... actually, wouldn't be too hard to move
    % the varargin to this function and save a copy as well... *
    if ~isfield(dop.hist,'steps')
        dop.hist.steps = [];
    end
    dop.hist.hist{end+1} = invoking_mfile; % add to this each time
    % count the steps
    if ~isfield(dop.hist,'count')
        dop.hist.count = 0;
    end
    dop.hist.count = dop.hist.count + 1; % counter
    fprintf('\n');
    
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end