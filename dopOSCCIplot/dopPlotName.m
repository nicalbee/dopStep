function [plot_name,okay,msg] = dopPlotName(dop_input,varargin)
% dopOSCCI3: dopPlotName
%
% creates a string related to the current data to-be-plotted
%
% Created: 25-Aug-2014 NAB
% Last edit:
% 25-Aug-2014 NAB
% 3-July-2015 NAB added event numbers to title if they exist

[dop,okay,msg] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);
plot_name = 'error';
switch dopInputCheck(dop)
    case 'dop'
        ep = '?';
        if isfield(dop,'epoch') && isfield(dop.epoch,'screen') && ~isempty(dop.epoch.screen)
            ep = sum(dop.epoch.screen);
        end
        plot_name = sprintf(['%s: %s data, ',dopVarType(ep),' epochs'],...
            dop.file_name,dop.tmp.type,ep);
        if strcmp(ep,'?') && isfield(dop,'event') && isfield(dop.event,'n') && ~isempty(dop.event.n)
            plot_name = strrep(plot_name,'? epochs',...
                sprintf('%i events',dop.event.n));
        end
        if dop.tmp.collect
            plot_name = sprintf('Collected (n = %u) %s data',...
                dop.collect.(dop.tmp.type).n,dop.tmp.type);
        end
    otherwise
        okay = 0;
        msg{end+1} = 'Expecting ''dop'' structure as input';
end