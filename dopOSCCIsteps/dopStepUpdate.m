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
% 

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
                case {'text','edit','pushbutton'}
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
                        case {'edit','pushbutton'}
                            set(dop.step.current.h(i),'CallBack',dop.step.next.Callback{i},...
                                'Enable',n.Enable{i});
                    end
                    if isfield(dop.step.next,'Visible')
                        set(dop.step.current.h(i),'Visible',dop.step.next.Visible{i});
                    end
                    dop.step.text.h(i) = dop.step.current.h(i);
                otherwise
                    warndlg(sprintf('Style (%s), not recognised - can''t create',n.style{i}));
            end
        end
        for i = 1 : numel(dop.step.action.h)
            switch get(dop.step.action.h(i),'tag')
                case 'import'
                case 'plot'
            end
        end
        
    end
    
    %% update UserData
    set(dop.step.h,'UserData',dop);
    % welcome/instruction
%     dop = dopStepWelcome(dop);
    
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end