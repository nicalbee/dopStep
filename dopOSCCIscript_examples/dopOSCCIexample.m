%% dopOSCCIexample script
% Example summary script for functional Transcranial Doppler Ultrasound
% (fTCD) data using 'DOPOSCCI' MATLAB toolbox

%% clear everything first
clc; % CLear the Command window
clear % clear any existing variables


% create the 'dop' structure variable - this hold everything
% + give it a 'struc_name' variable, used for identification
dop.struc_name = 'dop';

%% Definition Information
% a task_name will be used to automatically name the output files
dop.def.task_name = 'dopOSCCIdemo';

%% > data directory
% default location of demo data:
dop.data_dir = fullfile(getHigherDir,'dopOSCCIdemo_data');

if ~exist(dop.data_dir,'dir')
    dop.tmp.msg = 'Problem with demo data directory - aborting.';
    warndlg(dop.tmp.msg, 'Data Directory not found:');
    return
end

%% > get the file list
% search the dop.data_dir directory for known fTCD files
[dop,okay] = dopGetFileList(dop);
% in.file_list = {'test.exp'};
if ~okay
    dop.tmp.msg = 'Problem with file list.';
    warndlg(dop.tmp.msg, 'Files not found:');
    return
end

% define the columns of the channels to be processing - columns of the data
% file - signal channels [left and right] and event channel
dop.def.signal_channels = [3 4]; % columns in file (e.g., EXP)
dop.def.event_channels = 9; % EXP files

% likely to be slightly different for TX/TX files, keep this code here for
% reference
% dop.def.signal_channels = [1 2]; % columns in file (e.g., .TW/TX)
% dop.def.event_channels = 3; % TX/TW files

dop.def.event_height = 1000; % cm/s values above this will be event makers
dop.def.event_sep = 55; % separation between event markers in seconds
dop.def.num_events = 13; % total number of events

% any downsampling?
dop.def.downsample_rate = 100; % Hertz

%% > Define time periods for processing
% lower and upper values in seconds relative to event makers (ie zero)
dop.def.epoch = [-15 25];
dop.def.baseline = [-15 -5];
dop.def.poi = [5 15];

dop.def.act_window = 2; % duration of activation window

% check for overlap
dop = dopPeriodChecks(dop,'wait_warn',1);

%% > normalisation method
dop.def.norm_method = 'overall'; % or 'epoch'; % or 'deppe';

%% > data screening
% lower and upper bounds of acceptable activation in % change of blow flow
% velocity - usually run this after normalisation (ie average veloctiy set
% to 100).
dop.def.act_range = [50 150];

%% >  activation correction
% sometimes there are extreme values - these can be corrected to be within
% the normal range
dop.def.correct_range = [-3 4]; % lower and upper bounds in standard deviation units
dop.def.correct_pct = 5; % correct if <= x% data outside range, otherwise no correction

%% > activation separation
% as the difference values we're looking for are small, differences greater
% than a certain value are likely due to error.
dop.def.act_separation = 20; % acceptable activation difference
dop.def.act_separation_pct = 1; % reject epoch if <= x% data outside range, otherwise keep

%% > epoch screening
% reject epoch/s if there's:
% - 'length' = not enough data (ie first or last is short)
% - 'act' = activation outside specified range
% - 'sep' = left minus right difference beyond specified value
dop.def.screen = {'length','act','sep'};
% e.g., without sep:
% dop.def.screen = {'length','act'};

% keep copy of proccessing steps, e.g., dop.data.norm, dop.data.down etc.
% always keep raw for resetting
dop.def.keep_data_steps = 1;


%% > save file + location
dop.save.save_file = []; % this will be auto completed based upon the dop.def.task_name variable
[dop,okay,msg] = dopSaveDir(dop);
% or
% dop.save.save_dir = dopSaveDir(dop,'dir_only',1);
% or
% dop.save.save_dir = '/Users/mq20111600/Documents/nData/tmpData';

