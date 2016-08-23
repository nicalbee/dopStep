function [dop,okay,msg] = dopPlotSave(dop_input,varargin)
% dopOSCCI3: dopPlotSave
%
% [dop,okay,msg] = dopPlotSave(dop,[okay],[msg],...);
%
% notes:
%
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
% Created: 05-Sep-2014 NAB
% Edits:
% XX-Sep-2014 NAB

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
            'plot_file','dopOSCCIplot',... % file name for plot image
            'plot_dir',[],... % location for plot image
            'plot_fullfile',[],...
            'auto',1,...
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
            'wait_warn',0,... % wait to close warning dialogs
            'epoch',[], ... % [lower upper] limits in seconds
            'event_height',[],... % needed for dopEventMarkers
            'event_channels',[], ... % needed for dopEventMarkers
            'sample_rate',[] ... % not critical for dopEventMarkers
            );
%         inputs.required = ...
%             {'epoch'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        if okay
            if isfield(dop,'tmp') && isfield(dop.tmp,'h') && isprop(dop.tmp.h,'style')
                switch get(dop.tmp.h,'style')
                    case 'pushbutton'
                    dop.tmp.plot_h = get(dop.tmp.h,'parent');
                end
                
            else
            end
            % save location etc.
            if dop.tmp.auto
                dop.tmp.dir = fullfile(dopPlotSave(dop),'plots');
                dop.tmp.file = [];
            end
            if isempty(dop.tmp.plot_fullfile) && isempty(dop.tmp.plot_dir)
%                 dop.tmp.plot_dir = fullfile(dopSaveDir;
                dop.step.code.fullfile = [];
                switch questdlg(sprintf('Save the data to: %s? ',dop.step.code.dir),...
                        'DOPOSCCI plot save directory','Yes','Choose','Cancel','Yes');
                    case 'Choose'
                        dop.step.code.dir = uigetdir(dop.step.code.dir,...
                            'Choose DOPOSCCI code save directory:');
                    case 'Cancel'
                        dop.step.code.dir = [];
                end
                if ~isempty(dop.step.code.dir)
                    dop.step.code.file = inputdlg('Please type file name:',...
                        'DOPOSCCI code save filename (extension added later):',...
                        1,dop.step.code.file);
                    if ~isempty(dop.step.code.file{1})
                        dop.step.code.fullfile = fullfile(dop.step.code.dir,[dop.step.code.file{1},'.m']);
                    end
                end
            end
            if ~isempty(dop.step.code.fullfile)
                if ~exist(dop.step.code.dir,'dir')
                    mkdir(dop.step.code.dir);
                end
                if exist(dop.step.code.dir,'dir')
                    fprintf('Saving code to: %s (%s)\n',dop.step.code.dir,dop.step.code.file{1})
                    dop.tmp.fid = fopen(dop.step.code.fullfile,'w');
                    for i = 1 : numel(dop.step.code.data)
                        fprintf(dop.tmp.fid,'%s\n',dop.step.code.data{i});
                    end
                    fclose(dop.tmp.fid);
                    
                    switch questdlg('Open code in MATLAB editor?','Open?','Yes','No','Yes');
                        case 'Yes'
                            eval(sprintf('edit %s',dop.step.code.fullfile));
                        otherwise
                            dop.tmp.msg = sprintf('Success! Examine by typing: edit %s',dop.step.code.fullfile);
                            msgbox(dop.tmp.msg,'DOPOSCCI code saved:');
                    end
                else
                    dop.tmp.msg = sprintf('Problem with save directory for: %s',dop.step.code.fullfile);
                    warndlg(dop.tmp.msg,'Problem:');
                end
                
            end
        end
%         %% tmp check
%         [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);

        %% main code
        
        %% example msg
%         msg{end+1} = 'some string';
%         dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end