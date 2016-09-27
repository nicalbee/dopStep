function varargout = dopGetEXPfileList(folder,varargin)
% dopOSCCI Mark II: getEXPfileList ~ 10-Jan-2011 (last edit)
%
% examines folder (or folders{x} cell input) input for EXP files.
% Returns list and report
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
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
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
try
tx.folder=folder; tx.varargin=varargin;
tx.comment=0;
if ~isempty(tx.varargin)
    tx.comment=tx.varargin{1};
end
if tx.comment; fprintf('%s\n',['Running ',mfilename]); end

%% Create List of Files
% find all the EXP files 
tx.allEXPlist=[]; % tmp list at this stage, create permanent later

%% search for TX files
if iscell(folder) % assume multiple directories
    for i=1:length(folder)
        tx.allEXPlist=contentsList(folder{i},tx.allEXPlist);
    end
else
    tx.allEXPlist=contentsList(folder,tx.allEXPlist);
end
if tx.comment ; fprintf('\n'); end% add a line space for good measure
%% create report
report=sprintf('%s\n%s\n','EXP doppler file report:',...
    ['Found ',num2str(length(tx.allEXPlist)),' EXP files']);
%% set outputs
varargout{1}=tx.allEXPlist;
varargout{2}=report;
clear tx folder report
catch err
    %% catch dopOSCCI error
    save(dopOSCCIdebug(mfilename));rethrow(err);
end
clear inputs dop
end

%% --------------------------------
%% embedded
%% contentsList
function tmpList=contentsList(tmpDir,tmpList)
if exist(tmpDir,'dir')
    tmpCon=dir(tmpDir);
    for j=1:length(tmpCon)
        if isEXP(tmpCon(j).name)
            tmpList{end+1}=[tmpDir,tmpCon(j).name];
        end
    end
end
end