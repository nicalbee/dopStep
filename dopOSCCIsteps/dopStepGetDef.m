function dopStepGetDef(obj,event)
% dopOSCCI3: dopStepGetDef
%
% notes:
% run dopStep get definition information
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
% 30-Jul-2016 NAB added search to add definition values to gui if values
%   exsit
% 03-Aug-2016 NAB lots of development - fixed epoch enable today
try
    dop = get(gcf,'UserData');
    dop.tmp.options = {'lower','upper'};
    switch get(obj,'tag')
        case {'downsample_rate','event_height',...
                'event_sep',...
                'epoch_lower','epoch_upper',...
                'baseline_lower','baseline_upper',...
                'poi_lower','poi_upper',...
                'act_lower','act_upper',...
                'act_separation','act_separation_pct',...
                'act_window' ...
                }
            if ischar(event)
                dop.tmp.value = [];
                [dop.tmp.var,dop.tmp.rem] = strtok(get(obj,'tag'),'_');
                switch dop.tmp.var
                    case 'act'
                        dop.tmp.var = 'act_range';
                end
                dop.tmp.element = strrep(dop.tmp.rem,'_','');
                switch get(obj,'tag')
                    case {'epoch_lower','epoch_upper',...
                            'baseline_lower','baseline_upper',...
                            'poi_lower','poi_upper',...
                            'act_lower','act_upper' ...
                            }
                    otherwise
                        dop.tmp.var = get(obj,'tag');
                end
                if isfield(dop,'def') && isfield(dop.def,dop.tmp.var) && ~isempty(dop.def.(dop.tmp.var))
                    dop.tmp.index = 1;
                    if numel(dop.def.(dop.tmp.var)) > 1
                        dop.tmp.index = ismember(dop.tmp.options,dop.tmp.element);
                    end
                    dop.tmp.value = dop.def.(dop.tmp.var)(dop.tmp.index);
                    set(obj,'String',num2str(dop.tmp.value));
                end
            else
                dop.tmp.value = str2double(event.Source.String);
            end
            if ~isempty(dop.tmp.value) && ~isnan(dop.tmp.value)
                switch get(obj,'tag')
                    case {'epoch_lower','epoch_upper',...
                            'baseline_lower','baseline_upper',...
                            'poi_lower','poi_upper',...
                            'act_lower','act_upper'...
                            }
                        
                        [dop.tmp.var,dop.tmp.rem] = strtok(get(obj,'tag'),'_');
                        switch dop.tmp.var
                            case 'act'
                                dop.tmp.var = 'act_range';
                        end
                        dop.tmp.element = strrep(dop.tmp.rem,'_','');
                        dop.def.(dop.tmp.var)(ismember(dop.tmp.options,dop.tmp.element)) = dop.tmp.value;
                        fprintf('''%s'' %s value set to: %i\n',...
                            dop.tmp.var,dop.tmp.element,dop.tmp.value);
                        %                         dop = dopStepTimingPlot(dop);
                        dopStepButtonEnable(dop);
                    otherwise
                        dop.def.(get(obj,'tag')) = dop.tmp.value;
                        fprintf('''%s'' value set to: %i\n',get(obj,'tag'),dop.def.(get(obj,'tag')));
                        %% enable a button
                        set(dop.step.action.h(ismember(dop.step.action.tag,strtok(get(obj,'tag'),'_'))),'enable','on');
                end
                
            else
                if ~ischar(event)
                    %                     event_string = event;
                    %                 else
                    event_string = event.Source.String;
                    
                    dop.tmp.warn = sprintf('''%s'' needs to be numeric (not ''%s''). Please try again',...
                        get(obj,'tag'),event_string);
                    
                    fprintf('Warning: %s\n',dop.tmp.warn);
                    warndlg(dop.tmp.warn,sprintf('%s entry error:',get(obj,'tag')));
                    set(obj,'String','re-type');
                end
            end
        case 'hc_plot'
            dop.tmp.value = get(obj,'Value');
            dop.tmp.var = get(obj,'tag');
            dop.def.(dop.tmp.var) = dop.tmp.value;
            fprintf('''%s'' value set to: %i\n',...
                dop.tmp.var,dop.tmp.value);
        case 'hc_type'
            dop.tmp.value = get(get(obj,'SelectedObject'),'String');
            dop.tmp.var = get(obj,'tag');
            dop.def.(dop.tmp.var) = dop.tmp.value;
            fprintf('''%s'' value set to: %s\n',...
                dop.tmp.var,dop.tmp.value);
        case 'norm-method_radio'
            % normalisation method
            [dop.tmp.method_var,dop.tmp.rem] = strtok(get(obj,'tag'),'_');
            [dop.tmp.method,dop.tmp.rem] = strtok(dop.tmp.method_var,'-');
            dop.tmp.var = strrep(dop.tmp.method_var,'-','_');
            if ischar(event)
                dop.tmp.value = [];
                if isfield(dop,'def') && isfield(dop.def,dop.tmp.var) && ~isempty(dop.def.(dop.tmp.var))
                    dop.tmp.value = dop.def.(dop.tmp.var);
                    
                end
            else
                dop.tmp.value = get(get(obj,'SelectedObject'),'String');
            end
            if ~isempty(dop.tmp.value)
                dop.def.(dop.tmp.var) = dop.tmp.value;
                fprintf('''%s'' value set to: %s\n',...
                    dop.tmp.var,dop.tmp.value);
                switch dop.tmp.value
                    case 'overall'
                        set(dop.step.action.h(ismember(dop.step.action.tag,strtok(get(obj,'tag'),'-'))),'enable','on');
                        dop.tmp.times = struct('baseline','off','epoch','off');
                        set(dop.step.action.h(ismember(dop.step.action.tag,dop.step.current.name)),'enable','on');
                    case {'epoch','deppe'}
                        set(dop.step.action.h(ismember(dop.step.action.tag,dop.step.current.name)),'enable','off');
                        switch dop.tmp.value
                            case 'epoch'
                                dop.tmp.times = struct('baseline','off','epoch','on');
                            case 'deppe'
                                dop.tmp.times = struct('baseline','on','epoch','on');
                        end
                end
                [dop.tmp.h_var,dop.tmp.rem] = strtok(get(dop.step.current.h,'tag'),'_');
                dop.tmp.h_extra = strtok(dop.tmp.rem,'_');
                
                dop.tmp.filt = [];
                dop.tmp.filt.lower = ismember(dop.tmp.h_extra,'lower');
                dop.tmp.filt.upper = ismember(dop.tmp.h_extra,'upper');
                dop.tmp.times.list = fields(dop.tmp.times);
                for i = 1 : numel(dop.tmp.times.list)
                    dop.tmp.filt.var = ismember(dop.tmp.h_var,dop.tmp.times.list{i});
                    set(dop.step.current.h(and(dop.tmp.filt.var,dop.tmp.filt.lower)),'enable',dop.tmp.times.(dop.tmp.times.list{i}));
                    set(dop.step.current.h(and(dop.tmp.filt.var,dop.tmp.filt.upper)),'enable',dop.tmp.times.(dop.tmp.times.list{i}));
                end
                dopStepButtonEnable(dop);
            end
        case {'left_channel','right_channel','event_channel'}
%             if isfield(dop,'data') && isfield(dop.data,'channel_labels')
%                 set(obj,'Value',find(ismember(dop.data.channel_labels,strtok(get(obj,'Tag'),'_'))));
%             end
        otherwise
%             fprintf('''%s'' action not yet supported\n',get(obj,'tag'));
    end
    %% update UserData
    set(dop.step.h,'UserData',dop);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end