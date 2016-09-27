function [dop,okay,msg] = dopClipCheck(dop_input,varargin)
% dopOSCCI3: dopClipCheck
%
% [dop,okay,msg] = dopClipCheck(dop_input,[okay],[msg],...)
%
% notes:
%   The Doppler Box has a setting which sets an upper limit on the data
%   recording such that the top of the signal is 'clipped'. This function
%   checks for the occurence of clipping using a normality check.
%
%   Import to think about where you place this in the sequence of steps.
%   Best after any trimming but before any adjustments:
%   e.g.
%    - 'dopHeartCycle'
%    - 'dopActCorrect'
%    - 'dopNorm'
%
% Use:
%
% [dop,okay,msg] = dopClipCheck(dop_input,[okay],[msg],...)
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
%--- Optional, Text + value:
%   > e.g., ...,'variable_name',X,...
%   note: '...' indicates that other inputs can be included before or
%   after. The inputs can be included in any order.
%
% - 'clip_pct_flag':
%   > e.g., dopClipCheck(dop_input,okay,msg,...,'clip_pct_flag',1,...)
%   Left or right channels with the percentage of samples equal to the
%   maximum greater than this value will be flagged as 'may be' clipped.
%
% - 'file':
%   > e.g., dopFunction(dop_input,okay,msg,...,'file','subjectX.exp',...)
%   file name of the data file currently being summarised. This is used for
%   error reporting. Typically this variable is automatically populated in
%   the 'dopSetGetInputs' function by searching the 'dop' structure
%   variables: dop.save, dop.use, dop.def, dop.file_info.
%   The default value is empty.
%
% - 'msg':
%   > e.g., dopFunction(dop_input,okay,msg,...,'msg',1,...)
%       or
%           dopFunction(dop_input,okay,msg,...,'msg',0,...)
%   This is a logical variable (1 = on, 0 = off) setting whether or not
%   messages about the progress of the processing are printed to the MATLAB
%   command window.
%   The default value is 1 = on, messages are printed
%
% - 'wait_warn': e.g., ...,'wait_warn',1,... or ....,'wait_warn',0,...
%   This is a logical variable (1 = on, 0 = off) setting whether or not,
%   when 'okay' changes to 0 (i.e. an error), progress through the scripts
%   waits for the warning dialog popup to be closed.
%
%--- Outputs ---
%   note: outputs are optional, included at the left hand side of the call
%   to a function. The order is fixed
%   > e.g.,
%       dop = dopFunction(...);
%   or
%       [dop,okay] = dopFunction(...);
%   or
%       [dop,okay,msg] = dopFunction(...);
%
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 14-Jan-2015 NAB
% Edits:
% 20-May-2015 NAB added 'showmsg'

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
        %         inputs.turnOn = {'nomsg'};
        %         inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'clip_pct_flag',1, ... if greater than 1 pct of data, flag as potentially clipped
            'file',[],... % for error reporting mostly
            'showmsg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        inputs.required = [];...
%             {'epoch'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        if okay
            switch dopInputCheck(dop)
                case {'dop','matrix'}
                    
                    if ~isfield(dop.tmp,'data') || isempty(dop.tmp.data)
                        okay = 0;
                        msg{end+1} = sprintf(['Inputted data is empty. Could be'...
                            ' to do with the screening of epochs,'...
                            ' especially if you''re doing odd & even for'...
                            ' split-half calculations\n(%s:%s)'],...
                            mfilename,dop.tmp.file);
                    else
                        msg{end+1} = 'Using inputted data';
                    end
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                otherwise
                    okay = 0;
                    msg{end+1} = sprintf(['Input doesn''t include recognised data',...
                        '\n(%s:%s)'],mfilename,dop.tmp.file);
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
        end
%         %% tmp check
%         [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        
        %% main code
        dop.tmp.ch_indices = [1 2]; 
        if isfield(dop,'data') && isfield(dop.data,'channel_labels')
                dop.tmp.ch_indices = find(ismember(dop.data.channel_labels,{'left','right'}));
        end
        
        dop.tmp.max = max(dop.tmp.data(:,dop.tmp.ch_indices));
        dop.tmp.clip = 100*sum(bsxfun(@eq,dop.tmp.data(:,dop.tmp.ch_indices),dop.tmp.max))/length(dop.tmp.data(:,dop.tmp.ch_indices));
        % output variables to be saved
        dop.save.clip_left_max = dop.tmp.max(1);
        dop.save.clip_right_max = dop.tmp.max(2);
        dop.save.clip_left = dop.tmp.clip(1);
        dop.save.clip_right = dop.tmp.clip(2);
        dop.save.clip = 0;
        dop.tmp.text = 'unlikely to';
        if sum(dop.tmp.clip > dop.tmp.clip_pct_flag)
            dop.save.clip = 1;
            dop.tmp.text = 'may';
        end
        
        %%  msg
        msg{end+1} = sprintf(['%3.2f%% of left data equal to max (%3.2f)\n'...
            '\t%3.2f%% of right data equal to max (%3.2f)\n'...
            '\t > data %s be clipped.'],...
            dop.tmp.clip(1),dop.tmp.max(1),dop.tmp.clip(2),dop.tmp.max(2),...
            dop.tmp.text);
        
        dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        
        msg{end+1} = sprintf(['To include this information in data file add the following '...
            'to the dop.save.extras variable:\n',...
            '\t- ''clip'' = logical (yes = 1, no = 0) either channel percentage greater than %u\n',...
            '\t- ''clip_left'' = percentage samples at max value for left channel\n',...
            '\t- ''clip_right'' = percentage samples at max value for right channel\n',...
            '\t- ''clip_left_max'' = max value for left channel\n',...
            '\t- ''clip_right_max'' = max value for right channel\n'],dop.tmp.clip_pct_flag);
        
        dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end