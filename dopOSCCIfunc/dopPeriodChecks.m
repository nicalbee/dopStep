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
% [dop,okay,msg] = dopActCorrect(dop_input,[okay],[msg],...);
%
% * not yet implemented/tested 03-Sep-2014
%
% where:
% > Inputs
% - dop_input: dop matlab structure or data matrix* 
%
%   Optional:
% - okay:
%   logical (0 or 1) for problem, 0 = no problem, 1 = problem. This can be
%   carried through from previously run functions. If set to 1, the
%   function will not be implemented.
% - msg:
%   cell variable with a history of messages from previously run functions.
%   New messages are appended to the end of the array and can be reported
%   to examine the processing steps using 'dopMessage':
%   e.g. dopMessage(msg) or dopMessage(dop);
%
%   Text only:
% - 'nomsg':
%   By default, messages about the processing will be reported to the
%   MATLAB command window. If included as an input, 'nomsg' will turn off
%   these messages. note: they will continue to be collected in the 'msg'
%   variable.
% - 'plot':
%   If included as an input a plot will be produced at the conclusion of
%   the function. The function will wait (see 'uiwait') until the figure
%   has been closed to complete its operations.
%
%
% > Outputs: (note, optional)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 04-Sep-2014 NAB
% Edits:
% 05-Sep-2014 NAB added 'file' input for error reporting

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
            'file',[],...
            'msg',1,...
            'wait_warn',0,...
            'epoch',[], ... 
            'baseline',[],...  
            'poi',[], ... 
            'event_sep',[] ... 
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
                if numel(dop.tmp.(dop.length.fields{i})) ~= dop.length.(dop.length.fields{i}) ...
                        || ~isnumeric(dop.tmp.(dop.length.fields{i}))
                    okay = 0;
                    msg{end+1} = sprintf(['''%s'' variable = [',...
                        repmat(dopVarType(dop.tmp.(dop.length.fields{i})),...
                        1,numel(dop.tmp.(dop.length.fields{i}))),...
                        ']. Expected %u numeric elements\n(%s: %s)'],...
                        dop.tmp.(dop.length.fields{i}),...
                        dop.length.(dop.length.fields{i}),...
                        mfilename,dop.tmp.file);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
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
            if dop.tmp.nums(1) >= dop.tmp.nums(2)
                okay = 0;
                msg{end+1} = sprintf(['Lower %s value (%i) is greater'...
                    ' than upper (%i): needs to be opposite\n(%s: %s)'],...
                    dop.tmp.prd,dop.tmp.nums,mfilename,dop.tmp.file);
                if ~diff(dop.tmp.nums)
                    msg{end} = strrep(msg{end},'greater than','equal to');
                    msg{end} = strrep(msg{end},'opposite','different');
                end
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
        end
        %% check baseline & poi are within epoch
        dop.tmp.check = {'baseline','poi'};
        i = 0;
        while okay && i <  numel(dop.tmp.check)
            i = i + 1;
            dop.tmp.prd = dop.tmp.check{i};
            if sum(dop.tmp.(dop.tmp.prd) < dop.tmp.epoch(1))  || sum(dop.tmp.(dop.tmp.prd) > dop.tmp.epoch(2))
                okay = 0;
                msg{end+1} = sprintf(['One or more ''%s'' settings [%i %i] are'...
                    ' less than lower epoch settings [%i %i]. These need'...
                    ' to be within the epoch range\n(%s: %s)'],...
                    dop.tmp.prd,dop.tmp.(dop.tmp.prd),dop.tmp.epoch,...
                    mfilename,dop.tmp.file);
                if sum(dop.tmp.(dop.tmp.prd) > dop.tmp.epoch(2))
                    msg{end} = strrep(msg{end},'less than lower','greater than upper');
                end
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
        end
        
        %% check baseline and poi don't overlap
        if okay
            % lower baseline within poi
            if and(dop.tmp.baseline(1) > dop.tmp.poi(1), dop.tmp.baseline(1) < dop.tmp.poi(2)) ...
                    || ... % upper baseline within poi
                    and(dop.tmp.baseline(2) > dop.tmp.poi(1), dop.tmp.baseline(2) < dop.tmp.poi(2)) ...
                    || ... % lower poi within baseline
                    and(dop.tmp.poi(1) > dop.tmp.baseline(1), dop.tmp.poi(1) < dop.tmp.baseline(2)) ...
                    || ... % upper poi within baseline
                    and(dop.tmp.poi(2) > dop.tmp.baseline(1), dop.tmp.poi(2) < dop.tmp.baseline(2))
               okay = 0;
               dop.tmp.var = dop.tmp.baseline;
               dop.tmp.within = dop.tmp.poi;
               if and(dop.tmp.poi(1) > dop.tmp.baseline(1), dop.tmp.poi(1) < dop.tmp.baseline(2)) ...
                       || ... % upper poi within baseline
                       and(dop.tmp.poi(2) > dop.tmp.baseline(1), dop.tmp.poi(2) < dop.tmp.baseline(2))
                   dop.tmp.var = dop.tmp.poi;
                   dop.tmp.within = dop.tmp.baseline;
               end
                msg{end+1} = sprintf(['''%s'' settings [%i %i] are'...
                    ' within ''%s'' settings [%i %i]. This should not'...
                    ' be the case\n(%s: %s)'],...
                    dop.tmp.var,dop.tmp.within,...
                    mfilename,dop.tmp.file);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
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
                dopMessage(msg,dop.tmp.msg,1,sokay,dop.tmp.wait_warn);
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