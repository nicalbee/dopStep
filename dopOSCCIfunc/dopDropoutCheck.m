function [dop,okay,msg] = dopDropoutCheck(dop_input,varargin)
% dopOSCCI3: dopDropoutCheck
%
% [dop,okay,msg] = dopDropoutCheck(dop_input,[okay],[msg],...)
%
% notes:
% the idea is to check whether it's worth continuing with the processing -
% if the dropout - values == 0 are greater than a certain percentage,
% probably want to stop processing.
%
% actually setup in older versions of the software but just redoing it now
% so that a single channel could be processing. I'll create a dop.dropout
% variable that will record this information. This will include recommended
% channel usage - eg left = 1 or right = 2. Possible to carry on but ignore
% channel difference comparisons, especially as part of the epoch
% screening.
%
% Use:
%
% [dop,okay,msg] = dopDropoutCheck(dop_input,[okay],[msg],...)
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
% - 'epoch':
%   > e.g., dopFunction(dop_input,okay,msg,...,'epoch',[-15 30],...)
%   Lower and Upper epoch values in seconds used to divide the data
%   surrounding the event markers.
%
% - 'baseline':
%   > e.g., dopFunction(dop_input,okay,msg,...,'baseline',[-15 -5],...)
%   Lower and Upper baseline period values in seconds. The mean of this
%   period is subtracted from the rest of the data within the epoch (left
%   and right channels separately) to perform baseline correction (see
%   dopBaseCorrect).
%
% - 'poi':
%   > e.g., dopFunction(dop_input,okay,msg,...,'epoch',[10 25],...)
%   Lower and Upper period of interest values in seconds within which to
%   search for peak left minus right difference for calculation of the
%   lateralisation index.
%
% - 'sample_rate':
%   > e.g., dopFunction(dop_input,okay,msg,...,'sample_rate',25,...)
%   The sampling rate of the data in Hertz. This is used to convert the
%   'epoch' variable seconds to samples to divide the data into epochs.
%   note: After dopDownsample is run, this value should be the downsampled
%   sample rate.
%
% - 'event_channels':
%   > e.g., dopFunction(dop_input,okay,msg,...,'event_channels',13,...)
%   Column number of data which holds the event information. Typically
%   square signal data.
%   note: 'event_channels' is used within this function as an input for
%   dopEvent Markers if it hasn't previously been called. That is,
%   'dop.event' structure variable is not found
%
% - 'event_height':
%   > e.g., dopFunction(dop_input,okay,msg,...,'event_height',1000,...)
%   Number above which activity in the event channel/column data will be
%   detected as an event marker.
%   note: 'event_height' is used within this function as an input for
%   dopEvent Markers if it hasn't previously been called. That is,
%   'dop.event' structure variable is not found
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
% Created: 13-Jul-2018 NAB
% Edits:
% 27-Jul-2018 NAB typo on line 201 sprintf updated & continue
%

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
            'dropout_pct',50, ... % acceptable percent
            'single_channel',0,... % logical - okay to proceed with single channel
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        inputs.required = ...
            {};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        % really want this to be raw...
        if okay && size(dop.tmp.data,3) > 1
            okay = 0;
            msg{end+1} = 'Data already epoched. Reset data to pre-epoched; e.g., dop.data.raw or dop.data.down or dop.data.norm (with ''overall'' method)';
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        end
        %         %% tmp check
        %         [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        if okay
            %% main code
            dop.dropout.ch_names = {'left','right'};
            dop.dropout.samples = ones(1,2)*-9999;
            dop.dropout.pct = dop.dropout.samples; % empty variable to begin with
            dop.dropout.okay = [0 0];
            dop.dropout.continue = 1;
            for i = 1 : 2
                dop.dropout.samples(i) = sum(dop.tmp.data(:,i) <= 0);
                dop.dropout.pct(i) = dop.dropout.samples(i)/size(dop.tmp.data,1)*100;
                dop.save.(sprintf('dropout_pct_%s',dop.dropout.ch_names{i})) = dop.dropout.pct(i);
                if dop.dropout.pct(i) < dop.tmp.dropout_pct
                    dop.dropout.okay(i) = 1;
                else
                    msg{end+1} = sprintf(['Dropout in %s channel greater than %2.2f%% (%2.2f%%), ',...
                        'Flagged as extreme! (%s)'], ...
                        dop.dropout.ch_names{i},dop.tmp.dropout_pct,dop.dropout.pct(i),...
                        dop.tmp.file);
                    % set okay to 0 temporarily so it displays - this makes
                    % it warn - don't really need this
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    if ~dop.tmp.single_channel
                        dop.dropout.continue = 0;
                        okay = 0;
                    else
                        msg{end+1} = ['But, ''single_channel'' variable set to 1, ',...
                            'so will continue as best we can.'];
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    end
                end
            end
            %% check the data
            if dop.tmp.single_channel && sum(dop.dropout.okay) == 0
                msg{end+1} = sprintf(['Even though the ''single_channel'' variable set to 1, ',...
                    'neither channel passes the test, so won''t continue processing. (%s)'],...
                    dop.tmp.file);
                dop.dropout.continue = 1;
                okay = 1; % not sure about cancelling at this point but they'll be lots of popups if we don't...
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            %% summary message
            msg{end+1} = sprintf(['Dropout: Left = %2.2f%%, Right = %2.2f%% ',...
                '(samples = %i and %i)'],...
                dop.dropout.pct,dop.dropout.samples);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            msg{end+1} = ['To include this information in data file add the following ' ...
                'to the dop.save.extras variable:\n' ...
                '\t- ''dropout_pct_left''\n' ...
                '\t- ''dropout_pct_right'''];
        end
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end
%% tmp check
%         [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
%% example msg
%         msg{end+1} = 'some string';
%         dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);