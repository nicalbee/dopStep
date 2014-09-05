
function [dop,okay,msg] = dopGetTXfileList(dop_input,varargin)
% dopOSCCI3: dopGetTXfileList
%
% [dop,okay,msg] = dopGetTXfileList(dop_input,[okay],[msg],...);
%
% notes:
%
%
% Use:
%
% [dop,okay,msg] = dopGetTXfileList(dop_input,[okay],[msg],...);
%
%
% where:
% > Inputs
% - dop_input: dop matlab structure or data matrix* 
%
%   Optional:
% - okay:
%   logical (0 or 1) for problem, 0 = no problem, 1 = problem. This can be
%   carried through from previously run functions. If set to 1, the
%   function will not be implemented.
% - msg:
%   cell variable with a history of messages from previously run functions.
%   New messages are appended to the end of the array and can be reported
%   to examine the processing steps using 'dopMessage':
%   e.g. dopMessage(msg) or dopMessage(dop);
%
%   Text only:
% - 'nomsg':
%   By default, messages about the processing will be reported to the
%   MATLAB command window. If included as an input, 'nomsg' will turn off
%   these messages. note: they will continue to be collected in the 'msg'
%   variable.
% - 'plot':
%   If included as an input a plot will be produced at the conclusion of
%   the function. The function will wait (see 'uiwait') until the figure
%   has been closed to complete its operations.
%
%
% > Outputs: (note, optional)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 05-Sep-2014 NAB
% Edits:
% XX-Sep-2014 NAB

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);

try
    if okay
        dopOSCCIindent;%fprintf('\nRunning %s:\n',mfilename);
        %% inputs
%         inputs.turnOn = {'nomsg'};
%         inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'type','TX',...
            'dir',[],...
            'file',[],... % for error reporting mostly
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
%         inputs.required = ...
%             {'epoch'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        %% data check
        
        %% tmp check
        [dop,okay,msg] = dopMultiFuncTmpCheck(dop,okay,msg);

        %% main code
        
        %% example msg
        msg{end+1} = 'some string';
        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        
        %% save okay & msg to 'dop' structure
        dop.okay = okay;
        dop.msg = msg;
        
        dopOSCCIindent('done');%fprintf('\nRunning %s:\n',mfilename);
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end
% dopOSCCI Mark II: getTXfileList ~ 13-8-2010 (last edit)
%
% examines folder (or folders{x} cell input) input for tX files that have
% matching TW files.  Returns list and report
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
% find all the TX files with matching TW files in the specified folder/s
tx.allTXlist=[]; % tmp list at this stage, create permanent later
tx.TXmatchTWlist=[];

%% search for TX files
if iscell(folder) % assume multiple directories
    for i=1:length(folder)
        tx.allTXlist=contentsList(folder{i},tx.allTXlist);
    end
else
    tx.allTXlist=contentsList(folder,tx.allTXlist);
end
%% search for matching TW files
if tx.comment; fprintf('%s\n','Searching for TW matches:'); end
for i=1:length(tx.allTXlist)
    if isTXmatchTW(tx.allTXlist{i},tx.comment);
        tx.TXmatchTWlist{end+1}=tx.allTXlist{i};
    end
end
if tx.comment ; fprintf('\n'); end% add a line space for good measure
%% create report
report=sprintf('%s\n%s\n','TX match TW doppler file report:',...
    ['Found ',num2str(length(tx.allTXlist)),' TX files and ',...
    num2str(length(tx.TXmatchTWlist)),' matching TW files']);
%% set outputs
varargout{1}=tx.TXmatchTWlist;
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
        if isTX(tmpCon(j).name)
            tmpList{end+1}=[tmpDir,tmpCon(j).name];
        end
    end
end
end