function [dop,okay,msg] = dopMultiFuncTmpCheck(dop_input,varargin)
% dopOSCCI3: dopNew
%
% notes:
% basic structure of a function to save time when creating a new one
%
% * not yet implemented (19-Dec-2013)
%
% Use:
%
% [dop,okay,msg] = dopMultiFuncTmpCheck(dop,[okay],[msg],[comment]);
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
% Created: 18-Aug-2014 NAB
% Last edit:
% 18-Aug-2014 NAB
% 04-Sep-2014 NAB 
% 20-May-2015 NAB dop.data.use might not always exist - adjusted to
%   accommodate this
% 20-May-2015 NAB dop = dop_input was old and messing up 'showmsg' variable

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

% if ~exist('msg','var') || isempty(comment)
%     comment = 0;
% end

try
    if okay
                inputs.varargin = varargin;
        inputs.defaults = struct(...
            'showmsg',1,...
            'wait_warn',0 ...
            );
%         inputs.required = ...
%             {'epoch','baseline','poi'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        dopOSCCIindent('run',dop.tmp.showmsg);%fprintf('\nRunning %s:\n',mfilename);
        
        if exist('dop_input','var') && ~isempty(dop_input)
            switch dopInputCheck(dop_input)
                case 'dop'
%                     dop = dop_input; % not needed 20-May-2015 NAB
                    
                    
                    %% main code
                    %     [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                    tmp.stack = dbstack;
                    if okay && numel(tmp.stack) >= 2 && isfield(dop,tmp.stack(2).name)
                        % make sure the dop.tmp variable is correct: with multiple
                        % functions within functions this is required.
                        msg{end+1} = ['Multiple functions running with setGetInputs,'...
                            ' updating ''dop.tmp'' variable'];
                        dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                        
                        % might lose a couple of the tmp bits for this
                        % function
                        dop.tmp_now = dop.tmp;
                        
                        dop.tmp = dop.(tmp.stack(2).name);
                        dop = rmfield(dop,tmp.stack(2).name);
                        % current data set may have been updated also...
                        if isfield(dop,'data') && isfield(dop.data,'use')
                        dop.tmp.data = dop.data.use;
                        end
                    end
                otherwise
                    msg{end+1} = '''dop'' input structure not found: required for this function';
                    dopMessage(msg,dop.dop.tmp_now.showmsg,1,okay,dop.dop.tmp_now.wait_warn);
            end
        else
            okay = 0;
            msg{end+1} = 'Problem with inputs: can''t run function';
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        end
        
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done',dop.tmp_now.showmsg);%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end