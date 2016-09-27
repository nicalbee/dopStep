 function dopClosePlots(report)
% dopOSCCI3: dopClosePlots
%
% dopClosePlots([report])
%
% Closes dopOSCCI plots
%
% dopCloseProgess gathers all available handles using MATLAB's 'allchild'
% function and then closes those associated with (dop.stitch.match_column)
%
% Use:
%
% dopClosePlots([report]);
%
% Where
% > Optional Input:
% - report: logical variable (1 = yes, 0 = no) setting whether or not the
%   warning string from the popup message is reported to the MATLAB command
%   window. The default value is 1 = messages are reported.
%   Example:
%   dopClosePlots;
%       or
%   dopClosePlots(1);
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


handles = get(0,'Children'); %allchild(0);

for i = 1 : numel(handles)
    delete_h = 1;
%     if ~iscell(handles) && handles(i)
%         delete_h = 1;
%     elseif iscell(handles) && ~isempty(handles{i}) %&& handles{i} 
%         delete_h = 1;
%     end
tmp_data = get(handles(i),'UserData');
    if delete_h && isstruct(tmp_data) && isfield(tmp_data,'struc_name') && strmatch(tmp_data.struc_name,'dop')
%         if report
%             try
%                 ch = get(handles(i),'children');
%                 ch_ch = get(ch(2),'children');
%                 msg = get(ch_ch,'String');
%                 fprintf('Msgbox %u:\n',i);
%                 for j = 1 : size(msg,1)
%                     fprintf('\t%s\n',msg{j});
%                 end
%             end
%         end
        
        delete(handles(i));
    end
end
end
