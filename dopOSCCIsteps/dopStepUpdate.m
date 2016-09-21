function dop = dopStepUpdate(dop)
% dopOSCCI3: dopStepUpdate
%
% notes:
% update the information in the gui figure based on dopStepSettings
%
% Use:
%
% dopStepUpdate;
%
% where:
%
% Created: 15-Oct-2015 NAB
% Edits:
% 04-Nov-2015 NAB added 'channels' option
% 25-July-2016 NAB haven't been updating the edits...
% 25-July-2016 NAB adjusted backgroundcolor to be separate when adding the
%   checkbox uicontrol

try
    fprintf('\nRunning %s:\n',mfilename);
    %% get the figure handle
    if ~exist('dop','var') || isempty(dop)
        dop = get(gcf,'UserData');
        if isempty(dop) || ~isstruct(dop) || ~isfield(dop,'step') || ~isfield(dop.step,'h')
            error('Can''t find ''dopStep'' figure');
        end
    end
    %% clear current contents
    if isfield(dop.step,'current') && isfield(dop.step.current,'h')
        %         n = dop.step.current;
        for i = 1 : numel(dop.step.current.h)
            delete(dop.step.current.h(i));
        end
        %             switch n.style{i}
        %                 case 'text'
        %                     dop.step.current.h(i) = uicontrol(dop.step.h,...
        %                         'style',n.style{i},'String',n.string{i},...
        %                         'tag',n.tag{i},...
        %                         'Units','Normalized',...
        %                         'Position',n.position(i,:));
        %                 otherwise
        %                     warndlg(sprintf('Style (%s), not recognised - can''t create',n.style{i}));
        %             end
        %         end
        drawnow;
    end
    %% create next contents
    if isfield(dop.step,'next')
        % update the current settings
        dop.step.previous = dop.step.current;
        dop.step.current = dop.step.next;
        if isfield(dop.step.current,'h')
            dop.step.current = rmfield(dop.step.current,'h');
        end
        set(dop.step.h,'UserData',dop); % maybe 30-jul-2016
        n = dop.step.current;
        dop.step.text.h = []; % clear text handles
        for i = 1 : numel(n.style)
            switch n.style{i}
                case {'text','edit','pushbutton','popup','checkbox'}
                    % generic
%                     if iscell(n.string{i})
%                         dop.step.current.h(i) = uicontrol(dop.step.h,...
%                             'style',n.style{i},'String',n.string{i},...
%                             'tag',n.tag{i},...
%                             'Units','Normalized',...
%                             'Position',n.position(i,:),...
%                             'HorizontalAlignment',n.HorizontalAlignment{i},...
%                             'FontSize',dop.step.FontSize);
%                     else
                        dop.step.current.h(i) = uicontrol(dop.step.h,...
                            'style',n.style{i},'String',n.string{i},...
                            'tag',n.tag{i},...
                            'Units','Normalized',...
                            'Position',n.position(i,:),...
                            'HorizontalAlignment',n.HorizontalAlignment{i},...
                            'FontSize',dop.step.FontSize);
%                     end
                    
                    %% background colour
                    switch n.style{i}
                        case {'text','checkbox'}
                            set(dop.step.current.h(i),'BackgroundColor',...
                                get(dop.step.h,'Color'));
                            if isfield(dop.step.current,'col') && ~isempty(dop.step.current.col{i})
                                set(dop.step.current.h(i),'BackgroundColor',...
                                    dop.step.current.col{i});
                            end
                    end
                    % specific
                    switch n.style{i}
                        %                         case 'text'
                        %                             set(dop.step.current.h(i),'BackgroundColor',...
                        %                                 get(dop.step.h,'Color'));
                        %                             if isfield(dop.step.current,'col') && ~isempty(dop.step.current.col{i})
                        %                                 set(dop.step.current.h(i),'BackgroundColor',...
                        %                                 dop.step.current.col{i});
                        %                             end
                        case {'edit','pushbutton','popup','checkbox'}
                            
                            % check if there's an existing definition value
                            % available
                            
                            
                            dop.tmp.callback = dop.step.next.Callback{i};
                            if ~isempty(dop.tmp.callback) && isempty(strfind(dop.tmp.callback,'@'))
                                dop.tmp.callback = eval(['[@',dop.step.next.Callback{i},'];']);
                            end
                            set(dop.step.current.h(i),'CallBack',dop.tmp.callback)
                            if ~isempty(n.Enable{i})
                                set(dop.step.current.h(i),'Enable',n.Enable{i});
                            end
                            
                            if isfield(n,'tooltip') && numel(n.tooltip) >= i
                                set(dop.step.current.h(i),'ToolTipString',n.tooltip{i});
                            end
                            
                            % need to come after the default - I think
                            dopStepGetDef(dop.step.current.h(i),'check_value');
                            dop.tmp.dop = get(gcf,'UserData');
                            if isfield(dop.tmp.dop,'save')
