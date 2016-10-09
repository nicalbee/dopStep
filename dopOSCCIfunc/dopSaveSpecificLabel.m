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
% Edits:
% 09-Aug-2016 NAB floating point numbers
% 10-Oct-2015 NAB updated for smaller floating point numbers

% check float/decimal places
float_check = mod(period_limits,floor(period_limits));
if sum(float_check)
    period_specific_string = sprintf('%s',period_string);
    period_text = {'','to'};
    for i = 1 : numel(period_limits)
        if float_check(i)
            
            [~,point_num] = strtok(num2str(float_check(i)),'.');
            just_num = strrep(point_num,'.','');
            
            period_specific_string = sprintf('%s%s%ip%s',...
                period_specific_string,period_text{i},floor(period_limits(i)),just_num);
%             period_specific_string = sprintf('%s%s%ip%i',...
%                 period_specific_string,period_text{i},floor(period_limits(i)),float_check(i)*10);
           
        else
            period_specific_string = sprintf('%s%s%i',...
                period_specific_string,period_text{i},period_limits(i));
        end
    end
else
    period_specific_string = sprintf('%s%ito%i',period_string,period_limits);
end
% replace minus signs with 'n'
period_specific_string = strrep(period_specific_string,'-','n');

end