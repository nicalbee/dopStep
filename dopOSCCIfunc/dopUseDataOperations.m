function [dop,okay,msg] = dopUseDataOperations(dop_input,varargin) % okay,msg,data_type)
% dopOSCCI3: dopUseDataOperations
%
% updates the 'dop.data.use' variable (i.e., current default data) to the
% specified input. This can be used to 'return' to earlier steps of the
% data processing.
%
% if dop.def.keep_data_steps = 1, then a copy of the data will be saved as
% 'dop.data.[name]' (e.g., dop.data.norm).
%
% Potentially available data names include:
%   'raw','channels','norm','down','trim','hc_data','hc_correct',
%   'hc_linspace','act_correct','event','act_correct_plot',
%   'epoch','base'
%
% Use:
%
% dop = dopUseDataOperations(dop,[okay],[msg],'norm');
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) okay for dopOSCCI to use
% - msg = message about success of function
%
% Created: 08-Aug-2014 NAB & HMP
% Last edit:
% 22-Aug-2014 NAB added dopSetBasicInputs function
% 04-Sep-2014 NAB msg & wait_warn updates
% 16-Sep-2014 NAB updated documentation, a bit...
% 20-May-2015 NAB dop = dop_input deprecated

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
                inputs.varargin = varargin;
        inputs.defaults = struct(...
            'keep_data_steps',0,...
            'file',[],...
            'showmsg',1,...
            'wait_warn',0 ...
            );
%         inputs.required = ...
%             {'epoch','baseline','poi'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        dopOSCCIindent('run',dop.tmp.showmsg);%fprintf('\nRunning %s:\n',mfilename);
        
        %% check if the 'dop' structure has been included:
        if exist('dop_input','var') && ~isempty(dop_input)
            switch dopInputCheck(dop_input)
                case 'dop'
%                     dop = dop_input;
                otherwise
                    dop.data.operations = [];
            end
        else
            dop.data.operations = [];
        end
        tmp_stack = dbstack;
        if ~isfield(dop,'data') || ~isfield(dop.data,'operations')
            dop.data.operations = [];
        end
        dop.data.operations{end+1} = 'manual'; % commandwindow
        if isfield(dop,'data') && isfield(dop.data,'operations') && numel(tmp_stack) > 1
            dop.data.operations{end} = tmp_stack(2).name;
        end
        %% handle the data
        dop.data.use_type = 'unknown';
        
        %         if exist('data_type','var') && ~isempty(data_type)
        if ~isempty(varargin) && ischar(varargin{1})
            data_type = varargin{1};
            
            if isfield(dop,'data') && isfield(dop.data,data_type)
                dop.data.use = dop.data.(data_type);
                msg{end+1} = sprintf(['Updating ''dop.data.use'' variable to'...
                    ' ''%s'' data'],data_type);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                dop.data.use_type = data_type;
            else
                okay = 0;
                msg{end+1} = sprintf(['''dop.data.%s'' variable doesn''t',...
                    ' exist'],data_type);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
        else
            msg{end+1} = sprintf(['No ''data_type'' variable found. Assuming'...
                ' ''dop.data.use'' variable updated externally to this'...
                ' function (%s)'],mfilename);
            dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        end
        dop.use.data_type = dop.data.use_type; % doubling up on information again...
        if okay && isfield(dop,'def') && isfield(dop.def,'keep_data_steps')
            if dop.def.keep_data_steps
                msg{end+1} = sprintf(['''dop.data.%s'' being kept based on' ...
                    ' ''dop.def.keep_data_steps'' variable'],...
                    data_type);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            else
                msg{end+1} = sprintf(['''dop.data.%s'' being cleared based on' ...
                    ' ''dop.def.keep_data_steps'' variable'],...
                    data_type);
                if isfield(dop.data,data_type)
                    dop.data = rmfield(dop.data,data_type);
                end
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
        end
        dop.okay = okay;
        dop.msg = msg;
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end