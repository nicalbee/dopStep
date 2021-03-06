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
% 21-Sep-2016 NAB added upper epoch < 1 check
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
                        switch get(obj,'tag')
                            case 'epoch_upper'
                                if dop.tmp.value < 1
                                    switch questdlg('Upper epoch value less than 1, please confirm:','Check value:','Yes','Oops','Oops');
                                        case 'Oops'
                                            set(obj,'String','Try again');
                                            fprintf('Upper epoch value less than 1 (%i), Cancelling\n',dop.tmp.value);
                                            return
                                    end
                                end
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
        case {'save_summary_overall','save_summary_epoch'...
                'save_channels_Left','save_channels_Right','save_channels_Difference','save_channels_Average',...
                'save_periods_epoch','save_periods_baseline','save_periods_poi',...
                'save_epochs_all','save_epochs_screen','save_epochs_odd','save_epochs_even'...
                'save_variables_n','save_variables_LI','save_variables_SD','save_variables_Latency'}
            %                 fprintf('\t%s\n',get(obj,'tag'));
            [~,dop.tmp.rem] = strtok(get(obj,'tag'),'_'); % drop the 'save' bit
            [dop.tmp.var,dop.tmp.rem] = strtok(dop.tmp.rem,'_'); % get the variable name
            dop.tmp.option = strtok(dop.tmp.rem,'_'); % get the option information
            if ischar(event)
                dop.tmp.value = 0;
                
                
                if isfield(dop,'save') && isfield(dop.save,dop.tmp.var) && ...
                        sum(ismember(dop.save.(dop.tmp.var),dop.tmp.option))
                    dop.tmp.value = 1;
                elseif isfield(dop,'step') && isfield(dop.step,'next') && isfield(dop.step.next,'checked')
                    dop.tmp.tag_num = find(ismember(dop.step.next.tag,get(obj,'tag')));
                    if ~isempty(dop.tmp.tag_num) && dop.tmp.tag_num && numel(dop.step.next.checked) >= dop.tmp.tag_num
                        dop.tmp.value = dop.step.next.checked(dop.tmp.tag_num);
                    end
                    if dop.tmp.value
                        switch dop.tmp.var
                            case 'variables'
                                % translate this
                                dop.tmp.translation = struct(...
                                    'n','peak_n',...
                                    'LI','peak_mean',...
                                    'SD','peak_sd_of_mean',...
                                    'Latency','peak_latency');
                                dop.tmp.option = dop.tmp.translation.(dop.tmp.option);
                        end
                        if ~isfield(dop,'save') || ~isfield(dop.save,dop.tmp.var)
                            dop.save.(dop.tmp.var) = {dop.tmp.option};
                            dop.def.(['save_',dop.tmp.var]) = {dop.tmp.option};
                        else
                            dop.save.(dop.tmp.var){end+1} = dop.tmp.option;
                            dop.def.(['save_',dop.tmp.var]){end+1} = dop.tmp.option;
                        end
                    end
                end
                
                set(obj,'value',dop.tmp.value);
                
            else
                dop.tmp.value = event.Source.Value;
                switch dop.tmp.var
                    case 'variables'
                        % translate this
                        dop.tmp.translation = struct(...
                            'n','peak_n',...
                            'LI','peak_mean',...
                            'SD','peak_sd_of_mean',...
                            'Latency','peak_latency');
                        dop.tmp.option = dop.tmp.translation.(dop.tmp.option);
                end
                if dop.tmp.value
                    dop.save.(dop.tmp.var){end+1} = dop.tmp.option;
                    dop.def.(['save_',dop.tmp.var]){end+1} = dop.tmp.option;
                else
                    if numel(dop.save.(dop.tmp.var)) == 1
                        dop.tmp.msg = sprintf('''%s'' save variable must have at least 1 item',dop.tmp.var);
                        fprintf('%s\n',dop.tmp.msg);
                        warndlg(dop.tmp.msg,'Must maintain variable:');
                        set(obj,'Value',1);
                        return
                    else
                        dop.save.(dop.tmp.var)(ismember(dop.save.(dop.tmp.var),dop.tmp.option)) = [];
                        dop.def.(['save_',dop.tmp.var])(ismember(dop.save.(dop.tmp.var),dop.tmp.option)) = [];
                    end
                end
                dop.tmp.include = {'exluded from','included in'};
                fprintf('\t''%s'' option %s ''%s'' save variable\n',...
                    dop.tmp.option,dop.tmp.include{dop.tmp.value+1},dop.tmp.var);
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