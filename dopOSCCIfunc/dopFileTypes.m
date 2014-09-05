function file_types = dopFileTypes(report)
% dopOSCCI3: dopNew ~ 18-Dec-2013 (last edit)
%
% notes:
% returns a cell array of known dopOSCCI file types
%
% Use:
%
% file_types = dopFileTypes;
%
% where:
% > Inputs:
%
% > Outputs:
% - dop = dop matlab sructure
%
% Created: 07-Aug-2013 NAB
% Edits:
% 05-Sep-2014 NAB changed 'comment' to 'report' to be consistent with other
%   functions.
if ~exist('report','var') || isempty(report)
    report = 0;
end
try
    %     tmp  =  dbstack;
    %     left_tab = [];
    %     if length(tmp) > 1
    %         left_tab = '\t';
    %     end
    %     fprintf(['\n',left_tab,'Running %s\n'],mfilename);
    
    
    dopOSCCIindent('run',report);
    % hopefully not case sensitive in most instances...
    file_types = {'.TX','.EXP','.MAT','.tx','.exp','.mat'};%,'.tx','.tw','.exp','.mat'};
    if report
        fprintf('\tdopOSCCI recognises the following file types:\n');
        for i = 1 : numel(file_types)
            fprintf('\t - %s\n',file_types{i});
        end
    end
    dopOSCCIindent('done',report);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end