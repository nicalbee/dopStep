function dop = dopStep
% dopOSCCI3: dopStep
%
% notes:
% step through gui to teach dopOSCCI steps
%
% Use:
%
% dop = dopStep;
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
%
% Created: 13-Oct-2015 NAB
% Edits:
% 14-Oct-2015 NAB created dopStepFontAdjust
% 14-Oct-2015 NAB created dopStepMove
% 14-Oct-2015 NAB created dopStepSettings

try
    fprintf('\nRunning %s:\n',mfilename);
    dop.step.h = figure(...
        'Name','dopOSCCI: Steps',...
        'NumberTitle','off',...
        'Units','Normalized',...
        'Position',[.3 .4 .4 .4],...
        'Tag','dopStep',...
        'Color',[.7 1 .7],...
        'MenuBar','none',...
        'ToolBar','none');
    %% create figure basics
    %% - font adjust
    dop.step.font_adj.string = {'-','+'};
    dop.step.font_adj.tooltip = {'smaller','larger'};
    dop.step.font_adj.size = [.05 .05]; % x & y dimensions
    dop.step.font_adj.position = [.05 .05]; % x & y start positions, bottom left corner
    for i = 1 : numel(dop.step.font_adj.string)
        dop.step.font_adj.pos = dop.step.font_adj.position.*[i 1];
        dop.step.font_adj.h(i) = uicontrol(dop.step.h,...
            'style','pushbutton','String',dop.step.font_adj.string{i},...
            'tag',['font_adj_',dop.step.font_adj.tooltip{i}],...
            'Units','Normalized',...
            'CallBack',@dopStepFontAdjust,...
            'Position',[dop.step.font_adj.pos dop.step.font_adj.size],...
            'ToolTipString',...
            sprintf('Click to make font %s',dop.step.font_adj.tooltip{i}));
    end
    %% - back & forward buttons
    dop.step.move.string = {'back','next'};
    dop.step.move.tooltip = {'previous','next'};
    dop.step.move.size = [.1 .05]; % x & y dimensions
    dop.step.move.position = [.05 .9; .85 .9]; % x & y start positions, bottom left corner
    dop.step.move.visible = {'on','on'};
    for i = 1 : numel(dop.step.move.string)
        dop.step.move.pos = dop.step.move.position(i,:);
        dop.step.move.h(i) = uicontrol(dop.step.h,...
            'style','pushbutton','String',dop.step.move.string{i},...
            'tag',['move_',dop.step.move.string{i}],...
            'Units','Normalized',...
            'CallBack',@dopStepMove,...
            'Position',[dop.step.move.pos dop.step.move.size],...
            'ToolTipString',...
            sprintf('Click to move to %s step',dop.step.move.tooltip{i}),...
            'Visible',dop.step.move.visible{i});
    end
    
    %% update UserData
    set(dop.step.h,'UserData',dop);
    % welcome/instruction
    %     dop = dopStepWelcome(dop);
    %% update current information
    dopStepSettings(dop.step.h,'start');
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end