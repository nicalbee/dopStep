function save_fullfile  =  dopOSCCIdebug
% dopOSCCI3: dopOSCCIdebug
%
% returns an appropriate file name for save dopOSCCI error files into
%
%   see also 'dopOSCCIclean' for removing debug files
%
% Created: ??-???-???? NAB
% Edits:
% 22-Aug-2014 NAB updated save_dir and variable names to be more transparent
% 16-Sep-2014 NAB fixed up auto save directory

%
% -------------------------------------------------------------------------
%     'dopOSCCI' summarises functional transcranial Doppler ultrasonography
%     (fTCD) data.  The primary function of the software is to assess the
%     hemispheric lateralization of cognitive function.
%
%     Copyright (C) 2011 the Chancellor, Masters and Scholars of the
%     University of Oxford.
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FItmp_numberESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>
%     or write to the Free Software Foundation, Inc., 51 Franklin Street,
%     Fifth Floor, Boston, MA 02110-1301, USA.
%
%     Authors: Nic Badcock, Georgina Holt, Anneka Holden, & Dorothy Bishop.
%       contact: nicholas.badcock@gmail.com
%
%     Type 'dopOSCCIlicense' for license details or see dopOSCCIlicense.txt
%
% global dg % need this for gui adjustment - if available
dopOSCCIindent;
tmp  =  dbstack;
crash_func = 'test';
if numel(tmp) > 1
    crash_func  =  tmp(2).name;
end
commandwindow; % bring command window to front
fprintf('\n%s\n',['!!! Caught dopOSCCI crash in ',crash_func,'!!!']);

try
    dopOSCCIversion; % report the version - or at least try to
end
% close any open files:
fclose all;

% get the location of the dopOSCCI function - should be on matlab path
dop_fullfile = which('dopOSCCI'); % dopOSCCI file location
dop_dir = fileparts(dop_fullfile); % dopOSCCI location

% play sound to alert user
try
    dopOSCCIalert('crash');
end
% set save path on same level as dopOSCCI but different directory

save_dir = fullfile([dop_dir,'Data'],mfilename);
% check that the directory exists
if ~exist(save_dir,'dir')
    fprintf('\n\t%s\n','Making directory');
    mkdir(save_dir);
end

% make file name
save_file = ['caught_',crash_func,'_',datestr(now,30)]; % caught file name
save_fullfile = fullfile(save_dir,save_file); % caught file name location

tmp_number = 0; % tmp number for file renaming
while exist([save_fullfile,'.mat'],'file') % add number to make it original
    fprintf('\t%s\n','File exists, creating unique name...');
    tmp_number = tmp_number+1;
    save_file = ['caught_',crash_func,'_',datestr(now,30),'_',num2str(tmp_number)]; % crash file
    save_fullfile = [save_dir,save_file];
end

fprintf('\t%s\n\n\t%s\n\t%s\n\n\n\t%s\n\t\t%s\n\n',...
    'Saving caught variables to:',...
    ['Dir: ',save_dir],['File: ',save_file],...
    'Access by typing: (suggest copy & paste)',['load(''',save_fullfile,''')']);

dopOSCCIindent('done');
% change something in the gui - later: 25-Apr-2013
% enable 'Run' button of gui so don't have to keep resetting if there's a
% problem
% try
%     set(dg.run.but.h(1),'enable','on')
%     clear dg
% end




