% Doppler Downs dopOSCCI script
%
% overview:
% Once upon a time, Margriet Groen collected some functional Transcranial
% Doppler Ultrasound (fTCD) data with a group of children. Some of them had
% Down Syndome.
%
% The tasks included:
% - Freezefoot (word generation)
% - Rabbits (viual memory)
%
% Aim:
% The aim of this script is to process some of this data - most likely one
% task at a time but you never know...
%
% created 05-Jan-2016 NAB

clc;
% clear all;
% Freeze foot folders
% task_name = 'FreezeFoot';
% base_folder = '/Users/mq20111600/Google Drive/nWorkProjects/DopplerDowns/data/freezefoot/';
task_name = 'rabbits';
base_folder = sprintf('/Users/mq20111600/Google Drive/nWorkProjects/DopplerDowns/data/%s/',task_name);
folders = {'td14','ds14','td4'};
% manual_poi = 1;
% stitch_on = 1; % stitch will be on as long as you:
% 1. provide the stitch_file & stitch_dir (or stitch_fullfile) variables 
%   (dopGetFileList looks for these and overrides it's default function)
% And
% 2. run the dopStitch function at the end of the script - after
%   dopCalcAuto and dopSave (probably dopDataCollect and dopProgress as well)

for k = 1 : 1
    clear dop
    
    
    dop.struc_name = 'dop';
    
    % tmp.computer = questdlg('Computer?','Change data directory','Nic','Lab','Nic');
    % switch tmp.computer
    %     case 'Nic'
    dop.data_dir = fullfile(base_folder,folders{k});%Documents/nData/2015/ppValidation/raw/validation/pacedProduction1down_PP2/';
    %     case 'Lab'
    %         dop.data_dir = 'D:\ExpPC_files\HannahRap\...';
    % end
    
    
    dop.def.task_name = [task_name,'_',folders{k}];%'pacedProduction';
    
    % definition information
    
    dop.def.signal_channels = [1 2]; % [3 4] columns in file (e.g., EXP)
    dop.def.event_channels = 3; % (later in EXP files)
    dop.def.event_height = 1000; % 400; % greater than
    
    dop.def.event_sep = 30; %
    
    dop.def.num_events = 30; % only relevant if saving epoch by epoch data
    
    dop.def.downsample_rate = 100; % Hertz
    
    % lower and upper values
    
    dop.def.epoch = [-12 18];
    dop.def.baseline = [-12 0];
    dop.def.poi = [4 14];
    
    dop.def.act_window = 2; % activation window
    
    dop = dopPeriodChecks(dop,'wait_warn',1);
    
    dop.def.act_range = [50 150];
    
    dop.def.correct_range = [-3 4];%[50 150]; % acceptable activation limits [-4 5]; %
    dop.def.correct_pct = 5; % if =< x% outside range, correct with mean/median
    
    
    dop.def.act_separation = 10; % acceptable activation difference = 10 x interquartile range
    dop.def.act_separation_index ='iqr'; %'pct';
    dop.def.act_separation_pct = 1;
    
    dop.def.screen = {'manual','length','act','sep'};
    
    % keep copy of proccessing steps, e.g., dop.data.norm, dop.data.down etc.
    % always keep raw for resetting
    dop.def.keep_data_steps = 1;
    
    dop.save.extras = {'file','poi_lower','poi_upper'};%{'file','norm','base'}; % you can add your own variables to this, just need to be defined somewhere as dop.save.x = where x = variable name
    dop.save.summary = {'overall'}; % vs 'epoch'
    dop.save.channels = {'Left','Right','Difference','Average'};
    dop.save.periods = {'baseline','poi','epoch'};
    dop.save.epochs = {'screen','odd','even'};
    dop.save.variables = {'peak_n','peak_mean','peak_sd_of_mean','peak_latency','period_mean'};
    
    [dop,~,msg] = dopSaveDir(dop);

    
    % manual screening:
%         dop.def.manual_file = sprintf('langLat_%s_manualScreen.txt',folders{k}(end-3:end)); % specify the manual screening file
%     
%         dop.def.manual_dir = '/Users/mq20111600/Dropbox/HannahProjects/langLatTaskDemands/data/manual_screening_fTCDdata'; % directory
    
% manual period of interest
dop.def.poi_select = 1;
%         dop.def.poi_file = 'poi_manual.csv'; % specify the manual screening file
%     
%         dop.def.poi_dir = '/Users/mq20111600/Google Drive/nWorkProjects/DopplerDowns/data/period_of_interest/'; % directory
        
        dop.def.stitch = 1; % turn this on and off
        dop.def.stitch_file = 'rabbits_stitchfile.csv';
dop.def.stitch_dir = '/Users/mq20111600/Google Drive/nWorkProjects/DopplerDowns/data/stitch';
% dop.def.stitch_fullfile = [];


% the dopGetFileList function will look in the stich_dir/stich_file if it
% exists and then loop through these files
            [dop,okay] = dopGetFileList(dop);
    if okay
        for i = 1 : numel(dop.file_list)
            in.file = dop.file_list{i};
            
            fprintf('%u: %s\n',i,in.file);

            [dop,okay,msg] = dopImport(dop,'file',in.file);
            
            dop.save.file = dop.file; % dop.save.extras will save this as a column in the file
            
            % could extract a code number or something
%             [dop.tmp.tok,dop.tmp.remain] = strtok(dop.file,'_');
%             dop.save.code = str2double(strtok(dop.tmp.remain,'_'));

            % extract signal and event channels from larger set of data columns
            % this is called within dopImport as well
            [dop,okay,msg] = dopChannelExtract(dop,okay,msg);
            
            % dopReportMsg(msg); % or dopReportMsg(dop); % reports latest set of messages
            
%             [dop,okay,msg] = dopDownsample(dop,okay,msg); % or dop.data.down = dopDownSample(dop.data.raw,25,100)
            
            [dop,okay,msg] = dopEventMarkers(dop,okay,msg); % done automatically in (and redone at end of) dopDataTrim
            
            [dop,okay,msg] = dopPeriodChecks(dop,okay,msg);
            
%             [dop,okay,msg] = dopDataTrim(dop,okay,msg);
            
            [dop,okay,msg] = dopEventChannels(dop,okay,msg);
            
            [dop,okay,msg] = dopHeartCycle(dop,okay,msg);%,'plot');
            % to have a look at the data include 'plot' as an input
            
            % [dop,okay,msg] = dopEpoch(dop); % automatically in dopNorm(dop,[],[],'norm_method','epoch') or dopNorm(dop,[],[],'norm_method','deppe_epoch')
            [dop,okay,msg] = dopActCorrect(dop,okay,msg);%,'plot');
            
            [dop,okay,msg] = dopNorm(dop,okay,msg,'norm_method','epoch');%,dop.test.norm{j});
            
            %         [dop,okay,msg] = dopEpoch(dop,okay,msg);
            
            [dop,okay,msg] = dopEpochScreen(dop,okay,msg);
            
            
            [dop,okay,msg] = dopBaseCorrect(dop,okay,msg);
            

            [dop,okay,msg] = dopCalcAuto(dop,okay,msg);
            
            [dop,okay,msg] = dopSave(dop,okay,msg);%,'save_dir',dop.save.save_dir);
            
            %                 dop = dopPlot(dop,'wait');
            

            fprintf('%u: %u %s\n',i,okay,in.file);

            %% collect grp data?
            %     dop.grp.Difference.poi.data(:,j) = dop.overall.Difference.poi.data;
            
            % regarding stitching - could collect average of everything and
            % might be able to play with it so that it collects and can
            % plot file1, file 2, and combined... if desirable
            [dop] = dopDataCollect(dop,okay,msg);
            %         end
            %         if ~okay
            %             keyboard
            %             % type 'return' to exit keyboard mode
            %         end
            dop = dopProgress(dop);
            
            %% 'stitching' multiple files together
            [dop,okay,msg] = dopStitch(dop,okay,msg);
