function msg = dopEventExistMsg
% dopEventExistMsg
%
% within functions, if it is established that dop.event exists then the
% event markers have already been found so we don't need to run
% 'dopEventMarkers' again, probably. This is a long-winded message about
% potential issues with not re-running 'dopEventMarkers'. Really only a
% problem if the length of the data has been changed since running it in
% the first place. Length of the data can be changed with:
%  - dopDataTrim
%  - dopDownsample
%
% Hopefully the user is aware that they've run the functions in a
% particular order and that this might be a problem...
%
% There's a function for this message as it's long and it's used a few
% times so thought I'd keep a copy of it in one location and call it as
% necessary.
%
% Created: 30-Aug-2014 NAB
% Last edit:
% 30-Aug-2014 NAB

% commented code:
% msg{end+1} = dopEventExistMsg;
% dopMessage(msg,dop.tmp.comment,1);

msg = ['''dop.event'' variable exists - using pre-'...
    'defined epoch markers. This shouldn''t be a problem' ...
    ' unless you changed the length of the data (running' ...
    ' ''dopDataTrim'' or ''dopDownsample'' after determining' ...
    ' event marker positions'];