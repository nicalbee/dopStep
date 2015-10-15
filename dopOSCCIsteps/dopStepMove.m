function dopStepMove(button_handle,~)
% dopOSCCI3: dopStepMove
%
% notes:
% move backwards and forwards through dopStep gui steps
%
% Use:
%
% Callback function for dopStep gui
%
% Created: 14-Oct-2015 NAB
% Edits:
%

% options:
% 14-Oct-2015 NAB consider doing for all font information - currently very
%   specifc for stepInfo text object but could save a set of handles, e.g.,
%   dop.step.font.h(1:n), and adjust all in one hit
%   > do this by saving the 'dop' field into the figure 'UserData'
try
    % probably don't want to report function name eventually
    fprintf('\nRunning %s: %s button\n',mfilename, get(button_handle,'tag'));
%     switch get(button_handle,'tag')
%         case 'move_back'
% 
%         case 'move_next'
%             
%     end
    dopStepSettings(get(button_handle,'parent'),get(button_handle,'tag'));
    %% pass data back to figure
%     set(get(button_handle,'Parent'),'UserData',dop);
catch err
    save(dopOSCCIdebug);rethrow(err);
end