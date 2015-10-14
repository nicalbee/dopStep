function output = dopSaveAbbreviations(varargin)
% dopOSCCI3: dopSaveAbbreviations
%
% notes:
% list of variable_name names and abbreviations used to shorten their
% representation as save variable and in save directories.
%
%
% Use:
%
% ouput = dopSaveAbbreviations([msg],[variable_name]);
%
% where:
% > Inputs:
% - msg: logical (1 = yes, 0 = no) to display messages inside function
%
% - variable_name: character/string array
%
% > Outputs:
%   if 'variable_name' is included as an input, a single abbreviation
%   character string will be ouputed
% - e.g., abbreviation = dopSaveAbbreviations('baseline')
%
%   if no inputs of just the 'msg' input are included, the output will be a
%   structure variable with a list of variable names and associated
%   abbreviations:
% - e.g., abbreviations = dopSaveAbbreviations(1);
%   or
%   abbreviations = dopSaveAbbreviations;
%
%   where, abbreviations include:
%            overall: ''
%               Left: 'L'
%              Right: 'R'
%         Difference: 'Diff'
%            Average: 'Avg'
%                poi: 'poi'
%           baseline: 'base'
%              epoch: 'ep'
%                all: 'all'
%             screen: 'srn'
%                odd: 'odd'
%               even: 'even'
%                act: 'act'
%                sep: 'sep'
%     period_samples: 'period_samples'
%        period_mean: 'period_mean'
%          period_sd: 'period_sd'
%     period_latency: 'period_latency'
%             peak_n: 'n'
%          peak_mean: 'mean'
%            peak_sd: 'sd'
%       peak_latency: 'latency'
%
% Created: 15-Aug-2014 NAB
% Last edit:
% 15-Aug-2014 NAB
% 18-Sep-2014 NAB added variable name output option
% 27-Jan-2015 NAB added activation separation
% 11-Sep-2015 NAB unsure about mean/sd labelling...
% 14-Oct-2015 NAB change 'ep' to 'epoch' for abbreviation - this relates to
%   the period calculations, now differentiated from summary by epochs in
%   that this needs to be indicated as 'epochs' which will be abbreviated
%   to 'ep'
% 14-Oct-2015 NAB also added 'baseline' to be 'baseline' as well...

% if ~exist('okay','var') || isempty(okay)
%     okay = 0;
% end
% if ~exist('msg','var')
%     msg = [];
% end
% msg{end+1} = sprintf('Run: %s',mfilename);
%
msg = 0;
variable_name = [];
if nargin
    for i = 1 : numel(varargin)
        if isnumeric(varargin{i}) && numel(varargin{i}) == 1
            msg = varargin{i};
        elseif ischar(varargin{i})
            variable_name = varargin{i};
        end
    end
end
try
    dopOSCCIindent('run',msg);%fprintf('\nRunning %s:\n',mfilename);
    
    abbreviations = struct(...
        'overall','',... this isn't used to denote 'overall' variable_name names
        'Left','L',...
        'Right','R',...
        'Difference','Diff',...
        'Average','Avg',...
        'poi','poi',...
        'baseline','baseline',...
        'base','base',...
        'epoch','epoch',...
        'epochs','ep',...
        'all','all',...
        'screen','srn',...
        'odd','odd',...
        'even','even',...
        'act','act',...
        'sep','sep',...
        'act_separation','act_sep',...
        'period_samples','period_samples',... % number of samples
        'period_mean','period_mean',...
        'period_sd_of_mean','period_sd',...
        'period_sd_of_sd','period_sd_sd',...
        'period_mean_of_sd','period_mean_sd',...
        'period_latency','period_latency', ...
        'peak_n','n',... % number of epochs
        'peak_mean','mean',...
        'peak_sd_of_mean','sd',...
        'peak_mean_sd','mean_sd',...
        'peak_sd_of_sd','sd_sd',...
        'peak_latency','latency' ...
        );
    tmp.fields = fields(abbreviations);
    if msg
        for i = 1 : numel(tmp.fields);
            fprintf('\t%u: %s = ''%s''\n',i,tmp.fields{i},abbreviations.(tmp.fields{i}));
        end
    end
    output = abbreviations;
    if ~isempty(variable_name) && isfield(abbreviations,(variable_name))
        output = abbreviations.(variable_name);
        if msg
            fprintf('\n\t''%s'' variable abbreviation requested, returning: %s\n\n',...
                variable_name,output);
        end
    end
    
    dopOSCCIindent('done',msg);%fprintf('\nRunning %s:\n',mfilename);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end
