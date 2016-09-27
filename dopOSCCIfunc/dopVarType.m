function [var_type,okay,msg] = dopVarType(in_var,comment,num_decimals,eval_out)
% dopOSCCI3: dopVarType
%
% notes:
% determines the required formatting of a variable for using in sprintf or
% fprintf functions, e.g., %s %i or %3.2f for strings, integers, or decimal
%
%
% Use:
%
% [var_type,okay,msg] = dopVarType(variable,[comment],[num_decimals]);
%
% where:
% > Inputs:
% - variable = input variable of some type
% - [comment] = whether or not to report messages to the command window
% - [num_decimals] = number of decimal places for floating point numbers
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - var_type = variable type notation for sprintf or fprintf(%s, %i or
%   %3.xf)
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 10-Aug-2014 NAB
% Last edit:
% 10-Aug-2014 NAB
% 06-Aug-2016 NAB updated for eval_out as part of dopStepCode
% 28-Aug-2016 NAB added 'handle' and fixed isstruct

var_type = '%s'; % string by default
var_type_name = 'string';
okay = 1;
msg = {sprintf('Run: %s',mfilename)};
if ~exist('comment','var') || isempty(comment)
    comment = 0;
end
if ~exist('num_decimals','var') || isempty(num_decimals)
    % 2 decimal places should be enough most of the time
    num_decimals = 2;
    % could vary leading number here too...
end

if ~exist('eval_out','var') || isempty(eval_out)
    eval_out = 0;
end

try
    dopOSCCIindent('run',comment);%fprintf('\nRunning %s:\n',mfilename);
    
    if isnumeric(in_var)
        var_type = '%i'; % signed integer
        var_type_name = 'number';
        if isnan(in_var)
            var_type = '%s';
            var_type_name = 'NaN';
        elseif numel(in_var) == 1 && diff([abs(round(in_var)),abs(in_var)]) ~= 0
            var_type = sprintf('%%3.%uf',num_decimals);
            var_type_name = 'decimal number';
        elseif numel(in_var) > 1
            % check if any of them are decimal numbers - if not, stick with
            % %i, otherwise, all will be reported in decimal format
            decimal = 0;
            for i = 1 : numel(in_var)
                if diff([abs(round(in_var(i))),abs(in_var(i))])
                    decimal = 1;
                end
            end
            if decimal
                var_type = sprintf('%%3.%uf',num_decimals);
                var_type_name = 'decimal number';
            end
        end
        if numel(in_var) > 1
            var_type = repmat([var_type,' '],1,numel(in_var));
        end
    elseif ischar(in_var)
        var_type = '%s'; % string by default
        var_type_name = 'string';
    elseif iscell(in_var)
        var_type = [];
        for i = 1 : numel(in_var)
            var_type = [var_type,dopVarType(in_var{i}),' '];
        end
        var_type_name = 'cell';
    elseif ishandle(in_var)
        var_type = '!!';
        var_type_name = 'handle';
        okay = 1; % can work with this but can't report it in the same way for some outputs
    elseif isstruct(in_var)
        var_type = '!!';
        var_type_name = 'structure';
        okay = 0; % can't work with this
    end
    if okay
        switch var_type_name
            case 'cell'
                msg{end+1} = sprintf(...
                    ['Variable is a %s,'...
                    ' value/s = ',var_type,...
                    ': format = %s'],var_type_name,in_var{:},var_type);
            otherwise
                msg{end+1} = sprintf(...
                    ['Variable is a %s,'...
                    ' value = ',var_type,...
                    ': format = %s'],var_type_name,in_var,var_type);
        end
    else
        msg{end+1} = sprintf(...
            ['Variable is a %s, '...
            'sprintf or fprintf doesn''t work with these'],var_type_name);
    end
    if eval_out
        %         if iscell(in_var)
        %             var_type = strrep('%s','''%s''',var_type);
        %             var_type = sprintf('{%s}',var_type);
        %         else
        if strcmp(var_type,'%s') || iscell(in_var)
            var_type = strrep(var_type,'%s','''%s''');
            
            if iscell(in_var)
                var_type = strrep(var_type,' ',',');
                if strcmp(var_type(end),',')
                    var_type(end) = []; % remove last comma
                end
                var_type = sprintf('{%s}',var_type); % add curly brackets
            end
        elseif sum(ismember(var_type,'%')) > 1
            if strcmp(var_type(end),' ')
                var_type(end) = []; % remove last space
            end
            var_type = sprintf('[%s]',var_type);
        end
    end
    
    if comment; fprintf('\t%s\n',msg{end}); end
    
    dopOSCCIindent('done',comment);%fprintf('\nRunning %s:\n',mfilename);
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end