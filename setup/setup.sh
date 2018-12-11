#!/bin/bash

# files/dirs/links
touch ~/.bashrc_local
mkdir -p ~/.R/lib
ln -sf "$(pwd)"/bashrc_cloud ~/.bashrc_cloud
ln -sf "$(pwd)"/Renviron ~/.Renviron
ln -sf "$(pwd)"/Rprofile ~/.Rprofile
mkdir -p ~/.templates
ln -sf "$(pwd)"/Rscript.R ~/.templates/Rscript.R
ln -sf "$(pwd)"/untitled ~/.templates/untitled
sed -i 's/Templates/.templates/g' ~/.config/user-dirs.dirs
rm -Rf ~/Templates

# move close buttons to left
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,maximize,minimize:'

# setup bashrc
if ! grep -q "source local bashrc file" ~/.bashrc; then
echo "
# source local bashrc file
if [ -f ~/.bashrc_cloud ]; then
    . ~/.bashrc_cloud
fi
" >> ~/.bashrc
fi

# packages
sudo apt-get update
sudo apt-get --with-new-pkgs upgrade
sudo apt-get install synaptic apt-xapian-index r-base-dev gdebi gedit-plugins python3-pip gnome-tweak-tool nautilus-dropbox alien astromatic gparted calibre cmake cronutils dconf-editor default-jdk vim eog-plugins ffmpeg fftw-dev ftools-fv gimp inkscape inotify-tools iraf-dev iraf-wcstools jblas jupyter leafpad libatlas-base-dev libcfitsio-dev libclblas-dev libfftw3-dev libfftw3-3 libnlopt-dev libwcstools-dev libwcs5 meld nautilus-compare plplot-tcl-dev screen texlive-full tk-dev topcat ubuntu-dev-tools wcslib-dev wcslib-tools wcstools vlc saods9 

# refresh synaptic quick search
#sudo update-apt-xapian-index -vf

# google chrome
if [ ! -f /usr/bin/google-chrome ]; then
wget -P ~/Desktop https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i ~/Desktop/google-chrome-stable_current_amd64.deb
rm -Rf ~/Desktop/google-chrome-stable_current_amd64.deb
fi

