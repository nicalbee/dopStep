function dop = dopStepCode(dop,varargin)
% dopOSCCI3: dopStepCode
%
% notes:
% create a code string of the functions used for export - or actually do
% the exporting
%
% Use:
%
% dop = dopStepHistory(dop,varargin);
%
% where:
%
% Created: 03-Aug-2016 NAB
% Edits:

%% check the inputs
% assume that it's a structure and we're getting the last code - not
% exporting to an mfile
dop.tmp.run_export = 0;
if exist('varargin','var') && ~isempty(varargin) && strcmp(varargin{1},'export')
    dop.tmp.run_export = 1;
end
if ~isfield(dop,'step') || ~isfield(dop.step,'code') || ~isfield(dop.step.code,'data')
    % What should it say to begin with?
    dop.step.code.data = {...
        '%% DOPOSCCI ''dopStep'' MATLAB code:',...
        sprintf('%%\tCreated with DOPOSCCI version %s',dopOSCCIversion),...
        sprintf('%%\tCreated: %s',datestr(now)),...
        '',...
        'dop = []; % start with the ''dop'' structure variable empty',...
        'dop.struc_name = ''dop''; % structure identification - used internally',...
        ''}; % line space at the end
    
end
switch dop.tmp.run_export
    case 0
        dop.tmp.outputs = 'dop = '; % '[dop,okay,msg] = ';
        dop.tmp.function = '';
        dop.tmp.inputs = 'dop';
        if ~isempty(varargin)
            dop.tmp.function = varargin{1};
            
            for i = 2 : numel(varargin)
                if iscell(varargin{i})
                    dop.tmp.eval = 'dop.tmp.inputs = sprintf([''%s,'',dopVarType(varargin{i},[],[],1)],dop.tmp.inputs';
                    for j = 1 : numel(varargin{i})
                        tmp_var = varargin{i}{j};
                        dop.tmp.eval = sprintf(['%s,',dopVarType(tmp_var,[],[],1)],dop.tmp.eval,tmp_var);
                    end
                    dop.tmp.eval = sprintf('%s);',dop.tmp.eval);
                    eval(dop.tmp.eval);
                else
                    dop.tmp.inputs = sprintf(['%s,',dopVarType(varargin{i},[],[],1)],dop.tmp.inputs,varargin{i});
                end
            end
            
            %% comments before the code
            dop.tmp.prefix = [];
            switch dop.tmp.function
                case 'dopChannelExtract'
            end
            if ~isempty(dop.tmp.prefix)
                dop.step.code.data(end+1:end+numel(dop.tmp.suffix)) = dop.tmp.prefix;
            end
            
            %% the code
            dop.step.code.data{end+1} = sprintf('%s %s(%s);',dop.tmp.outputs,dop.tmp.function,dop.tmp.inputs);
            
            %% comments after the code
            dop.tmp.suffix = [];
            switch dop.tmp.function
                case 'dopChannelExtract'
                    if sum(strcmp(varargin,'gui'))
                        dop.tmp.suffix = {...
                            ['% Please note, when run without the ''gui'' input, ',...
                            'signal and event channel numbers '],...
                            ['% should match their ',...
                            'respective column numbers in the data file.'], ...
                            ''};
                    end   
            end
            if ~isempty(dop.tmp.suffix)
                dop.step.code.data(end+1:end+numel(dop.tmp.suffix)) = dop.tmp.suffix;
            end
        end
        if isfield(dop.step,'action') && isfield(dop.step.action,'h') && ~isempty(dop.step.action.h)
            set(dop.step.action.h(ismember(get(dop.step.action.h,'Tag'),'code')),'Enable','on');
        end
    case 1
        if isfield(dop,'step') && isfield(dop.step,'code') && isfield(dop.step.code,'data') && ~isempty(dop.step.code.data)
            
            if ~isfield(dop.step.code,'fullfile') || ~exist(dop.step.code.fullfile,'file')
                dop.step.code.file = {'DOPOSCCI_code'};
                dop.step.code.dir = pwd;
                dop.step.code.fullfile = [];
                switch questdlg(sprintf('Save the data to: %s? ',dop.step.code.dir),...
                        'DOPOSCCI code save directory','Yes','Choose','Cancel','Yes');
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
        else
            dop.tmp.msg = sprintf(['No data in the code/history variable\n',...
                'Run some steps first.']);
            warndlg(dop.tmp.msg,'Nothing to save:');
        end
end
