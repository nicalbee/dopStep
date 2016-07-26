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
            [dop,okay,msg] = dopImport(dop,'file',dop.fullfile,'gui');
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
        case 'norm'
            if isfield(dop,'def') && isfield(dop.def,'norm_method')
                switch dop.def.norm_method
                    case 'overall'
                        [dop,okay,msg] = dopNorm(dop,'norm_method',dop.def.norm_method);
                    case 'epoch'
                        [dop,okay,msg] = dopNorm(dop,'norm_method',dop.def.norm_method,...
                            'epoch',dop.def.epoch);
                    case 'deppe'
                        [dop,okay,msg] = dopNorm(dop,'norm_method','deppe_epoch',dop.def.norm_method,...
                            'epoch',dop.def.epoch,'baseline',dop.def.base,'gui');
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
            if isfield(dop.def,'event_sep') && ~isempty(dop.def.event_sep)
                [dop,okay,msg] = dopEventMarkers(dop,'event_height',dop.def.event_height,...
                    'event_sep',dop.def.event_sep,'gui');
            else
                [dop,okay,msg] = dopEventMarkers(dop,'event_height',dop.def.event_height,'gui'); % done automatically in (and redone at end of) dopDataTrim
            end
            if okay
                dop.tmp.h = dop.step.current.h(ismember(dop.step.current.tag,'event_chan_plot_info')); % 25-july-2016 NAB 'even_'?? should be event - changed
                set(dop.tmp.h,'Visible','on');
            end
        case 'heart'
            dop.tmp.check = struct(...
                'hc_type','step',...
                'hc_plot',0);
            dop.tmp.check_fields = fields(dop.tmp.check);
            for i = 1 : numel(dop.tmp.check_fields)
                if ~isfield(dop.def,dop.tmp.check_fields{i})
                    dop.def.(dop.tmp.check_fields{i}) = dop.tmp.check.(dop.tmp.check_fields{i});
                end
            end
            if dop.def.hc_plot
                [dop,okay,msg] = dopHeartCycle(dop,'type',dop.def.hc_type,'plot');
            else
                [dop,okay,msg] = dopHeartCycle(dop,'type',dop.def.hc_type);
            end
        case 'plot'
            dop = dopPlot(dop);
        otherwise
            fprintf('''%s'' action not yet supported\n',get(obj,'tag'));
    end
    if exist('msg','var') && ~isempty(msg)
        if iscell(msg)
            gui_msg = msg{end};
        else
            gui_msg = msg;
        end
        warndlg(gui_msg,sprintf('%s action:',get(obj,'tag')));
    end
    %% update UserData
    set(dop.step.h,'UserData',dop);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end