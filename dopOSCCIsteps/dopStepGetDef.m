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
try
    dop = get(gcf,'UserData');
    switch get(obj,'tag')
        case {'downsample_rate','event_height',...
                'event_sep',...
                'epoch_lower','epoch_upper',...
                'base_lower','base_upper',...
                'poi_lower','poi_upper',...
                'act_lower','act_upper',...
                'act_separation','act_separation_pct',...
                'baseline_lower','baseline_upper',...
                'act_window' ...
                }
            dop.tmp.value = str2double(event.Source.String);
            if ~isnan(dop.tmp.value)
                switch get(obj,'tag')
                    case {'epoch_lower','epoch_upper',...
                            'base_lower','base_upper',...
                            'poi_lower','poi_upper',...
                            'act_lower','act_upper',...
                            'baseline_lower','baseline_upper'}
                        dop.tmp.options = {'lower','upper'};
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
                        dopButtonEnable(dop);
                    otherwise
                        dop.def.(get(obj,'tag')) = dop.tmp.value;
                        fprintf('''%s'' value set to: %i\n',get(obj,'tag'),dop.def.(get(obj,'tag')));
                        %% enable a button
                        set(dop.step.action.h(ismember(dop.step.action.tag,strtok(get(obj,'tag'),'_'))),'enable','on');
                end
                
            else
                dop.tmp.warn = sprintf('''%s'' needs to be numeric (not ''%s''). Please try again',...
                    get(obj,'tag'),event.Source.String);
                fprintf('Warning: %s\n',dop.tmp.warn);
                warndlg(dop.tmp.warn,sprintf('%s entry error:',get(obj,'tag')));
                set(obj,'String','re-type');
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
            dop.tmp.value = get(get(obj,'SelectedObject'),'String');
            dop.def.(dop.tmp.var) = dop.tmp.value;
            fprintf('''%s'' value set to: %s\n',...
                dop.tmp.var,dop.tmp.value);
            switch dop.tmp.value
                case 'overall'
                    set(dop.step.action.h(ismember(dop.step.action.tag,strtok(get(obj,'tag'),'-'))),'enable','on');
                    dop.tmp.times = struct('basel','off','epoch','off');
                    set(dop.step.action.h(ismember(dop.step.action.tag,dop.step.current.name)),'enable','on');
                case {'epoch','deppe'}
                    set(dop.step.action.h(ismember(dop.step.action.tag,dop.step.current.name)),'enable','off');
                    switch dop.tmp.value
                        case 'epoch'
                            dop.tmp.times = struct('base','off','epoch','on');
                        case 'deppe'
                            dop.tmp.times = struct('base','on','epoch','on');
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
            dopButtonEnable(dop);
        otherwise
            fprintf('''%s'' action not yet supported\n',get(obj,'tag'));
    end
    %% update UserData
    set(dop.step.h,'UserData',dop);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end
%% dopButtonEnable
% enable the button
function dopButtonEnable(dop)
switch dop.step.current.name
    case 'norm'
        if isfield(dop.def,'norm_method')
            dop.tmp.vars = {'epoch','base'};
            switch dop.def.norm_method
                case 'overall'
                    dop.tmp.required = [0 0];
                case {'epoch','deppe'}
                    % need to have both of these values
                    switch dop.def.norm_method
                        case 'epoch'
                            dop.tmp.required = [1 0];
                        case 'deppe'
                            dop.tmp.required = [1 1];
                    end
            end
        end
    case 'epoch'
        dop.tmp.vars = {'epoch'};
        dop.tmp.required = 1;
    case 'screen'
        dop.tmp.vars = {'act_sep','act_separation_pct'};
        dop.tmp.required = [0 0];
    case 'baseline'
        dop.tmp.vars = {'baseline'};
        dop.tmp.required = 1;
    case 'li'
        dop.tmp.vars = {'poi'};
        dop.tmp.required = 1;
end
dop.tmp.okay = zeros(1,numel(dop.tmp.vars));
for i = 1 : numel(dop.tmp.vars)
    if isfield(dop.def,dop.tmp.vars{i}) && numel(dop.def.(dop.tmp.vars{i})) == 2
        switch dop.step.current.name
            case 'li'
                if isfield(dop.def,'act_window') && ~isempty(dop.def.act_window)
                    dop.tmp.okay(i) = 1;
                end
            otherwise
                dop.tmp.okay(i) = 1;
        end
    end
end

dop.tmp.enable = 'off';
% switch dop.step.current.name
%     case {'norm','epoch'}
if isfield(dop.def,'norm_method') && strcmp(dop.def.norm_method,'overall') || ...
        and(sum(dop.tmp.okay),sum(dop.tmp.required == dop.tmp.okay) == numel(dop.tmp.okay)) || ...
        strcmp(dop.step.current.name,'screen')
    dop.tmp.enable = 'on';
end
set(dop.step.action.h(ismember(dop.step.action.tag,dop.step.current.name)),'enable',dop.tmp.enable);
end