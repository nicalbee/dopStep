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
% 28-Oct-2015 NAB fixed progression button function

try
    fprintf('\nRunning %s:\n',mfilename);
    
    % an order will need to be generated but I'm thinking of having a
    % switch for different steps to a structure variable with a generic set
    % of options to drive the different components required for each step
    
    %% get dop structure
    dop = get(h,'UserData');
    
    %% define list of steps
    
    dop.step.steps = ...
        {'welcome','data_file','task_name','definition'};
    %% movement
    if isfield(dop.step,'current')
        dop.step.previous = dop.step.current;
    end
    if ~isfield(dop.step,'current') || ~isfield(dop.step.current,'name') || isempty(dop.step.current.name)
        dop.step.current.name = dop.step.steps{1};
    end
    dop.step.current.n = find(ismember(dop.step.steps,dop.step.current.name));
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
       % default settings
        dop.step.next.name = dop.step.steps{dop.step.next.n};
        dop.step.next.info_position = [.2 .75 .6 .2];
        dop.step.next.HorizontalAlignment = {'left'};
        switch dop.step.next.name
            case 'welcome'
                %% - information text field
                dop.step.next.style = {'text'};
                dop.step.next.string = {['Welcome to dopOSCCI. ',...
                    'This is a step through guide for summarising ',...
                    'functional Transcranial Doppler Ultrasound (fTCD) data. ',...
                    'Make sure you can read this text (increase ',...
                    'font size with the ''+'' button below) and then ',...
                    'click on the ''next'' button to get started.']};
                dop.step.next.tag = {'info'};
                dop.step.next.position = dop.step.next.info_position;
                case 'data_file'
                dop.step.next.style = {'text','edit','edit','pushbutton',...
                    'text','text'};
                dop.step.next.string = {...
                    ['We''ll start by importing an fTCD file. Use the ',...
                    'options below to type the full path of the file (i.e., folder ',...
                    'and file name) or use ',...
                    'pushbutton to browse for the file.'],...
                    'Data file:','empty','Browse',...
                    ['Now that you''ve got a file, try importing it ',...
                    'by clicking the import pushbutton'],...
                    ['If the data imported okay, you should be able ',...
                    'to have a look at it with the plot pushbutton. ',...
                    'Bear in mind that you will need to adjust the ',...
                    'y-axis to about 200 to see the data. Adjusting ',...
                    'x-axis to 10 seconds will allow you to see the ',...
                    'heart beats.']};
                if isfield(dop,'file') && exist(dop.file,'file')
                    dop.step.next.string{3} = dop.file;
                end
                dop.step.next.tag = {'info','data_file_text','data_file','data_file_browse',...
                    'import_text','plot_text'};
                dop.step.next.position = [dop.step.next.info_position;
                    .05 .65 .1 .1; .15 .65 .7 .1; .85 .65 .1 .1;
                    .2 .5 .6 .1;.1 .25 .8 .2];
                dop.step.next.HorizontalAlignment = {'left','center','center','center','left','left'};
                dop.step.next.Enable = {[],'off','on','on',[],[]};
                dop.step.next.Callback = {[],[],[],'dopStepBrowseFile',[],[]};
                dop.step.next.Visible = {'on','on','on','on','off','off'};
            case 'task_name'
                dop.step.next.style = {'text','edit','edit'};
                dop.step.next.string = {...
                    ['Let''s give the task a name. This will ', ...
                    'be used for labelling folders and variables. Please ', ...
                    'make sure it doesn''t have any spaces.'],...
                    'Task Name:','dopplerTask'};
                dop.step.next.tag = {'info','task_name_text','task_name'};
                dop.step.next.position = [dop.step.next.info_position;
                    .3 .5 .2 .1; .5 .5 .2 .1];
                dop.step.next.HorizontalAlignment = {'left','center','center'};
                dop.step.next.Enable = {[],'off','on'};
                dop.step.next.Callback = {[],[],'dopStepGetDef'};
            case 'definition'
                dop.step.next.style = {'text'};
                dop.step.next.string = {...
                    ['Let''s start by definining a few parameters for ',...
                    'your data']};
                dop.step.next.tag = {'info'};
                dop.step.next.position = dop.step.next.info_position;
        end
    end
    dopStepUpdate(dop);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end