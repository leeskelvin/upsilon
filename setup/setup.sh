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
ln -sf "$(pwd)"/screenrc ~/.screenrc

# move close buttons to left
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,maximize,minimize:'

# modify bashrc to read bashrc_cloud
if ! grep -q "source local bashrc file" ~/.bashrc; then
echo "
# source local bashrc file
if [ -f ~/.bashrc_cloud ]; then
    . ~/.bashrc_cloud
fi
" >> ~/.bashrc
fi

# setup bashrc_local
if ! grep -q "aliases" ~/.bashrc_local; then
echo "# aliases
alias galfit='~/software/galfit/galfit'
alias imfit='~/software/imfit/imfit'
alias imfit-mcmc='~/software/imfit/imfit-mcmc'
alias makeimage='~/software/imfit/makeimage'
alias imarith='~/software/cexamples/imarith'
alias listhead='~/software/cexamples/listhead'
alias modhead='~/software/cexamples/modhead'

# ssh
alias atlas='ssh -X lee@atlas.st-andrews.ac.uk'
alias external='ssh -t astlkelv@external.astro.ljmu.ac.uk \"bash\"'
alias external2='ssh -t astlkelv@external2.astro.ljmu.ac.uk \"bash\"'
alias xsinister='ssh -t astlkelv@external.astro.ljmu.ac.uk \"ssh -t astlkelv@sinister.astro.ljmu.ac.uk bash\"'
" >> ~/.bashrc_local
fi

# bring back nautilus type ahead find
if [ ! -f /etc/apt/sources.list.d/lubomir-brindza-ubuntu-nautilus-typeahead-bionic.list ]; then
sudo add-apt-repository ppa:lubomir-brindza/nautilus-typeahead
fi

# wanted packages
sudo apt-get update
sudo apt-get --with-new-pkgs upgrade
sudo apt-get install synaptic apt-xapian-index r-base-dev gdebi gedit-plugins python-pip python3-pip gnome-tweak-tool nautilus-dropbox alien astromatic gparted calibre cmake cronutils dconf-editor default-jdk vim eog-plugins ffmpeg fftw-dev ftools-fv gimp inkscape inotify-tools iraf-dev iraf-wcstools jblas jupyter leafpad libatlas-base-dev libcfitsio-dev libclblas-dev libfftw3-dev libfftw3-3 libnlopt-dev libwcstools-dev libwcs5 meld nautilus-compare plplot-tcl-dev screen texlive-full tk-dev topcat ubuntu-dev-tools wcslib-dev wcslib-tools wcstools vlc saods9 libcfitsio-bin gsl-bin libgsl-dev scons unrar

# ssh keygen
if [ ! -f ~/.ssh/id_rsa ]; then
/usr/bin/ssh-keygen
fi

# google chrome
if [ ! -f /usr/bin/google-chrome ]; then
wget -P ~/Desktop https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i ~/Desktop/google-chrome-stable_current_amd64.deb
rm -Rf ~/Desktop/google-chrome-stable_current_amd64.deb
fi

# cexamples
if [ ! -f ~/software/cexamples/fitscopy ]; then
tar -xvf cexamples.tar -C ~/software/
for filename in ~/software/cexamples/*.c; do
gcc -o ~/software/cexamples/$(basename "$filename" .c) $filename -L. -I/usr/include/cfitsio -lcfitsio -lm
done
fi

# ds9-lee
sudo sed -i 's/Exec=ds9 %F/Exec=ds9 -mode region -regions shape projection -cmap sls -scale log -scale mode 99.5 -wcs degrees -mecube %F/g' /usr/share/applications/saods9.desktop

# galfit
if [ ! -f ~/software/galfit/galfit ]; then
mkdir -p ~/software/galfit
wget -P ~/software/galfit/ https://users.obs.carnegiescience.edu/peng/work/galfit/galfit3-debian64.tar.gz
wget -P ~/software/galfit/ https://users.obs.carnegiescience.edu/peng/work/galfit/galfit-ex.tar.gz
wget -P ~/software/galfit/ https://users.obs.carnegiescience.edu/peng/work/galfit/README.pdf
tar -xvf ~/software/galfit/galfit3-debian64.tar.gz -C ~/software/galfit/
tar -xvf ~/software/galfit/galfit-ex.tar.gz -C ~/software/galfit/
rm -Rf ~/software/galfit/galfit3-debian64.tar.gz
rm -Rf ~/software/galfit/galfit-ex.tar.gz
fi

# imfit
if [ ! -f ~/software/imfit/imfit ]; then
git clone https://github.com/perwin/imfit.git ~/software/imfit
scons -C ~/software/imfit imfit
scons -C ~/software/imfit imfit-mcmc
scons -C ~/software/imfit makeimage
wget -P ~/software/imfit/ http://www.mpe.mpg.de/~erwin/resources/imfit/imfit_howto.pdf
fi

# GNU Astro
if [ ! -f /usr/local/bin/astnoisechisel ]; then
export CWD=$PWD
mkdir -p ~/software/gnuastro
cd ~/software/gnuastro
wget -P ~/software/gnuastro/ https://ftp.gnu.org/gnu/gnuastro/gnuastro-latest.tar.gz
tar -xvf ~/software/gnuastro/gnuastro-latest.tar.gz -C ~/software/gnuastro/ --strip 1
rm -Rf ~/software/gnuastro/gnuastro-latest.tar.gz
./configure
make -j4
make check
sudo make install
if [ ! -f /usr/lib/libgnuastro.so.5 ]; then
sudo ln -sf ~/software/gnuastro/lib/.libs/libgnuastro.so.5 /usr/lib/
fi
cd $CWD
wget -P ~/software/gnuastro/ https://www.gnu.org/software/gnuastro/manual/gnuastro.pdf
fi

# galsim
if [ ! -f /usr/local/bin/galsim ]; then
export CWD=$PWD
mkdir -p ~/software/galsim
cd ~/software/galsim
git clone https://github.com/GalSim-developers/GalSim.git ~/software/galsim
sudo chown -R lee.lee ~/.local/
pip3 install numpy
pip3 install -r requirements.txt
wget -P ~/software/galsim/ http://bitbucket.org/eigen/eigen/get/3.3.4.tar.bz2
tar -xjf 3.3.4.tar.bz2
sudo cp -R eigen-eigen-5a0156e40feb/Eigen /usr/local/include/
sudo python3 setup.py install
sudo chown -R lee.lee ~/software/galsim/*
cd $CWD
fi

# unwanted packages
sudo apt-get autoremove --purge shotwell shotwell-common thunderbird totem totem-common rhythmbox-data librhythmbox-core10 gir1.2-rb-3.0

# refresh synaptic quick search
sudo update-apt-xapian-index -vf

