function [dop,okay,msg] = dopPeriodChecks(dop_input,varargin)
% dopOSCCI3: dopPeriodChecks
%
% [dop,okay,msg] = dopPeriodChecks(dop,[okay],[msg],...)
%
% notes:
% Examines the epoch, baseline, and period of interest (poi) settings and
% reports whether there is overlap relative to the event marker separation
% (if avaialable - may or may not be part of the definition structure:
% 'dop.def')
%
% Use:
%
% [dop,okay,msg] = dopPeriodChecks(dop_input,[okay],[msg],...);
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
% - 'event_sep':
%   > e.g., dopFunction(dop_input,okay,msg,...,'event_sep',50,...)
%   The time between event markers in seconds. This is used to report
%   whether or not the epoch periods will overlap trial to trial.
%   This can be set manually at the start but will automatically be
%   calculated during dopEvent Markers.
%   Processing will not be cancelled if there is overlap, just a warning
%   message thrown.
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
% Created: 04-Sep-2014 NAB
% Edits:
% 05-Sep-2014 NAB added 'file' input for error reporting
% 08-Sep-2014 help info
% 19-May-2015 NAB baseline within poi checks... perhaps never worked!
% 15-Sep-2015 NAB adjusted for multiple rows for periods

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
            'epoch',[], ... 
            'baseline',[],...  
            'poi',[], ... 
            'event_sep',[], ...
            'file',[],...
            'showmsg',1,...
            'wait_warn',0 ...
            );
        inputs.required = ...
            {'epoch','baseline','poi'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        % check to make sure the variables are the expected size
        dop.length = struct(...
            'epoch',2, ... 
            'baseline',2,...  
            'poi',2, ... 
            'event_sep',1 ... 
            );
        dop.length.fields = fields(dop.length);
        for i = 1 : numel(dop.length.fields)
            if isfield(dop.tmp,dop.length.fields{i})
                if size(dop.tmp.(dop.length.fields{i}),2) ~= dop.length.(dop.length.fields{i}) ...
                        || ~isnumeric(dop.tmp.(dop.length.fields{i}))
                    okay = 0;
                    msg{end+1} = sprintf(['''%s'' variable = [',...
                        repmat(dopVarType(dop.tmp.(dop.length.fields{i})),...
                        1,numel(dop.tmp.(dop.length.fields{i}))),...
                        ']. Expected %u numeric elements\n(%s: %s)'],...
                        dop.tmp.(dop.length.fields{i}),...
                        dop.length.(dop.length.fields{i}),...
                        mfilename,dop.tmp.file);
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                end
            end
        end
        
        %% main code
        % check each pair number in turn
        i = 0;
        while okay && i <  numel(inputs.required)
            i = i + 1;
            dop.tmp.prd = inputs.required{i};
            dop.tmp.nums = dop.tmp.(dop.tmp.prd);
            for j = 1 : size(dop.tmp.nums,1)
            if dop.tmp.nums(j,1) >= dop.tmp.nums(j,2)
                okay = 0;
                msg{end+1} = sprintf(['Lower %s value (%i) is greater'...
                    ' than upper (%i): needs to be opposite\n(%s: %s)'],...
                    dop.tmp.prd,dop.tmp.nums(j,:),mfilename,dop.tmp.file);
                if ~diff(dop.tmp.nums)
                    msg{end} = strrep(msg{end},'greater than','equal to');
                    msg{end} = strrep(msg{end},'opposite','different');
                end
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
            end
        end
        %% check baseline & poi are within epoch
        dop.tmp.check = {'baseline','poi'};
        i = 0;
        while okay && i <  numel(dop.tmp.check)
            i = i + 1;
            dop.tmp.prd = dop.tmp.check{i};
            for j = 1 : size(dop.tmp.(dop.tmp.prd),1)
                if sum(dop.tmp.(dop.tmp.prd)(j,:) < dop.tmp.epoch(1))  || sum(dop.tmp.(dop.tmp.prd)(j,:) > dop.tmp.epoch(2))
                    okay = 0;
                    msg{end+1} = sprintf(['One or more ''%s'' settings [%i %i] are'...
                        ' less than lower epoch settings [%i %i]. These need'...
                        ' to be within the epoch range\n(%s: %s)'],...
                        dop.tmp.prd,dop.tmp.(dop.tmp.prd)(j,:),dop.tmp.epoch,...
                        mfilename,dop.tmp.file);
                    if sum(dop.tmp.(dop.tmp.prd)(j,:) > dop.tmp.epoch(2))
                        msg{end} = strrep(msg{end},'less than lower','greater than upper');
                    end
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                end
            end
        end
        
        %% check baseline and poi don't overlap
        if okay
            % lower baseline within poi
            for j = 1 : size(dop.tmp.poi,1)
            if and(dop.tmp.baseline(1) > dop.tmp.poi(j,1), dop.tmp.baseline(1) < dop.tmp.poi(j,2)) ...
                    || ... % upper baseline within poi
                    and(dop.tmp.baseline(2) > dop.tmp.poi(j,1), dop.tmp.baseline(2) < dop.tmp.poi(j,2)) ...
                    || ... % lower poi within baseline
                    and(dop.tmp.poi(j,1) > dop.tmp.baseline(1), dop.tmp.poi(j,1) < dop.tmp.baseline(2)) ...
                    || ... % upper poi within baseline
                    and(dop.tmp.poi(j,2) > dop.tmp.baseline(1), dop.tmp.poi(j,2) < dop.tmp.baseline(2))
               okay = 0;
               dop.tmp.var = dop.tmp.baseline;
               dop.tmp.within = dop.tmp.poi;
               if and(dop.tmp.poi(j,1) > dop.tmp.baseline(1), dop.tmp.poi(j,1) < dop.tmp.baseline(2)) ...
                       || ... % upper poi within baseline
                       and(dop.tmp.poi(j,2) > dop.tmp.baseline(1), dop.tmp.poi(j,2) < dop.tmp.baseline(2))
                   dop.tmp.var = dop.tmp.poi;
                   dop.tmp.within = dop.tmp.baseline;
               end
                msg{end+1} = sprintf(['''baseline'' settings [%i %i] are'...
                    ' within ''Period of interest'' settings [%i %i]. This should not'...
                    ' be the case\n(%s: %s)'],...
                    dop.tmp.baseline,dop.tmp.poi,...
                    mfilename,dop.tmp.file);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                if ~okay
                    return
                end
            end  
            end
        end
        
        %% check event marker separation
        if okay && ~isempty(dop.tmp.event_sep)
            if diff(dop.def.epoch) > dop.tmp.event_sep
                sokay = 0; % not sure if this is enough of a problem to quit processing
                msg{end+1} = sprintf(['The ''epoch'' settings [%i %i]'...
                    ' cover a period of %i seconds and the event '...
                    ' marker separation (''event_sep'' variable) is %3.2f' ...
                    ' which is less than the epoch period. There may be' ...
                    ' overlap between consecutive epoch data.' ...
                    ' This may or may not be a problem' ...
                    '\n\t(%s: %s)'],...
                    dop.tmp.epoch,diff(dop.tmp.epoch),dop.tmp.event_sep,...
                    mfilename,dop.tmp.file);
                dopMessage(msg,dop.tmp.showmsg,1,sokay,dop.tmp.wait_warn);
            end
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