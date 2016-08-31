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
    
    dop_version = '3.1.3';
    dop_date = 'Tuesday 30th of August 2016';
    dop_out = [dop_version,': ',dop_date];
    fprintf('MATLAB version: %s\n',version);
    fprintf('dopOSCCI version number is %s\n > last modified on %s\n\n',...
        dop_version,dop_date);
    
%     switch output
%         case 1
            varargout{1} = dop_out;            
%     end
catch err
    save(dopOSCCIdebug);rethrow(err);
end