function data_dir = dopStepBrowseFolder(varargin)
% dopOSCCI3: dopStepBrowseFolder
%
% notes:
% browse for a folder
%
% Use:
%
% dir = dopStepBrowseFolder;
%
% where:
%
% Created: 21-Sep-2016 NAB
% - writing for the gui in the first instance
% - could be more general later
% Edits:
%
data_dir = [];

try
    %% get dop structure
    dop = get(gcf,'UserData');
    if isfield(dop,'step') && isfield(dop.step,'h') && ishandle(dop.step.h) && strcmp(get(dop.step.h,'tag'),'dopStep')
        %         search_dir = '';
%         current_dir = pwd;
%         if isfield(dop,'data_dir') && exist(dop.data_dir,'dir')
%             %             search_dir = dop.data_dir;
%             cd(dop.data_dir);
%         end
%         [dop.tmp.types,dop.tmp.types_search] = dopFileTypes; %(0,search_dir);
        
        
        %             fullfile(getHigherDir,'dopOSCCIdemo_data');
        dop.tmp.data_dir = uigetdir( 'Browse for folder:');
        if ~isempty(dop.tmp.data_dir) && ~isnumeric(dop.tmp.data_dir)
            
            fprintf('Directory selected:\n\t - %s\n\n',...
                dop.tmp.data_dir);
            
%             data_dir = dop.tmp.data_dir;
            dop = dopSaveDir(dop,'task_name',[],'base_save_dir',dop.tmp.data_dir);
            dop = dopMultiFuncTmpCheck(dop);
            % set gui data
            dop.tmp.h = dop.step.current.h(ismember(dop.step.current.tag,'save_dir_edit'));
            set(dop.tmp.h,'String',dop.def.save_dir);
%             
%             dop.tmp.h = dop.step.action.h(ismember(dop.step.action.tag,'import'));
%             set(dop.tmp.h,'enable','on');
%             
%             dop.tmp.h = dop.step.current.h(ismember(dop.step.current.tag,'import_text'));
%             set(dop.tmp.h,'Visible','on');
%             
%             % set definition like data in structure
%             dop.data_dir = data_dir;
%             dop.fullfile = full_file;
%             dop.file = file_name; % file name only
%             dop.def.data_dir = data_dir;
%             dop.def.fullfile = full_file;
%             dop.def.file = file_name; % file name only
            
        end
%         cd(current_dir);
        %% update UserData
        set(dop.step.h,'UserData',dop);
    else
        fprintf('Functionality not yet supported for %s\n',mfilename)
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end