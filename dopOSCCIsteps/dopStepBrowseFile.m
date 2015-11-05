function [full_file,file_name,data_dir] = dopStepBrowseFile(varargin)
% dopOSCCI3: dopStepBrowseFile
%
% notes:
% browse for a functional Transcranial Doppler Ultrasound data file
%
% Use:
%
% [full_file, file, dir] = dopStepBrowseFile;
%
% where:
%
% Created: 29-Oct-2015 NAB
% - writing for the gui in the first instance
% - could be more general later
% Edits:
% 
full_file = [];
file_name = [];
data_dir = [];

try
    %% get dop structure
    dop = get(gcf,'UserData');
    if isfield(dop,'step') && isfield(dop.step,'h') && ishandle(dop.step.h) && strcmp(get(dop.step.h,'tag'),'dopStep')
%         search_dir = '';
current_dir = pwd;
        if isfield(dop,'data_dir') && exist(dop.data_dir,'dir')
%             search_dir = dop.data_dir;
cd(dop.data_dir);
        end
        [dop.tmp.types,dop.tmp.types_search] = dopFileTypes; %(0,search_dir);
        
        while 1
            [dop.tmp.filename, dop.tmp.data_dir, dop.tmp.filterindex] = uigetfile(dop.tmp.types_search, 'Browse for Doppler file:');
            if dop.tmp.filterindex == 1
                [~,dop.tmp.file,dop.tmp.file_type] = fileparts(dop.tmp.filename);
                fprintf('Found file:\n\t - name: %s\n\t - dir: %s\n\n',...
                    dop.tmp.filename,dop.tmp.data_dir);
                dop.tmp.file = fullfile(dop.tmp.data_dir,dop.tmp.filename);
                full_file = dop.tmp.file;
                file_name = dop.tmp.filename;
                data_dir = dop.tmp.data_dir;
                
                % set gui data
                dop.tmp.h = dop.step.current.h(ismember(dop.step.current.tag,'data_file'));
                set(dop.tmp.h,'string',dop.tmp.file);
                
                dop.tmp.h = dop.step.action.h(ismember(dop.step.action.tag,'import'));
                set(dop.tmp.h,'enable','on');
                
                dop.tmp.h = dop.step.current.h(ismember(dop.step.current.tag,'import_text'));
                set(dop.tmp.h,'Visible','on');
                
                % set definition like data in structure
                dop.data_dir = data_dir;
                dop.fullfile = full_file;
                dop.file = file_name; % file name only
                break
            elseif isnumeric(dop.tmp.filename) && ~dop.tmp.filename
                break
            end
        end
        cd(current_dir);
        %% update UserData
        set(dop.step.h,'UserData',dop);
    else
        fprintf('Functionality not yet supported for %s\n',mfilename)
    end
    catch err
    save(dopOSCCIdebug);rethrow(err);
end
end