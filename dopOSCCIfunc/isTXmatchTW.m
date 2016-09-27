function varargout=isTXmatchTW(fileName,varargin)
% dopOSCCI Mark II ~ 04-Nov-2011 (last edit)
%
% determines whether the entered TX file (full path) has a matching TW file
% - this is where the critical data is stored. TX is the basic record of
% testing/log file.
%
% requires matching file to be in the same directory.
%
% [ans matchFile]=isTXmatchTW(fileName)
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
out=0;
comment=0;
if ~isempty(varargin)
    comment=varargin{1};
end

if isTX(fileName) % confirm that it's TX file
    [fp fn fex]=fileparts(fileName);
    matchFile=[fp,'/',fn,strrep(fex,fex(3),'W')]; % replace the x for W
    if exist(matchFile,'file')==2
        out=1;
    else
        matchFile='no match';
    end
    if comment
        fprintf('%s\n\t%s\n',['TX : ',fileName],['TW match: ',matchFile]);
    end
else
    if comment
        fprintf('%s\n\t%s\n','Not TX file: ',fileName);
    end
end
varargout{1}=out;
varargout{2}=matchFile;
clear out fileName matchFile comment
    