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
try
    % probably don't want to report function name eventually
    fprintf('\nRunning %s:\n',mfilename);
    tmp.fig_ch = get(get(button_handle,'Parent'),'Children');
    tmp.ch_tags = get(tmp.fig_ch,'tag');
    tmp.info_index = find(ismember(tmp.ch_tags,'stepInfo'));
    if ~isempty(tmp.info_index)
        tmp.info_h = tmp.fig_ch(tmp.info_index);
        tmp.font_size = get(tmp.info_h,'FontSize');
        switch get(button_handle,'tag')
            case 'font_adj_larger'
                tmp.font_size_adj = tmp.font_size + 1;
            case 'font_adj_smaller'
                if tmp.font_size > 2
                    tmp.font_size_adj = tmp.font_size - 1;
                end
        end
        set(tmp.info_h,'FontSize',tmp.font_size_adj);
    else
        fprintf('Can''t find ''stepInfo text handle: No adjustment made\n')
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end