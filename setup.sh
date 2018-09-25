#!/bin/sh

ln -s upsilon/bashrc_cloud ~/.bashrc_cloud
ln -s upsilon/Renviron ~/.Renviron
ln -s upsilon/Rprofile ~/.Rprofile

echo "
# source local bashrc file
if [ -f ~/.bashrc_local ]; then
    . ~/.bashrc_local
fi
" >> ~/.bashrc

source ~/.bashrc
