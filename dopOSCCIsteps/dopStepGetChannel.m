function dopStepGetChannel(obj,event)
% dopOSCCI3: dopGetChannel
%
% notes:
% dopStep channel definition
%
% Use:
%
% Callback from gui;
%
% where:
%
% Created: 04-Nov-2015 NAB
% Edits:
%
try
    dop = get(gcf,'UserData');
    dop.tmp.channel = strtok(get(obj,'tag'),'_');
    dop.tmp.signal_options = {'left','right'};
    if ~isfield(dop.step,'channels_okay')
        dop.step.channels_okay = zeros(1,3);
    end
                                    
    switch dop.tmp.channel
        case dop.tmp.signal_options
            dop.tmp.channel_number = find(ismember(dop.tmp.signal_options,dop.tmp.channel));
            dop.def.signal_channels(dop.tmp.channel_number) = event.Source.Value;
            dop.def.signal_channel_labels{dop.tmp.channel_number} = event.Source.String{event.Source.Value};
            dop.step.channels_okay(dop.tmp.channel_number) = 1;
        case 'event'
            dop.def.event_channels = event.Source.Value;
            dop.def.event_channel_labels = event.Source.String(event.Source.Value);
            % keep it as a cell array for the time being
            dop.step.channels_okay(3) = 1;
    end
    
    fprintf('%s selected for ''%s'' channel (data column %i)\n',...
        event.Source.String{event.Source.Value},dop.tmp.channel,event.Source.Value);
    %% channel button visible
    if sum(dop.step.channels_okay) == numel(dop.step.channels_okay)
        % turn channel button on
        set(dop.step.action.h(ismember(dop.step.action.tag,'channels')),'enable','on');
    end
                    
%     switch get(obj,'tag')
%         case 'import'
%             [dop,okay] = dopImport(dop,'file',dop.fullfile);
%             if okay
%                 dop.tmp.h = dop.step.action.h(ismember(dop.step.action.tag,'plot'));
%                 set(dop.tmp.h,'enable','on');
%                 dop.tmp.h = dop.step.current.h(ismember(dop.step.current.tag,'plot_text'));
%                 set(dop.tmp.h,'Visible','on');
%             end
%         case 'plot'
%             dop = dopPlot(dop);
%         otherwise
%             fprintf('''%s'' action not yet supported\n',get(obj,'tag'));
%     end
    %% update UserData
    set(dop.step.h,'UserData',dop);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end