#!/bin/bash

# files/dirs/links
touch ~/.bashrc_local
mkdir -p ~/.R/lib
mkdir -p ~/.vim/ftplugin
mkdir -p ~/.ipython/profile_default/startup
ln -sf "$(pwd)"/bashrc_cloud ~/.bashrc_cloud
ln -sf "$(pwd)"/Renviron ~/.Renviron
ln -sf "$(pwd)"/Rprofile ~/.Rprofile
ln -sf "$(pwd)"/screenrc ~/.screenrc
ln -sf "$(pwd)"/gitconfig ~/.gitconfig
ln -sf "$(pwd)"/vimrc ~/.vimrc
ln -sf "$(pwd)"/ftplugin-c.vim ~/.vim/ftplugin/c.vim
ln -sf "$(pwd)"/ftplugin-python.vim ~/.vim/ftplugin/python.vim
ln -sf "$(pwd)"/ipython-startup.py ~/.ipython/profile_default/startup/ipython-startup.py

# templates
mkdir -p ~/.templates
ln -sf "$(pwd)"/Rscript.R ~/.templates/Rscript.R
ln -sf "$(pwd)"/untitled ~/.templates/untitled
rm -Rf ~/Templates
if [ -f ~/.config/user-dirs.dirs ]; then
sed -i 's/Templates/.templates/g' ~/.config/user-dirs.dirs
fi

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
#alias galfit='~/software/galfit/galfit'
#alias imfit='~/software/imfit/imfit'
#alias imfit-mcmc='~/software/imfit/imfit-mcmc'
#alias makeimage='~/software/imfit/makeimage'
#alias imarith='~/software/cexamples/imarith'
#alias listhead='~/software/cexamples/listhead'
#alias modhead='~/software/cexamples/modhead'

# ssh
alias atlas='ssh -X lee@atlas.st-andrews.ac.uk'
alias external='ssh -t astlkelv@external.astro.ljmu.ac.uk \"bash\"'
alias xsinister='ssh -t astlkelv@external.astro.ljmu.ac.uk \"ssh -t astlkelv@sinister.astro.ljmu.ac.uk bash\"'
alias physauth='ssh lskelvin@physauth.physics.ucdavis.edu'
alias xemerald='ssh -t lskelvin@physauth.physics.ucdavis.edu \"ssh -t lskelvin@emerald.physics.ucdavis.edu bash\"'
alias minos='ssh -X lkelvin@minos.astro.princeton.edu'
alias lsstdev='ssh -X lskelvin@lsst-dev01.ncsa.illinois.edu'
alias ldmount='mkdir -p ~/ldmount; sshfs lskelvin@lsst-dev01.ncsa.illinois.edu:/home/lskelvin ~/ldmount'
alias ldunmount='fusermount -u ~/ldmount; echo "ldmount file listing:"; ls -lA ~/ldmount; rm -iR ~/ldmount'
alias xstart='xpra start :5525; export DISPLAY=:5525'
alias xstop='xpra stop'
alias xattach='xpra attach ssh:lskelvin@lsst-dev01.ncsa.illinois.edu:5525'
alias xdetach='xpra detach ssh:lskelvin@lsst-dev01.ncsa.illinois.edu:5525'
alias tigressgateway='ssh -Xt lkelvin@tigressgateway.princeton.edu'
alias tiger='ssh -Xt lkelvin@tigressgateway.princeton.edu "ssh -Xt lkelvin@tiger2-sumire.princeton.edu bash"'
" >> ~/.bashrc_local
fi

