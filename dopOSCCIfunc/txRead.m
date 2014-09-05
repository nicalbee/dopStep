function varargout=txRead(fileNameLoc)
%% txRead
% read *.TX? files created by the Monitoring Software MF transcranial
% doppler sonography system.
%
% varargout=txRead(fileNameLoc)
%
% requires a complete file name and location and outputs...
%
% Outputs:
% varargout{1}=basic information
% varargout{2}=dump of all information
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
if exist(fileNameLoc,'file')==2
    fd=dir(fileNameLoc); % file details
    im.import=fileread(fileNameLoc);
    toFind={'VERSION:','NAME:','BIRTH:','EXAM:','PRF:','SAMPLE_F:','DOPCHAN:','EXTCHAN:','FDOP1:','FDOP2:'};
    toFindAlt={'VERSION','NAME','BIRTH','EXAM','PRF','SAMPLE_F','DOPCHAN','EXTCHAN','FDOP1','FDOP2'};
    labels={'fileVersion','name','DOB','exam','pulseRepFreq','sampleRate','dopCh','extCh',...
        'fDop1','fDop2'};
    im.count=0;
[im.token im.remain]=strtok(im.import);
while ~isempty(im.remain)
    if sum(strcmpi(im.token,toFind))
        im.thisOne=find(strcmpi(im.token,toFind));
        [im.token im.remain]=strtok(im.remain);
                im.(labels{im.thisOne})=im.token;
                im.count=im.count+1;
    elseif sum(strcmpi(im.token,toFindAlt))
        im.thisOne=find(strcmpi(im.token,toFindAlt));
        [im.token im.remain]=strtok(im.remain);
                im.(labels{im.thisOne})=im.token;
                im.count=im.count+1;
    end
    [im.token im.remain]=strtok(im.remain);
%     disp(im.token);
end
% example:
% 
%     '       0 TEXT FILE VERSION 8.27L'
%     '       0 PATIENT  NAME: AP word generation'
%     '       0 PATIENT  EXAM: 07-06-04 '
%     '       0 SYS PRF 7000'
%     '       0 SYS SAMPLE_F 1000'
%     '       0 SYS DOPCHAN 136'
%     '       0 SYS EXTCHAN 240'
%     '       0 SYS FDOP1 2000'
%     '       0 SYS FDOP2 2000'
%     '0 SYS NSAMPLE 1'
%     '0 START 12'
%     '4322 TIME 12'
%     '10319 TIME 12'
%     '16277 TIME 12'
%     '22274 TIME 12'
%     '28274 TIME 12'
%     '34274 TIME 12'
%     '40274 TIME 12'
%     '46274 TIME 12'
%     '52274 TIME 12'
%     '58269 TIME 12'
%     '64260 TIME 12'
%     '70257 TIME 12'
%     '76249 TIME 12'
%     '82246 TIME 12'
%     '88238 TIME 12'
%     '94229 TIME 12'
%     '100226 TIME 12'

%%  find channel numbers
% convert decimal number to binary and find 1s
if isfield(im,'dopCh')
    im.dopChNum=dec2ch(im.dopCh);
else
    im.dopCh='not found';
    im.dopChNum=0;
end
if isfield(im,'extCh')
    im.extChNum=dec2ch(im.extCh);
else
    im.extCh='not found';
    im.extChNum=0;
end

%% Accompanying .tx file name location
ext='.TX';
nameNOext=fileNameLoc(1:findstr(fileNameLoc,ext)-1);

if isempty(nameNOext)
    ext=lower(ext);
    nameNOext=fileNameLoc(1:findstr(fileNameLoc,ext)-1);
end
if ~isTX(fileNameLoc)%isempty(nameNOext)
    error('%s\n%s\n%s\n','Can''t find upper or lowercase ''.TX'' in file name',...
        '- need this for next step.','Check case of file name: e.g., .Tx or .tX will cause a problem');
end
bInfo.twFileNameLoc=[nameNOext,'.TW',fileNameLoc(findstr(fileNameLoc,ext)+length(ext):length(fileNameLoc))];
%% Output:
%% > basic info
bInfo.name=im.name;
bInfo.exam=im.exam;
bInfo.dopCh=im.dopChNum;
bInfo.extCh=im.extChNum;
bInfo.sampleRate=str2double(im.sampleRate)/10; % tx file reports over 10 second period...for some reason
bInfo.pulseRepFreq=str2double(im.pulseRepFreq);
bInfo.fileDate=fd.date(1:find(isspace(char(fd.date)))-1);
bInfo.fileTime=fd.date(find(isspace(char(fd.date)))+1:length(char(fd.date)));
varargout{1}=bInfo;

%% > all info
im.fileDate=bInfo.fileDate;
im.fileTime=bInfo.fileTime;
im.twFileNameLoc=bInfo.twFileNameLoc;
varargout{2}=im;
else
    error(['Can''t find file: ',fileNameLoc]);
end
clear fileNameLoc bInfo im fd