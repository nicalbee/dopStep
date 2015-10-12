function dop = dopStep
% dopOSCCI3: dopStep ~ 13-Oct-2015
%
% notes:
% step through gui to teach dopOSCCI steps
%
% Use:
%
% dop = dopStep;
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
%
% Created: 13-Oct-2015 NAB
% Edits:
%

try
    fprintf('\nRunning %s:\n',mfilename);
    dop.step.h = figure;
    % welcome/instruction
    dop = dopStepWelcome(dop);
    
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end