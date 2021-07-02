function dop_iqr = dopIQR(dop_input)
% dopOSCCI3: dopIQR
%
% [dop,okay,msg] = dopIQR(dop_input,[okay],[msg],...)
%
% notes:
%
% Use:
%
% [dop,okay,msg] = dopIQR(dop_input,[okay],[msg],...)
%
% where:
%--- Inputs ---
% - dop_input: dop matlab structure or data matrix, file name, or data
%   directory, depending on the function. Other than 'dop' structure is
%   currently not well tested 07-Sep-2014 NAB
%
%--- Optional, data only:
%   > e.g., ...,0,... or ...,'string',... or ...,cell,...
% - okay:
%   e.g., dopFunction(dop_input,1,...) or dopFunction(dop_input,0,...)
%       or dopFunction(dop_input,[],...)
%   logical (0 or 1) for problem, 0 = no problem, 1 = problem. This can be
%   carried through from previously run functions. If set to 0, the
%   function will not be implemented - designed to skip functions if there
%   is a problem with the data or variable settings.
%
% - msg:
%   > e.g., dopFunction(dop_input,1,msg,...)
%       or dopFunction(dop_input,1,[],...)
%   Cell variable with a history of messages from previously run functions.
%   New messages are appended to the end of the array and can be reported
%   to examine the processing steps using 'dopMessage':
%   e.g. dopMessage(msg) or dopMessage(dop);
%
%   note: okay and msg will only be recognised as the 1st and 2nd inputs
%   after the dop_input variable and only in this order.
%       e.g., dopFunction(dop,okay,msg,...)
%   If run without, e.g., dopFunction(dop,...), okay and msg will be reset
%   to 1 (i.e., no problem) and empty (i.e., []) respectively.
%

% [dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
% msg{end+1} = sprintf('Run: %s',mfilename);

try
%     if okay
%         dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% main code
        dop.tmp.data = dop_input;
        dop.tmp.sort = sort(dop.tmp.data); % should already be sorted but might as well do this
        dop.tmp.median = median(dop.tmp.sort);
        dop.tmp.lower = dop.tmp.sort(dop.tmp.sort < dop.tmp.median);
        dop.tmp.upper = dop.tmp.sort(dop.tmp.sort > dop.tmp.median);
        
        dop.tmp.Q1 = median(dop.tmp.lower);
        dop.tmp.Q3 = median(dop.tmp.upper);
        
        dop.tmp.iqr = dop.tmp.Q3 - dop.tmp.Q1;
        dop_iqr = dop.tmp.iqr;
        %% example msg
        %         msg{end+1} = 'some string';
        %         dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        
        %% save okay & msg to 'dop' structure
%         dop.okay = okay;
%         dop.msg = msg;
        
%         dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
%     end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end
%% tmp check
%         [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
%% example msg
%         msg{end+1} = 'some string';
%         dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);