%             if stitch_on && okay
%                 % which file?
%                 ii = 0;
%                 stitch_match = 0;
%                 while ~stitch_match && ii < size(dop.stitch.file_sets,1); ii = ii + 1;
%                     jj = 0;
%                     while ~stitch_match && jj < size(dop.stitch.file_sets,2); jj = jj + 1;
%                         if strcmp(dop.file,dop.stitch.file_sets{ii,jj})
%                             stitch_match = 1;
%                         end
%                     end
%                 end
%                 if stitch_match
%                     dop.stitch.collect(jj).data = dop.data.use;
%                     dop.stitch.epoch.n(jj) = size(dop.stitch.collect(jj).data,2);
%                     dop.stitch.epoch.screen(jj).data = dop.epoch.screen;
%                     dop.stitch.epoch.okay(jj) = sum(dop.epoch.screen);
%                     if jj == size(dop.stitch.file_sets,2)
%                         dop.stitch.data = [];
%                         dop.stitch.ep_screen = [];
%                         for ii = 1 : size(dop.stitch.file_sets,2)
%                             dop.stitch.data = [dop.stitch.data,dop.stitch.collect(jj).data]; %(:,1:min(dop.stitch.epochs.n),:)];
%                             %                             dop.stitch.epoch.screen.collect = [dop.stitch.epoch.screen.collect,dop.stitch.epoch.screen(jj).data];
%                             % best to randomly drop 1 or more trials... to balance
%                             dop.tmp.filt = dop.stitch.epoch.screen(jj).data;
%                             if dop.stitch.epoch.okay(jj) > min(dop.stitch.epoch.okay)
%                                 dop.tmp.use = find(dop.tmp.filt);
%                                 dop.tmp.rand = dop.tmp.use(randperm(numel(dop.tmp.use)));
%                                 dop.tmp.filt(dop.tmp.rand(min(dop.stitch.epoch.okay)+1:end)) = 0;
%                             end
%                             dop.stitch.ep_screen = [dop.stitch.ep_screen,dop.stitch.epoch.screen(jj).data];
%                         end
%                         
%                     dop.data.use = dop.stitch.data;
%                     dop.save.file = sprintf(['%s',repmat('_%s',size(dop.stitch.file_sets,2)-1)],dop.stitch.file_sets{ii,:});
%                     dop.epoch.screen = dop.stitch.ep_screen;
%                     [dop,okay,msg] = dopCalcAuto(dop,okay,msg,'poi',poi_tmp);
%                     
%                     [dop,okay,msg] = dopSave(dop,okay,msg);%,'save_dir',dop.save.save_dir);
%                     end
%                 end
%             end
        end
        % save the 'collected' data for all okay files
        [dop,okay,msg] = dopSaveCollect(dop,'type','base');
        % plot the 'collected' data for all okay files
        [dop,okay,msg] = dopPlot(dop,'collect','type','base');
        %     [dop,okay,msg] = dopPlot(dop,'collect','wait');
        % close all popup warning dialogs with one command :)
        dopCloseMsg;
        dopCloseProgress;
    end
end
dopOSCCIalert('finish');