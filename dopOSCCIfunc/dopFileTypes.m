function [file_types,file_types_search] = dopFileTypes(report,search_dir,varargin)
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
%
% 29-Oct-2015 NAB added file_types_search output for uigetfile browse check
%   see dopStepBrowseFile function
%
% 29-Oct-2015 NAB added search_dir but it's not working properly - I'll
%   leave it in for the moment in case it makes sense at some point
if ~exist('report','var') || isempty(report)
    report = 0;
end
if ~exist('search_dir','var') || isempty(search_dir)
    search_dir = '';
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
    file_types_search = [];
    search_sep = ';';
    for i = 1 : numel(file_types)
        if i == numel(file_types)
            search_sep = '';
        end
        switch file_types{i}
            case {'.TX','.tx'}
                file_types_search = sprintf('%s%s*%s*%s',file_types_search,search_dir,file_types{i},search_sep);
            otherwise
                file_types_search = sprintf('%s%s*%s%s',file_types_search,search_dir,file_types{i},search_sep);
        end
    end
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