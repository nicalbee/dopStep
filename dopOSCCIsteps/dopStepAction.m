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
%
try
    dop = get(gcf,'UserData');
    switch get(obj,'tag')
        case 'import'
            [dop,okay] = dopImport(dop,'file',dop.fullfile);
            if okay
                dop.tmp.h = dop.step.action.h(ismember(dop.step.action.tag,'plot'));
                set(dop.tmp.h,'enable','on');
                dop.tmp.h = dop.step.current.h(ismember(dop.step.current.tag,'plot_text'));
                set(dop.tmp.h,'Visible','on');
            end
        case 'plot'
            dop = dopPlot(dop);
        otherwise
            fprintf('''%s'' action not yet supported\n',get(obj,'tag'));
    end
    %% update UserData
    set(dop.step.h,'UserData',dop);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end