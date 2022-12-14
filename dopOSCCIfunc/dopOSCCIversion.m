function varargout = dopOSCCIversion%(output)
% dopOSCCI3: dopOSCCIversion
% output some information as to the version - mostly so this can be
% included in the debugging files (see dopOSCCIdebug)
%
% -------------------------------------------------------------------------
% 3.0.0 24-Apr-2013 revising dopOSCCI2... nearly from scratch
% 3.0.0 05-Sep-2014 continuing with Heather Payne's input
% 3.0.0 20-May-2015 revisiting for whatbox processing... not very good at
%   updating version date
% 3.0.1 21-Jan-2016 many updates but currently working on stitching for
%   Margriet. Maybe I'll start adding extra numbers to this
% 3.0.2 22-Jan-2016 manual POI selection and stitching working with toggles
%   so no longer auto file recognition, use dop.def.poi_select = 1 and
%   dop.def.stitch = 1;
% 3.1.2 05-Aug-2016  dopStep development - minor changes throughout
% 3.1.3 30-Aug-2016 ready for dopOSCCI Laterality workshop
% 3.2.0 22-Sep-2016 added the save button etc. to the dopStep gui
% 3.3.0 28-Sep-2016 added multiple event marker capacity
% 3.3.1 15-Oct-2016 custom save swith option in dopSave
% 3.4.0 18-Mar-2017 behavioural data handling/epoch selection
% 3.4.1 27-Mar-2017 added remove_start & remove_end options from
%   dopEventMarkers
% 3.4.2 07-July-2017 fixed dopEventMarkers and dopDataTrim, updated
%   dopProgress
% 3.4.3 13-Nov-2017 mostly working on dopMethodText function to help report
%   the DOPOSCCI steps that were run
% 3.5.0 16-Jul-2018 added dropout check and single channel processing
%   options with plotting variations as well as saving data 'extras'
% 3.5.1 2018-Jul-27 fixed a few bugs
% 3.5.2 2018-Aug-27 making sure that the 'value' and 'peak' settings for
%   the channel calculations flow through. And removed the legend from the
%   average/epoch plots
% 3.5.7 2018-Sep-07 added .txt to the dopFileTypes options (Delica)
% 3.6.0 2018-Dec-21 changed what the peak_n reflects for 'epoch' saving -
%   logical whether or not it was included in the screen
% 3.6.1 2019-04-24 added an 'epochm' summary option. Returns epoch values
%   based on the timing of the overall average peak
% 3.6.2 2019-05-10 updated to behavioural list finding and method text
%   output
% 3.6.3 2019-10-25  making sure the 'epochm' option works in dopCalcAuto
% 3.6.4 2020-06-16  found that messages weren't passing through a couple of
%   the functions. Fixed now.
% 3.6.5 2021-07-03 dopIQR added + 'remove_short' in dopEventMarkers
% 3.6.6 2022-12-14 updated last week to give odd-even breakdown within
%   behavioural conditions: today fixed behavioural plotting files column
%   headers

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

try
    
%     if ~exist('output','var')
%         output = 0;
%     end
    
    dop_version = '3.6.6';
    dop_date = 'Wednesday 14 December 2022';
%     dop_out = [dop_version,': ',dop_date];
    fprintf('MATLAB version: %s\n',version);
    fprintf('dopOSCCI version number is %s\n > last modified on %s\n\n',...
        dop_version,dop_date);
    
%     switch output
%         case 1
            varargout{1} = dop_version;            
%     end
catch err
    save(dopOSCCIdebug);rethrow(err);
end