===================================
Intro
===================================
- This tool allows previewing your paist files in engine in real time,
by starting a server which informs clients whenever a file changes,
and what the new contents of the file are.

-Creator and Maintainer: Drew Wright

===================================
SETUP
===================================
-Need python 2.7
-Install pip on your machine. 
--Download https://bootstrap.pypa.io/get-pip.py
--Run get-pip.py in an admin enabled prompt
- install the following packages using pip install:
-- twisted
--- An event-driven networking engine written in Python
-- autobahn
--- A library for creating web servers and clients
-- watchdog
--- A cross-platform library for monitoring changes to files within directories
-if "pip install" doesn't work, try navigating to your python directory in a 
	command prompt and running .\Scripts\pip.exe install "yourpackagenamehere"

===================================
INSTRUCTIONS - SIMPLE
===================================
run startFreshGloo.bat

===================================
INSTRUCTIONS - ADVANCED
===================================

1: Run from this directory:
python freshGlooServer <full path of paist layouts directory> [hostname] [port]

eg.
python freshGlooServer "C:\projects\smokescreen\trunk\Engineering\lib\layouts"

-Full path is mandatory, eg. Projects/myProject/lib/layouts
-Host name is optional, and will default to 127.0.0.1. For local builds, this is fine.
-Port is optional, and will default to 9001. Right now, that's all the tool is configured for.

2: Run a local build, enter the menu previewing state.

3: Now, whenever you save a change to any paist file in the provided directory,
the new version will be piped over to the game, and will be displayed in real time