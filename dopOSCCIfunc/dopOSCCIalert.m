function varargout = dopOSCCIalert(label)
% dopOSCCI3: dopOSCCIallert ~ 25-Apr-2013 (last edit)
%
% plays a wav file to alert user about:
% - crash/caught variable
% - finish of summary
%
% h = dopOSCCIalert(label)
% - where label = 'caught' or 'finish'
% h = sound handle (created using 'audioplayer' function)
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

%% play sound
% to announce the crash/caught variable and finish
try
    dopOSCCIindent;
    default_alert = 'gong.mat';
    if ~exist('label','var')
        label = 'finish';
    end
    player = 0;
    switch label
        case 'finish'
            tmp_file = 'handel.mat';
        case 'crash'
            tmp_file = 'chirp.mat';
        case 'warn'
            tmp_file = 'gong.mat';
        otherwise
            fprintf('\t Input (%s) not recognised.\n',label);
            tmp_file = default_alert;
    end
    if ~isempty(tmp_file)
        load(tmp_file);
        player = audioplayer(y, Fs);
        play(player);
    end
    varargout{1} = player; % give it the handle as an optional output
    dopOSCCIindent('done');
catch err
    %% catch dopOSCCI error
    save(dopOSCCIdebug); rethrow(err);
end
