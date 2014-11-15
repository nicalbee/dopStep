function file_types = dopFileTypes(report,varargin)
% dopOSCCI3: dopFileType
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
% - report = logical variable (yes = 1, 0 = no) to report list to the
%   command window when running. Default is 'no'.
%
% > Outputs:
% - dop = dop matlab sructure
%
% Created: 07-Aug-2013 NAB
% Edits:
% 05-Sep-2014 NAB changed 'comment' to 'report' to be consistent with other
%   functions.
% 15-Sep-2014 NAB added '.dat' file for reading in data files - primarily
%   for dopEpochScreenManualRead but figure they'll be more down the line
%
% 15-Nov-2014 NAB added '.txt' but mostly because I want to ignore them...
%   also changed so there's no repeition, just lowercase...
%   % and removed .'txt' again... troubles with dopGetFileList
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
    file_types = {'.TX','.EXP','.MAT','.tx','.exp','.mat','.dat'};%,'.tx','.tw','.exp','.mat'};
%     file_types = {'.tx','.exp','.mat','.dat'};%,'.tx','.tw','.exp','.mat'};
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