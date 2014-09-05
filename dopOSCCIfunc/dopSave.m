function [dop,okay,msg] = dopSave(dop_input,varargin)
% dopOSCCI3: dopNew
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
% Created: 14-Aug-2014 NAB
% Last edit:
% 20-Aug-2014 NAB
% 01-Sep-2014 NAB fixed dopSetBasicInputs
% 04-Sep-2014 NAB msg & wait_warn updates

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
%         inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'msg',1,...
            'wait_warn',0,...
            'save_file','dopOSCCIoutput',...
            'save_dir','/Users/mq20111600/Documents/nData/dopOSCCIoutput/',...
            'save_mat',0,...
            'save_dat',1 ...
            );
        inputs.defaults.extras = {'file'};
        inputs.defaults.summary = {'overall'};
        inputs.defaults.channels = {'Difference'};
        inputs.defaults.periods = {'poi'};
        inputs.defaults.epochs = {'screen'}; % 'screen','odd','even','all','act','sep'
        inputs.defaults.variables = {'n','mean','sd','latency'};
        %     inputs.defaults.variables = {'peak_n','peak_mean','peak_sd','peak_latency'};
        inputs.required = ...
            {};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        
        %% data check
        if okay && ~isfield(dop,'sum')
            okay = 0;
            msg{end+1} = ['There''s no ''dop.sum'' variable. You need to' ...
                ' run ''dopCalc'' to create summary variables otherwise' ...
                ' there''s nothing to save'];
            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        
        %% main code
        if okay
            %% set variable abbreivations
            dop.save.abb = dopSaveAbbreviations;
            dop.save.delim = {'\t','\n',1};
            %% save a mat file
            if isempty(strfind(dop.tmp.save_file,'.mat'))
                dop.save.save_file = [dop.tmp.save_file,'.mat'];
            end
            if ~exist(dop.tmp.save_dir,'dir')
                mkdir(dop.tmp.save_dir);
            end
            dop.save.fullfile_mat = fullfile(dop.tmp.save_dir,dop.save.save_file);
            if dop.tmp.save_mat
                save(dop.save.fullfile_mat,'dop');
            end
            % to load
            % load(dop.save.fullfile);
            
            dop.save.fullfile_dat = strrep(dop.save.fullfile_mat,'.mat','.dat');
            
        end
        %% labels/headers
        if okay && ~isfield(dop.save,'labels')
            
            dop.save.labels = [];
            for i = 1 : numel(dop.tmp.extras)
                dop.save.labels{end+1} = dop.tmp.extras{i};
            end
            for i = 1 : numel(dop.tmp.summary)
                dop.tmp.sum = dop.save.abb.(dop.tmp.summary{i});
                
                for ii = 1 : numel(dop.tmp.channels)
                    dop.tmp.ch = dop.save.abb.(dop.tmp.channels{ii});
                    
                    for iii = 1 : numel(dop.tmp.periods)
                        dop.tmp.prd = dop.save.abb.(dop.tmp.periods{iii});
                        
                        for iiii = 1 : numel(dop.tmp.epochs)
                            dop.tmp.eps = dop.save.abb.(dop.tmp.epochs{iiii});
                            
                            for iiiii = 1 : numel(dop.tmp.variables)
                                dop.tmp.var = dop.save.abb.(dop.tmp.variables{iiiii});
                                switch dop.tmp.summary{i}
                                    case 'overall'
                                        % overall data
                                        dop.save.labels{end+1} = sprintf('%s%s_%s_%s',...
                                            dop.tmp.var,dop.tmp.ch,dop.tmp.eps,...
                                            dop.tmp.prd);
                                    case 'epoch'
                                        for j = 1 : dop.event.n % for the moment
                                            dop.save.labels{end+1} = sprintf('%s_%s%u%s_%s_%s',...
                                                dop.tmp.var,dop.tmp.sum,j,dop.tmp.ch,dop.tmp.eps,...
                                                dop.tmp.prd);
                                        end
                                        
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if okay && ~exist(dop.save.fullfile_dat,'file')
            % write the labels
            dop.save.fid = fopen(dop.save.fullfile_dat,'w');
            dop.save.delim = {'\t','\n',1};
            for i = 1 : numel(dop.save.labels)
                if i == numel(dop.save.labels)
                    dop.save.delim{3} = 2;
                end
                fprintf(dop.save.fid,['%s',dop.save.delim{dop.save.delim{3}}],dop.save.labels{i});
            end
            fclose(dop.save.fid);
        end
        if okay
            dop.save.fid = fopen(dop.save.fullfile_dat,'a');
            k = 0;
            dop.save.delim{3} = 1; % reset delimiter
            for i = 1 : numel(dop.tmp.extras)
                k = k + 1;
                dop.tmp.data_name = dop.tmp.extras{i};
                tmp.check = {'save','use','def','file_info'}; % order of these matters
                for j = 1 : numel(tmp.check)
                    if isfield(dop,tmp.check{j}) ...
                            && isfield(dop.(tmp.check{j}),dop.tmp.data_name)
                        dop.tmp.value = dop.(tmp.check{j}).(dop.tmp.data_name);
                        fprintf(dop.save.fid,...
                            [dopVarType(dop.tmp.value),...
                            dop.save.delim{dop.save.delim{3}}],dop.tmp.value);
                        break
                    end
                end
            end
            for i = 1 : numel(dop.tmp.summary)
                dop.tmp.sum = dop.tmp.summary{i};
                
                for ii = 1 : numel(dop.tmp.channels)
                    dop.tmp.ch = dop.tmp.channels{ii};
                    
                    for iii = 1 : numel(dop.tmp.periods)
                        dop.tmp.prd = dop.tmp.periods{iii};
                        
                        for iiii = 1 : numel(dop.tmp.epochs)
                            dop.tmp.eps = dop.tmp.epochs{iiii};
                            
                            for iiiii = 1 : numel(dop.tmp.variables)
                                dop.tmp.var = dop.tmp.variables{iiiii};
                                switch dop.tmp.summary{i}
                                    case 'overall'
                                        k = k + 1;
                                        if k == numel(dop.save.labels)
                                            dop.save.delim{3} = 2;
                                        end
                                        % overall data
                                        dop.tmp.value = dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).(dop.tmp.var);
                                        fprintf(dop.save.fid,...
                                            [dopVarType(dop.tmp.value),...
                                            dop.save.delim{dop.save.delim{3}}],dop.tmp.value);
                                        
                                    case 'epoch'
                                        for j = 1 : dop.event.n % for the moment
                                            k = k + 1;
                                            if k == numel(dop.save.labels)
                                                dop.save.delim{3} = 2;
                                            end
                                            dop.tmp.value = dop.sum.(dop.tmp.sum).(dop.tmp.ch).(dop.tmp.prd).(dop.tmp.eps).(dop.tmp.var)(j);
                                            fprintf(dop.save.fid,...
                                                [dopVarType(dop.tmp.value),...
                                                dop.save.delim{dop.save.delim{3}}],dop.tmp.value);
                                        end
                                        
                                end
                            end
                        end
                    end
                end
            end
            fclose(dop.save.fid);
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