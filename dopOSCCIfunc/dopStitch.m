function [dop,okay,msg] = dopStitch(dop_input,varargin)
% dopOSCCI3: dopStitch
%
% [dop,okay,msg] = dopStitch(dop_input,[okay],[msg],...)
%
% notes:
%
% Use:
%
% [dop,okay,msg] = dopStitch(dop_input,[okay],[msg],...)
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
% - 'sample_rate':
%   > e.g., dopFunction(dop_input,okay,msg,...,'sample_rate',25,...)
%   The sampling rate of the data in Hertz. This is used to convert the
%   'epoch' variable seconds to samples to divide the data into epochs.
%   note: After dopDownsample is run, this value should be the downsampled
%   sample rate.
%
% - 'event_channels':
%   > e.g., dopFunction(dop_input,okay,msg,...,'event_channels',13,...)
%   Column number of data which holds the event information. Typically
%   square signal data.
%   note: 'event_channels' is used within this function as an input for
%   dopEvent Markers if it hasn't previously been called. That is,
%   'dop.event' structure variable is not found
%
% - 'event_height':
%   > e.g., dopFunction(dop_input,okay,msg,...,'event_height',1000,...)
%   Number above which activity in the event channel/column data will be
%   detected as an event marker.
%   note: 'event_height' is used within this function as an input for
%   dopEvent Markers if it hasn't previously been called. That is,
%   'dop.event' structure variable is not found
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
% Created: 21-Jan-2016 NAB
% Edits:
% 21-Jan-2016 NAB getting this organised quickly for Margriet - will need
%   more commenting etc.
% 22-Jan-2016 NAB updated for updated auto manualPOI
% 22-Jan-2016 NAB corrected stitch - was repeated the same data due to an
%   incorrect use of an index... spotted it by plotting the data to see if
%   the manual POI selection would work!
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
            'stitch',0,...
            'stitch_file',[],...
            'stitch_dir',[],...
            'stitch_fullfile',[],...
            'poi',[],...
            'epoch',[],...
            'baseline',[],...
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        inputs.required = [];...
            %             {'epoch'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        if dop.tmp.stitch
            if ~isfield(dop,'stitch') || ~isfield(dop.stitch,'file_sets') || isempty(dop.stitch.file_sets)
                okay = 0;
                msg{end+1} = ['Required ''dop.stitch'' variables not available\n',...
                    '\tMake sure you provided the dop.def.stitch_dir & dop.def.stitch_file ',...
                    '(or dop.def.stitch_fullfile) to the dopGetFileList function\n'];
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            elseif ~isfield(dop,'file')
                okay = 0;
                msg{end+1} = ['Required ''dop.file'' variable not available\n',...
                    '\tCan''t match the files without this information\n'];
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            elseif ~isfield(dop,'data') || ~isfield(dop.data,'use') || isempty(dop.data.use)
                okay = 0;
                msg{end+1} = ['Required ''dop.data.use'' variable not available\n',...
                    '\tNothing to stitch together if there''s no data\n'];
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
            end
            %% main code
            if okay
                dop.stitch.match = 0;
                % which file are we up to?
                ii = 0;
                while ~dop.stitch.match && ii < size(dop.stitch.file_sets,1); ii = ii + 1;
                    jj = 0;
                    while ~dop.stitch.match && jj < size(dop.stitch.file_sets,2); jj = jj + 1;
                        if strcmp(dop.file,dop.stitch.file_sets{ii,jj})
                            dop.stitch.match = 1;
                            dop.stitch.match_row = ii;
                            dop.stitch.match_column = jj;
                            dop.stitch.match_indices = [ii jj];
                            msg{end+1} = sprintf(['Current file (''%s'') ',...
                                'matched in dop.stitch.file_sets:\n\trow %i, column %i (file/session)',...
                                '\n\tfile set: ',dopVarType(dop.stitch.file_sets{ii,:}),'\n'],...
                                dop.file,dop.stitch.match_row,...
                                dop.stitch.match_column,dop.stitch.file_sets{ii,:});
                            dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        end
                    end
                end
                if dop.stitch.match
                    dop.stitch.collect(dop.stitch.match_column).data = dop.data.use;
                    dop.stitch.epoch.n(dop.stitch.match_column) = size(dop.stitch.collect(dop.stitch.match_column).data,2);
                    dop.stitch.epoch.screen(dop.stitch.match_column).data = dop.epoch.screen;
                    dop.stitch.epoch.okay(dop.stitch.match_column) = sum(dop.epoch.screen);
                    if dop.stitch.match_column == size(dop.stitch.file_sets,2)
                        dop.stitch.data = [];
                        dop.stitch.ep_screen = [];
                        % need to update the screening information to balance
                        % between different files - balancing by default
                        for ii = 1 : size(dop.stitch.file_sets,2)
                            dop.stitch.data = [dop.stitch.data,dop.stitch.collect(ii).data]; %(:,1:min(dop.stitch.epochs.n),:)];
                            %                             dop.stitch.epoch.screen.collect = [dop.stitch.epoch.screen.collect,dop.stitch.epoch.screen(dop.stitch.match_column).data];
                            % best to randomly drop 1 or more trials... to balance
                            dop.tmp.filt = dop.stitch.epoch.screen(ii).data;
                            if dop.stitch.epoch.okay(ii) > min(dop.stitch.epoch.okay)
                                dop.tmp.use = find(dop.tmp.filt);
                                dop.tmp.rand = dop.tmp.use(randperm(numel(dop.tmp.use)));
                                dop.tmp.filt(dop.tmp.rand(min(dop.stitch.epoch.okay)+1:end)) = 0;
                            end
                            dop.stitch.ep_screen = [dop.stitch.ep_screen,dop.tmp.filt];
                        end
                        
                        %% update variables:
                        %% > the dop.data.use
                        dop.data.use = dop.stitch.data;
                        msg{end+1} = sprintf(['''dop.data.use'' updated to be ''dop.data.stitch'', ',...
                            'combining available files for file set: ',...
                            dopVarType(dop.stitch.file_sets{dop.stitch.match_row,:}),'\n'],...
                            dop.file,dop.stitch.file_sets{dop.stitch.match_row,:});
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        
                        
                        %% > dop.save.file
                        dop.save.file = sprintf(['%s',repmat('_%s',size(dop.stitch.file_sets,2)-1)],dop.stitch.file_sets{dop.stitch.match_row,:});
                        
                        
                        msg{end+1} = sprintf(['''dop.save.file'' updated to be ''%s'', ',...
                            'combination of file names from the set (',...
                            dopVarType(dop.stitch.file_sets{dop.stitch.match_row,:}),')\n'],...
                            dop.save.file,dop.stitch.file_sets{dop.stitch.match_row,:});
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        
                        %% > dop.epoch.screen
                        dop.epoch.screen = logical(dop.stitch.ep_screen);
                        msg{end+1} = sprintf(['''dop.epoch.screen'' updated ',...
                            'to be balance the number of accepted epochs per file:\n\t',...
                            'combination of file names from the set (',...
                            dopVarType(dop.stitch.epoch.okay),')\n'],...
                            dop.stitch.epoch.okay);
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                        
                        
                        
                        [dop,okay,msg] = dopCalcAuto(dop,okay,msg);%,'poi',dop.tmp.poi);
                        [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                        
                        [dop,okay,msg] = dopSave(dop,okay,msg);%,'save_dir',dop.save.save_dir);
                        [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
                    end
                end
            end
            
            %         %% example msg
            %         msg{end+1} = 'some string';
            %         dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
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
%% tmp check
%         [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
%% example msg
%         msg{end+1} = 'some string';
%         dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);