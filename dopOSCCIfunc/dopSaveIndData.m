function [dop,okay,msg] = dopSaveIndData(dop_input,varargin)
% dopOSCCI3: dopSaveIndData
% (very early days for this script - only epoched data at the moment)
%
% [dop,okay,msg] = dopSaveIndData(dop_input,[okay],[msg],...)
%
% notes:
% I want to be able to save the block (ie all trials across time) of the
% individual data for plotting error bars bascially
%
% Use:
%
% [dop,okay,msg] = dopSaveIndData(dop_input,[okay],[msg],...)
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
% Created: 2019-03-22 NAB
%
% Changlog:
%  2019-03-25 fixed the time variable/column

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
            'with_screen',1,... % screen problematic epochs: logical yes = 1, no = 0
            'sample_rate',[], ... % not critical for dopEventMarkers
            'epoch',[],...
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        inputs.required = ...
            {};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        switch size(dop.data.use,3)
            case 1 % continuous
%                 dop.tmp.save_data = [ones(size(dop.tmp.save_data,1),1)*dop.tmp.sample_rate/1, dop.tmp.save_data];
%                 dop.tmp.save_table = array2table(dop.tmp.save_data,'VariableNames',dop.tmp.save_headers);
            case 4 % epoched
                dop.tmp.size = size(dop.data.use);
                dop.tmp.n_timepoints = dop.tmp.size(1);
                dop.tmp.n_epochs = dop.tmp.size(2);
                dop.tmp.n_channels = dop.tmp.size(3);
                
                dop.tmp.save_data = reshape(dop.data.use,dop.tmp.n_timepoints,dop.tmp.n_epochs*dop.tmp.n_channels);
                %                 dop.tmp.save_headers = reshape(repmat(dop.data.epoch_labels,dop.tmp.n_epochs,1),1,dop.tmp.n_epochs*dop.tmp.n_channels);
                
                if dop.tmp.with_screen && isfield(dop,'epoch') && isfield(dop.epoch,'screen')
                    dop.tmp.size = size(dop.data.use(:,dop.epoch.screen,:));
                    dop.tmp.n_timepoints = dop.tmp.size(1);
                    dop.tmp.n_epochs = dop.tmp.size(2);
                    dop.tmp.n_channels = dop.tmp.size(3);
                    
                    dop.tmp.save_data = reshape(dop.data.use(:,dop.epoch.screen,:),dop.tmp.n_timepoints,dop.tmp.n_epochs*dop.tmp.n_channels);
                end
                
                % has to be a better way...
                dop.tmp.k = 0;
                dop.tmp.save_headers = {'latency'};
                for i = 1 : dop.tmp.n_channels
                    for j = 1 : size(dop.data.use,2)
                        
                        dop.tmp.k = dop.tmp.k + 1;
                        if ~dop.tmp.with_screen || dop.tmp.with_screen && ...
                                isfield(dop,'epoch') && ...
                                isfield(dop.epoch,'screen') && ...
                                dop.epoch.screen(j) % (mod(dop.tmp.k,size(dop.data.use,2)))
                            dop.tmp.save_headers{end+1} = sprintf('%sEp%i',dop.data.epoch_labels{i},j);
                        end
                        
                    end
                end
                dop.tmp.save_data = [(dop.tmp.epoch(1):1/dop.tmp.sample_rate:dop.tmp.epoch(2))', dop.tmp.save_data];
                dop.tmp.save_table = array2table(dop.tmp.save_data,'VariableNames',dop.tmp.save_headers);
        end
            %% save the data
            [~,dop.tmp.save_name] = fileparts(dop.tmp.file);
            dop.tmp.save_file = sprintf('%s_%s.dat',dop.tmp.save_name,dop.data.use_type);
            dop.tmp.save_dir = fullfile(dop.save.save_dir,'ind_plot_data');
            dop.tmp.save_fullfile = fullfile(dop.tmp.save_dir,dop.tmp.save_file);
            
            if ~exist(dop.tmp.save_dir,'dir')
                mkdir(dop.tmp.save_dir);
            end
            
            if isfield(dop.tmp,'save_table')
                writetable(dop.tmp.save_table,dop.tmp.save_fullfile,'delimiter','\t','WriteVariableNames',1);
            end
        %% tmp check
        [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        
        %% main code
        
        %% example msg
        msg{end+1} = 'some string';
        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        
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