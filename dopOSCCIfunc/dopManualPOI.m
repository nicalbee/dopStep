function [dop,okay,msg] = dopManualPOI(dop_input,varargin)
% dopOSCCI3: dopManualPOI
%
% [dop,okay,msg] = dopManualPOI(dop_input,[okay],[msg],...)
%
% notes:
%   created dop.poi.use variable with a manually set period of interest
%   from an input file
%
% Use:
%
% [dop,okay,msg] = dopManualPOI(dop_input,[okay],[msg],...)
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
% - 'exclude':
%   > e.g., dopFunction(dop_input,okay,msg,...,'exclude',[4 6 7],...)
%   numeric variable setting epoch numbers to be manually excluded
%
% - 'poi_file':
%   > e.g., dopFunction(dop_input,okay,msg,...,'poi_file','C:\my_dir\poi_use.dat',...)
%   string variable setting the file name for a text file indicating for
%   each file, which epoch numbers should be excluded.
%   14-Sep-2014 still thinking about format but
%   Two columns:
%       file_name       exclude_string
%       'my_file.EXP    [4 6 7]
%   Or
%       'my_file.EXP    ~4~6~7
%
%   Or file_name    exclude_epoch#
%   > containing column for each epoch number and logical (1 = exclude, 0 =
%   keep) value for each epoch.
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
% Created: 14-Jan-2016 NAB
% Edits:
% 14-Jan-2016 NAB getting this to work for Margriet quickly - will need
%   editing and all sorts
% 22-Jan-2016 NAB saving a copy of the choices in the save directory for
%   future reference (and use in this function for future processing)

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
            'poi_select',0,... % off by default
            'poi',[5 15],...
            'poi_fullfile',[], ... %
            'poi_dir',[],...
            'poi_file',[],...
            'poi_save',1,... % save a copy of this information by default
            'task_name','saved',...
            'poi_save_file',[],...
            'poi_save_dir',[],...
            'poi_save_fullfile',[],...
            'save_dir',[],... % this should find the default save directory
            'delim','\t',...
            'file',[],... % for error reporting mostly
            'showmsg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        %                 inputs.required = ...
        %                     {'data'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %         %% data check
        %         % need to know how many epochs there are
        %         if isfield(dop,'data') && size(dop.tmp.data,3) == 1
        %             % data hasn't been epoched - do this
        %             [dop,okay,msg] = dopEventMarkers(dop,okay,msg);
        %             % refresh the data if necessary
        %             [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
        %         elseif ~isfield(dop,'data')
        %             okay = 0;
        %                 msg{end+1} = sprintf(['There isn''t any data yet, ',...
        %                     'so can''t determine the number of epochs which is ',...
        %                     'important for this function'],mfilename,dop.tmp.file);
        %                 dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
        %         end
        %% main code
        if okay && dop.tmp.poi_select
            % include all
            dop.poi.use = dop.tmp.poi;
            %             if ~isempty(dop.tmp.exclude) && isnumeric(dop.tmp.exclude) && ...
            %                     sum(dop.tmp.exclude <= dop.event.n) == numel(dop.tmp.exclude)
            %                 if sum(dop.tmp.exclude == 0)
            %                     msg{end+1} = sprintf(['%u values in ''dop.tmp.exclude''' ...
            %                         ' variable are zero. These have been removed',...
            %                         '\n\t(%s: %s)'],sum(dop.tmp.exclude == 0),mfilename,dop.tmp.file);
            %                     if sum(dop.tmp.exclude == 0) == 1
            %                         msg{end} = strrep(msg{end},'values in ''dop.tmp.exclude'' variable are zero. These have',...
            %                             'value in ''dop.tmp.exclude'' variable is zero. This has');
            %                     end
            %                     dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            %                     dop.tmp.exclude(dop.tmp.exclude == 0) = [];
            %                 end
            %                 % set the excluded values to zero - that is, not used
            %                 dop.poi.use(dop.tmp.exclude) = 0;
            %                 msg{end+1} = sprintf(['Manual selection of period of interest: ' ...
            %                     dopVarType(dop.tmp.exclude)],dop.tmp.exclude);
            %                 dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            %             elseif ~isempty(dop.tmp.exclude) && ~isnumeric(dop.tmp.exclude)
            %                 okay = 0;
            %                 msg{end+1} = sprintf(['''exclude'' input variable for ''%s''',...
            %                     ' function must be numeric\n\t(%s)'],mfilename,dop.tmp.file);
            %                 dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            % %             elseif ~isempty(dop.tmp.exclude) && ...
            % %                     sum(dop.tmp.exclude <= dop.event.n) ~= numel(dop.tmp.exclude)
            % %                 okay = 0;
            % %                 msg{end+1} = sprintf(['''exclude'' input variable (',...
            % %                     dopVarType(dop.tmp.exclude),...
            % %                     ' has values greater than the number of available epochs'...
            % %                     ' (%u)\n\t(%s: %s)'],dop.tmp.exclude,dop.event.n,...
            % %                     mfilename,dop.tmp.file);
            % %                 dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            % %             else
            %             else
            if ~isempty(dop.tmp.poi_fullfile) && exist(dop.tmp.poi_fullfile,'file')
                %                 warndlg('Not yet programmed!','Manual epoch file');
                [dop.tmp.poi,okay,msg] = dopManualPOIRead(dop.tmp.poi_fullfile,okay,msg,'delim',dop.tmp.delim);
            elseif ~isempty(dop.tmp.poi_file) && ~isempty(dop.tmp.poi_dir) ...
                    && exist(dop.tmp.poi_dir,'dir') ...
                    && exist(fullfile(dop.tmp.poi_dir,dop.tmp.poi_file),'file')
                [dop.tmp.poi,okay,msg] = dopManualPOIRead(...
                    fullfile(dop.tmp.poi_dir,dop.tmp.poi_file),okay,msg);
            elseif isempty(dop.tmp.poi_file)
                % may or may not be a problem so not saying it's not okay, just
                % might not have one
                msg{end+1} = '''dop.tmp.poi_file'' variable is empty';
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            elseif ~exist(dop.tmp.poi_file,'file')
                okay = 0;
                msg{end+1} = sprintf('''dop.tmp.poi_file'' does not exist: %s',dop.tmp.poi_file);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
            %% find the current file
            dop.tmp.match = [];
            if isfield(dop.tmp,'poi') ...
                    && isfield(dop.tmp.poi,'poi_list') && isfield(dop.tmp.poi,'poi_values') ...
                    && ~isempty(dop.file)
                
                
                dop.tmp.match = find(strcmp(dop.tmp.poi.poi_list,dop.file),1,'first');
            end
            if isempty(dop.tmp.match) && isfield(dop.tmp.poi,'poi_list')
                % first let's check if the extension is mat
                [~,~,dop.tmp.poi_ext] = fileparts(dop.tmp.poi.poi_list{1});
                [~,~,dop.tmp.file_ext] = fileparts(dop.file);
                if ismember(dop.tmp.file_ext,{'.mat','.MAT'}) && ...
                        ~strcmp(dop.tmp.poi_ext,dop.tmp.file_ext) && ...
                        find(strcmp(dop.tmp.poi.poi_list,strrep(dop.file,dop.tmp.file_ext,dop.tmp.poi_ext)),1,'first')
                    
                    msg{end+1} = sprintf(['Assuming that %s files '...
                        'have been converted to %s files. Adjusted '...
                        'manual list to be %s files. Hope this is okay...'...
                        'If not, edit the ''%s'' function around line 210'],...
                        dop.tmp.poi_ext,dop.tmp.file_ext,dop.tmp.file_ext,...
                        mfilename);%dop.tmp.poi_file);
                    dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                    
                    for i = 1 : numel(dop.tmp.poi.poi_list)
                        dop.tmp.poi.poi_list{i} = strrep(dop.tmp.poi.poi_list{i},dop.tmp.poi_ext,dop.tmp.file_ext);
                    end
                    % let's try again
                    dop.tmp.match = find(strcmp(dop.tmp.poi.poi_list,dop.file),1,'first');
                end
                
            end
            
            if isempty(dop.tmp.match) && isfield(dop.tmp.poi,'poi_list') % might be a full file list
                i = 0;
                while isempty(dop.tmp.match) && i < numel(dop.tmp.poi.poi_list)
                    i = i + 1;
                    [~,tmp_file,tmp_ext] = fileparts(dop.tmp.poi.poi_list{i});
                    if strcmp([tmp_file,tmp_ext],dop.file)
                        dop.tmp.match = i;
                    elseif  ismember(dop.tmp.poi.poi_list,dop.file) %~isempty(strfind(dop.tmp.poi.poi_list,dop.file))
                        % or from Heather Payne 01-Apr-2015
                        % update NAB 08-May-2015
                        dop.tmp.match = find(ismember(dop.tmp.poi.manula_list,dop.file));
                        if isempty(dop.tmp.match)
                            dop.tmp.match = 0;
                        end
                    end
                end
            end
            if isempty(dop.tmp.match) % not found
                msg{end+1} = sprintf(['file (%s) not found in '...
                    'manual period of interest file: %s\n\t'...
                    'opening plot for manual selection'],dop.file,dop.tmp.poi_file);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
                dop.poi.use = dopPlot(dop,okay,msg,'poi_select',dop.tmp.poi_select);
                [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);
            else
                dop.poi.use = dop.tmp.poi.poi_values{dop.tmp.match};
                msg{end+1} = sprintf(['file (%s) found in '...
                    'manual period of interest file: %s\n\t'...
                    '\t manual period of interest = ',dopVarType(dop.poi.use)],...
                    dop.file,dop.tmp.poi_file,dop.poi.use);
                %                     if numel(dop.tmp.exclude)
                %                         msg{end} = strrep(msg{end},'exclude',...
                %                             sprintf(['exclude: ',dopVarType(dop.tmp.exclude)],dop.tmp.exclude));
                %                     end
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            end
            
            %             %% check the exclusion fits within the current set of epochs
            %             if ~isempty(dop.tmp.exclude) && ...
            %                     sum(dop.tmp.exclude > dop.event.n)
            %                 dop.tmp.greater = dop.tmp.exclude > dop.event.n;
            %                 okay = 0;
            %                 msg{end+1} = sprintf(['''exclude'' input variable (',...
            %                     dopVarType(dop.tmp.exclude),')',...
            %                     ' has %u values greater than the available epochs (%u).'...
            %                     ' \n\tThese will be ignored.',...
            %                     ' \n\t(%s: %s)'],...
            %                     dop.tmp.exclude,sum(dop.tmp.greater),dop.event.n,...
            %                     mfilename,dop.tmp.file);
            %                 if sum(dop.tmp.greater) == 1
            %                     msg{end} = strrep(msg{end},'values','value');
            %                     msg{end} = strrep(msg{end},'These','This');
            %                 end
            %                 dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
            %                 okay = 1; % we can fix this, ignoring the greater values
            %                 dop.tmp.exclude(dop.tmp.greater) = [];% % remove from list
            %             end
            dop.save.poi_lower = dop.poi.use(1);
            dop.save.poi_upper = dop.poi.use(2);
            dop.poi.string = sprintf('[%i %i]',dop.poi.use);
            if dop.tmp.poi_save
                if isempty(dop.tmp.poi_save_file) && isempty(dop.tmp.poi_save_fullfile)
                    dop.poi.save_file = sprintf('%s_%s.txt',dop.tmp.task_name,mfilename);
                elseif isempty(dop.tmp.poi_save_file)
                    [dop.poi.save_dir,dop.poi.save_file,dop.poi.file_ext] = fileparts(dop.tmp.poi_save_fullfile);
                    dop.poi.save_file = [dop.poi.save_file,dop.poi.file_ext];
                elseif isempty(dop.tmp.poi_save_fullfile)
                    dop.poi.save_file = dop.tmp.file;
                    % should have checks on this to make sure it's a
                    % sensible extension
                end
                if isempty(dop.tmp.poi_save_dir) && isempty(dop.tmp.poi_save_fullfile) && isempty(dop.tmp.save_dir)
                    dop.poi.dir = pwd; % current directory
                elseif ~isempty(dop.tmp.poi_save_dir)
                    dop.poi.save_dir = dop.tmp.poi_save_dir;
                elseif ~isempty(dop.tmp.save_dir)
                    dop.poi.save_dir = dop.tmp.save_dir;
                    %                 elseif ~isempty(dop.tmp.poi_save_fullfile) % should
                    %                 already have this from file check above
                    
                end
                if ~exist(dop.poi.save_dir,'dir')
                    mkdir(dop.poi.save_dir);
                end
                dop.poi.save_fullfile = fullfile(dop.poi.save_dir,dop.poi.save_file);
                if ~exist(dop.poi.save_fullfile,'file')
                    dop.tmp.fid = fopen(dop.poi.save_fullfile,'w');
                    fprintf(dop.tmp.fid,['%s',dop.tmp.delim,'%s\n'],...
                        'file','selected_period_of_interest');
                    fclose(dop.tmp.fid);
                end
                dop.tmp.fid = fopen(dop.poi.save_fullfile,'a');
                fprintf(dop.tmp.fid,['%s',dop.tmp.delim,'%s\n'],...
                    dop.tmp.file,dop.poi.string);
                fclose(dop.tmp.fid);
                msg{end+1} = sprintf(['Selected period of interest (%s) '...
                    'for file %s,\n\twritten/saved to file %s (%s)'],...
                    dop.poi.string,dop.file,dop.poi.save_file,dop.poi.save_dir);
                dopMessage(msg,dop.tmp.showmsg,1,okay,dop.tmp.wait_warn);
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