#!/usr/bin/Rscript --no-init-file

clippings = commandArgs(TRUE)

if(length(clippings) == 0){
    
    clippings = system('zenity --title "Kindle Clippings" --file-selection --file-selection="*.txt" 2>/dev/null', intern=TRUE)
    
}

text = suppressWarnings(c("==========", readLines(clippings)))

text = gsub("", "", text) # hidden characters

starts = grep("==========", text)

names = text[starts+1]

selection = system(paste('zenity --list --title "Kindle Clippings" --text "Select a document from the list:" --column "Name" --hide-header ', paste(sort(unique(paste0('"',names,'"'))), sep="", collapse=" "), "2>/dev/null"), intern=TRUE)

goods = starts[which(names %in% selection)]

ids = text[goods+2]

times = substr(ids, nchar(ids)-(7), nchar(ids))

res = data.frame(page=numeric(0), hilite=character(0), note=character(0), stringsAsFactors=FALSE)

for(i in 1:length(goods)){
    
    start = starts[which(starts == goods[i])]
    end = starts[which(starts == goods[i])+1]
    nstart = starts[which(starts == goods[i])+1]
    nend = starts[which(starts == goods[i])+2]
    note = ""
    
    if(length(grep("Your Highlight on page", text[goods[i]+2])) > 0){
        
        page = as.numeric(strsplit(strsplit(text[start+2], " +")[[1]][6], "-")[[1]][1])
        hilite = text[(start+4):(end-1)]
        
        if(length(which(times %in% times[i])) > 1){ # note before highlight
            
            nstart = starts[which(starts == goods[i])-1]
            nend = starts[which(starts == goods[i])]
            
        }
        
        if(length(grep("Your Note on page", text[nstart+2])) > 0){
            
            note = text[(nstart+4):(nend-1)]
            
        }
        
        if(note != ""){
            
            res[nrow(res)+1,] = list(page,hilite,note)
            
        }
        
    }
    
}

if(nrow(res) > 0){
    
    oo = order(res[,"page"])
    res = res[oo,]
    
    tres = paste0("page ", res[,"page"], ":\n> ", res[,"hilite"], "\n", res[,"note"], "\n\n")
    
    cat(tres, sep="", file=paste0(strsplit(selection, " +")[[1]][1], ".txt"))
    
}




