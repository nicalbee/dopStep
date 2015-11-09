function dop = dopStepTimingPlot(dop)
% Plot the timing information in the dopStep timing step
%
% created: 10-Nov-2015 NAB

i = find(ismember(dop.step.current.style,'axes'));

if numel(dop.step.current.h) < i
    dop.step.current.h(i) = axes('Parent',dop.step.h,'Units','Normalized',...
        'Position',dop.step.current.position(i,:),...
        'Tag',dop.step.current.tag{i},...
        'YTickLabel',[],'YTick',[],...
        'XTick',[]);
end
if isfield(dop.step.current,'options')
    dop.tmp.options = dop.step.current.options; %{'epoch','base','poi'};
end
if isfield(dop.step.current,'colours')
    dop.tmp.col = dop.step.current.colours; %{'y','k','g'};
end
dop.tmp.y = [.8 .5 .2];

dop.tmp.xlim = [-30 30];
dop.tmp.ylim = [0 1];

% add zero line = event marker
if ~isfield(dop.step.current,'axes0')
    dop.step.current.axes0 = plot(dop.step.current.h(i),...
        zeros(1,2),get(dop.step.current.h(i),'YLim'),'c');
    dop.step.current.axes = zeros(1,numel(dop.tmp.y));
    dop.tmp.numbers = zeros(numel(dop.tmp.y),2);
    hold(dop.step.current.h(i));
end
if isfield(dop,'def')
    for j = 1 : numel(dop.tmp.options)
        if isfield(dop.def,dop.tmp.options{j})
            if numel(dop.def.(dop.tmp.options{j})) == 2 && ...
                    dop.def.(dop.tmp.options{j})(1) < dop.def.(dop.tmp.options{j})(2)
                dop.tmp.numbers(j,:) = dop.def.(dop.tmp.options{j});
                if dop.step.current.axes(j) ~= 0
                    % move if if already exists
                    set(dop.step.current.axes(j),'XData',dop.def.(dop.tmp.options{j}));
                else
                    % create plot
                    dop.step.current.axes(j) = plot(dop.step.current.h(i),...
                        dop.def.(dop.tmp.options{j}),...
                        ones(1,2)*dop.tmp.y(j),'color',dop.tmp.col{j});
                end
            else
                fprintf(['''dop.def.%s'' missing or lower value > than ',...
                    'upper value: can''t plot.\n'],dop.tmp.options{j});
            end
        end
    end
    dop.tmp.x_lim = dop.tmp.xlim;
    if sum(dop.tmp.numbers == 0) ~= numel(dop.tmp.numbers)
       dop.tmp.x_lim = [min(min(dop.tmp.numbers))-5, max(max(dop.tmp.numbers))+5];
    end
    set(dop.step.current.h(i),'Xlim',dop.tmp.x_lim,'YLim',dop.tmp.ylim,...
        'Color',[.75 .75 .75],...
        'YTickLabel',[],'YTick',[],...
        'XTick',eval(sprintf('[%i:5:%i]',dop.tmp.x_lim)));
end