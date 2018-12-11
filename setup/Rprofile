### commands to be run first ###
.First = function(){
    options(editor="vim")
    options(papersize="a4")
    cat("\n")
    cat(R.version.string,' -- "',R.version$nickname,'"\n', sep="")
    cat(date(),"\n\n")
    #library(grDevices, quietly=TRUE)
    #library(graphics, quietly=TRUE)
    #library(stats, quietly=TRUE)
    #library(utils, quietly=TRUE)
    #library(astro, quietly=TRUE)
    #library(astroextras, quietly=TRUE)
    #library(astrosigma, quietly=TRUE)
}

### commands to be run last ###
.Last = function(){
    graphics.off()
    cat("\nkthxbai!\n\n")
}

### others ###
qq = function(){quit(save="no")}                                             # quit
XX11 = xx11 = function(...){X11(type="Xlib", ...)}                          # Xlib X11
odot = "u2609"                                                              # solar symbol
#options("repos" = c(CRAN = "http://cran.rstudio.com/"))                     # default repository
#s = base::summary                                                           # summary
#h = utils::head                                                             # head
#ht = function(d) rbind(head(d,10),tail(d,10))                               # head-tail
#hh = function(d) if(class(d)=="matrix"|class(d)=="data.frame") d[1:5,1:5]   # short head
#options(prompt="> ")                                                        # disable > prompt
inst = function(..., dependencies = TRUE) install.packages(..., dependencies = TRUE)    # installer

