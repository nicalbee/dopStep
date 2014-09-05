function varargout=readTWfromTX(fileNameLoc)
%
% [data info]=readTWfromTX(fileNameLoc)
%
% - imports rawDoppler info (using txRead) - returns appropriate tw file
% name
% - imports rawDoppler files (using twRead)
% - equalises left & right channels (using dopChEqual)
% - identifies external channel markers
%
%% import data and place in channels
% 1. dopCh1 - Left
% 2. dopCh2 - Right
% 3. extCh1 - first signal
% 4. extCh2 - second signal
% 5. extCh3 - usually empty
% 6. extCh4 - usually empty
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
A=txRead(fileNameLoc); % returns matrix of information regarding file +
    % an accompanying file name for the twRead function.
B=twRead(A.twFileNameLoc);

varargout{1}=B; % data
varargout{2}=A; % info
catch err
    %% catch dopOSCCI error
    % 
    commandwindow; % bring command window to front
    cl=[fileparts(which('dopOSCCI')),'Data\dopOSCCIdebug\']; % caught location
    cfn=['caught_',mfilename,'_',datestr(now,30)]; % caught file name
    cfnl=[cl,cfn]; % caught file name location
    save(cfnl); % save all variables to a mat file
    fprintf('\t%s\n\n\t%s\n\t%s\n\n\n\t%s\n\t\t%s\n',...
            'Error: Saving caught variables:',...
            ['Dir: ',cl],['File: ',cfn],...
            'Access by typing:',['load(''',cfnl,''')']);
    rethrow(err); 
end

