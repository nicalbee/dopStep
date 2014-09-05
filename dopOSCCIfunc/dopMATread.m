function dop = dopMATread(file_name,dop_struc)
% dopOSCCI3: dopMATread ~ 16-Dec-2013 (last edit)
%
% notes:
% reads dop structure from a '.mat' file which is/(can be*) created using
% dopMATsave function. This allows for the data to be imported more
% efficiently (quickly).
%
% * not yet implemented (07-Aug-2013)
%
% Use:
%
% dop = dopMATread(file_name,[dop_struc]);
%
% where:
% > Inputs:
% - dop = dop matlab structure
%
% > Outputs:
% - dop = dop matlab sructure
%
% Created: 07-Aug-2013 NAB
try
    fprintf('\nRunning %s:\n',mfilename);
    switch dopInputCheck(file_name)
        case {'.mat','.MAT'}
            tmp_dop = dop_struc;
            load(file_name);
            tmp_fields = fieldnames(tmp_dop);
            fprintf('\t > checking fields in new vs old structure:\n');
            for i = 1 : numel(tmp_fields)
                if ~isfield(dop,tmp_fields{i})
                    fprintf('\t\tadding field:\t%s\n',tmp_fields{i});
                    dop.(tmp_fields{i}) = tmp_dop.(tmp_fields{i});
                end
            end
        otherwise
            fprintf('This is not a ''.mat'' file (%s)\n',file_name)
    end
    fprintf('\n');
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end