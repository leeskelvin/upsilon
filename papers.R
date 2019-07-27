#!/usr/bin/Rscript --no-init-file

# definitions
indir = normalizePath("~/Dropbox/work/archive")
librds = paste(indir, "/bibtex.rds", sep="")
reader = "/usr/bin/evince"
inputargs = commandArgs(TRUE)

# DOES NOT WORK AS EXPECTED
# # parse inputargs
# #inputargs = c("-s", "'galaxies", "with'")
# inputcon = textConnection(paste(inputargs, collapse=" "))
# inputargs = unlist(read.table(inputcon, stringsAsFactors=FALSE))
# close(inputcon)

# split up stacked inputargs
#inputargs = c("-s", "galaxies with", "-yr") # test
tempargs = as.list(inputargs)
char1 = substr(tempargs, 1, 1)
char2 = substr(tempargs, 2, 2)
tosplit = which(char1 == "-" & char2 != "-")
tempargs[tosplit] = lapply(X=strsplit(substr(inputargs[tosplit], 2, 50), ""), FUN=function(X){paste("-",X,sep="")})
inputargs = unlist(tempargs)

# show help file, open paper or print paper list?
if( (length(grep("-h",inputargs)) > 0)
    | (length(grep("--help",inputargs)) > 0)
    ){

    cat("
Usage: papers [arg] [var]

Arguments:

papers                  (list all papers in bibliography)
papers -h,--help        (show help file)
papers -o,--open        (open a file by named reference)
papers -s,--search      (search references, years and titles for a string)
papers -y,--year        (order by year)
papers -r,--reverse     (reverse order)
papers -a,--all         (print full paper titles, no truncation)

")

}else if(
    (length(grep("-o",inputargs)) > 0)
    | (length(grep("--open",inputargs)) > 0)
    ){
    
    files = dir(indir)
    varnum = grep("-o", inputargs) + 1
    myfile = files[grep(tolower(inputargs[varnum]), tolower(files))]
    if(length(myfile) > 0){
        comm = paste(reader, " ", indir, "/", myfile, " &", sep="")
        system(comm)
    }else{
        cat("ERROR: no file found\n")
    }
    
}else{
    
    # data
    dat = readRDS(librds)
    refs = unlist(lapply(dat[,"ref"], formatC, mode="character", width=-14))
    numyears = as.numeric(dat[,"year"])
    years = unlist(lapply(as.character(numyears), formatC, mode="character", width=-4))
    titles = dat[,"title"]
    codes = unlist(lapply(dat[,"code"], formatC, mode="character", width=-19))
    nchars = nchar(refs) + nchar(codes)
    
    # sort by year
    if( (length(grep("-y",inputargs)) > 0)
        | (length(grep("--year",inputargs)) > 0)
        ){
        oo = order(numyears)
        refs = refs[oo]
        years = years[oo]
        titles = titles[oo]
        codes = codes[oo]
    }
    
    # reverse ordering
    if( (length(grep("-r",inputargs)) > 0)
        | (length(grep("--reverse",inputargs)) > 0)
        ){
        oo = length(refs):1
        refs = refs[oo]
        years = years[oo]
        titles = titles[oo]
        codes = codes[oo]
    }
    
    # # indented width titles
    # titles2 = character(length(titles))
    # for(i in 1:length(titles)){
    #     indent = nchars[i] + 2
    #     bits = c(strsplit(titles[i], " +")[[1]], " ")
    #     nbits = nchar(bits) + 1
    #     temp = bits[1]
    #     start = 1
    #     for(j in 2:length(bits)){
    #         if(sum(nbits[start:j]) > (80-indent)){
    #             temp = c(temp, paste("\n", paste(rep(" ", (indent-1)), sep="", collapse=""), sep="", collapse=""))
    #             start = j
    #         }
    #         temp = c(temp, bits[j])
    #     }
    #     titles2[i] = paste(temp, sep="", collapse=" ")
    # }
    #
    # # trimmed width titles
    # titles3 = character(length(titles))
    # cols = as.numeric(system("tput cols", intern=TRUE))
    # widths = cols - nchars - 2
    # f = function(titles, widths){substr(titles, start=1, stop=widths)}
    # titles3 = Vectorize(f, vectorize.args=c("titles","widths"))(titles=titles, widths=widths)
    #
    # # output
    # out = paste("\n", paste(refs, years, titles3, sep=" ", collapse="\n"), "\n\n", sep="")
    # cat(out)
    
    # full length titles, trimmed to terminal width using colrm below
    refs = paste0("\033[1m", refs, "\033[0m") # bold font references
    out = paste("\n", paste(refs, codes, titles, sep=" ", collapse="\n"), "\n\n", sep="")
    tmp = tempfile()
    cat(out, file=tmp)
    
    # print
    if( (length(grep("-a",inputargs)) == 0)
        & (length(grep("--all",inputargs)) == 0)
        ){
        system("tput rmam")
    }
    if( (length(grep("-s",inputargs)) > 0)
        | (length(grep("--search",inputargs)) > 0)
        | (length(grep("-f",inputargs)) > 0)
        | (length(grep("--find",inputargs)) > 0)
        | (length(grep("-g",inputargs)) > 0)
        | (length(grep("--grep",inputargs)) > 0)
        ){
        varnum = c(grep("-s", inputargs) + 1, grep("-f", inputargs) + 1, grep("-g", inputargs) + 1)
        cat("\n")
        system(paste("cat ", tmp, " | grep --color=auto --ignore-case '", inputargs[varnum], "'", sep=""))
        cat("\n")
    }else{
        system(paste("cat ", tmp, sep=""))
    }
    system("tput smam")
    unlink(tmp)
    
}
