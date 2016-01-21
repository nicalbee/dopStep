 function dopCloseProgress(report)
% dopOSCCI3: dopCloseProgress
%
% dopCloseProgress([report])
%
% Closes the dopOSCCI progress bar if it happens to be open - something
% left over when you've finished processing a directory of stuff. This may
% occur with file stitching, if your stitch file has missing files in it at
% the end.
%
% dopCloseProgess gathers all available handles using MATLAB's 'allchild'
% function and then closes those associated with (dop.stitch.match_column)
%
% Use:
%
% dopCloseProgress([report]);
%
% Where
% > Optional Input:
% - report: logical variable (1 = yes, 0 = no) setting whether or not the
%   warning string from the popup message is reported to the MATLAB command
%   window. The default value is 1 = messages are reported.
%   Example:
%   dopCloseProgress;
%       or
%   dopCloseProgress(1);
%   > popups will be closed/deleted and messages will be reported
%
%   dopCloseProcess(0);
%   > popups will be closed/deleted and messages will NOT be reported
%
% Created: 22-Jan-2016 NAB
% Edits:

if ~exist('report','var') || isempty(report)
    report = 1;
end

handles = allchild(0);

waitbars = strfind(get(handles,'Tag'),'TMWWaitbar');

for i = 1 : numel(waitbars)
    delete_h = 0;
    if ~iscell(waitbars) && waitbars(i)
        delete_h = 1;
    elseif iscell(waitbars) && ~isempty(waitbars{i}) %&& waitbars{i} 
        delete_h = 1;
    end
    if delete_h
        if report
            try
                ch = get(waitbars(i),'children');
                ch_ch = get(ch(2),'children');
                msg = get(ch_ch,'String');
                fprintf('Msgbox %u:\n',i);
                for j = 1 : size(msg,1)
                    fprintf('\t%s\n',msg{j});
                end
            end
        end
        
        delete(waitbars(i));
    end
end
end
