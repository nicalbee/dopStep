%% dopStepButtonEnable
%
% check settings to see if certain buttons should be enabled in the dopStep
% gui.
%
% Created: 02-Sep-2016 NAB - well, saved as separate file
function dopStepButtonEnable(dop)
dop.tmp.check_tags = dop.step.action.tag;
% for some reason I've done something a bit weird with this - something
% about the labelling and the name of the definition variable
dop.tmp.check_tags{ismember(dop.step.action.tag,'event')} = 'events';
dop.tmp.vars = [];
switch dop.step.current.name
    case 'import'
        dop.tmp.vars = {'fullfile'};
        dop.tmp.required = 1;
    case 'events'
        dop.tmp.vars = {'event_height'};
        dop.tmp.required = 1;
    case 'norm'
        
        %         if ~isfield(dop.step,'dopNorm') || ~dop.step.dopNorm && isfield(dop.def,'norm_method')
        if  isfield(dop.def,'norm_method')
            dop.tmp.vars = {'epoch','baseline'};
            switch dop.def.norm_method
                case 'overall'
                    dop.tmp.required = [0 0];
                case {'epoch','deppe'}
                    % need to have both of these values
                    switch dop.def.norm_method
                        case 'epoch'
                            dop.tmp.vars(2) = [];
                            dop.tmp.required = 1;
                        case 'deppe'
                            dop.tmp.required = [1 1];
                    end
            end
        end
    case 'epoch'
        dop.tmp.vars = {'epoch'};
        dop.tmp.required = 1;
    case 'screen'
        dop.tmp.vars = {'act_sep','act_separation_pct'};
        dop.tmp.required = [1 0];
    case 'baseline'
        dop.tmp.vars = {'baseline'};
        dop.tmp.required = 1;
    case 'li'
        dop.tmp.vars = {'poi'};
        dop.tmp.required = 1;
        %     otherwise
        
end
if ~isempty(dop.tmp.vars) && isfield(dop,'def')
    dop.tmp.okay = zeros(1,numel(dop.tmp.vars));
    for i = 1 : numel(dop.tmp.vars)
        if isfield(dop.def,dop.tmp.vars{i}) && numel(dop.def.(dop.tmp.vars{i})) == 2
            switch dop.step.current.name
                case 'li'
                    if isfield(dop.def,'act_window') && ~isempty(dop.def.act_window)
                        dop.tmp.okay(i) = 1;
                    end
                otherwise
                    dop.tmp.okay(i) = 1;
            end
        else
            switch dop.step.current.name
                case {'import','events'}
                    % just a single variable here
                    if isfield(dop.def,dop.tmp.vars{i}) && ~isempty(dop.def.(dop.tmp.vars{i}))
                        dop.tmp.okay(i) = 1;
                    end
            end
        end
        
    end
    
    dop.tmp.enable = 'off';
    % switch dop.step.current.name
    %     case {'norm','epoch'}
    if strcmp(dop.step.current.name,'norm') && isfield(dop.def,'norm_method') && strcmp(dop.def.norm_method,'overall') && ~isfield(dop.step,'dopNorm') || ...
            and(sum(dop.tmp.okay),sum(dop.tmp.required == dop.tmp.okay) == numel(dop.tmp.okay)) || ...
            strcmp(dop.step.current.name,'screen')
        dop.tmp.enable = 'on';
    end
    set(dop.step.action.h(ismember(dop.tmp.check_tags,dop.step.current.name)),'enable',dop.tmp.enable);
end
end