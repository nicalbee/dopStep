function dopPlotClose(handle,varargin)
% dopOSCCI3: dopPlotClose
%
% close the dopOSCCI figure - people might be more comfortable with this
%
% Created: 05-Jan-2016 NAB

delete(get(handle,'parent'));