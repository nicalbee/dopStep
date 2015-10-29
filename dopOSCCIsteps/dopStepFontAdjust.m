function dopStepFontAdjust(button_handle,~)
% dopOSCCI3: dopStepFontAdjust
%
% notes:
% adjust the font size for the dopStep gui
%
% Use:
%
% Callback function for dopStep gui
%
% Created: 14-Oct-2015 NAB
% Edits:
%

% options:
% 14-Oct-2015 NAB consider doing for all font information - currently very
%   specifc for stepInfo text object but could save a set of handles, e.g.,
%   dop.step.font.h(1:n), and adjust all in one hit
%   > do this by saving the 'dop' field into the figure 'UserData'
% 30-Oct-2015 NAB updated to use dop.step.text.h
try
    % probably don't want to report function name eventually
    fprintf('\nRunning %s:\n',mfilename);
    
    dop = get(gcf,'UserData');
    if isfield(dop,'step') && isfield(dop.step,'text') && isfield(dop.step.text,'h')
        for i = 1 : numel(dop.step.text.h)
            dop.tmp.font_size = get(dop.step.text.h(i),'FontSize');
            switch get(button_handle,'tag')
                case 'font_adj_larger'
                    dop.tmp.font_size_adj = dop.tmp.font_size + 1;
                case 'font_adj_smaller'
                    if dop.tmp.font_size > 2
                        dop.tmp.font_size_adj = dop.tmp.font_size - 1;
                    end
            end
            set(dop.step.text.h(i),'FontSize',dop.tmp.font_size_adj);
        end
        
        %     dop.tmp.fig_ch = get(get(button_handle,'Parent'),'Children');
        %     dop.tmp.ch_tags = get(dop.tmp.fig_ch,'tag');
        %     dop.tmp.info_index = find(ismember(dop.tmp.ch_tags,'stepInfo'));
        %     if ~isempty(dop.tmp.info_index)
        %         dop.tmp.info_h = dop.tmp.fig_ch(dop.tmp.info_index);
        %         dop.tmp.font_size = get(dop.tmp.info_h,'FontSize');
        %         switch get(button_handle,'tag')
        %             case 'font_adj_larger'
        %                 dop.tmp.font_size_adj = dop.tmp.font_size + 1;
        %             case 'font_adj_smaller'
        %                 if dop.tmp.font_size > 2
        %                     dop.tmp.font_size_adj = dop.tmp.font_size - 1;
        %                 end
        %         end
        %         set(dop.tmp.info_h,'FontSize',dop.tmp.font_size_adj);
        %     else
        %         fprintf('Can''t find ''stepInfo text handle: No adjustment made\n')
        %     end
    else
        fprintf('Can''t find ''dop.step.text.h'' variable: No adjustment made\n')
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end