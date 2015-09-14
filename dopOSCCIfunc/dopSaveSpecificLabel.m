function period_specific_string = dopSaveSpecificLabel(period_string,period_limits)
% dopOSCCI3: dopSaveSpecificLabel
%
% notes:
% convert period string and numeric limits to label for structure and
% column header.
%
% returns a string in the format: %s%ito%i e.g., poi5to15 [5 15]
%
% Negative numbers will be denoted by 'n#' e.g., poin15ton5 for [-15 -5]
%
% Use:
%
% specific_string = dopSaveSpecificLabel(period_string,period_limits);
%
% where:
% > Inputs:
% - period_string = string array relating to variable (e.g., 'poi')
%
% > Outputs: 
% - period_limits = 2 item numeric array denoting upper and lower temporal
%   limits of period (e.g., [5 15] or [-15 -5]
%
% Created: 15-Sep-2015 NAB

period_specific_string = sprintf('%s%ito%i',period_string,period_limits);
% replace minus signs with 'n'
period_specific_string = strrep(period_specific_string,'-','n');
