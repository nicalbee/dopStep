function [dop,okay,msg] = dopPlotSave(dop_input,varargin)
% dopOSCCI3: dopPlotSave
%
% [dop,okay,msg] = dopPlotSave(dop,[okay],[msg],...);
%
% notes:
% save an image file of the dopOSCCI plot - strips the buttons and adds a
% legend. It's not suitable for publication but it's a quick way of keeping
% a record of what the data looks like.
%
% Currently (28-Aug-2016) implemented within 'dopSave' but also via a
% 'pushbutton' from the 'dopPlot' figure.
%
% Use:
%
% [dop,okay,msg] = dopPlotSave(dop_input,[okay],[msg],...);
%
% * not yet implemented/tested 03-Sep-2014
%
% where:
% > Inputs
% - dop_input: dop matlab structure or data matrix*
%
%   Optional:
% - okay:
%   logical (0 or 1) for problem, 0 = no problem, 1 = problem. This can be
%   carried through from previously run functions. If set to 1, the
%   function will not be implemented.
% - msg:
%   cell variable with a history of messages from previously run functions.
%   New messages are appended to the end of the array and can be reported
%   to examine the processing steps using 'dopMessage':
%   e.g. dopMessage(msg) or dopMessage(dop);
%
%   Text only:
% - 'nomsg':
%   By default, messages about the processing will be reported to the
%   MATLAB command window. If included as an input, 'nomsg' will turn off
%   these messages. note: they will continue to be collected in the 'msg'
%   variable.
%
% Name + value inputs:
% note: if the variable name string is recognised as an input, the next
%   input will be set as its value. For example, ...,'name',value,...
%   These can be included in any order
%
% - 'save_dir' = base directory/location for plot image -'plots' will be
%   added to the end of this:
%	e.g., ...,'save_dir','/Users/me/doppler',... > '/Users/me/doppler/plots'
%       or ...,'save_dir','D:\MyDocuments\doppler',... > 'D:\MyDocuments\doppler\plots'
%   > default is based on dop.tmp.task_name + settings
%   Recommend leaving blank. See 'dopSaveDir' for further information.
%
% - 'plot_file' =  file name for plot image
%	e.g., ...,'plot_file','my_image_file',...
%   > default is 'dopOSCCIplot' or derived from imported filename -
%   recommend leaving blank
%
% - 'plot_dir' =  location for plot image
%	e.g., ...,'plot_dir','/Users/me/Documents/doppler/plots',...
%       or ...,'plot_dir','D:\MyDocuments\doppler\plots',...
%   > default is based on dop.tmp.task_name + settings
%   Recommend leaving blank. See 'dopSaveDir' for further information.
%
% - 'plot_fullfile' = location and filename of the to-be-save plot image
%   > recommend leaving blank
%
% - 'plot_file_type' = image file type of the plot image
%   e.g., ...,'plot_file_type','png',...
%   > 'png' = default
%
% > Outputs: (note, optional)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 05-Sep-2014 NAB
% Edits:
% 28-Aug-2016 NAB finally getting this into gear
% 28-Aug-2016 NAB playing around with save directories - not quite sure of
%   the best way to be automated about this
% 30-Aug-2016 NAB various documentation added
% 18-Mar-2017 NAB added collected file names + individual files
% 18-Mar-2017 NAB playing with legend as well = better but it's not ideal
%   as it's hard to control under these circumstances.
% 07-Apr-2017 NAB 'disp_str' coming down as cell array - which doesn't
%   work. Pulled it out as string variable
% 20-Apr-2017 NAB added 'task_name' input and removed reference to dop.def
%   variable
% 02-Jul-2018 NAB little update for when not dop.tmp.collect (when it
%   doesn't exist)
% 14-Jul-2018 NAB making sure collect name works and only looks for the
%   dop.tmp.beh variable when it exists
% 27-Aug-2018 NAB removing legend from evoked flow (from Abu Dhabi!)
%

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;
        %% inputs
        %         inputs.turnOn = {'nomsg'};
        %         inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'save_dir',[],...
            'task_name',[],...
            'plot_file','dopOSCCIplot',... % file name for plot image
            'plot_dir',[],... % location for plot image
            'plot_fullfile',[],...
            'plot_file_type','fig',...'png',...
            'plot_save_legend',0,... % only toggles for evoked flow
            'collect',0,...
            'handle',[],...
            'auto',1,...
            'gui',0,...
            'type','',...
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        %         inputs.required = ...
        %             {'epoch'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        if okay
            if isprop(dop.tmp.handle,'style')
                switch get(dop.tmp.handle,'style')
                    case 'pushbutton'
                        dop.tmp.plot_h = get(dop.tmp.handle,'parent');
                        dop.tmp.gui = 1;
                end
                
            elseif strcmp(get(dop.tmp.handle,'Tag'),'dopPlot')
                dop.tmp.plot_h = dop.tmp.handle;
            end
            % save location etc.
            if dop.tmp.auto
                if isfield(dop.tmp,'save_dir') && ~isempty(dop.tmp.save_dir)
                    dop.tmp.plot_dir = fullfile(dop.tmp.save_dir,'plots',dop.tmp.type);
                elseif isempty(dop.tmp.plot_dir)
                    [dop,okay,msg] = dopSaveDir(dop,'gui',dop.tmp.gui); % ,'dir_out',1)
                    %                     dop.tmp.plot_dir = fullfile(dopSaveDir(dop,'dir_out',1),'plots');
                    [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                    if okay
                        dop.tmp.plot_dir = fullfile(dop.save.save_dir,'plots',dop.tmp.type);
                    else
                        dop.tmp.plot_dir = fullfile(dopSaveDir(dop,'dir_out',1),'plots',dop.tmp.type);
                        okay = 1;
                    end
                end
                if ~exist(dop.tmp.plot_dir,'dir')
                    mkdir(dop.tmp.plot_dir);
                end
                if isempty(dop.tmp.file) && isfield(dop,'file') && ~isempty(dop.file)
                    dop.tmp.file = dop.file;
                end
                dop.tmp.plot_file = dop.tmp.defaults.plot_file;
                if isfield(dop.tmp,'collect') && dop.tmp.collect
                    fig_ch = get(gcf,'children');
                    disp_h = fig_ch(ismember(get(fig_ch,'tag'),'display'));
                    disp_str = get(disp_h,'String');
                    if iscell(disp_str)
                        disp_str = disp_str{1};
                    end
                    dop.tmp.plot_file = sprintf('%s_%s_n%i_%s',...
                        dop.tmp.task_name,dop.tmp.type,dop.collect.(dop.tmp.type).n,disp_str);
                    switch disp_str
                        case {'mean','median','all'}
                            
                        otherwise
                            if isnumeric(str2double(disp_str))
                                [~,dop_file,~] = fileparts(dop.collect.(dop.tmp.type).files{str2double(disp_str)});
                                dop.tmp.plot_file = sprintf('%s_%s_%s',...
                                    dop_file,dop.tmp.task_name,dop.tmp.type);
                            end
                    end
                    if isfield(dop.tmp,'beh') && ~isempty(dop.tmp.beh)
                        dop.tmp.plot_file = sprintf('%s_%s',dop.tmp.plot_file,dop.tmp.beh);
                    end
                elseif ~isempty(dop.tmp.file) && strcmp(dop.tmp.plot_file,dop.tmp.defaults.plot_file) || ~isempty(dop.tmp.file) && isempty(dop.tmp.plot_file)
                    [~,dop_file,~] = fileparts(dop.tmp.file);
                    dop.tmp.plot_file = sprintf('%s_%s_%s',...
                        dop_file,dop.tmp.task_name,dop.tmp.type);
                    %                     dop.tmp.plot_file = strrep(dop.tmp.file,dop.tmp.ext,'');
                end
                if ~isempty(dop.tmp.plot_fullfile)
                    [dop.tmp.plot_dir,dop.tmp.plot_file,dop.tmp.plot_file_type] = fileparts(dop.tmp.plot_fullfile);
                end
                dop.tmp.file_num = 0;
                while 1
                    dop.tmp.file_num = dop.tmp.file_num + 1;
                    dop.tmp.plot_fullfile = fullfile(dop.tmp.plot_dir,...
                        sprintf('%s%u.%s',dop.tmp.plot_file,dop.tmp.file_num,dop.tmp.plot_file_type));
                    if ~exist(dop.tmp.plot_fullfile,'file')
                        break
                    end
                    % otherwise keep adding up the number until it's a
                    % new file
                end
                
            else
                %                 if isempty(dop.tmp.plot_fullfile) && isempty(dop.tmp.plot_dir)
                %                     %                 dop.tmp.plot_dir = fullfile(dopSaveDir;
                %                     dop.step.code.fullfile = [];
                %                     switch questdlg(sprintf('Save the data to: %s? ',dop.step.code.dir),...
                %                             'DOPOSCCI plot save directory','Yes','Choose','Cancel','Yes');
                %                         case 'Choose'
                %                             dop.step.code.dir = uigetdir(dop.step.code.dir,...
                %                                 'Choose DOPOSCCI code save directory:');
                %                         case 'Cancel'
                %                             dop.step.code.dir = [];
                %                     end
                %                     if ~isempty(dop.step.code.dir)
                %                         dop.step.code.file = inputdlg('Please type file name:',...
                %                             'DOPOSCCI code save filename (extension added later):',...
                %                             1,dop.step.code.file);
                %                         if ~isempty(dop.step.code.file{1})
                %                             dop.step.code.fullfile = fullfile(dop.step.code.dir,[dop.step.code.file{1},'.m']);
                %                         end
                %                     end
                %                 end
                %                 if ~isempty(dop.step.code.fullfile)
                %                     if ~exist(dop.step.code.dir,'dir')
                %                         mkdir(dop.step.code.dir);
                %                     end
                %                     if exist(dop.step.code.dir,'dir')
                %                         fprintf('Saving code to: %s (%s)\n',dop.step.code.dir,dop.step.code.file{1})
                %                         dop.tmp.fid = fopen(dop.step.code.fullfile,'w');
                %                         for i = 1 : numel(dop.step.code.data)
                %                             fprintf(dop.tmp.fid,'%s\n',dop.step.code.data{i});
                %                         end
                %                         fclose(dop.tmp.fid);
                %
                %                         switch questdlg('Open code in MATLAB editor?','Open?','Yes','No','Yes');
                %                             case 'Yes'
                %                                 eval(sprintf('edit %s',dop.step.code.fullfile));
                %                             otherwise
                %                                 dop.tmp.msg = sprintf('Success! Examine by typing: edit %s',dop.step.code.fullfile);
                %                                 msgbox(dop.tmp.msg,'DOPOSCCI code saved:');
                %                         end
                %                     else
                %                         dop.tmp.msg = sprintf('Problem with save directory for: %s',dop.step.code.fullfile);
                %                         warndlg(dop.tmp.msg,'Problem:');
                %                     end
                %                 end
            end
            %% main code
            if isfield(dop.tmp,'plot_h') && ~isempty(dop.tmp.plot_h)
                dop.tmp.axes_only = figure('visible','off','units','normalized',...
                    'position',get(dop.tmp.plot_h,'Position'));
                dop.tmp.ch = get(dop.tmp.plot_h,'children');
                dop.tmp.axes_h = dop.tmp.ch(ismember(get(dop.tmp.ch,'type'),'axes'));
                copyobj(dop.tmp.axes_h,dop.tmp.axes_only);
                dop.tmp.axes_new = get(dop.tmp.axes_only,'children');
                set(dop.tmp.axes_new,'Position',[.1 .1 .8 .8],...
                    'Box','off');
                set(get(dop.tmp.axes_new,'XLabel'),'String','Time in seconds (zero = event)');
                set(get(dop.tmp.axes_new,'YLabel'),'String','Blood Flow Velocity cm/sec');
                
                % the legend is a pain for the evoked flow - always gets in the
                % way and hopefully the information is self-explanatory
                switch dop.tmp.type
                    case {'epoch','base','epoch_norm'}
                        if dop.tmp.plot_save_legend
                            dop.tmp.legend = legend;
                            legend show;
                            
                            % below legend code doesn't work...
                            %             dop.tmp.legend = findobj(gcf,'Type','axes','Tag','legend');
                            %             set(dop.tmp.legend,'EdgeColor',[1 1 1],'Location','Best');%'NorthWest');
                            
                            legend Location best % this does work but can't alter the EdgeColor...
                        end
                    otherwise
                        dop.tmp.legend = legend;
                        legend show;
                        legend Location best % this does work but can't alter the EdgeColor...
                end
                %             drawnow;
                dop.tmp.save_h = dop.tmp.axes_only; % dop.tmp.plot_h
                dop.tmp.pos = get(dop.tmp.plot_h,'Position');
                set(dop.tmp.save_h,'PaperPos',[0 0 dop.tmp.pos([3 4]).*[50 47]]); % adjusting this number includes the x title... 20 does not
                dop.tmp.plot_file_type = strrep(dop.tmp.plot_file_type,'.','');
                switch dop.tmp.plot_file_type
                    case {'png','jpeg','jpg','tiff','tif','bmp'}
                        print(dop.tmp.save_h,dop.tmp.plot_fullfile,...
                            ['-d',dop.tmp.plot_file_type] ...
                            );
                    case 'fig'
                        set(dop.tmp.save_h,'Visible','on');
                        savefig(dop.tmp.save_h,dop.tmp.plot_fullfile);
                end
                
                % add these to a non-temporary structure so that they can be
                % accessed after dopMultiFuncTmpCheck - reported in gui msgbox
                dop.safe.plot_fullfile = dop.tmp.plot_fullfile;
                [dop.safe.plot_dir,dop.safe.plot_file,dop.safe.plot_file_type] = fileparts(dop.safe.plot_fullfile);
                
                msg{end+1} = sprintf('Plot saved to: %s%s (%s)',dop.safe.plot_file,dop.safe.plot_file_type,dop.tmp.plot_dir);
                
                
                
                
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                delete(dop.tmp.axes_only);
                
                if isprop(dop.tmp.handle,'style')
                    switch get(dop.tmp.handle,'style')
                        case 'pushbutton'
                            msgbox(msg{end},'Saved plot:');
                    end
                end
            else
                msg{end+1} = sprintf(['''dop.tmp.plot_h'' variable not found. ',...
                    '- ''%s'' should be called from within ''dopPlot''.'],mfilename);
                okay = 0;
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
        end
        %         %% tmp check
        %         [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        
        
        
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end