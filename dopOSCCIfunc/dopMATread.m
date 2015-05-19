function [dop,okay,msg] = dopMATread(dop_input,varargin)%file_name)
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
% 19-May-15 NAB this is a very old funciton - updating many things...

[dop,okay,msg,varargin] = dopSetBasicInputs(dop_input,varargin);
msg{end+1} = sprintf('Run: %s',mfilename);
try
    if okay
        dopOSCCIindent;%fprintf('Running %s:\n',mfilename);
        %% Inputs
        %         inputs.turnOff = {'comment'};
        inputs.varargin = varargin;
        inputs.defaults = struct(...
            'mat_file',[],...
            'file',[], ...
            'dir',[], ...
            'msg',1,... % show messages
            'wait_warn',0 ... % wait to close warning dialogs
            );
        inputs.required = ...
            {'mat_file'};
        [dop,okay,msg] = dopSetGetInputs(dop_input,inputs,msg);
        switch dopInputCheck(dop.tmp.mat_file)
            case 'file' %{'.mat','.MAT'}
                tmp_dop_use = dop; % dop_struc;
                load(dop.tmp.mat_file);
                
                % really just want to grab the data & file info
                if exist('dop','var')
                    tmp_dop_import = dop;
                dop = tmp_dop_use;
                dop.tmp.get_fields = {'data','file_info'};
                for i = 1 : numel(dop.tmp.get_fields)
                    if isfield(tmp_dop_import,dop.tmp.get_fields{i})
                        dop.(dop.tmp.get_fields{i}) = tmp_dop_import.(dop.tmp.get_fields{i});
                    else
                        okay = 0;
                        msg{end+1} = sprintf(['''%s'' data field not found ',...
                            'in mat file(%s): this is necessary.\n'],...
                            dop.tmp.get_fields{i},dop.tmp.mat_file);
                        dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                    end
                end
%                     tmp_fields = fieldnames(tmp_dop);
%                     fprintf('\t > checking fields in new vs old structure:\n');
%                     for i = 1 : numel(tmp_fields)
%                         if ~isfield(dop,tmp_fields{i})
%                             fprintf('\t\tadding field:\t%s\n',tmp_fields{i});
%                             dop.(tmp_fields{i}) = tmp_dop.(tmp_fields{i});
%                         end
%                     end
                else
                    okay = 0;
                    msg{end+1} = sprintf('Input from file not recognised (%s)\n',dop.tmp.mat_file);
                    dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
                end
            otherwise
                okay = 0;
                msg{end+1} = sprintf('This is not a ''.mat'' file (%s)\n',dop.tmp.mat_file);
                dopMessage(msg,dop.tmp.msg,1,okay,dop.tmp.wait_warn);
        end
        dop.msg = msg;
        dop.okay = okay;
        dopOSCCIindent('done');
    end
catch err
    save(dopOSCCIdebug);rethrow(err);
end
end