%                                 if isfield(dop,'save')
%                                     % refresh
% I don't think it needs to be refreshed - should just be able to copy over
% it as it'll be 'full' of all the currently set options...
%                                 else
                                    dop.save = dop.tmp.dop.save;
                                    dop.def = dop.tmp.dop.def;
%                                 end
                            end
                            %                             set(dop.step.current.h(i),'CallBack',dop.step.next.Callback{i},...
                            %                                 'Enable',n.Enable{i});
                            switch n.style{i}
                                case {'popup'}
                                    %                             set(dop.step.current.h(i),'CallBack',eval(['[@',dop.step.next.Callback{i},'];']),...
                                    %                                 'Enable',n.Enable{i});
                                    switch dop.step.next.Callback{i}
                                        case 'dopStepGetChannel'
                                            dop.tmp.ch = strtok(get(dop.step.current.h(i),'tag'),'_');
                                            if ~isfield(dop.step,'channels_okay') || strcmp(dop.tmp.ch,'left')
                                                dop.step.channels_okay = zeros(1,3);
                                            end
                                            % check if data exists
                                            dop.tmp.signal_options = {'left','right'};
                                            if isfield(dop,'def')
                                                switch dop.tmp.ch
                                                    case dop.tmp.signal_options
                                                        if  isfield(dop.def,'signal_channels')
                                                            dop.tmp.signal_number = find(ismember(dop.tmp.signal_options,dop.tmp.ch));
                                                            dop.tmp.value = dop.def.signal_channels(dop.tmp.signal_number);
                                                            if dop.step.dopChannelExtract
                                                                set(dop.step.current.h(i),'String',dop.def.signal_channel_labels{dop.tmp.signal_number},...
                                                                    'Enable','off');
%                                                                 dop.tmp.value = dop.tmp.signal_number;
                                                            else
                                                                set(dop.step.current.h(i),'Value',dop.tmp.value);
                                                                dop.step.channels_okay(dop.tmp.signal_number) = 1;
                                                            end
                                                        end
                                                    case 'event'
                                                        if  isfield(dop.def,'event_channels')
                                                            dop.tmp.value = dop.def.event_channels;
                                                            if isfield(dop,'use') && isfield(dop.use,'event_channels')
                                                                dop.tmp.value = dop.use.event_channels;
                                                            end
                                                            if dop.step.dopChannelExtract