%% > variables to be saved:
% various information will be save automatically based on
% 'summary','channels','periods','epochs', and 'variables' variables but
% 'extras' can be specified so you can add your own variables. They just 
% need to be defined somewhere as dop.save.x = where x = variable name. For
% example, below is dop.save.extras = {'file'}; so dop.save.file needs to
% be defined somewhere, otherwise the 'file' column in the output file will
% be empty or have a missing value (usually 999)
dop.save.extras = {'file'};
dop.save.summary = {'overall'}; % vs 'epoch'
dop.save.channels = {'Difference'};
dop.save.periods = {'poi'};
dop.save.epochs = {'screen','odd','even'};
dop.save.variables = {'peak_n','peak_mean','peak_sd_of_mean','peak_latency'};

if okay
    % loop through each of the files in the list
    for i = 1 : numel(dop.file_list)
        in.file = dop.file_list{i};
        
        fprintf('%u: %s\n',i,in.file);
        %         in.i_collect(end+1) = i;
        [dop,okay,msg] = dopImport(dop,'file',in.file);
        dop.save.file = dop.file; % dop.save.extras will save this as a column in the file
        
        % extract signal and event channels from larger set of data columns
        % this is called within dopImport as well
        [dop,okay,msg] = dopChannelExtract(dop,okay,msg);
        
        % probably done on import if channel information is available
        % [dop,okay,msg] = dopChannelAdjust(dop); % haven't adjusted for dopSetGetInputs
        % dopReportMsg(msg); % or dopReportMsg(dop); % reports latest set of messages
        
        [dop,okay,msg] = dopDownsample(dop,okay,msg); % or dop.data.down = dopDownSample(dop.data.raw,25,100)
        
        [dop,okay,msg] = dopEventMarkers(dop,okay,msg); % done automatically in (and redone at end of) dopDataTrim
        
        [dop,okay,msg] = dopPeriodChecks(dop,okay,msg);
        
        [dop,okay,msg] = dopDataTrim(dop,okay,msg);
        
        [dop,okay,msg] = dopEventChannels(dop,okay,msg);
        
        [dop,okay,msg] = dopHeartCycle(dop,okay,msg);
        % to have a look at the data include 'plot' as an input
        % [dop,okay,msg] = dopHeartCycle(dop,okay,'plot');
        
        [dop,okay,msg] = dopActCorrect(dop,okay,msg);%,'plot');
        
        [dop,okay,msg] = dopNorm(dop,okay,msg);%,'norm_method',dop.test.norm{j});
        % [dop,okay,msg] = dopEpoch(dop,okay,msg); % automatically in dopNorm(dop,[],[],'norm_method','epoch') or dopNorm(dop,[],[],'norm_method','deppe_epoch')
        [dop,okay,msg] = dopEpoch(dop,okay,msg);
        
        [dop,okay,msg] = dopEpochScreen(dop,okay,msg);
        
        [dop,okay,msg] = dopBaseCorrect(dop,okay,msg);
        
        [dop,okay,msg] = dopCalcAuto(dop,okay,msg);%'periods',{'baseline','poi'}); % ,'poi',[5 15],'act_window',2);
        
        [dop,okay,msg] = dopSave(dop,okay,msg);%,'save_dir',dop.save.save_dir);
        
        %% Plot individual data?
        % uncomment to do so. The 'wait' input will wait at this point in
        % the script until the figure close, before continuing
%         dop = dopPlot(dop,'wait');
       
        
        %% collect/group data
        dop = dopDataCollect(dop,okay,msg);

        % progress indicator/bar
        dop = dopProgress(dop);
        
        % save the messages for each file
        dop = dopMessageSave(dop,okay,msg);
    end
    
    %% > Collected/Group data
    % save the 'collected' data for all okay files
    [dop,okay,msg] = dopSaveCollect(dop);
    
    % plot the 'collected' data for all okay files
    [dop,okay,msg] = dopPlot(dop,'collect','type','base'); % ,'wait'
    %     [dop,okay,msg] = dopPlot(dop,'collect','wait');
    
    % close all/any popup warning dialogs with one command :)
    dopCloseMsg;
end

dopOSCCIalert('finish'); % plays a sound!