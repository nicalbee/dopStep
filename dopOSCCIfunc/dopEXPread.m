function varargout = dopEXPread(fileNameLoc)
%% read doppler digital data
%
% [data info timings] = expRead(fileNameLoc)
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

% Edits:
% 17-March-2017 NAB added dir information for file into 'headers' variable
% 11-June-2020 NAB old dopOSCCI debug
try
    %     headers=[]; % create structure for output
    %     dopplerColumns=[2 3];
    %     eventColumn=8;
    columnLabels=[];
    
    
    %% import the data
    fprintf('%s\n\t%s\n','Importing data:',fileNameLoc);
    % tic;
    headers = dir(fileNameLoc);
    [inData, txtdata, numHeaderLines] = importdata(fileNameLoc);%,'\t',numHeaderLines);
    % toc;
    % don't use the txtdata but matlab 2008 doesn't like ~
    % time column (first) will be treated as text
    varargout{1} = [];
    varargout{2} = [];
    varargout{3} = [];
    %% header info:
    % fprintf('\n%s\n','Header Info:');
    for i = 1 : numHeaderLines
        if isempty(columnLabels)
            if isfield(inData,'textdata')
                tmpRow = inData.textdata{i};
            else
                tmpRow = inData{i};
            end
        end
        if isempty(columnLabels) && sum(strfind(tmpRow,':'))
            [tmpLabel,tmpData] = strtok(tmpRow,':');
            if length(strfind(tmpData,':'))>1 % if more colons after first colon:
                tmpData=tmpData(2:end);
                %             fprintf('\t%s\t%s\n',[tmpLabel,':'],tmpData);
            else
                % otherwise, just tmpData it without first colon
                %             fprintf('\t%s\t%s\n',[tmpLabel,':'],strtok(tmpData,':'));
                if strfind(tmpData,'Hz')
                    tmpData = strtok(tmpData,':');
                    tmpData = str2double(tmpData(1:strfind(tmpData,'Hz')-1));
                end
            end
            if sum(isspace(tmpLabel))
                tmpLabel = tmpLabel(find(isspace(tmpLabel),1,'last')+1:end);
            end
            headers.(lower(tmpLabel)) = tmpData;
        else
            if isempty(columnLabels) % first time here, therefore row of header labels
                if isfield(inData,'textdata')
                    columnLabelsCell=textscan(inData.textdata{i},'%s\t','delimiter','\t');
                else
                    columnLabelsCell=textscan(inData{i},'%s\t','delimiter','\t');
                end
                columnLabels=cellstr(columnLabelsCell{1});
                %             columnLabels{end+1}='Event'; % doesn't include this one for some reason
                %             fprintf('\n\t%s\n','Data Column Labels:');
                %for j=1:length(columnLabels)
                %                 fprintf('\t\t%s\n',columnLabels{j});
                %end
                headers.columnLabels=columnLabels;
            else
                %                 columnMeasures=textscan(inData.textdata{i},'%s\t','delimiter','\t');
                % headers.columnMeasures=cellstr(columnMeasures{1});
                if isfield(inData,'textdata')
                    headers.columnMeasures = inData.textdata(i,:);
                else
                    headers.columnMeasures = inData(i,:);
                end
                
            end
            if isfield(headers,'columnLabels')
                headers.dataLabels=headers.columnLabels(2:end);%{'left','right','event'};
            end
            if isfield(headers,'rate')
                headers.sample_rate=headers.rate;
            end
            if isfield(headers,'columnMeasures')
            headers.list=fieldnames(headers);
            % Octave read doesn't know how many header lines there are...
            break
            end
        end
    end
    
    % set outputs
    if isfield(inData,'data')
        varargout{1} = inData.data;
        
            if isfield(inData,'textdata')
        varargout{3} = inData.textdata(numHeaderLines+1 : end);
    end
    
    else
        fid = fopen(fileNameLoc);
        in_mat = textscan(fid,'%s%u%u%u%u%f%u%f%u','HeaderLines',i,'delimiter','\t');
        fclose(fid);

      varargout{1} = cell2mat(in_mat(2:end));
      varargout{3} = in_mat{1};
    end
    
    varargout{2} = headers;
    

    
catch err
    %% catch dopOSCCI error
    save(dopOSCCIdebug); rethrow(err);
end