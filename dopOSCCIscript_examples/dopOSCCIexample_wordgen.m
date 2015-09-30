% % function dopOSCCItest

clc;
% clear all;
clear dop


dop.struc_name = 'dop';

dop.data_dir = '/Users/mq20111600/Google Drive/nData/2015/ppValidationB/WG/';

dop.def.task_name = 'wordGenValidation';
% definition information
dop.def.signal_channels = [3 4]; % columns in file (e.g., EXP)
dop.def.event_channels = 5; % TX/TW files
dop.def.event_height = 1000; % 400; % greater than
dop.def.event_sep = 50; %
dop.def.num_events = 24;

dop.def.downsample_rate = 100; % Hertz

% lower and upper values
dop.def.epoch = [-15 25]; %[-5 20];
dop.def.baseline = [-15 -5];
dop.def.poi = [5 15];
dop.def.act_window = 2; % activation window

dop = dopPeriodChecks(dop,'wait_warn',1);

dop.def.act_range = [50 150];

dop.def.correct_range = [-3 4];%[50 150]; % acceptable activation limits [-4 5]; %
dop.def.correct_pct = 5; % if =< x% outside range, correct with mean/median

dop.def.act_separation = 20; % acceptable activation difference
dop.def.act_separation_pct = 1;

dop.def.screen = {'length','act','sep'};

% keep copy of proccessing steps, e.g., dop.data.norm, dop.data.down etc.
% always keep raw for resetting
dop.def.keep_data_steps = 1;

dop.save.extras = {'file','code'};%{'file','norm','base'}; % you can add your own variables to this, just need to be defined somewhere as dop.save.x = where x = variable name
dop.save.summary = {'overall','epoch'}; % vs 'epoch'
dop.save.channels = {'Difference'};
dop.save.periods = {'poi'};
dop.save.epochs = {'screen','odd','even'};
dop.save.variables = {'peak_n','peak_mean','peak_sd_of_mean','peak_latency'};

dop.save.save_file = []; % this will be auto completed based upon the dop.def.task_name variable
% dop.save.save_dir = 'C:\Users\mq20111600\Documents\nData\dopStep';
[dop,okay,msg] = dopSaveDir(dop);
% or
% dop.save.save_dir = dopSaveDir(dop,'dir_only',1);
% or
% dop.save.save_dir = '/Users/mq20111600/Documents/nData/tmpData';

% in.dir = '/Users/mq20111600/Documents/nData/tmp';%'/Users/mq20111600/Documents/nData/2013/201312infant_fTCD_UniSA/'; %
% dop.data_dir = '/Users/mq20111600/Google Drive/tmp/';%'/Users/mq20111600/Documents/nData/Study AA (Abbie doppler stories)/data/raw/dopTrials/wordGen';
% dop.data_dir = '/Users/mq20111600/Documents/nData/2015/ppValidation/raw/validation/wordGen/';
% dop.data_dir = '/Users/mq20111600/Google Drive/nData/2015/ppValidationB/WG/';
% in.file_list = dir(fullfile(in.dir,'*.exp'));
% dop.file_list = dopGetFileList(dop.data_dir);%;dir(in.dir);
[dop,okay] = dopGetFileList(dop);%;dir(in.dir);
% in.file_list = {'test.exp'};
if okay
    for i = 1 : 1 %numel(dop.file_list)
        in.file = dop.file_list{i};
        
        fprintf('%u: %s\n',i,in.file);
        %         in.i_collect(end+1) = i;
        [dop,okay,msg] = dopImport(dop,'file',in.file);
        dop.save.file = dop.file; % dop.save.extras will save this as a column in the file
        [dop.tmp.tok,dop.tmp.remain] = strtok(dop.file,'_');
        dop.save.code = str2double(strtok(dop.tmp.remain,'_'));
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
        
        [dop,okay,msg] = dopHeartCycle(dop,okay,msg);%,'plot');
        % to have a look at the data include 'plot' as an input
        % to specify the plot range add 'plot_range',[lower upper] input (in
        % samples currently 10-Aug-2014)
        % [dop,okay,msg] = dopHeartCycle(dop,'plot');
        
        % [dop,okay,msg] = dopEpoch(dop); % automatically in dopNorm(dop,[],[],'norm_method','epoch') or dopNorm(dop,[],[],'norm_method','deppe_epoch')
        [dop,okay,msg] = dopActCorrect(dop,okay,msg);%,'plot');
        
        [dop,okay,msg] = dopNorm(dop,okay,msg);%,'norm_method',dop.test.norm{j});
        
        [dop,okay,msg] = dopEpoch(dop,okay,msg);
        
        [dop,okay,msg] = dopEpochScreen(dop,okay,msg);
        
        %         [dop,okay,msg] = dopEpochScreenAct(dop,okay,msg);
        %
        %         [dop,okay,msg] = dopEpochScreenSep(dop,okay,msg);
        
        [dop,okay,msg] = dopBaseCorrect(dop,okay,msg);
        
        [dop,okay,msg] = dopCalcAuto(dop,okay,msg);%'periods',{'baseline','poi'}); % ,'poi',[5 15],'act_window',2);
        
        [dop,okay,msg] = dopSave(dop,okay,msg);%,'save_dir',dop.save.save_dir);
        
                dop = dopPlot(dop,'wait');
        
        % other functions
        % [dop,okay,msg] = dopUseDataOperations(dop,'base');
        fprintf('%u: %u %s\n',i,okay,in.file);
        %         if ~okay && isempty(dop)
        %             pause;
        %         end
        %% collect grp data?
        %     dop.grp.Difference.poi.data(:,j) = dop.overall.Difference.poi.data;
        [dop] = dopDataCollect(dop,okay,msg);
        %         end
        %         if ~okay
        %             keyboard
        %             % type 'return' to exit keyboard mode
        %         end
    end
    % save the 'collected' data for all okay files
    [dop,okay,msg] = dopSaveCollect(dop);
    % plot the 'collected' data for all okay files
    [dop,okay,msg] = dopPlot(dop,'collect','type','base');
    %     [dop,okay,msg] = dopPlot(dop,'collect','wait');
    % close all popup warning dialogs with one command :)
    dopCloseMsg;
end

dopOSCCIalert('finish');