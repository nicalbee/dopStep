function [dop,okay,msg] = dopDownsample(dop_input,varargin)
% dopOSCCI3: dopDownsample
%
% notes:
% changes the sampling rate of the data using matlab's downsample or
%
% Use:
%
% dop = dopDownsample(dop_input);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
% - tmp_okay = logical (0 or 1) tmp_okay for dopOSCCI to use
% - msg = message about success of function
%
% Created: 17-Dec-2013 NAB
% Last edit:
% 7-Aug-14 NAB
% 01-Sep-2014 NAB fixed dopSetBasicInputs
% 04-Sep-2014 NAB msg & wait_warn update
% 27-Jan-2015 NAB removed part of help * not yet implemented - wasn't doing
%   anything

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        msg{end+1} = sprintf('Run: %s',mfilename);
        dopOSCCIindent;%fprintf('Running %s:\n',mfilename);
        
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'msg',1,...
            'wait_warn',0,...
            'downsample_rate',[],...
            'sample_rate',[] ... % could have a default value here, 100
            );
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        if okay && ~isempty(dop.tmp.sample_rate) && ~isempty(dop.tmp.downsample_rate) % ~isempty(dop.tmp.downsample_rate)
            if dop.tmp.sample_rate ~= dop.tmp.downsample_rate && dop.tmp.downsample_rate < dop.tmp.sample_rate
                msg{end+1} = sprintf('downsampling from %u to %u Hertz (i.e., keeping every %u samples)',...
                    dop.tmp.sample_rate,dop.tmp.downsample_rate,...
                    dop.tmp.sample_rate/dop.tmp.downsample_rate);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                if exist('downsample','file')
                    msg{end+1} = 'Running MATLAB''s ''downsample'' function';
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    outdata = downsample(dop.tmp.data,dop.tmp.sample_rate/dop.tmp.downsample_rate);
                else
                    msg{end+1} = 'MATLAB''s ''downsample'' function not found - running simple downsample';
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    % function might not be available - this isn't as sophisticated
                    tmp_keep = dop.tmp.sample_rate/dop.tmp.downsample_rate;
                    tmp_filt = zeros(size(dop.tmp.data,1),1); % filter of zeros
                    tmp_filt(1:tmp_keep:size(dop.tmp.data,1),1) = 1; % put 1 at every 4th sample starting from 1st
                    outdata = dop.tmp.data(logical(tmp_filt),:); % remove the non-selected points.
                end
            elseif dop.tmp.downsample_rate > dop.tmp.sample_rate
                msg{end+1} = sprintf(['The downsample rate (%u) is actually' ...
                    ' greater than the sample rate (%u), so downsampling' ...
                    ' isn''t going to work'],...
                    dop.tmp.downsample_rate,dop.tmp.sample_rate);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            elseif dop.tmp.downsample_rate == dop.tmp.sample_rate
                msg{end+1} = sprintf(['The downsample rate (%u) is the same' ...
                    ' as the sample rate (%u), so downsampling' ...
                    ' isn''t going to do anything...' ...
                    ' perhaps you''ve already run it?'],...
                    dop.tmp.downsample_rate,dop.tmp.sample_rate);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            % update the sample rate for use in other functions
            dop.use.sample_rate = dop.tmp.downsample_rate;
        elseif isempty(dop.tmp.downsample_rate)
            dop.use.sample_rate = dop.tmp.sample_rate;
            msg{end+1} = 'downsample variable is empty - so skipping downsample';
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        %% output settings
        if exist('outdata','var')
            dop.data.down = outdata;
            [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'down');
        end
        dop.okay = okay;
        dop.msg = msg;
        dopOSCCIindent('done');
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end