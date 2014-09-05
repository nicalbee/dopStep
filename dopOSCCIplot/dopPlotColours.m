function col_out = dopPlotColours(type,comment)
% dopOSCCI3: dopNew
%
% notes:
% basic structure of a function to save time when creating a new one
%
% * not yet implemented (19-Dec-2013)
%
% Use:
%
% [dop,okay,msg] = dopNew(dop,[]);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 29-Aug-2014 NAB
% Last edit:
% 29-Aug-2014 NAB

% if ~exist('okay','var') || isempty(okay)
%     okay = 0;
% end
% if ~exist('msg','var')
%     msg = [];
% end
% msg{end+1} = sprintf('Run: %s',mfilename);
%
col_out = [0 0 1]; % default colour
if ~exist('type','var') || isempty(type)
    type = [];
end
if ~exist('comment','var') || isempty(comment)
    comment = 0;
end
try
    dopOSCCIindent('run',comment);%fprintf('\nRunning %s:\n',mfilename);
    % rgb (red geen blue) coordindates
    
    colours = struct(...
        'act_correct',[0 .5 .5],... ?
        'rawleft',[0 1 1],... % cyan
        'rawright',[1 0 1],... % magenta
        'correctleft',[0 0 .8],...
        'correctright',[.8 0 0],...
        'hc_events',[.8 .6 0],...
        'xzero',[.9 .9 .9], ... % faint grey
        'yzero',[.9 .9 .9], ... % faint grey
        'zero',[.9 .9 .9], ... % faint grey
        'left',[0 0 .8],... % blue
        'right',[.8 0 0],... % red
        'event',[0 .7 .2],... % green
        'difference',[0 .4 0],...
        'average',[.4 0 .4],... ?
        'peak',[1 0 1], ... % magenta/pink
        'epoch',[.8 .6 0], ... orange?
        'poi',[0 1 .2],... % light green
        'act_window',[.8 .8 0],... yellow?
        'baseline',[0 0 0]... % black
        );
    if isempty(type)
        col_out = colours;
    else
        if isfield(colours,type)
            col_out = colours.(type);
            if comment
                fprintf('Colour for %s: [%1.1f %1.1f %1.1f]',type,col_out);
            end
        else
            fprintf('Type (%s) unknow, defaulting to blue\n',type');
            col_out = colours.left;
        end
    end
    
    dopOSCCIindent('done',comment);%fprintf('\nRunning %s:\n',mfilename);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end
