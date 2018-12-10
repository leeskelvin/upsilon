#!/bin/sh

# new files/dirs
touch ~/.bashrc_local
mkdir -p ~/.R/lib

# links
ln -s bashrc_cloud ~/.bashrc_cloud
ln -s Renviron ~/.Renviron
ln -s Rprofile ~/.Rprofile

# setup bashrc files
echo "
# source local bashrc file
if [ -f ~/.bashrc_cloud ]; then
    . ~/.bashrc_cloud
fi
" >> ~/.bashrc
source ~/.bashrc

# refresh synaptic quick search
sudo apt-get install synaptic
sudo apt-get install apt-xapian-index
sudo update-apt-xapian-index -vf

