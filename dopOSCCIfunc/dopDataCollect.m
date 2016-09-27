function [dop,okay,msg] = dopDataCollect(dop_input,varargin)
% dopOSCCI3: dopDataCollect
%
% notes:
% basic structure of a function to save time when creating a new one
%
% * not yet implemented (19-Dec-2013)
%
% Use:
%
% [dop,okay,msg] = dopNew(dop,[]);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 22-Aug-2014 NAB
% Last edit:
% 22-Aug-2014 NAB
% 01-Sep-2014 NAB fixed collection when data variables aren't saved
%   see dop.def.keep_data_steps
% 04-Sep-2014 NAB msg & wait_warn updates

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %         %% inputs
%         inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'file',[],...
            'msg',1,...
            'wait_warn',0,...
            'type','use' ...
            );
        %         inputs.required = ...
        %             {'epoch'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg,0);
        %% data check
        
        %% main code
        if isfield(dop,'data') && isfield(dop.data,dop.tmp.type)
           dop.tmp.data = dop.data.(dop.tmp.type);
            if strcmp(dop.tmp.type,'use')
                dop.tmp.type = dop.data.use_type;
            end
            if size(dop.tmp.data,3) == 1
                msg{end+1} = sprintf('Non-epoched data requested: %s',dop.tmp.type);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                if ~isfield(dop.data,'channel_labels')
                    dop.data.channel_labels = {'left','right'};
                    for i = 3 : size(dop.tmp.data,2)
                        dop.data.channel_labels{i} = 'event';
                    end
                end
                if ~isfield(dop,'collect') || ~isfield(dop.collect,dop.tmp.type)
                    dop.collect.(dop.tmp.type).n = 0;
                    dop.collect.(dop.tmp.type).files = [];
%                     dop.collect.(dop.tmp.type).times = [];
%                     if size(dop.tmp.data,3) > 1 && isfield(dop,'epoch') && isfield(dop.epoch,'times')
%                         dop.collect.(dop.tmp.type).times = dop.epoch.times;
%                     end
                    for i = 1 : numel(dop.data.channel_labels)
                        dop.collect.(dop.tmp.type).(dop.data.channel_labels{i}) = [];
                    end
                end
                % count the columns & collect file names/identifiers
                dop.collect.(dop.tmp.type).n = dop.collect.(dop.tmp.type).n + 1;
                dop.collect.(dop.tmp.type).files{dop.collect.(dop.tmp.type).n} = ...
                    dop.file;
                % stack the data into a matrix: left, right, event markers
                % (not sure why you'd want event markers but you never
                % know)
                % this won't work unless the data is trimmed the same
                if dop.collect.(dop.tmp.type).n > 1
                    if size(dop.collect.(dop.tmp.type).(dop.data.channel_labels{1}),1) ~= ...
                            size(dop.tmp.data,1)
                        okay = 0;
                        msg{end+1} = sprintf(['Mismatch between data'...
                            ' rows: %u vs %u, can''t combine into a data matrix',...
                            '\n\t(%s: %s)'],...
                            size(dop.collect.(dop.tmp.type).(dop.data.channel_labels{i}),1),...
                            size(dop.tmp.data,1),mfilename,dop.tmp.file);
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    end
                end
                if okay
                    for i = 1 : numel(dop.data.channel_labels) % number of columns
                        dop.collect.(dop.tmp.type).(dop.data.channel_labels{i})...
                            (:,end+1) = dop.tmp.data(:,i);
                    end
                end
            elseif size(dop.tmp.data,3) == 4
                msg{end+1} = sprintf('Epoched data requested: %s',dop.tmp.type);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                if ~isfield(dop.data,'epoch_labels')
                    dop.data.epoch_labels = {'Left'  'Right'  'Difference'  'Average'};
                end
                if ~isfield(dop,'collect') || ~isfield(dop.collect,dop.tmp.type)
                    dop.collect.(dop.tmp.type).n = 0;
                    dop.collect.(dop.tmp.type).files = [];
                    dop.collect.(dop.tmp.type).data = [];
                end
                % count the columns & collect file names/identifiers
                dop.collect.(dop.tmp.type).n = dop.collect.(dop.tmp.type).n + 1;
                dop.collect.(dop.tmp.type).files{dop.collect.(dop.tmp.type).n} = ...
                    dop.file;
                % stack the data into a matrix: left, right, event markers
                % (not sure why you'd want event markers but you never
                % know)
                % this won't work unless the data is trimmed the same
                if dop.collect.(dop.tmp.type).n > 1
                    if size(dop.collect.(dop.tmp.type).data,1) ~= ...
                            size(dop.tmp.data,1)
                        okay = 0;
                        msg{end+1} = sprintf(['Mismatch between data'...
                            ' rows: %u vs %u, can''t combine into a data matrix',...
                            '\n\t(%s: %s)'],...
                            size(dop.collect.(dop.tmp.type).data,1),...
                            size(dop.tmp.data,1),mfilename,dop.tmp.file);
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    end
                end
                if okay
                    if ~isfield(dop,'epoch') || ~isfield(dop.epoch,'screen')
                        msg{end+1} = sprintf(['No ''dop.epoch.screen''',...
                            ' variable found: saving mean of all %u epochs'],...
                            size(dop.tmp.data,2));
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        dop.epoch.screen = ones(1,size(dop.tmp.data,2));
                        dop.epoch.screen = logical(dop.epoch.screen);
                    end
%                     for i = 1 : numel(dop.data.epoch_labels) % number of columns
                        dop.collect.(dop.tmp.type).data(:,end+1,:) = ...
                            mean(dop.tmp.data(:,dop.epoch.screen,:),2);
%                     end
                end
            else
                msg{end+1} = sprintf(['Unrecognised data structure %s:',...
                    ' data not collected'],dop.tmp.type);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
        else
            okay = 0;
            msg{end+1} = sprintf(['Can''t find ''dop.data.%s'' variable.',...
                ' Data not collected\n\t(%s: %s)'],dop.tmp.type,...
                mfilename,dop.tmp.file);
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
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