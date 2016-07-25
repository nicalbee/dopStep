function dop = dopStepSettings(h,steps)
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
% 02-Dec-2015 NAB adjusting for optional buttons

try
    fprintf('\nRunning %s:\n',mfilename);
    
    % an order will need to be generated but I'm thinking of having a
    % switch for different steps to a structure variable with a generic set
    % of options to drive the different components required for each step
    
   
    %% get dop structure
    dop = get(h,'UserData');
    
        %% define list of steps
     dop.step.steps = {'welcome'};
     dop.step.steps(end+1:end+numel(dop.step.action.string)) = lower(dop.step.action.string);%...;%...
%         {'welcome','data_file','channels','event',...
%         'timing'}; %,'downsample','definition','task_name'
%     dop.step.action.string = {'Import','Channels','Events','Norm',...
%         'Heart','Epoch','Screen','Baseline','LI'}; % ,'Plot'
    
    dop.step.steps_optional = lower(dop.step.option.string);%...
%         {'downsample','trim'};
    dop.step.optional = 0;
    if exist('steps','var') && ~isempty(steps) && isnumeric(steps) && steps
        % just make sure we have the steps variable to work with
        set(h,'UserData',dop);
        return
    elseif exist('steps','var') && ~isempty(steps) && ~isnumeric(steps)
        switch steps
            case 'start'
                dop.step.next.n = 1;
                dop.step.current.n = 0;
            case dop.step.steps_optional
                fprintf('Optional step: ''%s''\n',steps);
                dop.step.optional = 1;
                dop.step.next.name = steps;
            otherwise
                dop.tmp.warn = sprintf('''%s'' step not recognised. Aborting',steps);
                fprintf('%s\n',dop.tmp.warn);
                warndlg(dop.tmp.warn,'Unknown step')
                return
        end
    end

    %% settings details
    if dop.step.optional || dop.step.next.n ~= dop.step.current.n || dop.step.next.n == 1
        % default settings
        dop.step.next.name = dop.step.steps{dop.step.next.n};
        dop.step.next.left_pos = .15;
        dop.step.next.title_position = [dop.step.next.left_pos .87 .7 .1];
        dop.step.next.info_position = [dop.step.next.left_pos .7 .7 .2];
        dop.step.next.HorizontalAlignment = {'left','left'};
        switch dop.step.next.name
%% > welcome:
            case 'welcome'
                %% - information text field
                dop.step.next.style = {'text','text'};
                dop.step.next.string = {'Welcome to dopOSCCI!',...
                    ['This is a step through guide for summarising ',...
                    'functional Transcranial Doppler Ultrasound (fTCD) data. ',...
                    'Make sure you can read this text (increase ',...
                    'font size with the ''+'' button below) and then ',...
                    'click on the ''next'' button to get started.']};
                dop.step.next.tag = {'title','info'};
                dop.step.next.position = [dop.step.next.title_position;...
                    dop.step.next.info_position];
                %% >> import:
            case 'import'
                dop.step.next.style = {'text','text','edit','edit','pushbutton',...
                    'text','text'};
                dop.step.next.string = {'Import data:',...
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
                dop.step.next.tag = {'title','info','data_file_text','data_file','data_file_browse',...
                    'import_text','plot_text'};
                dop.step.next.position = [dop.step.next.title_position;...
                    dop.step.next.info_position;
                    dop.step.next.left_pos .65 .1 .1; ...
                    dop.step.next.left_pos+.1 .65 .5 .1;...
                    dop.step.next.left_pos+.1+.5 .65 .1 .1;
                    dop.step.next.left_pos .5 .6 .1;...
                    dop.step.next.left_pos .25 .8 .2];
                dop.step.next.HorizontalAlignment = [dop.step.next.HorizontalAlignment,{'center','center','center','left','left'}];
                dop.step.next.Enable = {[],[],'off','on','on',[],[]};
                dop.step.next.Callback = {[],[],[],[],'dopStepBrowseFile',[],[]};
                dop.step.next.Visible = {'on','on','on','on','on','off','off'};
            case 'channels'
                
                dop.step.next.style = {'text','text','edit','popup',...
                    'edit','popup','edit','popup','text'};
                % create channel lists for dropdown/popup menu
                dop.step.next.ch_list = [];
                if isfield(dop,'data') && isfield(dop.data,'use')
                for k = 1 :  size(dop.data.use,2)
                    dop.step.next.ch_list{k} = sprintf('column_%u',k);
                    if isfield(dop.data,'file_info') && isfield(dop.data.file_info,'dataLabels') ...
                            && numel(dop.data.file_info.dataLabels) >= k
                        if size(dop.data.use,2) < numel(dop.data.file_info.dataLabels)
                            dop.step.next.ch_list{k} = dop.data.channel_labels{k};
                        else
                            dop.step.next.ch_list{k} = dop.data.file_info.dataLabels{k};
                        end
                    end
                end
                else
                    dop.step.next.ch_list = {'empty'};
                end
                dop.step.next.string = {'Data channels:',...
                    ['For fTCD data, we need to know which data column ',...
                    'should be treated as the left, right, and event ',...
                    'channels. Please select these from the available ',...
                    'columns. Then push the ''Channels'' button to extract ',...
                    'these from the rest of the data.'],...
                    'Left:',dop.step.next.ch_list,'Right:',dop.step.next.ch_list,...
                    'Event:',dop.step.next.ch_list,...
                    ['If the data channels were extracted correctly, ',...
                    ' you should be able to have a look at them with ',...
                    'the plot pushbutton.']};
%                 if isfield(dop,'file') && exist(dop.file,'file')
%                     dop.step.next.string{3} = dop.file;
%                 end
                dop.step.next.tag = {'title','info','left_text','left_channel',...
                    'right_text','right_channel',...
                    'event_text','event_channel','ch_plot_text'};
                dop.step.next.position = [dop.step.next.title_position;...
                    dop.step.next.info_position; ...
                    .2 .7 .1 .05; .3 .65 .3 .1; ...
                    .2 .55 .1 .05; .3 .5 .3 .1; ...
                    .2 .4 .1 .05; .3 .35 .3 .1;
                    .1 .25 .8 .1];
                dop.step.next.HorizontalAlignment = [dop.step.next.HorizontalAlignment,{'center','center','center','center','center','center','left'}];
                dop.step.next.Enable = {[],[],'off','on','off','on','off','on','off'};
                dop.step.next.Visible = {'on','on','on','on','on','on','on','on','off'};
                dop.step.next.Callback = {[],[],[],'dopStepGetChannel',...
                    [],'dopStepGetChannel',[],'dopStepGetChannel',[]};
                %% downsample
            case 'downsample'
                dop.step.next.style = {'text','text','text','edit','edit'};
                dop.step.next.string = {'Downsample data:',...
                    'This is an optional step - feel free to skip.',...
                    ['Functional Transcranial Doppler Ultrasound (fTCD) data is ',...
                    'often recorded at 100 Hertz (100 samples be second) = ',...
                    'one piece of information every 10 milliseconds. ',...
                    'Traditionally, fTCD data has been downsampled - ',...
                    ' every 4th data point retained and the rest excluded. ',...
                    ' There are 2 reasons for this. 1) Historically ',...
                    'computers didn''t have the processing ',...
                    'power to deal with this much data - not now a ',...
                    'limitation. 2) 10 millisecond accuracy is unnecessary ',...
                    'when analysing signals that occur over multiple seconds.'],...
                    'Downsample','type number'};
                dop.step.next.tag = {'title','info','downsample_hist','downsample_text','downsample_rate'};
                dop.step.next.position = [dop.step.next.title_position;...
                    dop.step.next.info_position;
                    .1 .55 .8 .3;...
                    .3 .4 .2 .1; .5 .4 .2 .1];
                dop.step.next.HorizontalAlignment = [dop.step.next.HorizontalAlignment,{'left','center','center'}];
                dop.step.next.Enable = {[],[],[],'off','on'};
                dop.step.next.Callback = {[],[],[],[],'dopStepGetDef'};
            case 'events'
                dop.step.next.style = {'text','text','edit','edit','text','edit','edit','text'};
                dop.step.next.string = {'Event markers:',...
                    ['To determine the timing of the event markers, ',...
                    'we need to separate the event markers from noise. ',...
                    'To do this, the function will assume that data in ',...
                    'the event channel above a certain height ',...
                    '(e.g., 1000) is an event. If you''re unsure, ',...
                    'have a look at the y-value ',...
                    'of your event markers in the plot.'],...
                    'Event Height:','type a number',...
                    ['You can also enter the expected separation (in seconds) ',...
                    'between event markers. If you do, the function will ',...
                    'indicate whether you have any outliers which might be ',...
                    'cause for you to manually exclude them (see dopEpochScreenManual.m).'],...
                    'Event Separation:','type a number',...
                    ['If you have a look at the ''Plot'' now, you should see that ',...
                    'there are only 3 data channels available.']};
                dop.step.next.tag = {'title','info','event_height_text','event_height',...
                    'event_sep_info','event_sep_text','event_sep','event_chan_plot_info'};
                dop.step.next.position = [dop.step.next.title_position;...
                    dop.step.next.info_position;
                    dop.step.next.left_pos .6 .2 .1; dop.step.next.left_pos+.2 .6 .2 .1;... 'event_height_text','event_height'
                    dop.step.next.left_pos .4 .7 .15;...  'event_sep_info'
                    dop.step.next.left_pos .275 .2 .1; dop.step.next.left_pos+.2 .275 .2 .1;... %'event_sep_text','event_sep'
                    dop.step.next.left_pos .15 .7 .075];% 'event_chan_plot_info']; 
                dop.step.next.HorizontalAlignment = [dop.step.next.HorizontalAlignment,...
                    {'center','center','left','center','center','left'}];
                dop.step.next.Enable = {[],[],'off','on','on','off','on','off'};
                dop.step.next.Callback = {[],[],[],'dopStepGetDef',[],[],'dopStepGetDef',[]};
            case 'norm'
                dop.step.next.style = {'text','text','edit','radio',...
                    'text','edit','edit','edit',...
                    'text','edit','edit','edit'};
                dop.step.next.string = {'Data Normalisation:',...
                    ['When measuring blood flow velocity bilaterally ',...
                    '(i.e., on the left and right sides of the head), ',...
                    'it is likely that the insonation angle for each probe ',...
                    'will be different, resulting in differing overall ',...
                    'activation levels between sides. In order to correct ',...
                    'for this, we set the average of the two channels to the ',...
                    'same value. There are three ways to do this with ',...
                    'specific requirements and strengths/weaknesses.'],...
                    'Method:',{'overall','epoch','deppe'},...
                    ['Normalisation by the ''epoch'' or ''deppe'' methods ',...
                    'requires to lower and upper time points of the epoch ',...
                    'period to be defined. These are the time points, ',...
                    'relative to the event marker over which the data is ',...
                    'processed. Word Generation is typically -15 to 25 seconds.'],...
                    'Epoch:','type lower number','type upper number',...
                    ['Normalisation by the ''deppe'' method ',...
                    'requires to lower and upper time points of the baseline ',...
                    'period to be defined. These are the time points, ',...
                    'relative to the event marker over which activity is ',...
                   'compared. Generally considered to be a period of non ',...
                   'or control condition behaviour. ',...
                    'Word Generation is typically 5 to 15 seconds.'],...
                    'Baseline:','type lower number','type upper number',...
                    };
                dop.step.next.tag = {'title','info','norm-method_text','norm-method_radio',...
                'epoch_info','epoch_text','epoch_lower','epoch_upper',...
                'baseline_info','baseline_text','base_lower','base_upper'};
            dop.step.next.pos_ht = .1;
                dop.step.next.position = [dop.step.next.title_position;...
                    dop.step.next.info_position;
                    dop.step.next.left_pos .65 .2 dop.step.next.pos_ht; ... % method_text
                    dop.step.next.left_pos+.225 .65 .425 dop.step.next.pos_ht; ... % method_radio
                    dop.step.next.left_pos .475 .7 dop.step.next.pos_ht*1.5; ... % epoch_info
                    dop.step.next.left_pos .4 .2 dop.step.next.pos_ht; ... % epoch_text
                    dop.step.next.left_pos+.225 .4 .2 dop.step.next.pos_ht; ... % epoch_lower
                    dop.step.next.left_pos+.45 .4 .2 dop.step.next.pos_ht; ... % epoch_upper
                    dop.step.next.left_pos .225 .7 dop.step.next.pos_ht*1.5; ... % baseline_info
                    dop.step.next.left_pos .15 .2 dop.step.next.pos_ht; ... % baseline_text
                    dop.step.next.left_pos+.225 .15 .2 dop.step.next.pos_ht; ... % baseline_lower
                    dop.step.next.left_pos+.45 .15 .2 dop.step.next.pos_ht];% ... % baseline_upper
                    
                dop.step.next.HorizontalAlignment = [dop.step.next.HorizontalAlignment,...
                    {'center','center',...
                    'left','center','center','center',...
                    'left','center','center','center'}];
                dop.step.next.Enable = {[],[],...
                    'off','off',...
                    [],'off','off','off',...
                    [],'off','off','off'};
                dop.step.next.visible = {'on','on',...
                    'on','on',...
                   'off','off','off','off',...
                    'off','off','off','off'};
                dop.step.next.Callback = {[],[],...
                    [],'dopStepGetDef',...
                    [],[],'dopStepGetDef','dopStepGetDef',...
                    [],[],'dopStepGetDef','dopStepGetDef'};
            %% > heart cycle integration
            case 'heart'
                dop.step.next.style = {'text','text',...
                    'text','text','text','checkbox'};
                dop.step.next.string = {'Heart Cycle Integration:',...
                    ['Michael Deppe tested many different methods for ',...
                    'cleaning up the blood flow velocity signal and ',...
                    'found that removing the ''heart cycle'' (ie ',...
                    'heart beat patterns) using a ''step function'' was ',...
                    'best.'],...
                    'The step function:',...
                    ['The step function simply involves finding the peaks ',...
                    'of the heart beats and taking the average between ',...
                    'these points. Due to changes in velocity ',...
                    'over time, the result looks like a staircase going ',...
                    'up or down.'],...
                    ['You can explore what this looks like by viewing the ',...
                    'plot within this step. Check the box below to do this.'],...
                    'View step function'};
                dop.step.next.tag = {'title','info','title2','info2','info3',...
                    'plot_check'};
                
                dop.step.next.position = [dop.step.next.title_position;... [dop.step.next.left_pos .87 .7 .1];
                    dop.step.next.info_position;... [dop.step.next.left_pos .7 .7 .1];
                    dop.step.next.left_pos .65 .7 .05; ... % title2
                    dop.step.next.left_pos .45 .7 .2; ... % info 2
                    dop.step.next.left_pos .4 .7 .05; ... % info 3
                    dop.step.next.left_pos .35 .5 .05; ... % plot_check
                    ]; %title2
                dop.step.next.HorizontalAlignment = [dop.step.next.HorizontalAlignment,...
                    {'left','left','left','left'}];
                dop.step.next.Enable = {[],[],[],[],[],'on'};

                dop.step.next.visible = {'on','on',...
                    'on','on','on','on'};
                dop.step.next.Callback = {[],[],[],[],[],'dopStepGetDef'};
            case 'timing'
                dop.step.next.size = [.2 .05];
                dop.step.next.options = {'epoch','base','poi'};
                dop.step.next.colours = {[.9 .9 0],[0 0 0],[.2 .7 .1]};%{'y','k','g'};
                dop.step.next.style = {'text','text','text','text',...
                    'edit','edit','edit','text',...
                    'edit','edit','edit','text',...
                    'edit','edit','edit','text',...
                    'axes'};
                dop.step.next.string = {'Period timing:',...
                    ['Now we''ll define some of the timing for the processing. ',...
                    'Epoch = limits of the data around the event marker. ',...
                    'Baseline = limits of the data to be used for baseline correction. ',...
                    'Period of interest = limits within which the laterality index is calculated. '],...
                    'Lower','Upper',...
                    'Epoch','type a number','type a number',[],...
                    'Baseline','type a number','type a number',[],...
                    'Period of Interest','type a number','type a number',[],...
                    []};
               
                dop.step.next.tag = {'title','info','lower_text','upper_text',...
                    'epoch_text','epoch_lower','epoch_upper','epoch_col',...
                    'base_text','base_lower','base_upper','base_col',...
                    'poi_text','poi_lower','poi_upper','poi_col',...
                    'timing_plot'};
                dop.step.next.col = cell(1,numel(dop.step.next.tag));
                 dop.step.next.lims = {'lower','upper'};
                for i = 1 : numel(dop.step.next.options)
                    dop.tmp.tag = sprintf('%s_col',dop.step.next.options{i});
                    dop.step.next.col{ismember(dop.step.next.tag,dop.tmp.tag)} = dop.step.next.colours{i};
                    for j = 1 : numel(dop.step.next.lims)
                        if isfield(dop,'def') && isfield(dop.def,dop.step.next.options{i})
                            dop.tmp.tag = sprintf('%s_%s',dop.step.next.options{i},dop.step.next.lims{j});
                            dop.step.next.string{ismember(dop.step.next.tag,dop.tmp.tag)} = ...
                                num2str(dop.def.(dop.step.next.options{i})(j));
                        end
                    end
                end
                dop.step.next.position = [dop.step.next.title_position;...
                    dop.step.next.info_position;
                                 .35 .6 .2 .1; .6 .6 .2 .1;...
                    .1 .6 dop.step.next.size; .35 .6 dop.step.next.size; .6 .6 dop.step.next.size; .85 .6 .05 .05;...
                    .1 .525 dop.step.next.size; .35 .525 dop.step.next.size; .6 .525 dop.step.next.size; .85 .525 .05 .05;...
                    .1 .45 dop.step.next.size; .35 .45 dop.step.next.size; .6 .45 dop.step.next.size; .85 .45 .05 .05;...
                    .1 .3 .8 .125];
                dop.step.next.HorizontalAlignment = [dop.step.next.HorizontalAlignment,{'center','center',...
                    'center','center','center','left',...
                    'center','center','center','left',...
                    'center','center','center','left',[]}];
                dop.step.next.Enable = {[],[],[],[],'off','on','on','on'...
                    'off','on','on','on','off','on','on','on',[]};
                dop.step.next.Callback = {[],[],[],[],...
                    [],'dopStepGetDef','dopStepGetDef',[],...
                    [],'dopStepGetDef','dopStepGetDef',[],...
                    [],'dopStepGetDef','dopStepGetDef',[],[]};
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
                dop.step.next.HorizontalAlignment = [dop.step.next.HorizontalAlignment,{'center'}];
                dop.step.next.Enable = {[],'off','on'};
                dop.step.next.Callback = {[],[],'dopStepGetDef'};
            case 'definition'
                dop.step.next.style = {'text'};
                dop.step.next.string = {...
                    ['Let''s start by definining a few parameters for ',...
                    'your data']};
                dop.step.next.tag = {'info'};
                dop.step.next.position = dop.step.next.info_position;
            otherwise
                dop.step.next.style = {'text'};
                dop.step.next.string = {...
                    sprintf('I''m afraid ''%s'' hasn''t been programmed yet',dop.step.next.name)};
                dop.step.next.tag = {'info'};
                dop.step.next.position = dop.step.next.info_position;
        end
    end
    dopStepUpdate(dop);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end