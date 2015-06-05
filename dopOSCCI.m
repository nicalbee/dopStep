% dopOSCCI3: steps AKA 'dopStep' This function/mfile is current a
% placeholder for debugging
%
% Created: 15-Sep-2014
dopOSCCIindent;
fprintf(['\nThe ''%s'' function/mfile doesn''t currently do anything, just acts as a'...
    ' placeholder for ''dopOSCCIdebug'' to create a deubg data folder\n\n'],...
    mfilename);
dopOSCCIindent('done');
%% notes:
% dopOSCCI wish-list From Hannah Keage 16-Dec-2013
% 
% a.       Average mean velocity increase during LI 2-sec period.
% 
% b.      Maximal average velocity increase within POI (this is not
% necessarily related to LI period).
% 
% c.       An ability to change the LI period (i.e. toggle it across).  I
% know this sounds terribly unsystematic, however, sometimes I find the LI
% period hangs on at the start of the end of the POI, especially when there
% is not much difference between the hemispheres, trying to get some sort
% of LI difference.  In some cases, I don?t think that is a meaningful
% difference, when you look at the waveform.  I am coming at this from an
% ERP-perspective, but if you have an ERP component time-window, sometimes
% you will be flexible when looking at an individual case if the window
% does not accurately reflect their waveform.

% 01-June-2015 Hannah Rapaport wants dopOSCCI to do split-half
% reliability... we can do this, one day...