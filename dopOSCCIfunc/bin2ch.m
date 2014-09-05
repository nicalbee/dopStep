function ch=bin2ch(binIn)
%% bin2ch
%
% ch=bin2ch(bin)
%
% accepts binary number (e.g., 1000100) and returns position of nonzero
% elements.  useful for determining doppler channels from decimal numbers
%
ch=strfind(num2str(binIn),'1');