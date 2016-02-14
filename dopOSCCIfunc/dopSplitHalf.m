function dopSplitHalf(dop_input)

if exist('dop_input','var') && ~isempty(dop_input) && exist(dop_input,'file')
    [dop.tmp.dir,dop.tmp.file,dop.tmp.ext] = fileparts(dop_input);
    dop.tmp.file = [dop.tmp.file,dop.tmp.ext];
    
    dop.tmp.data = readtable(dop_input,'Delimiter','\t');
    dop.tmp.headers = dop.tmp.data.Properties.VariableNames;
    
    if sum(ismember(dop.tmp.headers,'meanDiff_odd_poi')) && sum(ismember(dop.tmp.headers,'meanDiff_even_poi'))
    dop.tmp.odd = dop.tmp.data.meanDiff_odd_poi;
    dop.tmp.even = dop.tmp.data.meanDiff_even_poi;
    [dop.tmp.pearson,dop.tmp.pearson_p] = corr(dop.tmp.odd,dop.tmp.even,'type','Pearson');
    [dop.tmp.spearman,dop.tmp.spearman_p] = corr(dop.tmp.odd,dop.tmp.even,'type','Spearman');
    fprintf('For %s (dir = %s)\n',dop.tmp.file,dop.tmp.dir);
    dop.tmp.text.n = sprintf('(n = %i)',size(dop.tmp.data,1));
    dop.tmp.text.pearson = sprintf('r = %1.2f, p = %1.4f',dop.tmp.pearson,dop.tmp.pearson_p);
    dop.tmp.text.spearman = sprintf('rho = %1.2f, p = %1.4f',dop.tmp.spearman,dop.tmp.spearman_p);
    h = figure('Name',dop.tmp.file);
    scatter(dop.tmp.odd,dop.tmp.even);
    x_lim = get(gca,'Xlim');
    y_lim = get(gca,'Ylim');
    dop.tmp.text.x_pos = min(x_lim)+diff(x_lim)*.7;
    dop.tmp.text.y_pos = min(y_lim)+diff(y_lim).*[.25 .2 .15];
    text(dop.tmp.text.x_pos,dop.tmp.text.y_pos(3),dop.tmp.text.n);
    text(dop.tmp.text.x_pos,dop.tmp.text.y_pos(1),dop.tmp.text.pearson);
    text(dop.tmp.text.x_pos,dop.tmp.text.y_pos(2),dop.tmp.text.spearman);
    
    fprintf('\n\t%s\n\t%s\n\t%s\n\n',dop.tmp.text.pearson,...
        dop.tmp.text.spearman,dop.tmp.text.n);
    end    
end