function dopCloseMsg(report)
% dopOSCCI3: dopCloseMsg
%
% dopCloseMsg([report])
%
% Closes the popup warning messages that occur while running the dopOSCCI
% function. If a 'file_list' is run, there can be quite a few messages and
% 'close all' doesn't close them.
%
% dopCloseMsg gathers all available handles using MATLAB's 'allchild'
% function and then closes those associated with msg boxes
%
% Use:
%
% dopCloseMsg([report]);
%
% Where
% > Optional Input:
% - report: logical variable (1 = yes, 0 = no) setting whether or not the
%   warning string from the popup message is reported to the MATLAB command
%   window. The default value is 1 = messages are reported.
%   Example:
%   dopCloseMsg;
%       or
%   dopCloseMsg(1);
%   > popups will be closed/deleted and messages will be reported
%
%   dopCloseMsg(0);
%   > popups will be closed/deleted and messages will NOT be reported
%
% Created: 05-Sep-2014 NAB
% Edits:
% 08-Sep-2014 NAB problems with multiple popups - still not reporting all
%   of the messages
% 08-Feb-2016 NAB had some troubles with this but adjusted handles and
%   msgboxes (logical) variable interaction and seems to be fine now.
% 14-Feb-2016 NAB needs to have something in it - checks for elements
if ~exist('report','var') || isempty(report)
    report = 1;
end

handles = allchild(0);

msgboxes = strfind(get(handles,'Tag'),'Msgbox');

for i = 1 : numel(handles) %numel(msgboxes)
    delete_h = 0;
    if ~iscell(msgboxes) && numel(msgboxes) && ~isempty(msgboxes(i))
        delete_h = 1;
    elseif iscell(msgboxes) && numel(msgboxes) && ~isempty(msgboxes{i}) %&& msgboxes{i}
        delete_h = 1;
    end
    if delete_h
        if report
            try
                ch = get(handles(i),'children');
                ch_ch = get(ch(2),'children');
                msg = get(ch_ch,'String');
                fprintf('Msgbox %u:\n',i);
                for j = 1 : size(msg,1)
                    fprintf('\t%s\n',msg{j});
                end
            end
        end
            delete(handles(i));
    end
end
end
