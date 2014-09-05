function dop = dopFunctionHistory(dop_input)
% dopOSCCI3: dopFunctionHistory
%
% Saves a record of which functions have been called/applied to this data
% set.
%
% * not yet implemented (08-Aug-2014)
% save command/call history... like eeglab...
%
% Use:
%
% dop = dopFunctionHistory(dop);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) okay for dopOSCCI to use
% - msg = message about success of function
%
% Created: 08-Aug-2014 NAB & HMP
% Last edit:
% 08-Aug-2014 NAB

try
    dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
    % check if the 'dop' structure has been included:
    switch dopInputCheck(dop_input)
        case 'dop'
            dop = dop_input;
        otherwise
            dop.history = [];
    end
    tmp_stack = dbstack;
    if isfield(dop,'history')
        dop.history{end+1} = tmp_stack(2).name;
    else
        dop.history = tmp_stack(2).name;
    end
    
    dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end