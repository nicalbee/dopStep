function dop = dopStep(dop)
% dopOSCCI3: dopStep ~ 17-Dec-2013 (last edit)
%
% notes:
% keep a record of what processing has been done
%
% * not yet implemented (17-Dec-2013)
%
% Use:
%
% dop = dopStep(dop);
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

try
    fprintf('\nRunning %s:\n',mfilename);
    tmp  =  dbstack;
    invoking_mfile  =  tmp(2).name;
    dop.step.last = invoking_mfile;
    % keep a record of everything that's been run... be nice if I could
    % collect the inputs as well... actually, wouldn't be too hard to move
    % the varargin to this function and save a copy as well... *
    if ~isfield(dop.step,'hist')
        dop.step.hist = [];
    end
    dop.step.hist{end+1} = invoking_mfile; % add to this each time
    % count the steps
    if ~isfield(dop.step,'count')
        dop.step.count = 0;
    end
    dop.step.count = dop.step.count + 1; % counter
    fprintf('\n');
    
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end