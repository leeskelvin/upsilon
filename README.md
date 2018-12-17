# UPSILON: Useful Personal Software I Lacked Or Needed

A collection of software routines written by me to perform various tasks. 

## setup

Folder containing basic files required to set up a new computer. Sets up bash, R, screen, nautilus, Dropbox, Chrome, GALFIT, IMFIT and many more.

The script has been split into two parts: setup and install. The former performs basic file linking (mostly bash), whilst the latter installs several useful pieces of software. The former is usually all that's required for a remote server, whilst both are recommended for a full desktop setup.

On cloning upsilon repository, execute ./setup.sh to begin setup process and ./install.sh to begin the install process (Warning: this will take some time on a fresh machine).

## getbib

A routine to grab/update bibtex entries from ADS, using papers in a given folder as an input. 

Papers must be in the form RefID::ADSID.pdf. 

## kindleclip

A routine to parse notes from a Kindle 'My Clippings.txt' file and produce a single notes file for a given document. 

## papers

A routine to display, search and access all papers stored on a machine via a bibtex.rds file generated via getbib. 

