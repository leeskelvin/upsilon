#!/usr/bin/Rscript --no-init-file

# definitions
indir = normalizePath("~/Dropbox/professional/archive") # dir with PDFs
reader = "/usr/bin/evince"                              # PDF reader
exiftool = "/usr/bin/exiftool"                          # check/set PDF title
file = "/usr/bin/file"                                  # check file mime type

# mirror
#mirror = "http://adsabs.harvard.edu"
mirror = "http://ukads.nottingham.ac.uk"
#mirror = "http://ads.nao.ac.jp"

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

# FUNCTION strip
strip = function(x, strip=" "){
    # workhorse function
    sfunc = function(x, strip){
        x = strsplit(x,"")[[1]]
        for(i in 1:length(strip)){
            s = strip[i]
            good = which(x!=s)
            if(length(good)>0){
                x = x[min(good):max(good)]
            }else{
                x = ""
            }
        }
        x = paste(x,collapse="")
        return(x)
    }
    # vectorize
    stripped = as.character(Vectorize(sfunc, vectorize.args=c("x"))(x=x, strip=strip))
    # return results
    return(stripped)
}

# split up stacked inputargs, define rds/bib files
inputargs = commandArgs(TRUE)
#inputargs = c("kelvin1899a", "-o")
if(length(inputargs)==0){inputargs = "-h"}
tempargs = as.list(inputargs)
char1 = substr(tempargs, 1, 1)
char2 = substr(tempargs, 2, 2)
tosplit = which(char1 == "-" & char2 != "-")
tempargs[tosplit] = lapply(X=strsplit(substr(inputargs[tosplit], 2, 50), ""), FUN=function(X){paste("-",X,sep="")})
inputargs = unlist(tempargs)
if(length(inputargs)>0){if(strsplit(inputargs[1], "")[[1]][1]=="-"){inputargs = c(" ",inputargs)}}
librds = paste(indir, "/bibtex.rds", sep="")
libbib = paste(indir, "/bibtex.bib", sep="")
libtxt = paste(indir, "/bibtex.txt", sep="")

