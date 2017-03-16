function varargout = dopTXTread(fileNameLoc)
%% read doppler digital data - Delica file
%
% [data info timings] = dopTXTread(fileNameLoc)
%
% commandwindow; % bring to front
% clc
% folder='F:\nWork\nWorking\dopOSCCI\digital\';
% file='temp2.txt';
%
% fileNameLoc=[folder,file];

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

%% Edits
% 17-Mar-2017 adjusted for Delica txt files
try
    headers = []; % create structure for output
%     dopplerColumns = [2 3];
%     eventColumn = 4;
%     columnLabels = [];
    
    
    %% import the data
    fprintf('%s\n\t%s\n','Importing data:',fileNameLoc);
    % tic;
    if exist('table','file')
        in_data = readtable(fileNameLoc,'delimiter',',');
        headers.list = in_data.Properties.VariableNames;
        headers.sampleRate = 125; % Delica default
        % need to peel off the first column as it's text
        text_data = in_data(:,[1 end]);
        headers.list([1 end]) = [];
        in_data(:,1) = []; % remove from the data
        in_data(:,end) = []; % remove the mark channel - it's a different class
        in_data = table2array(in_data);
    else
        return;
    end
%     [inData, txtdata, numHeaderLines] = importdata(fileNameLoc,',');%,'\t',numHeaderLines);
    % toc;
    % don't use the txtdata but matlab 2008 doesn't like ~
    % time column (first) will be treated as text
    varargout{1} = in_data;
    varargout{2} = headers;
    varargout{3} = text_data; % first column
%     %% header info:
%     % fprintf('\n%s\n','Header Info:');
%     for i = 1 : numHeaderLines
%         if isempty(columnLabels) && sum(strfind(inData.textdata{i},':'))
%             [tmpLabel tmpData] = strtok(inData.textdata{i},':');
%             if length(strfind(tmpData,':'))>1 % if more colons after first colon:
%                 tmpData=tmpData(2:end);
%                 %             fprintf('\t%s\t%s\n',[tmpLabel,':'],tmpData);
%             else
%                 % otherwise, just tmpData it without first colon
%                 %             fprintf('\t%s\t%s\n',[tmpLabel,':'],strtok(tmpData,':'));
%                 if strfind(tmpData,'Hz')
%                     tmpData = strtok(tmpData,':');
%                     tmpData = str2double(tmpData(1:strfind(tmpData,'Hz')-1));
%                 end
%             end
%             if sum(isspace(tmpLabel))
%                 tmpLabel = tmpLabel(find(isspace(tmpLabel),1,'last')+1:end);
%             end
%             headers.(lower(tmpLabel)) = tmpData;
%         else
%             if isempty(columnLabels) % first time here, therefore row of header labels
%                 columnLabelsCell=textscan(inData.textdata{i},'%s\t','delimiter','\t');
%                 columnLabels=cellstr(columnLabelsCell{1});
%                 %             columnLabels{end+1}='Event'; % doesn't include this one for some reason
%                 %             fprintf('\n\t%s\n','Data Column Labels:');
%                 for j=1:length(columnLabels)
%                     %                 fprintf('\t\t%s\n',columnLabels{j});
%                 end
%                 headers.columnLabels=columnLabels;
%             else
%                 columnMeasures=textscan(inData.textdata{i},'%s\t','delimiter','\t');
%                 headers.columnMeasures=cellstr(columnMeasures{1});
%             end
%         end
%         if isfield(headers,'columnLabels')
%             headers.dataLabels=headers.columnLabels(2:end);%{'left','right','event'};
%         end
%         if isfield(headers,'rate')
%             headers.sample_rate=headers.rate;
%         end
%         headers.list=fieldnames(headers);
%     end
%     
%     % set outputs
%     if isfield(inData,'data')
%         varargout{1} = inData.data;
%     end
% 
%     varargout{2} = headers;
%     
%     if isfield(inData,'textdata')
%         varargout{3} = inData.textdata(numHeaderLines+1 : end);
%     end
        
catch err
    %% catch dopOSCCI error
    save(dopOSCCIdebug(mfilename)); rethrow(err); 
end