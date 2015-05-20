function [dop,okay,msg] = dopNorm(dop_input,varargin)
% dopOSCCI3: dopNorm
%
% notes:
% normalise the signals to a fixed average to account for any difference in
% insonation angle between the left and right channels.
%
% * not yet implemented (18-Dec-2013)
%
% Use:
%
% dop = dopNorm(dop);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
%
% Created: 18-Dec-2013 NAB
% Last Edit:
% 10-Aug-2014 NAB
% 01-Sep-2014 NAB fixed dopSetBasicInputs
% 04-Sep-2014 NAB msg & wait_warn updates
% 17-Sep-2014 NAB testing on MATLAB 2011 and bsxfun(@mrdivide,... is not
%   available. Added a try/catch to bsxfun(@rdivide and it's running and
%   seems to be doing the same thing - perhaps mrdivide is quicker
%   note: version = 7.11.1.866 (R2010b) Service Pack 1

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        
%         inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'msg',1,...
            'wait_warn',0,...
            'epoch',[], ... %
            'baseline',[],...
            'norm_method','overall',... % 'epoch' or 'deppe_epoch'
            'signal_channels',[],...
            'event_height',[],... % needed for dopEventMarkers if norm by epoch
            'event_channels',[], ... % needed for dopEventMarkers if norm by epoch
            'sample_rate',[] ... % not critical for dopEventMarkers if norm by epoch
            );
        inputs.required = ...
            {'epoch','baseline'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        switch dop.tmp.norm_method
            case {'epoch','deppe_epoch'}
                if ~isfield(dop,'event')
                    % make sure we've got the right event markers for the
                    % current dop.data.use
                    [dop,okay,msg] = dopEventMarkers(dop,okay,msg);
                    [dop,okay,msg] = dopEpoch(dop,okay,msg);
                    [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                else
                    [dop,okay,msg] = dopEpoch(dop,okay,msg);
                    [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                    msg{end+1} = dopEventExistMsg;
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
                if okay
%                     [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                    dop.data.norm = zeros(size(dop.tmp.data));
                    
                    for i = 1 : numel(dop.event.samples)
                        if dop.epoch.length(i)
                            switch dop.tmp.norm_method
                                case 'epoch'
                                    try
                                    dop.data.norm(:,i,:) = bsxfun(@mrdivide,dop.tmp.data(:,i,:)*100,mean(dop.tmp.data(:,i,:)));
                                    catch
                                         dop.data.norm(:,i,:) = bsxfun(@rdivide,dop.tmp.data(:,i,:)*100,mean(dop.tmp.data(:,i,:)));
                                    end
                                case 'deppe_epoch'
                                    % need baseline in samples relative to
                                    % the start of the epoch, not
                                    % zero/event marker
                                    tmp_base = (-dop.tmp.epoch(1) + dop.tmp.baseline)*dop.tmp.sample_rate;
                                    if tmp_base(1) < 1
                                        tmp_base = tmp_base + diff([tmp_base(1),1]);
                                    end
                                    try
                                    dop.data.norm(:,i,:) = bsxfun(@mrdivide,dop.tmp.data(:,i,:),mean(dop.tmp.data(tmp_base(1):tmp_base(2),i,:)))*100;
                                    catch
                                        dop.data.norm(:,i,:) = bsxfun(@rdivide,dop.tmp.data(:,i,:),mean(dop.tmp.data(tmp_base(1):tmp_base(2),i,:)))*100;
                                    end
                            end
                        end
                    end
                    % calculate the difference and average again
                    dop.data.norm(:,:,3) = bsxfun(@minus,dop.data.norm(:,:,1),dop.data.norm(:,:,2));
                    dop.data.norm(:,:,4) = mean(dop.data.norm(:,:,1:2),3);%bsxfun(@mean,dop.data.norm(:,:,1),dop.data.norm(:,:,2));
                    if ~isfield(dop.epoch,'notes')
                        dop.epoch.notes = [];
                    end
                    dop.epoch.notes{end+1} = sprintf(...
                        'epoch data normed using ''%s'' option',...
                        dop.tmp.norm_method);
                    msg{end+1} = dop.epoch.notes{end};
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
            case 'overall'
                dop.data.norm = dop.tmp.data; % save a copy of the data, columns 1 and 2 will be overwritten
                dop.tmp.channels = [1 2]; % only want to norm the left and right channels
                try
                dop.data.norm(:,dop.tmp.channels) = ...
                    bsxfun(@mrdivide,dop.tmp.data(:,dop.tmp.channels)*100,...
                    mean(dop.tmp.data(:,dop.tmp.channels)));
                catch
                    dop.data.norm(:,dop.tmp.channels) = ...
                    bsxfun(@rdivide,dop.tmp.data(:,dop.tmp.channels)*100,...
                    mean(dop.tmp.data(:,dop.tmp.channels)));
                end
                dop.tmp.ev_channels = ones(1,size(dop.tmp.data,2)); % 1 to # of columns
                dop.tmp.ev_channels(dop.tmp.channels) = 0;
                dop.data.norm(:,logical(dop.tmp.ev_channels)) = ...
                    dop.tmp.data(:,logical(dop.tmp.ev_channels));
                
        end
        % update what's been done to the data
        if isfield(dop.data,'norm')
            [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'norm');
        end
        
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end