# run argument(s)
if( (length(grep("-h",inputargs)) > 0)
    | (length(grep("--help",inputargs)) > 0)
    ){

    cat("
Usage: bib [arg] [INPUT]

Arguments:

bib -a,--all        (print full paper titles, no truncation)
bib -b,--bib        (include full bibtex entries in search)
bib -f,--fix        (run PDF title get/set routine over all PDFs)
bib -h,--help       (show help file)
bib -m,--max        (maximum number of entries to print)
bib -o,--open       (open first matching search entry in PDF reader)
bib -r,--reverse    (reverse order)
bib -u,--update     (update bibliography from ADS or local bibtex.txt file)
bib -w,--whole      (update bibliography from ADS or local and re-scan local)
bib -y,--year       (order by year)
")
    if(file.exists(librds)){cat("\nBibliography currently contains \033[1m",nrow(readRDS(librds)),"\033[0m entries.\n", sep="")}
    cat("\n")

}else if(
    (length(grep("-f",inputargs)) > 0)
    | (length(grep("--fix",inputargs)) > 0)
    ){

    # data
    files = grep(".pdf", dir(indir), value=TRUE)
    bits = matrix(unlist(strsplit(files, "::")),ncol=2,byrow=T)
    bits[,2] = unlist(strsplit(bits[,2], ".pdf"))

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

}else if(
    (length(grep("-u",inputargs)) > 0)
    | (length(grep("--update",inputargs)) > 0)
    | (length(grep("-w",inputargs)) > 0)
    | (length(grep("--whole",inputargs)) > 0)
    ){

    # data
    files = grep(".pdf", dir(indir), value=TRUE)
    bits = matrix(unlist(strsplit(files, "::")),ncol=2,byrow=T)
    bits[,2] = unlist(strsplit(bits[,2], ".pdf"))
    res = data.frame( ref = bits[,1]                    # reference
                    , year = rep(-9999,length(files))   # publication year
                    , title = character(length(files))  # title
                    , code = bits[,2]                   # ADS ID
                    , bibentry = I(vector("list",length(files))) # ADS bibtex entry
                    , stringsAsFactors = FALSE
                    )
    if(file.exists(librds)){
        old = readRDS(librds)
        bad = which(!old[,"ref"] %in% res[,"ref"])
        if(length(bad) > 0){old = old[-bad,]}
        pos = match(old[,"ref"], res[,"ref"])
        res[pos,] = old
    }
    if(file.exists(libtxt)){
        extra = readLines(libtxt)
    }else{
        extra = ""
    }

    # loop over each necessary entry
    if((length(grep("-w",inputargs)) > 0) | (length(grep("--whole",inputargs)) > 0)){
        lookup = which(res[,"year"]==-9999 | res[,"code"]=="bibtex.txt")
    }else{
        lookup = which(res[,"year"]==-9999)
    }
    for(i in lookup){

        # setup
        ref = res[i,"ref"]
        code = res[i,"code"]
        counter(which(lookup==i), length(lookup), ref)

        # ADS or local bibtex entry?
        if(code=="bibtex.txt"){

            bibnodes = c(grep("@", extra), (length(extra)+1))
            bibstart = grep(paste0("\\{",ref), extra)
            bibend = bibnodes[which(bibnodes > bibstart)[1]] - 1
            bibentry = extra[bibstart:bibend]
            if(bibentry[length(bibentry)] != ""){bibentry = c(bibentry, "")}
            year = as.numeric(strip(strsplit(strsplit(grep(" year", bibentry, v=T), "= ")[[1]][2], ",")[[1]][1], c("{","}")))
            title = strsplit(strsplit(grep(" title", bibentry, v=T), "\\{")[[1]][2], "\\}")[[1]][1]

        }else{

            # ADS URLs
            adsurl = paste(mirror, "/abs/", code, sep="")
            biburlold = paste(mirror, "/cgi-bin/nph-bib_query?bibcode=", code, "&data_type=BIBTEX&db_key=AST&nocookieset=1", sep="")
            biburl = paste(mirror, "/abs/", code, "/exportcitation", sep="")

            # get and parse BIBTEX from ADS
            bibfile = suppressWarnings(readLines(biburl, skipNul=TRUE))
            bibfile = gsub("&amp;", '&', bibfile)       # ampersand (impacts many below)
            bibfile = gsub("&#34;", '"', bibfile)       # quotation mark
            bibfile = gsub("\\\\&lt;", '<', bibfile)    # less than
            bibfile = gsub("\\\\&gt;", '>', bibfile)    # greater than
            bibfile = gsub("\\\\&le;", '<=', bibfile)   # less than or equal to
            bibfile = gsub("\\\\&ge;", '>=', bibfile)   # greater than or equal to

            # update reference
            firstline = suppressWarnings(grep('readonly=\"\">@',bibfile)[1])
            bibtype = tolower(strsplit(strsplit(bibfile[firstline], 'readonly=\"\">')[[1]][2], "\\{")[[1]][1])
            bibfile[firstline] = paste(bibtype, "{", ref, ",", sep="")
            finalline = suppressWarnings(grep('adsnote',bibfile)[1])+1

            # pick out metadata
            title = suppressWarnings(strip(strsplit(grep("title = ", bibfile, value=TRUE), "title =")[[1]][2], c(" ","{","}",",","\\",'"',"{","}")))
            year = suppressWarnings(as.numeric(strip(strsplit(grep("year =", bibfile, value=TRUE), "year =")[[1]][2], c(" ",","," ",'"'))))

            # generate bibtext entry
            bibentry = bibfile[firstline:finalline]
            if(bibentry[length(bibentry)] != ""){bibentry = c(bibentry,"")}

            # arXiv fix (MNRAS compatible)
            if(length(grep("e-prints", bibentry)) > 0){
                bibentry[grep("e-prints", bibentry)] = "  journal = {ArXiv e-prints},"
                vrow = grep("   adsurl = \\{", bibentry)
                bibentry = bibentry[c(1:vrow,vrow:length(bibentry))]
                bibentry[vrow] = '   volume = "{\\!\\!}",'
            }

            # replace %26 with ampersand (principally in HTML URLs)
            if(length(grep("%26", bibentry)) > 0){bibentry = gsub("%26", "&", bibentry)}

            # replace &#39; with '
            if(length(grep("&#39;", bibentry)) > 0){bibentry = gsub("&#39;", "'", bibentry)}

        }

        # add to global
        res[i,"year"] = year
        res[i,"title"] = title
        res[i,"bibentry"][[1]] = list(bibentry)

        # check/set PDF title, if PDF, and if appropriate
        myfile = paste0(indir, "/", files[i])
        filetype = system(paste0(file, ' --mime-type -b "', myfile, '"'), intern=TRUE)
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

    # write results RDS file
    saveRDS(res, file=librds)

    # write  bibtex file
    bibinfo = unlist(res[,"bibentry"])
    cat(paste(bibinfo, "\n", sep=""), sep="", file=libbib)
    if(file.exists(librds)){cat("Bibliography currently contains \033[1m",nrow(readRDS(librds)),"\033[0m entries (\033[1m", nrow(res)-nrow(old), "\033[0m new).\n", sep="")}

}else{

    # data
    dat = readRDS(librds)
    refs = unlist(lapply(dat[,"ref"], formatC, mode="character", width=-14))
    numyears = as.numeric(dat[,"year"])
    years = unlist(lapply(as.character(numyears), formatC, mode="character", width=-4))
    titles = dat[,"title"]
    codes = unlist(lapply(dat[,"code"], formatC, mode="character", width=-19))
    nchars = nchar(refs) + nchar(codes)
    bibentries = unlist(lapply(dat[,"bibentry"], paste, collapse=" "))

    # sort by year
    if( (length(grep("-y",inputargs)) > 0)
        | (length(grep("--year",inputargs)) > 0)
        ){
        oo = order(numyears)
        refs = refs[oo]
        years = years[oo]
        titles = titles[oo]
        codes = codes[oo]
        bibentries = bibentries[oo]
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
        bibentries = bibentries[oo]
    }

    # maximum number of entries to print
    maxcount = 9999
    if( (length(grep("-m",inputargs)) > 0)
        | (length(grep("--max",inputargs)) > 0)
        ){
        varnum = c(grep("-m", inputargs) + 1, grep("--max", inputargs) + 1)[1]
        maxcount = as.numeric(inputargs[varnum])
    }

    # full length titles, trimmed to terminal width below (possibly incl. bibentries)
    if( (length(grep("-b",inputargs)) > 0)
        | (length(grep("--bib",inputargs)) > 0)
        ){
        out1 = paste("\n", paste(paste0("\033[1m", refs, "\033[0m"), titles, bibentries, sep=" ", collapse="\n"), "\n\n", sep="")
    }else{
        out1 = paste("\n", paste(paste0("\033[1m", refs, "\033[0m"), titles, sep=" ", collapse="\n"), "\n\n", sep="")
    }
    tmp1 = tempfile()
    cat(out1, file=tmp1)

    # print
    if( (length(grep("-a",inputargs)) == 0)
        & (length(grep("--all",inputargs)) == 0)
        ){
        system("tput rmam")
    }
    cat("\n")
    system(paste("cat ", tmp1, " | grep --max-count=", maxcount," --color=auto --ignore-case '", inputargs[1], "'", sep=""))
    cat("\n")
    system("tput smam")

    # clean up
    unlink(tmp1)

    # open file?
    if( (length(grep("-o",inputargs)) > 0)
        | (length(grep("--open",inputargs)) > 0)
        ){

        # write greppable tmp file without bolded font
        if( (length(grep("-b",inputargs)) > 0)
        | (length(grep("--bib",inputargs)) > 0)
        ){
            out2 = paste("\n", paste(refs, titles, bibentries, sep=" ", collapse="\n"), "\n\n", sep="")
        }else{
            out2 = paste("\n", paste(refs, titles, sep=" ", collapse="\n"), "\n\n", sep="")
        }
        tmp2 = tempfile()
        cat(out2, file=tmp2)

        # first matched file (for subsequent file opening)
        allmatches = as.character(suppressWarnings(system(paste("cat ", tmp2, " | grep --max-count=", maxcount," --color=never --ignore-case '", inputargs[1], "'", sep=""), intern=T)))
        if(length(allmatches) > 0){
            allmatchessplit = strsplit(allmatches, " +")
            allmatchessplit = allmatchessplit[lapply(allmatchessplit,length)>0]
            firstmatchref = allmatchessplit[[1]][1]
            firstmatchcode = codes[which(strip(refs) == firstmatchref)]
            firstmatchfile = paste0(indir, "/", firstmatchref, "::", firstmatchcode, ".pdf")
        }else{
            firstmatchfile = NULL
        }

        # open file
        if(length(firstmatchfile) > 0){
            comm = paste(reader, ' "', firstmatchfile, '" &', sep="")
            system(comm)
        }else{
            cat("ERROR: no file found\n")
        }

        # clean up
        unlink(tmp2)

    }

}
