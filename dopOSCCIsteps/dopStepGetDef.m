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
                'poi_lower','poi_upper'}
            dop.tmp.value = str2double(event.Source.String);
            if ~isnan(dop.tmp.value)
                switch get(obj,'tag')
                    case {'epoch_lower','epoch_upper',...
                            'base_lower','base_upper',...
                            'poi_lower','poi_upper'}
                        dop.tmp.options = {'lower','upper'};
                        [dop.tmp.var,dop.tmp.rem] = strtok(get(obj,'tag'),'_');
                        dop.tmp.element = strrep(dop.tmp.rem,'_','');
                        dop.def.(dop.tmp.var)(ismember(dop.tmp.options,dop.tmp.element)) = dop.tmp.value;
                        fprintf('''%s'' %s value set to: %i\n',...
                            dop.tmp.var,dop.tmp.element,dop.tmp.value);
%                         dop = dopStepTimingPlot(dop);
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
                case {'epoch','deppe'}
                    
                    switch dop.tmp.value
                        case 'epoch'
                            dop.tmp.value = 'epoch';
                        case 'deppe'
                            dop.tmp.value = 'baseline';
                    end
                    [dop.tmp.h_var,dop.tmp.rem] = strtok(get(dop.step.current.h,'tag'),'_');
                    dop.tmp.h_extra = strtok(dop.tmp.rem,'_');
                    
                    dop.tmp.filt.var = ismember(dop.tmp.h_var,dop.tmp.value);
                    dop.tmp.filt.lower = ismember(dop.tmp.h_extra,'lower');
                    dop.tmp.filt.upper = ismember(dop.tmp.h_extra,'upper');
                    
                    set(dop.step.current.h(and(dop.tmp.filt.var,dop.tmp.filt.lower)),'enable','on');
                    set(dop.step.current.h(and(dop.tmp.filt.var,dop.tmp.filt.upper)),'enable','on');
            end
        otherwise
            fprintf('''%s'' action not yet supported\n',get(obj,'tag'));
    end
    %% update UserData
    set(dop.step.h,'UserData',dop);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end