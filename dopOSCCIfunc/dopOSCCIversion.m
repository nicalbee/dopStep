function varargout = dopOSCCIversion%(output)
% dopOSCCI3: dopOSCCIversion
% output some information as to the version - mostly so this can be
% included in the debugging files (see dopOSCCIdebug)
%

% dopOSCCI2 output options - not sure they're really useful
% inputs = numbers
% 0 or empty = not output, just report to screen
% 1 = single version: date modified output
% 
% -------------------------------------------------------------------------
% 3.0.0 24-Apr-2013 revising dopOSCCI2... nearly from scratch
% 3.0.0 05-Sep-2014 continuing with Heather Payne's input
% 3.0.0 20-May-2015 revisiting for whatbox processing... not very good at
%   updating version date

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
    
    dop_version = '3.0.0';
    dop_date = 'Wednesday 20th of May 2015';
    dop_out = [dop_version,': ',dop_date];
    fprintf('Matlab version: %s\n',version);
    fprintf('dopOSCCI version number is %s\n > last modified on %s\n',...
        dop_version,dop_date);
    
%     switch output
%         case 1
            varargout{1} = dop_out;            
%     end
catch err
    save(dopOSCCIdebug);rethrow(err);
end