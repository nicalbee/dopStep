% % function dopOSCCItest

clc;
% clear all;
clear dop

dop.struc_name = 'dop';
% this is used to verify the stucture as the 'dopOSCCI' structure, best not
% to change!

% definition information
dop.def.task_name = 'whatbox'; % this will be used to create save file names

dop.def.signal_channels = [3 4]; % columns in file (e.g., EXP)
dop.def.event_channels = 14;%9;%13; % 14 also in example
dop.def.event_height = 1000; % 400; % greater than
dop.def.event_sep = 35; % no longer used to find events, just to check whether you're allowing enough time
% dop.def.num_events = 40; % maximum number of events, important for saving epoch data

dop.def.downsample_rate = 25; % Hertz

% lower and upper values
dop.def.epoch = [-10 16]; %[-5 20];
dop.def.baseline = [-10 -5];
dop.def.poi = [5 15];
dop.def.act_window = 2; % activation window

[dop,okay,msg] = dopPeriodChecks(dop,'wait_warn',1);

dop.def.act_range = [50 150];

dop.def.correct_range = [-3 4];%[50 150]; % acceptable activation limits [-4 5]; %
dop.def.correct_pct = 5; % if =< x% outside range, correct with mean/median

dop.def.act_separation = 10; % acceptable activation difference
dop.def.act_separation_pct = 1;%0.5;%1;

dop.def.screen = {'length','act','sep'}; % could add 'manual' to this

% manual screening:
dop.def.manual_file = []; % specify the manual screening file
dop.def.manual_dir = []; % directory
% use the above 2 or the below 1
dop.def.manual_fullfile = []; % directory and name in single string

% keep copy of proccessing steps, e.g., dop.data.norm, dop.data.down etc.
% this allows you to go back and forth between different data steps for
% alternate processing and also allows you to view the data at different
% stages using, for example, dopPlot(dop,'type','norm')
% see dopUseDataOperations for setting current dop.data.use variable to
% certain steps.
dop.def.keep_data_steps = 1;


% define which information will be saved
dop.save.extras = {'file'};
% you can add your own variables to 'extras', just need to be defined
% somewhere as dop.save.x = where x = variable name
dop.save.summary = {'overall'}; % versus 'epoch' (not well tested yet)
dop.save.channels = {'Difference'}; % {'Left','Right','Difference','Average'}
dop.save.periods = {'poi'}; % {'baseline','epoch'}
dop.save.epochs = {'screen','odd','even'};%{'all','screen','odd','even'};
dop.save.variables = {'peak_n','peak_mean','peak_sd','peak_latency'};

dop.save.messages = 1;


dop.save.save_file = []; % this will be auto completed based upon the dop.def.task_name variable
% dop.save.save_dir = 'C:\Users\mq20111600\Documents\nData\dopStep';
[dop,okay,msg] = dopSaveDir(dop);
% or
% dop.save.save_dir = dopSaveDir(dop,'dir_only',1);
% or
% dop.save.save_dir = '/Users/mq20111600/Documents/nData/tmpData';

% dop.data_dir = 'C:\Users\mq20111600\Desktop\UniSA Infant TCD';
dop.data_dir = '/Users/mq20111600/Documents/nData/nData2014/UniSA Infant TCD';
[dop,okay,msg] = dopGetFileList(dop,okay,msg);
% in.file_list = {'test.exp'};
if okay
    for i = 1 : numel(dop.file_list)
        in.fullfile = dop.file_list{i};
        [~,in.file_noext,in.file_ext] = fileparts(in.fullfile);
        in.file = [in.file_noext,in.file_ext];
        dop.save.file = in.file; % dop.save.extras will save this as a column in the file
        
        fprintf('%u: %s\n',i,in.file);
        
        [dop,okay,msg] = dopImport(dop,'file',in.fullfile);
        % extract signal and event channels from larger set of data columns
        % this is called within dopImport as well
        [dop,okay,msg] = dopChannelExtract(dop,okay,msg);
        
        % probably done on import if channel information is available
        % [dop,okay,msg] = dopChannelAdjust(dop); % haven't adjusted for dopSetGetInputs
        
        % dopMessage(msg); % or dopMessage(dop); % reports latest set of messages
        
        [dop,okay,msg] = dopDownsample(dop,okay,msg); % or dop.data.down = dopDownSample(dop.data.raw,25,100)
        
        [dop,okay,msg] = dopEventMarkers(dop,okay,msg); % done automatically in (and redone at end of) dopDataTrim
        
        [dop,okay,msg] = dopPeriodChecks(dop,okay,msg);
        
        [dop,okay,msg] = dopDataTrim(dop,okay,msg);
        
        [dop,okay,msg] = dopEventChannels(dop,okay,msg);
        
        [dop,okay,msg] = dopHeartCycle(dop,okay,msg);
        % to have a look at the data include 'plot' as an input
        % to specify the plot range add 'plot_range',[lower upper] input (in
        % samples currently 10-Aug-2014)
        % [dop,okay,msg] = dopHeartCycle(dop,'plot');
        
        
        [dop,okay,msg] = dopActCorrect(dop,okay,msg);%,'plot');
        
        [dop,okay,msg] = dopNorm(dop,okay,msg,'norm_method','epoch');
        
        % [dop,okay,msg] = dopEpoch(dop); % automatically in dopNorm(dop,[],[],'norm_method','epoch') or dopNorm(dop,[],[],'norm_method','deppe_epoch')
        %         [dop,okay,msg] = dopEpoch(dop,okay,msg);
        
        [dop,okay,msg] = dopEpochScreen(dop,okay,msg);
        % dopEpochScreen runs all of these:
        %
        %         [dop,okay,msg] = dopEpochScreenAct(dop,okay,msg);
        %
        %         [dop,okay,msg] = dopEpochScreenSep(dop,okay,msg);
        %
        %         [dop,okay,msg] = dopEpochScreenCombine(dop,okay,msg);
        %
        
        [dop,okay,msg] = dopBaseCorrect(dop,okay,msg);

        if okay
            [dop,okay,msg] = dopCalcAuto(dop,okay,msg);%'periods',{'baseline','poi'}); % ,'poi',[5 15],'act_window',2);
            %% collect grp data?
            [dop,okay,msg] = dopDataCollect(dop,okay,msg);
            fprintf('%u: %u %s\n',i,okay,in.file);
            % forcing the same function, even if an error is thrown due to too
            % few trials when calculating the LI. This will results in default
            % values of 999 for the variables but at least you'll know what
            % happened to the file.
            [dop,okay,msg] = dopSave(dop,1,msg);%,'save_dir',dop.save.save_dir);
        else
            fprintf('%u: %u %s\n',i,okay,in.file);
        end
        %         dop = dopPlot(dop,'wait');
        
        % other functions
        % [dop,okay,msg] = dopUseDataOperations(dop,'base');
        
        
    end
    % save the 'collected' data for all okay files
    [dop,okay,msg] = dopSaveCollect(dop);
    % plot the 'collected' data for all okay files
    [dop,okay,msg] = dopPlot(dop,'collect');
    
    dopCloseMsg;
end

dopOSCCIalert('finish');