function dop = dopStepSettings(h,move_direction)
% dopOSCCI3: dopStepSettings
%
% notes:
% dopOSCCI step settings/information for each step
%
% Use:
%
% dop.steps = dopStepSettings;
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
%
% Created: 14-Oct-2015 NAB
% Edits:
% 15-Oct-2015 NAB plugging away

try
    fprintf('\nRunning %s:\n',mfilename);
    
    % an order will need to be generated but I'm thinking of having a
    % switch for different steps to a structure variable with a generic set
    % of options to drive the different components required for each step
    
    %% get dop structure
    dop = get(h,'UserData');
    
    %% define list of steps
    
    dop.step.steps = ...
        {'welcome','definition'};
    %% movement
    if isfield(dop.step,'current')
        dop.step.previous = dop.step.current;
    end
    if ~isfield(dop.step,'current') || ~isfield(dop.step.current,'name') || isempty(dop.step.current.name)
        dop.step.current.name = dop.step.steps{1};
    end
    dop.step.current.n = find(ismember(dop.step.current.name,dop.step.steps));
    if isempty(dop.step.current.n)
        save(dopOSCCIdebug);
        error('Can''t find current step in options: %s',dop.step.current);
    else
        switch move_direction
            case 'move_back'
                if dop.step.current.n == 1
                    dop.step.next.n = dop.step.current.n;
                    if ~isfield(dop.step,'previous') || dop.step.previous.n == dop.step.current.n
                        fprintf('First step - can''t move back\n');
                    end
                else
                    dop.step.next.n = dop.step.current.n - 1;
                end
            case 'move_next'
                if dop.step.current.n == numel(dop.step.steps)
                    fprintf('Last step - can''t move forward\n');
                    dop.step.next.n = dop.step.current.n;
                else
                    dop.step.next.n = dop.step.current.n + 1;
                end
            case 'start'
                dop.step.next.n = 1;
        end
    end
    %% settings details
    if dop.step.next.n ~= dop.step.current.n || dop.step.next.n == 1
        dop.step.next.name = dop.step.steps{dop.step.next.n};
        switch dop.step.next.name
            case 'welcome'
                %% - information text field
                dop.step.next.style = {'text'};
                dop.step.next.string = {'Welcome'};
                dop.step.next.tag = {'info'};
                dop.step.next.position = [.2 .7 .6 .2];
            case 'definition'
                dop.step.next.style = {'text'};
                dop.step.next.string = {...
                    ['Let''s start by definining a few parameters for ',...
                    'your data']};
                dop.step.next.tag = {'info'};
                dop.step.next.position = [.2 .7 .6 .2];
        end
    end
    dopStepUpdate(dop);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end