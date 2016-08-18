% getHigherDir
%
% returns the directory x levels up from calling function path
%
% dir = getHigherDir(x)
%
% where x is the number of directory levels you want to go up by
%
% Added: 18-Aug-2016 NAB - added to dopOSCCI
% Edits:

function up_dir = getHigherDir(levels_up)

comment = 1;
if comment
    fprintf('Running %s\n',mfilename);
end
if ~exist('levels_up','var') || isempty(levels_up)
    levels_up = 1;
    if comment
        fprintf('levels_up variable not found, default = %u\n',levels_up);
    end
end
in_info = dbstack; % get calling information
if size(in_info) == 1
    ref_func = in_info(1).name;
    if comment
        fprintf('\t(note: Function called on it''s own,i.e., not calling fucntion)\n');
    end
else
    ref_func = in_info(2).name;
end
% report what's happening
if comment
    fprintf('\tMoving %u directories up, relative to %s location/path\n',levels_up,ref_func);
end
% get current working directory, return to this when done
current_dir = pwd; % print working directory (current directory)

% change directory to x levels up
from_dir = fileparts(which(ref_func)); % path of the reference function
if comment
    fprintf('\t%s location/path:\n\t = %s\n',ref_func,from_dir);
end
cd(fullfile(from_dir,repmat(['..',filesep],1,levels_up)));
% save this new directory to a variable for output
up_dir = [pwd,filesep]; % add the separate for good measure
if comment
    fprintf('\t> %u levels up:\n\t = %s\n',levels_up,up_dir);
end
% return to original directory
cd(current_dir);
