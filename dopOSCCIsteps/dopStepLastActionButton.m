% dopOSCCI3: dopStepLastActionButton
%
% dopStep gui internal function script
%
% notes:
% finds the last 'action' button in the settings sequences for reference
% against which other this can be inserted.

function num = dopStepLastActionButton(dop)

if sum(ismember(dop.step.action.tag,'save'))
    num = diff([find(ismember(dop.step.action.tag,'save')),numel(dop.step.action.string)])-1;
else
    num = diff([find(ismember(dop.step.action.tag,'lI')),numel(dop.step.action.string)])-1;
end