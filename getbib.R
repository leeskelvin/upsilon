#!/usr/bin/Rscript --no-init-file

# definitions
indir = normalizePath("~/work/papers")
outrds = paste(indir, "/bibtex.rds", sep="")
outbib = paste(indir, "/bibtex.bib", sep="")
#outtemp = paste(indir, "/bibtex.temp.rds", sep="")

# mirror
mirror = "http://adsabs.harvard.edu"
#mirror = "http://ukads.nottingham.ac.uk"
#mirror = "http://ads.nao.ac.jp"

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
if(file.exists(outrds)){
    old = readRDS(outrds)
    bad = which(!old[,"ref"] %in% res[,"ref"])
    if(length(bad) > 0){old = old[-bad,]}
    pos = match(old[,"ref"], res[,"ref"])
    res[pos,] = old
}

i = 1

# loop over each necessary entry
lookup = which(res[,"year"]==-9999)
for(i in lookup){
    # setup
    ref = res[i,"ref"]
    code = res[i,"code"]
    counter(which(lookup==i), length(lookup), ref)
#    # check if a rescan of ADS is necessary
#    rescan = TRUE
#    if(ref %in% old[,"ref"]){
#        row = which(old[,"ref"] == ref)
#        oldcode = old[row,"code"]
#        if(oldcode == code){
#            rescan = FALSE
#            year = old[row,"year"]
#            title = old[row,"title"]
#            bibentry = old[row,"bibentry"][[1]]
#        }
#    }
#    # rescan from ADS if necessary
#    if(rescan){
    # rescan from ADS
    adsurl = paste(mirror, "/abs/", code, sep="")
    biburl = paste(mirror, "/cgi-bin/nph-bib_query?bibcode=", code, "&data_type=BIBTEX&db_key=AST&nocookieset=1", sep="")
    # get BIBTEX
    bibfile = readLines(biburl)
    # update reference
    firstline = grep("@",bibfile)[1]
    bibtype = tolower(strsplit(bibfile[firstline], "\\{")[[1]][1])
    bibfile[firstline] = paste(bibtype, "{", ref, ",", sep="")
    # pick out metadata
    title = strip(strsplit(grep("title = ", bibfile, value=TRUE), "title =")[[1]][2], c(" ","{","}",",","\\",'"',"{","}"))
    year = as.numeric(strip(strsplit(grep("year =", bibfile, value=TRUE), "year =")[[1]][2], c(" ",","," ")))
    # generate bibtext entry
    bibentry = bibfile[firstline:length(bibfile)]
    # arXiv fix (MNRAS compatible)
    if(length(grep("e-prints", bibentry)) > 0){
        bibentry[grep("e-prints", bibentry)] = "  journal = {ArXiv e-prints},"
        vrow = grep("   adsurl = \\{", bibentry)
        bibentry = bibentry[c(1:vrow,vrow:length(bibentry))]
        bibentry[vrow] = '   volume = "{\\!\\!}",'
    }
    # replace %26 with ampersand (principally in HTML URLs)
    if(length(grep("%26", bibentry)) > 0){bibentry = gsub("%26", "&", bibentry)}
#    }
    # add to global
    #res[i,"ref"] = ref
    res[i,"year"] = year
    res[i,"title"] = title
    #res[i,"code"] = code
    #res[i,"adsurl"] = adsurl
    #res[i,"biburl"] = biburl
    res[i,"bibentry"][[1]] = list(bibentry)
    ## save global (constant save in case of HTTP break)
    #saveRDS(res, file=outtemp)
}

i = 1

# write results RDS file
saveRDS(res, file=outrds)
#unlink(outtemp)

# write  bibtex file
bibinfo = unlist(res[,"bibentry"])
cat(paste(bibinfo, "\n", sep=""), sep="", file=outbib)




