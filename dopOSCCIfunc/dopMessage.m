function dopMessage(dop_input,report,last,okay,wait_warn)
% dopOSCCI3: dopMessage
%
% dopReportMsg(dop_input,[report],[last],[okay],[wait_warn]);
%
% notes:
%
% Uses 'fprintf' to display dopOSCCI messages/progress reports to the
% MATLAB command window.
%
% Use:
%
% dopReportMsg(dop_input,[report],[last],[okay],[wait_warn]);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%   > or msg (message) output from dopOSCCI function
%
% Optional:
% - report:
%   logical variable (0 = no, 1 = yes) setting whether or not the message/s
%   is/are printed to the MATLAB command window
%
% - last:
%   logical variable (0 = no, 1 = yes) setting whether all message (0) or
%   just the last (1) message will be printed to the MATLAB command window
%
% - okay:
%   logical variable (0 = no, 1 = yes) setting whether a warning flag
%   (exclamation marks) and a MATLAB warn dialog (see warndlg) will be
%   presented.
%
% - wait_warn:
%   logical variable (0 = no, 1 = yes) setting whether the user has to
%   close the warn dialog for the script to continue. Uses 'uiwait' to hold
%   the warn dialog handle until it is closed.
%
% Created: 09-Aug-2014 NAB
% Last edit:
% 19-Aug-2014 NAB
% 04-Sep-2014 NAB including warning flags and popups
% 05-Sep-2014 NAB deleted figure if wait_warn is on
% 20-May-2015 NAB need a way to turn these off... adjust report but this is
%   different to the warnings I thinkg

if ~exist('report','var') || isempty(report)
    report = 1;
end
if ~exist('last','var') || isempty(last)
    last = 0;
end

if ~exist('okay','var') || isempty(okay)
    okay = 1;
end
if ~exist('wait_warn','var') || isempty(wait_warn)
    wait_warn = 0;
end

try
    %     dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
    % check if the 'dop' structure has been included:\
    if exist('dop_input','var') && ~isempty(dop_input)
        switch dopInputCheck(dop_input)
            case 'dop'
                dop = dop_input;
                msg = dop.msg;
            case 'msg'
                msg = dop_input; % assume
            otherwise
                if report; fprintf('Input not recognised for %s function\n',mfilename); end
        end
        if ~isempty(msg) && report
            if ~last
                fprintf('\nReporting messages (using ''%s'' function):\n',mfilename);
                for i = 1 : numel(msg)
                    fprintf('\t(%u): %s\n',i,msg{i})
                end
                fprintf('\n'); % add an extra line at the end
            else
                if ~okay
                    fprintf(['\t',repmat('! ',1,20),'\n']);
                end
                fprintf('\t%s\n',msg{end})
                if ~okay
                    h = warndlg(msg{end},'dopOSCCI: Not Okay');
                    if wait_warn
                        uiwait(h);
                        drawnow;
%                         close(h);
                    end
                end
            end
        end
    else
        if report; fprintf('\tNeed an input for %s\n',mfilename); end
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end