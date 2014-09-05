function outData=twRead(fileNameLocation)
%% twRead
% read *.TW? files created by the Monitoring Software MF transcranial
% doppler sonography system.
%
% outData=twRead(fileNameLocation)
%
% requires a complete file name and location and outputs a 6 channel by x
% time point matrix.
%
% noticed that sometimes a *.TA? file is output only with a small *.TW?
% file.  In this case, information appears to be in the TA file but
% possibly not enough...
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
if exist(fileNameLocation,'file')==2
    
    fid=fopen(fileNameLocation);
    inData=fread(fid,inf,'int16');
    
    blk=64; % number of single channel samples in a row
    ch=6; % number of channels
    cycle=blk*ch;
    outData=zeros(length(inData)/blk,6);
    for i=1:length(inData)/cycle % number of cycles of 6 channels
        outData(1+blk*(i-1):blk*i,:)=reshape(inData(1+cycle*(i-1):cycle*i),[blk ch]);
    end
    fclose(fid);
else
    error(['Can''t find file: ',fileNameLocation]);
end
clear fileNameLocation fid inData