function dop = dopStepHistory(dop,varargin)
% dopOSCCI3: dopStepHistory
%
% notes:
% create a command history string for export
%
% Use:
%
% dop = dopStepHistory(dop,varargin);
%
% where:
%
% Created: 03-Aug-2016 NAB
% Edits:

if ~isfield(dop,'step') || ~isfield(dop.step,'history')
    dop.step.history = [];
end

dop.tmp.outputs = '[dop,okay,msg] = ';
dop.tmp.function = '';
dop.tmp.inputs = 'dop';
if ~isempty(varargin)
    dop.tmp.function = varargin{1};
    
    for i = 2 : numel(varargin)
        dop.tmp.inputs = sprintf('%s,''%s''',dop.tmp.inputs,varargin{i});
    end
    dop.step.history{end+1} = sprintf('%s %s(%s);',dop.tmp.outputs,dop.tmp.function,dop.tmp.inputs);
else
    % save history
    
end

