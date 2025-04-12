## king_rel_Psylvestris_MIerrorplot.R for KING MI error plot, by Wei-Min Chen and Zhennan Zhu
rm(list=ls(all=TRUE))
library(kinship2)
library(igraph)
ped <- read.table(file="king_rel_Psylvestrissplitped.txt", stringsAsFactors=FALSE)[,c(1,2,5,6,7,8,9)]
ped$V8[ped$V8==-9 | ped$V8==0 | ped$V8==1] <- 0
ped$V8[ped$V8==2] <- 1
colnames(ped) <- c("FID", "ID", "FA", "MO", "Sex", "Affected", "Status")
data <- read.table("king_rel_Psylvestris.kin",header = TRUE, stringsAsFactors = FALSE)
mi.err <- data[data[, "Error"]==1, "FID" ]
Inf.color <- c("purple", "red", "green", "blue", "yellow", NA)
Inf.type <- c("Dup/MZ", "PO", "FS", "2nd", "3rd")
data.fam <- merge(data, ped, by.x = c("FID", "ID1"), by.y = c("FID", "ID"))
data.all <- merge(data.fam, ped, by.x = c("FID", "ID2"), by.y = c("FID", "ID"))[, c("FID", "ID1", "ID2", "Sex.x", "Sex.y", "InfType", "Error")]
data.all[!data.all$InfType %in% Inf.type, "InfType"] <- 6
for (i in 1:5) data.all[data.all$InfType == Inf.type[i], "InfType"] <- i
data.all[data.all$Error==1,"Error"] <- 5
data.all[data.all$Error==0.5|data.all$Error==0,"Error"] <- 1
postscript("king_rel_Psylvestris_MIerrorplot.ps", paper="letter", horizontal=T, fonts=c("serif", "Palatino"))
par(mfrow=c(1, 2))
for (famid in unique(mi.err)){
  fam <- ped[ped[, "FID"]==famid,]
  if (all(fam[, c("FA", "MO")]==0)){
    g.empty <- make_empty_graph(n = nrow(fam), directed = FALSE)
    plot(g.empty, vertex.size=27, vertex.color=NA, vertex.label.cex=.5, vertex.label.dist=1.6,
         vertex.label.degree= pi/2, vertex.label.color="black", vertex.label= fam[,"ID"],
         edge.color=NA, layout=layout_with_fr(g.empty, grid="nogrid"), asp=0,
         vertex.shape=c("none", "square", "circle")[1+fam[,"Sex"]])}else{
  pedplot <- pedigree(id = fam$ID, dadid = fam$FA, momid = fam$MO, sex = as.numeric(fam$Sex),
    affected = as.numeric(fam$Affected), status = as.numeric(fam$Status), famid = fam$FID, missid = 0)
  plot(pedplot[toString(famid)], cex = 0.5, symbolsize = 2.8)}
  fam.sub <- data.all[data.all$FID==famid,][, 2:7]
  id <- unique(mapply(c, fam.sub[,c(1,3)], fam.sub[,c(2, 4)]))
  g <- graph_from_data_frame(d=fam.sub, vertices=id[, 1], directed=FALSE)
  plot(g, edge.width=fam.sub$Error, vertex.size=27, vertex.color=NA, vertex.label.cex=0.5,
       edge.color=Inf.color[as.numeric(fam.sub$InfType)], layout=layout_with_fr(g, grid="nogrid"), asp=0,
       vertex.shape=c("none", "square", "circle")[1+as.numeric(id[, 2])], margin=c(0.3,0,0,0))
  legend("bottomright", Inf.type, lty=1, col=Inf.color, text.col=Inf.color, cex=0.7, bty="n")
  mtext(paste("Documented versus Inferred Family", famid, "in king_rel_Psylvestris"), side = 3, line = -2, outer = TRUE)}
dev.off()
rm(list=ls(all=TRUE))
