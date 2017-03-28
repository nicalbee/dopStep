function [plot_name,okay,msg] = dopPlotName(dop_input,varargin)
% dopOSCCI3: dopPlotName
%
% creates a string related to the current data to-be-plotted
%
% Created: 25-Aug-2014 NAB
% Last edit:
% 25-Aug-2014 NAB
% 3-July-2015 NAB added event numbers to title if they exist
% 04-Jan-2015 NAB played around with file name, see if we can retrieve it
%   when working with directly inputted data - ie not dop structure
% 28-Sep-2016 NAB updating for multiple events... - just works with the
%   first
% 15-Mar-2017 NAB added behavioural info
% 18-Mar-2017 NAB added collected file names as figure name
% 27-Mar-2017 NAB updated cases of empty disp_str
% 28-Mar-2017 NAB fixed beh naming + extra (empty) figure popup

[dop,okay,msg] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);
plot_name = 'error';
switch dopInputCheck(dop)
    case 'dop'
        ep = '?';
        if isfield(dop,'epoch') && isfield(dop.epoch,'screen') && ~isempty(dop.epoch.screen)
            ep = sum(dop.epoch.screen);
        end
        if ~isfield(dop,'file_name')
            dop.file_name = 'Missing file name';
            if isfield(dop,'tmp') && isfield(dop.tmp,'file_name')
                dop.file_name = dop.tmp.file_name;
            end
        end
        plot_name = sprintf(['%s: %s data, ',dopVarType(ep),' epochs'],...
            dop.file_name,dop.tmp.type,ep);
        % multiple events - assumes first
        if strcmp(ep,'?') && isfield(dop,'event') && isfield(dop.event(1),'n') && ~isempty(dop.event(1).n)
            plot_name = strrep(plot_name,'? epochs',...
                sprintf('%i events',dop.event(1).n));
        end
        if dop.tmp.collect
            
            fig_ch = get(gcf,'children');
            disp_h = fig_ch(ismember(get(fig_ch,'tag'),'display'));
            disp_str = get(disp_h,'String');
            plot_name = sprintf('Collected (n = %u) %s data',...
                dop.collect.(dop.tmp.type).n,dop.tmp.type);
            if ~isempty(dop.tmp.beh)
                plot_name = sprintf('Collected (n = %u) %s data',...
                dop.collect.(dop.tmp.type).([dop.tmp.beh,'_n']),dop.tmp.type);
            end
            if isempty(disp_str)
                disp_str = 'empty';
            elseif iscell(disp_str)
                disp_str = disp_str{1};
            end
            if isscalar(disp_str) || isvector(disp_str)
                switch disp_str
                    case {'mean','median','all'}
                        plot_name = sprintf('%s: %s',plot_name,disp_str);
                        if ~isempty(dop.tmp.beh)
                            plot_name = sprintf('%s %s',plot_name,dop.tmp.beh);
                        end
                    otherwise
                        if isnumeric(str2double(disp_str)) && ~isnan(str2double(disp_str))
                            plot_name = sprintf('File: %s',...
                                dop.collect.(dop.tmp.type).files{str2double(disp_str)});
                             if ~isempty(dop.tmp.beh)
                                 plot_name = sprintf('File: %s',...
                                dop.collect.(dop.tmp.type).([dop.tmp.beh,'_files']){str2double(disp_str)});
                             end
                        end
                end
            end
        end
    otherwise
        okay = 0;
        msg{end+1} = 'Expecting ''dop'' structure as input';
end