%                                                                 dop.tmp.value = 3;
                                                                set(dop.step.current.h(i),'String',dop.def.event_channel_labels{1},...
                                                                    'Enable','off');
                                                            else
                                                            set(dop.step.current.h(i),'Value',dop.tmp.value);
                                                            dop.step.channels_okay(3) = 1;
                                                            end
                                                        end
                                                        
                                                end
                                            end
                                    end
                            end
                            
                    end
                    if isfield(dop.step.next,'Visible') && numel(dop.step.next.Visible) >= i
                        set(dop.step.current.h(i),'Visible',dop.step.next.Visible{i});
                    end
                    dop.step.text.h(i) = dop.step.current.h(i);
                    
                case 'axes'
                    dop = dopStepTimingPlot(dop);
                case 'radio'
                    
                    dop.step.current.h(i) = uibuttongroup(dop.step.h,...'String',n.string{i},...
                        'tag',n.tag{i},...
                        'Units','Normalized',...
                        'Position',n.position(i,:),...'HorizontalAlignment',n.HorizontalAlignment{i},...
                        'FontSize',dop.step.FontSize,...
                        'SelectionChangedFcn',@dopStepGetDef);
                    for j = 1 : numel(n.string{i})
                        dop.step.current.h_button(j) = uicontrol(...
                            dop.step.current.h(i),'Style','radiobutton',...
                            'Units','Normalized',...
                            'String',n.string{i}{j},...
                            'Position',[.05+(1/numel(n.string{i})*(j-1)) .25 ...
                            1/numel(n.string{i}) .5],...
                            'HandleVisibility','on');
                    end
                    
                otherwise
                    warndlg(sprintf('Style (%s), not recognised - can''t create',n.style{i}));
            end
        end
        
        % set gui data
        if sum(ismember(dop.step.current.tag,'data_file')) && isfield(dop,'fullfile') && exist(dop.fullfile,'file')
            dop.tmp.h = dop.step.current.h(ismember(dop.step.current.tag,'data_file'));
            set(dop.tmp.h,'string',dop.fullfile);
        end
        for i = 1 : numel(dop.step.action.tag)
            
            dop.tmp.h = dop.step.action.h(ismember(dop.step.action.tag,dop.step.action.tag{i}));
            dop.tmp.enable = 'off';
            switch dop.step.action.tag{i}
                case 'import'
                    % should the import button be on?
                    % if there's a data_file to import
                    if strcmp(dop.step.current.name,dop.step.action.tag{i})
                        if isfield(dop,'fullfile') && exist(dop.fullfile,'file')
                            dop.tmp.enable = 'on'; % set(dop.tmp.h,'enable','on');
                            if sum(ismember(dop.step.current.tag,'import_text'))
                                set(dop.step.current.h(ismember(dop.step.current.tag,'import_text')),'Visible','On')
                            end
                        end
                    end
                case 'channels'
                    %% channel button visible
                    if strcmp(dop.step.current.name,dop.step.action.tag{i})
                        if isfield(dop.step,'channels_okay') && sum(dop.step.channels_okay) == numel(dop.step.channels_okay)
                            % turn channel button on
                            if ~dop.step.dopChannelExtract
                                dop.tmp.enable = 'on'; %
                                %                             set(dop.step.action.h(ismember(dop.step.action.tag,'channels')),'enable','on');
                            end
                            if sum(ismember(dop.step.current.tag,'ch_plot_text'))
                                set(dop.tmp.h,'Visible','on');
                            end
                            if isfield(dop.step,'dopChannelExtract') 
                                if ~dop.step.dopChannelExtract
                                    dop.tmp.enable = 'on';
                                else
                                    % make sure the strings are okay
                                    keyboard
                                end
                            end
                        end
                    end
                    %                      set(dop.tmp.h,'Enable',dop.tmp.enable);
                    %                 case 'downsample'
                    %                     if isfield(dop,'def') && isfield(dop.def,'downsample_rate') ...
                    %                             && isfield(dop.step,'dopDownsample') && ~dop.step.dopDownsample
                    %                         % turn channel button on
                    %                         dop.tmp.enable = 'on'; %
                    %                         set(dop.step.action.h(ismember(dop.step.action.tag,'channels')),'enable','on');
                    %                     end
                case 'events'
                    if strcmp(dop.step.current.name,dop.step.action.tag{i})
                        if isfield(dop,'def') && isfield(dop.def,'event_height') && ...
                                ~isempty(dop.def.event_height)
                            % turn channel button on
                            dop.tmp.enable = 'on'; %
                            %                         set(dop.step.action.h(ismember(dop.step.action.tag,'channels')),'enable','on');
                        end
                    end
                case {'heart','norm'}
                    if strcmp(dop.step.current.name,dop.step.action.tag{i}) % was 'norm' 25-july-2016
                        dop.tmp.enable = 'on'; %
                        switch dop.step.current.name
                            case 'norm'
                                if ~isfield(dop,'def') || ~isfield(dop.def,'norm_method')
                                    dop.def.norm_method = 'overall';
                                end
                            case 'heart'
                                if isfield(dop.step,'dopHeartCycle') && ~isempty(dop.step.dopHeartCycle) && dop.step.dopHeartCycle
                                    dop.tmp.enable = 'off';
                                end
                        end
                        %                         set(dop.step.action.h(ismember(dop.step.action.tag,dop.step.current.name)),'enable','on');
                    end
                    %                 case 'norm'
                    %                     % need some checks here
                    %                     dop.tmp.enable = 'on'; %
                    %                     set(dop.step.action.h(ismember(dop.step.action.tag,dop.step.current.name)),'enable','on');
                case 'epoch'
                    if strcmp(dop.step.current.name,dop.step.action.tag{i})
                        if ~isfield(dop,'data') || ~isfield(dop.data,'epoch') || isempty(dop.data.epoch)
                            dop.tmp.var = {'epoch'};
                            for j = 1 : numel(dop.tmp.var)
                                if isfield(dop,'def') && isfield(dop.def,dop.tmp.var{j}) && ...
                                        ~isempty(dop.def.(dop.tmp.var{j})) && numel(dop.def.(dop.tmp.var{j})) == 2
                                    dop.tmp.enable = 'on'; %
                                    %                             set(dop.step.action.h(ismember(dop.step.action.tag,dop.step.current.name)),'enable','on');
                                end
                            end
                        end
                    end
                case 'screen'
                    if strcmp(dop.step.current.name,dop.step.action.tag{i})
                        if ~isfield(dop,'epoch') || ~isfield(dop.epoch,'screen') && isempty(dop.epoch.screen) || ...
                                isfield(dop,'def') && isfield(dop.def,'act_range') && ~isempty(dop.def.act_range)
                            dop.tmp.enable = 'on';
                        end
                    end
                case 'baseline'
                    if strcmp(dop.step.current.name,dop.step.action.tag{i}) && ...
                            isfield(dop,'def') && isfield(dop.def,'base') && ~isempty(dop.def.base) && numel(dop.def.base) == 2
                            dop.tmp.enable = 'on';
                    end
                case {'plot','plotsave'}
                    % should the plot button be on?
                    % if there's 'use' data to plot
                    if isfield(dop,'data') && isfield(dop.data,'use') && ~isempty(dop.data.use)
                        dop.tmp.enable = 'on'; % set(dop.tmp.h,'enable','on');
                        if sum(ismember(dop.step.current.tag,'plot_text'))
                            set(dop.step.current.h(ismember(dop.step.current.tag,'plot_text')),'Visible','On')
                        end
                    end
                case 'save'
                    if isfield(dop,'sum')
                        dop.tmp.enable = 'on';
                    end
            end
            if strcmp(dop.step.action.tag{i},'close') || strcmp(dop.step.action.tag{i},'dop')
                dop.tmp.enable = 'on';
            elseif strcmp(dop.step.current.name,'import') || ~isfield(dop.step,'dopImport') || ~dop.step.dopImport
                dop.tmp.enable = 'off';
            elseif strcmp(dop.step.current.name,'code') && isfield(dop.step,'code') && ~isempty(dop.step.code)
                dop.tmp.enable = 'on';
            end
            set(dop.tmp.h,'enable',dop.tmp.enable);
        end
        
    end
    dopStepButtonEnable(dop);
    %% update UserData
    set(dop.step.h,'UserData',dop);
    % welcome/instruction
    %     dop = dopStepWelcome(dop);
    %% adjust the colour of the 'back' and 'next' buttons
    for i = 1 : numel(dop.step.move.string)
        switch dop.step.current.name
            case 'welcome'
                dop.tmp.col = [dop.step.col.stop;dop.step.col.go];
            case 'finished'
                dop.tmp.col = [dop.step.col.go;dop.step.col.stop];
            otherwise
                dop.tmp.col = [dop.step.col.go;dop.step.col.go];
        end
        set(dop.step.move.h(ismember(dop.step.move.string,dop.step.move.string{i})),'BackgroundColor',dop.tmp.col(i,:));
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end