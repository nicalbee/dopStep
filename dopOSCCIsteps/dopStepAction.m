function dopStepAction(obj,event)
% dopOSCCI3: dopStepAction
%
% notes:
% run dopStep gui action
%
% Use:
%
% Callback from gui;
%
% where:
%
% Created: 29-Oct-2015 NAB
% Edits:
% 04-Nov-2015 NAB added channels option - no action yet
% 05-Nov-2015 NAB sorted channels action
try
    dop = get(gcf,'UserData');
    switch get(obj,'tag')
        case 'import'
            [dop,okay,msg] = dopImport(dop,'file',dop.fullfile);
            if okay
                dop.tmp.h = dop.step.action.h(ismember(dop.step.action.tag,'plot'));
                set(dop.tmp.h,'enable','on');
                dop.tmp.h = dop.step.current.h(ismember(dop.step.current.tag,'plot_text'));
                set(dop.tmp.h,'Visible','on');
            end
        case 'channels'
            [dop,okay,msg] = dopChannelExtract(dop,'signal_channels',dop.def.signal_channels,...
                'event_channels',dop.def.event_channels,'gui');
            if okay
                dop.tmp.h = dop.step.current.h(ismember(dop.step.current.tag,'ch_plot_text'));
                set(dop.tmp.h,'Visible','on');
                % also need to adjust the strings
                dop.step.next.ch_list = dop.data.channel_labels;
                for i = 1 : numel(dop.step.current.h)
                    switch get(dop.step.current.h(i),'Style')
                        case 'popup'
                           set(dop.step.current.h(i),'String',dop.data.channel_labels) 
                    end
                end
            end
        case 'downsample'
            
            dop.tmp.sample_rate = 100; % assume default
            if isfield(dop.data,'file_info') && isfield(dop.data.file_info,'sample_rate')
                dop.tmp.sample_rate = dop.data.file_info.sample_rate;
            end
            [dop,~,msg] = dopDownsample(dop,'downsample_rate',dop.def.downsample_rate,...
                'sample_rate',dop.tmp.sample_rate);
        case 'event'
            [dop,~,msg] = dopEventMarkers(dop,'event_height',dop.def.event_height); % done automatically in (and redone at end of) dopDataTrim
        
        case 'plot'
            dop = dopPlot(dop);
        otherwise
            fprintf('''%s'' action not yet supported\n',get(obj,'tag'));
    end
    if exist('msg','var') && ~isempty(msg)
        warndlg(msg{end-1},sprintf('%s action:',get(obj,'tag')));
    end
    %% update UserData
    set(dop.step.h,'UserData',dop);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end