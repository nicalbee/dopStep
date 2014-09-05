function [dop,okay,msg,dop_output] = dopSetBasicInputs(dop_input,varargin)
% dopOSCCI3: dopSetBasicInputs
%
% notes:
% determine whether the first 2 elements of the 'varargin' (variable
% agruments in) variable are the 'okay' and 'msg' variables to be carried
% through.
% - this is designed to be useful as the first function within a function
% to 'set the basic inputs'
%
% I've done this because I want to make these variables optional inputs.
% For example, if you want to run the functions without 'okay' and 'msg'
% inputs, you don't have to input two blank variables: i.e.,
% dop*(dop,[],[],...)
% * represents wildcard for any dopOSCCI function.
%
% A full example:
%
% 1. [dop,okay,msg] = dopUseDataOperations(dop,okay,msg,'norm')
%   or
% 2. [dop,okay,msg] = dopUseDataOperations(dop,'norm')
%   or
% 3. [dop,okay,msg] = dopUseDataOperations(dop,[],[],'norm')
%
% All of these will have similar functions.
% For 1, the 'okay' and 'msg' values will be carried through the function
% For 2 and 3, the 'okay' and 'msg' values will be default:
%   okay = 1
%   msg = [];
%
% Use:
%
% [dop,okay,msg,varargin] = dopSetBasicInputs(dop,varargin);
%
% If variables that look like 'okay' and 'msg' are found as the first two
% elements of varargin, their values will be used, and the first two
% elements of varargin will be removed so the outputted varargin doesn''t
% include these variables.
%
%  'okay' should look like a [1 1] numeric variable or empty
%  'msg' should look like an empty or cell variable
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs: (note, varargout - therefore optional or as many as you want)
% - dop = dop matlab sructure
%
% - okay = logical (0 or 1) for problem, 0 = no problem, 1 = problem
% - msg = message about progress/events within function
%
% Created: 22-Aug-2014 NAB
% Last edit:
% 22-Aug-2014 NAB % created

dop = dop_input;
okay = 1;
msg = [];
dop_output = varargin;
try
    if ~isempty(varargin{1})
        % check what's in it
        if iscell(varargin) && numel(varargin{1}) && numel(varargin) == 1
            dop_output = varargin{1};
        else
            fprintf(['!!! Not sure about this ''varargin'' variable\n\t',...
                '''%s'' function might not work properly'],mfilename);
        end
        found = 0;
        % checking the first 2 elements of varargin to see if they're 'okay'
        % and 'msg' variables
        for i = 1 : numel(dop_output)
            if i == 1 && or(and(isnumeric(dop_output{i}),... % numeric and
                    sum(size(dop_output{i}) == [1 1]) == 2),... % size is 1 x 1
                    isempty(dop_output{i})) % or isempty
                okay = dop_output{i};
                if isempty(okay)
                    okay = 1;
                end
                found = found + 1;
            elseif i == 2 && found && or(iscell(dop_output{i}),isempty(dop_output{i})) % cell or empty
                msg = dop_output{i};
                found = found + 1;
            end
            if found && or(i == numel(dop_output),i == 2)
                % clear the found items from dop_output
                dop_output(1:found) = [];
                break
            end
        end
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end