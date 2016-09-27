%% dopStepDop2workspace
%
% assigns the 'dop' variable from the dopStep gui into the MATLAB workspace
% for interogation.
%
% Created: 02-Sep-2016 NAB

function dopStepDop2workspace
dop = get(gcf,'UserData');
msg = '''dop'' variable sent to the workspace.';
if ~isempty(dop) && isstruct(dop)
    assignin('base','dop',dop);
else
    msg = sprintf('Problem with current figure UserData - %s',...
        strrep(msg,'variable_sent','variable NOT sent'));
end
fprintf('%s\n\n',msg);
msgbox(msg,'''dop'' variable:');