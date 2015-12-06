function dopStep
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
% 04-Nov-2015 NAB added 'channels' option

try
    fprintf('\nRunning %s:\n',mfilename);
    dop.struc_name = 'dop'; % some function like to know this
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
    dop.step.font_adj.position = [.05 .8]; % x & y start positions, bottom left corner
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
    %% - action buttons
    dop.step.action.string = {'Import','Channels','Events','Norm',...
        'Heart','Epoch','Screen','Baseline','LI'}; % ,'Plot'
    dop.step.action.n = numel(dop.step.action.string);
    dop.step.action.tooltip = lower(dop.step.action.string); %{'import','channels','event','norm','heart','plot'};
    dop.step.action.tag = dop.step.action.tooltip;
    dop.step.action.size = [.1 .1]; % x & y dimensions
    dop.step.action.pos_start = [.05 .01];
    dop.step.action.position = repmat(dop.step.action.pos_start,dop.step.action.n,1); % x & y start positions, bottom left corner
    dop.step.action.position(:,1) = ...
        dop.step.action.pos_start(1):...
        dop.step.action.size(1):...
        dop.step.action.size(1)*dop.step.action.n;
    dop.step.action.visible = repmat({'on'},1,dop.step.action.n);%,'on','on','on','on''on',};
    dop.step.action.enable = repmat({'off'},1,dop.step.action.n);
    for i = 1 : dop.step.action.n
        dop.step.action.pos = dop.step.action.position(i,:);
        dop.step.action.h(i) = uicontrol(dop.step.h,...
            'style','pushbutton','String',dop.step.action.string{i},...
            'tag',dop.step.action.tag{i},...
            'Units','Normalized',...
            'CallBack',@dopStepAction,...
            'Position',[dop.step.action.pos dop.step.action.size],...
            'ToolTipString',...
            sprintf('Click to %s current data',dop.step.action.tooltip{i}),...
            'Visible',dop.step.action.visible{i},...
        'enable',dop.step.action.enable{i});
    end
    %% - optional action buttons
    dop.step.option.string = {'Downsample','Trim'};
    dop.step.option.tooltip = {'downsample','trim'};
    dop.step.option.tag = dop.step.option.tooltip;
    dop.step.option.size = [.1 .1]; % x & y dimensions
    dop.step.option.position = [.85 .75; .85 .65; .85 .55; .85 .45; .85 .35; .85 .25]; % x & y start positions, bottom left corner
    dop.step.option.visible = repmat({'on'},1,numel(dop.step.option.string)); %{'on','on','on','on','on','on'};
    dop.step.option.enable = repmat({'off'},1,numel(dop.step.option.string)); %{'off','off','off','off','off','off'};
    for i = 1 : numel(dop.step.option.string)
        dop.step.option.pos = dop.step.option.position(i,:);
        dop.step.option.h(i) = uicontrol(dop.step.h,...
            'style','pushbutton','String',dop.step.option.string{i},...
            'tag',dop.step.option.tag{i},...
            'Units','Normalized',...
            'CallBack',@dopStepOption,...@dopStepAction,...
            'Position',[dop.step.option.pos dop.step.option.size],...
            'ToolTipString',...
            sprintf('Click to %s current data (optional step)',dop.step.option.tooltip{i}),...
            'Visible',dop.step.option.visible{i},...
        'enable',dop.step.option.enable{i});
    end
    dop.step.FontSize = get(dop.step.option.h(i),'FontSize');
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