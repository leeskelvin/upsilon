#!/usr/bin/Rscript --no-init-file

# definitions
indir = normalizePath("~/Dropbox/professional/archive")
outrds = paste(indir, "/bibtex.rds", sep="")
exiftool = "/usr/bin/exiftool" # check/set PDF title
file = "/usr/bin/file" # check file mime type

# data
files = grep(".pdf", dir(indir), value=TRUE)
bits = matrix(unlist(strsplit(files, "::")),ncol=2,byrow=T)
bits[,2] = unlist(strsplit(bits[,2], ".pdf"))

# FUNCTION counter
counter = function(i, total, text = "", overline = FALSE, underline = FALSE, endnewline = TRUE){
    
    toprint = paste("  ", i, " / ", total, " ", sep="")
    if(text != ""){toprint = paste(toprint, ": ", text, " ", sep="")}
    linelen = nchar(toprint) + 1
    if(overline){
        toprint = paste(paste(rep("-",linelen), collapse=""), "\n", toprint, sep="")
        endnewline = FALSE
    }
    if(underline){
        toprint = paste(toprint, "\n", paste(rep("-",linelen), collapse=""), sep="")
        endnewline = FALSE
    }
    if(overline | underline){
        toprint = paste(toprint, "\n", sep="")
    }
    if(!overline & !underline){
        cat(paste(rep(c(" ","\b"),each=80),collapse=""))    # clear line
        todelete = nchar(toprint)
        backspace = paste(rep("\b", len=todelete), collapse="")
        toprint = paste(toprint, backspace, sep="")
    }
    if(endnewline){
        if(i == total){
            toprint = paste(toprint, "\n", sep="")
        }
    }
    cat(toprint)
    
}

# loop
for(i in 1:length(files)){
    
    #  setup
    ref = bits[i,1]
    code = bits[i,2]
    counter(i, length(files), ref)
    myfile = paste0(indir, "/", files[i])
    filetype = system(paste0(file, ' --mime-type -b "', myfile, '"'), intern=TRUE)
    
    # check/set title only if PDF
    if(filetype == "application/pdf"){
        
        # title
        title.prelim = system(paste0(exiftool, ' -title "', myfile, '"'), intern=TRUE)
        if(length(title.prelim) > 0){
            title = strsplit(title.prelim, " : ")[[1]][2]
        }else{
            title = ""
        }
        if(is.na(title)){title = ""}
        
        # set title if necessary
        if(title != ref){
            system(paste0(exiftool, ' -title="', ref, '" -overwrite_original_in_place -preserve -quiet -m "', myfile, '"'))
        }
        
    }
    
}

