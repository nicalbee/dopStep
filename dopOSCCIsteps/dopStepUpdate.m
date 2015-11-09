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
        n = dop.step.current;
        dop.step.text.h = []; % clear text handles
        for i = 1 : numel(n.style)
            switch n.style{i}
                case {'text','edit','pushbutton','popup'}
                    % generic
                    dop.step.current.h(i) = uicontrol(dop.step.h,...
                        'style',n.style{i},'String',n.string{i},...
                        'tag',n.tag{i},...
                        'Units','Normalized',...
                        'Position',n.position(i,:),...
                        'HorizontalAlignment',n.HorizontalAlignment{i});
                    % specific
                    switch n.style{i}
                        case 'text'
                            set(dop.step.current.h(i),'BackgroundColor',...
                                get(dop.step.h,'Color'));
                            if isfield(dop.step.current,'col') && ~isempty(dop.step.current.col{i})
                                set(dop.step.current.h(i),'BackgroundColor',...
                                dop.step.current.col{i});
                            end
                        case {'edit','pushbutton','popup'}
                            dop.tmp.callback = dop.step.next.Callback{i};
                            if ~isempty(dop.tmp.callback) && isempty(strfind(dop.tmp.callback,'@'))
                                dop.tmp.callback = eval(['[@',dop.step.next.Callback{i},'];']);
                            end
                            set(dop.step.current.h(i),'CallBack',dop.tmp.callback,...
                                'Enable',n.Enable{i});
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
                                                                dop.tmp.value = dop.tmp.signal_number;
                                                            end
                                                            set(dop.step.current.h(i),'Value',dop.tmp.value);
                                                            dop.step.channels_okay(dop.tmp.signal_number) = 1;
                                                        end
                                                    case 'event'
                                                        if  isfield(dop.def,'event_channels')
                                                            dop.tmp.value = dop.def.event_channels;
                                                            if isfield(dop,'use') && isfield(dop.use,'event_channels')
                                                                dop.tmp.value = dop.use.event_channels;
                                                            end
                                                            if dop.step.dopChannelExtract
                                                                dop.tmp.value = 3;
                                                            end
                                                            set(dop.step.current.h(i),'Value',dop.tmp.value);
                                                            dop.step.channels_okay(3) = 1;
                                                        end
                                                        
                                                end
                                            end
                                    end
                            end
                            
                    end
                    if isfield(dop.step.next,'Visible') && numel(dop.step.next.Visible) <= i
                        set(dop.step.current.h(i),'Visible',dop.step.next.Visible{i});
                    end
                    dop.step.text.h(i) = dop.step.current.h(i);
                case 'axes'
                    dop = dopStepTimingPlot(dop);
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
            set(dop.tmp.h,'enable','off');
            switch dop.step.action.tag{i}
                case 'import'
                    % should the import button be on?
                    % if there's a data_file to import
                    if isfield(dop,'fullfile') && exist(dop.fullfile,'file')
                        set(dop.tmp.h,'enable','on');
                        if sum(ismember(dop.step.current.tag,'import_text'))
                            set(dop.step.current.h(ismember(dop.step.current.tag,'import_text')),'Visible','On')
                        end
                    end
                case 'channels'
                    %% channel button visible
                    if isfield(dop.step,'channels_okay') && sum(dop.step.channels_okay) == numel(dop.step.channels_okay)
                        % turn channel button on
                        if ~dop.step.dopChannelExtract
                            set(dop.step.action.h(ismember(dop.step.action.tag,'channels')),'enable','on');
                        end
                        if sum(ismember(dop.step.current.tag,'ch_plot_text'))
                            set(dop.tmp.h,'Visible','on');
                        end
                    end
                case 'downsample'
                    if isfield(dop,'def') && isfield(dop.def,'downsample_rate') ...
                            && isfield(dop.step,'dopDownsample') && ~dop.step.dopDownsample
                        % turn channel button on
                        set(dop.step.action.h(ismember(dop.step.action.tag,'channels')),'enable','on');
                    end
                case 'event'
                     if isfield(dop,'def') && isfield(dop.def,'event_height') && ...
                             ~isempty(dop.def.event_height)
                        % turn channel button on
                        set(dop.step.action.h(ismember(dop.step.action.tag,'channels')),'enable','on');
                    end
                case 'plot'
                    % should the plot button be on?
                    % if there's 'use' data to plot
                    if isfield(dop,'data') && isfield(dop.data,'use') && ~isempty(dop.data.use)
                        set(dop.tmp.h,'enable','on');
                        if sum(ismember(dop.step.current.tag,'plot_text'))
                            set(dop.step.current.h(ismember(dop.step.current.tag,'plot_text')),'Visible','On')
                        end
                    end
            end
        end
        
        %         for i = 1 : numel(dop.step.action.h)
        %             switch get(dop.step.action.h(i),'tag')
        %                 case 'import'
        %
        %                 case 'plot'
        %             end
        %         end
        
    end
    
    %% update UserData
    set(dop.step.h,'UserData',dop);
    % welcome/instruction
    %     dop = dopStepWelcome(dop);
    
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end