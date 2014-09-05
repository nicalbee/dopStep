function abbreviations = dopSaveAbbreviations(comment)
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
% Created: 15-Aug-2014 NAB
% Last edit:
% 15-Aug-2014 NAB

% if ~exist('okay','var') || isempty(okay)
%     okay = 0;
% end
% if ~exist('msg','var')
%     msg = [];
% end
% msg{end+1} = sprintf('Run: %s',mfilename);
%
if ~exist('comment','var') || isempty(comment)
    comment = 0;
end
try
    dopOSCCIindent('run',comment);%fprintf('\nRunning %s:\n',mfilename);
    
    abbreviations = struct(...
        'overall','',... this isn't used to denote 'overall' variable names
        'Left','L',...
        'Right','R',...
        'Difference','Diff',...
        'Average','Avg',...
        'poi','poi',...
        'baseline','base',...
        'epoch','ep',...
        'all','all',...
        'screen','srn',...
        'odd','odd',...
        'even','even',...
        'act','act',...
        'sep','sep',...
        'period_samples','period_samples',... % number of samples
        'period_mean','period_mean',...
        'period_sd','period_sd',...
        'period_latency','period_latency', ...
        'peak_n','n',... % number of epochs
        'peak_mean','mean',...
        'peak_sd','sd',...
        'peak_latency','latency' ...
        );
    tmp.fields = fields(abbreviations);
    if comment
    for i = 1 : numel(tmp.fields);
        fprintf('\t%u: %s = ''%s''\n',i,tmp.fields{i},abbreviations.(tmp.fields{i}));
    end
    end
    
    dopOSCCIindent('done',comment);%fprintf('\nRunning %s:\n',mfilename);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end
