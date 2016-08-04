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

if ~isfield(dop,'step') || ~isfield(dop.step,'code')
    dop.step.code = [];
end
switch dop.tmp.run_export
    case 0
        dop.tmp.outputs = '[dop,okay,msg] = ';
        dop.tmp.function = '';
        dop.tmp.inputs = 'dop';
        if ~isempty(varargin)
            dop.tmp.function = varargin{1};
            
            for i = 2 : numel(varargin)
                dop.tmp.inputs = sprintf('%s,''%s''',dop.tmp.inputs,varargin{i});
            end
            dop.step.code{end+1} = sprintf('%s %s(%s);',dop.tmp.outputs,dop.tmp.function,dop.tmp.inputs);
            
        end
        set(dop.step.action.h(ismember(get(dop.step.action.h,'Tag'),'code')),'Enable','on');
    case 1
        if isfield(dop,'step') && isfield(dop.step,'code') && ~isempty(dop.step.code)
            dop.tmp.code_file = {'DOPOSCCI_code'};
            dop.tmp.code_dir = pwd;
            dop.tmp.code_fullfile = [];
            switch questdlg(sprintf('Save the data to: %s? ',dop.tmp.code_dir),...
                    'DOPOSCCI code save directory','Yes','Choose','Cancel','Yes');
                case 'Choose'
                    dop.tmp.code_dir = uigetdir(dop.tmp.code_dir,...
                        'Choose DOPOSCCI code save directory:');
                case 'Cancel'
                    dop.tmp.code_dir = [];
            end
            if ~isempty(dop.tmp.code_dir)
                dop.tmp.code_file = inputdlg('Please type file name:',...
                    'DOPOSCCI code save filename (extension added later):',...
                    1,dop.tmp.code_file);
                if ~isempty(dop.tmp.code_file{1})
                    dop.tmp.code_fullfile = fullfile(dop.tmp.code_dir,[dop.tmp.code_file{1},'.m']);
                end
            end
            if ~isempty(dop.tmp.code_fullfile)
                if ~exist(dop.tmp.code_dir,'dir')
                    mkdir(dop.tmp.code_dir);
                end
                if exist(dop.tmp.code_dir,'dir')
                    fprintf('Saving code to: %s (%s)\n',dop.tmp.code_dir,dop.tmp.code_file{1})
                    dop.tmp.fid = fopen(dop.tmp.code_fullfile,'w');
                    for i = 1 : numel(dop.step.code)
                        fprintf(dop.tmp.fid,'%s\n',dop.step.code{i});
                    end
                    fclose(dop.tmp.fid);
                    dop.tmp.msg = sprintf('Success! Examine by typing: edit %s',dop.tmp.code_fullfile);
                    msgbox(dop.tmp.msg,'DOPOSCCI code saved:');
                    eval(sprintf('edit %s',dop.tmp.code_fullfile));
                else
                    dop.tmp.msg = sprintf('Problem with save directory for: %s',dop.tmp.code_fullfile);
                    warndlg(dop.tmp.msg,'Problem:');
                end
                
            end
        else
            dop.tmp.msg = sprintf(['No data in the code/history variable\n',...
                'Run some steps first.']);
            warndlg(dop.tmp.msg,'Nothing to save:');
        end
end
