function [dop,okay,msg] = dopClip(dop_input,varargin)
% dopOSCCI3: dopClip
%
% [dop,okay,msg] = dopClip(dop_input,[okay],[msg],...)
%
% notes:
% artificially set upper and/or lower limits on the data. Written to check
% for the effect of having the data 'clipped' (see dopClipCheck). This
% relates to recording issues where data beyond a set limit is recorded at
% that value.
%
% Use:
%
% [dop,okay,msg] = dopClip(dop_input,[okay],[msg],...)
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
% - 'upper':
%   > e.g., dopFunction(dop_input,okay,msg,...,'upper',133,...)
%   set an upper limit to the data such that data/samples with higher
%   values are set to this value, lower than the original recording
%
% - 'lower':
%   > e.g., dopFunction(dop_input,okay,msg,...,'lower',20,...)
%   set an lower limit to the data such that data/samples with lower values
%   are set to this value, higher than the original recording
%
% - 'event_channels':
%   > e.g., dopFunction(dop_input,okay,msg,...,'event_channels',13,...)
%   Column number of data which holds the event information. Typically
%   square signal data.
%   note: 'event_channels' is used within this function as an input for
%   dopEvent Markers if it hasn't previously been called. That is,
%   'dop.event' structure variable is not found
%
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
% Created: 27-Jan-2015 NAB
% Edits:

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
            'upper',[], ... % upper limit in cm/s
            'lower',[],... % lower limit in cm/s
            'event_channels',[], ... % needed for dopEventMarkers
            'sample_rate',[], ... % not critical for dopEventMarkers
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        inputs.required = ...
            {'epoch'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        %% data check
        %% check inputs
        if okay && size(dop.tmp.data,3) > 1
            okay = 0;
            msg{end+1} = sprintf(['''dop.data.use'' variable has 3rd'...
                ' dimension - probably already epoched.'...
                'set ''dop.data.use'' to earlier data structure, ' ...
                'e.g., dop.data.raw or dop.data.down or dop.data.trim',...
                '\n(%s: %s)'], size(dop.tmp.data,3),mfilename,dop.file);
            
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        
        if okay
            %% main code
            dop.tmp.clips = {'upper','lower'};
            dop.tmp.clips_chs = {'left','right'}; % channels
            if or(~isempty(dop.tmp.upper),~isempty(dop.tmp.lower'))
                dop.tmp.outdata = dop.tmp.data;
            end
            for i = 1 : numel(dop.tmp.clips)
                dop.tmp.clip = dop.tmp.clips{i}; % clip name, upper or lower
                if ~isempty(dop.tmp.(dop.tmp.clip))
                    for j = 1 : numel(dop.tmp.clips_chs)
                        % channel index - of inputted data
                        dop.tmp.ch = dop.tmp.clips_chs{j};
                        dop.tmp.ch_ind = find(ismember(dop.tmp.clips_chs,dop.tmp.ch));
                        switch dop.tmp.clip
                            case 'upper'
                                dop.tmp.filt = dop.tmp.outdata(:,dop.tmp.ch_ind) > dop.tmp.(dop.tmp.clip);
                            case 'lower'
                                dop.tmp.filt = dop.tmp.outdata(:,dop.tmp.ch_ind) > dop.tmp.(dop.tmp.clip);
                        end
                        
                        % summary variables
                        dop.tmp.vname = [dop.tmp.ch,'_',dop.tmp.clip];
                        dop.tmp.([dop.tmp.vname,'_samples']) = sum(dop.tmp.filt);
                        dop.tmp.([dop.tmp.vname,'_pct']) = 100*(sum(dop.tmp.filt)/numel(dop.tmp.filt));
                        
                        % clip the data
                        dop.tmp.outdata(dop.tmp.filt,dop.tmp.ch_ind) = dop.tmp.(dop.tmp.clip);
                        
                        %%  msg
                        msg{end+1} = sprintf('%u samples (%3.2f%%) of %s channel set to %i\n',...
                            dop.tmp.([dop.tmp.vname,'_samples']),dop.tmp.([dop.tmp.vname,'_pct']),...
                            dop.tmp.ch,dop.tmp.(dop.tmp.clip));
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    end
                end
                
            end
            %% output settings
            if isfield(dop.tmp,'outdata') && ~isempty(dop.tmp.outdata)
                dop.data.clip = dop.tmp.outdata;
                [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'clip');
            end
            %% save okay & msg to 'dop' structure
            dop.okay = okay;
            dop.msg = msg;
        end
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end