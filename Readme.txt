DOPOSCCI 3: dopStep
A functional Transcranial Doppler Ultrasound (fTCD) Summary MATLAB Toolbox
where:
dop = Doppler
OSCCI = Oxford Study of Children’s Communication Impairments

DOPOSCCI is a MATLAB toolbox for handling and summarising fTCD data.

It has been programmed to work with .TX/.TW and .EXP data files acquired with DopplerBox hardware from DWL and QL software. But there’s no reason it couldn’t be updated for additional data formats.

It has been written for Mac X and Windows operating systems running MATLAB 2014a or later.

GETTING STARTED:
To get started, you’ve probably already downloaded a copy of the toolbox from:
https://github.com/nicalbee/dopStep

1. Make sure you unzip the files and you know where the files are on your hard drive.

2. Set the MATLAB path to include the files. To do this*:
 - Open MATLAB
 - go to the ‘Home’ tab
 - then click ‘Set Path’
 - click ‘Add with subfolders’
 - browse to the main dopStep/dopOSCCI folder
 - then click okay.
 There’s an option to save the path. You may be able to do this - it depends on your access/administration rights on your computer. But, as it’s an important step and worth remembering how to do, it may be best NOT to save the path, just add it each time you start MATLAB.

> Now MATLAB will know about the functions.

3. Type ‘dopStep’ in the MATLAB command window. A GUI (graphical user interface) should open. This will provide you with a step by step guide to using the software, including the capacity to:
 - visualise the data at each processing step (clicking the ‘plot’ button),
 - examine the underlying ‘dop’ variable that holds the data behind the GUI (clicking the ‘dop’ button), and
 - see a copy of the MATLAB code use to complete the processing steps (clicking the ‘code’ button).

PROCESSING BACKGROUND, EXPLANATION, AND CITATION:
Much of the code is based on the work by Michael Deppe:
Deppe, M., Knecht, S., Henningsen, H., & Ringelstein, E. B. (1997). AVERAGE: a Windows® program for automated analysis of event related cerebral blood flow. Journal of Neuroscience Methods, 75(2), 147–154. http://doi.org/10.1016/S0165-0270(97)00067-8

Deppe, M., Ringelstein, E. B., & Knecht, S. (2004). The investigation of functional brain lateralization by transcranial Doppler sonography. NeuroImage, 21(3), 1124–1146. http://doi.org/10.1016/j.neuroimage.2003.10.016


If you do make use of the code, please cite the following papers:
Badcock, N. A., Holt, G., Holden, A., & Bishop, D. V. M. (2012). dopOSCCI: A functional transcranial Doppler ultrasonography summary suite for the assessment of cerebral lateralization of cognitive function. Journal of Neuroscience Methods, 204(2), 383–388. http://doi.org/10.1016/j.jneumeth.2011.11.018

Badcock NA, Spooner R, Hofmann J, Flitton AJ, Elliott S, Kurylowicz L, Lavrencic LM, Payne HM, 'Holt GK, Holden A, Churches OF, Kohler MJ, Keage HA. (2016) What Box: a task for assessing language lateralisation in young children. PeerJ Preprints ,  4:e1939v2 https://doi.org/10.7287/peerj.preprints.1939v2

I hope you find the code useful. I’ll do my best to support you if you have any difficulties or are interested in additional functionality.

Nic Badcock
nicholas.badcock@mq.edu.au

* As an alternative, you could type the following code into the MATLAB command window:
	addpath(genpath(‘myfolder/dopStep’))
Where: ‘myfolder/dopStep’ is the directory location of the dopOSCCI files (Windows example ’C:\myfolder\dopStep’)
> Next time you start MATLAB, you should be able to start typing this code (e.g., ‘add’) then press the ‘up arrow’ key for MATLAB to auto complete the command for you.
 