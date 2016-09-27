function dopOSCCIindent(option,varargin)
% dopOSCCI3: dopOSSCIindent ~ 18-Dec-2013 (last edit)
%
% notes:
% function to report which function is being (>)/has been run (<),
% indenting depending upon the number of invoking functions:
%
% 1 invoking function:
%   (tab) > Running 'mfilename' OR (tab) < Finished 'mfilename'
%
% 2 invoking functions:
%   (tab) >> Running 'mfilename' OR (tab) < Finished 'mfilename'
%
% number of > increases
%
% * not yet implemented (17-Dec-2013)
%
% Use:
%
% dopOSSCIdoneIndent
%
% where:
%
% Created: 18-Dec-2013 NAB

try
    comment = 1;
    if ~isempty(varargin)
        comment = varargin{1};
    end
    if comment
        %     fprintf('\nRunning %s:\n',mfilename);
        % settings
        if ~exist('option','var')
            option = 'run'; % default = run
        end
        ind_arrow = {'>','<'};
        options = {'run','done'};
        ind_msg = {'Running','Finished'};
        ind_i = strcmp(options,option);
        % create and report a message
        tmp = dbstack;
        if length(tmp) > 1
            tmp_indent = [];
            if length(tmp) > 2
                tmp_indent = (repmat(ind_arrow{ind_i},1,length(tmp)-2));
            end
            fprintf(['\n',tmp_indent,' ',ind_msg{ind_i},' %s:\n'],tmp(2).name);
        else
            fprintf('Running %s:\n',mfilename);
            fprintf('\tThis function isn''t helpful unless invoked by another function\n');
        end
        fprintf('\n');
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end