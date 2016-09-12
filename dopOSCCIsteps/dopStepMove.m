function dopStepMove(button_handle,~,option)
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
%   2015-Nov-30 NAB pulled movement code back in here
% 03-Aug-2016 NAB set move to stop at 'finished' tab

% options:
% 14-Oct-2015 NAB consider doing for all font information - currently very
%   specifc for stepInfo text object but could save a set of handles, e.g.,
%   dop.step.font.h(1:n), and adjust all in one hit
%   > do this by saving the 'dop' field into the figure 'UserData'
try
    % probably don't want to report function name eventually
    fprintf('\nRunning %s: %s button\n',mfilename, get(button_handle,'tag'));
    %     if exist('move_direction','var') && isempty(move_direction)
    move_direction =  get(button_handle,'tag');
    %     end
    %     case 'move_back'
    %
    %         case 'move_next'
    %
    % end
    if ~exist('option','var') || isempty(option)
        option = '';
    end
    steps = 1; % return dop.step.steps list from dopStepSettings
    dop = dopStepSettings(get(button_handle,'parent'),steps);
    fprintf('\tSetting up: %s\n',dop.step.next.name);
    %% movement
    if isfield(dop.step,'current')
        dop.step.previous = dop.step.current;
    end
    if ~isfield(dop.step,'current') || ~isfield(dop.step.current,'name') || isempty(dop.step.current.name)
        dop.step.current.name = dop.step.steps{1};
    end
    dop.step.current.n = find(ismember(dop.step.steps,dop.step.current.name));
    if isfield(dop.step,'next')
        dop.step = rmfield(dop.step,'next');
    end
    if isempty(dop.step.current.n)
        save(dopOSCCIdebug);
        error('Can''t find current step in options: %s',dop.step.current.name);
    else
        switch move_direction
            case 'move_back'
                if dop.step.current.n == 1
                    dop.step.next.n = dop.step.current.n;
                    if ~isfield(dop.step,'previous') || dop.step.previous.n == dop.step.current.n
                        fprintf('First step - can''t move back\n');
                        return % 07-Dec-2015 NAB no need to do anything
                    end
                else
                    dop.step.next.n = dop.step.current.n - 1;
                end
            case 'move_next'
                %                 if dop.step.current.n == numel(dop.step.steps)-2
                if dop.step.current.n == find(ismember(dop.step.steps,'finished'))
                    fprintf('Last step - can''t move forward\n');
                    return % 07-Dec-2015 NAB no need to do anything
                    %                     dop.step.next.n = dop.step.current.n;
                else
                    dop.step.next.n = dop.step.current.n + 1;
                end
            case 'start'
                dop.step.next.n = 1;
        end
    end
    
    %% pass data back to figure
    set(get(button_handle,'Parent'),'UserData',dop);
    dopStepSettings(get(button_handle,'parent'));
catch err
    save(dopOSCCIdebug);rethrow(err);
end