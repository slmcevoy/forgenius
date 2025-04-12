## king_rel_Csativa_uniqfam0plot.R for KING --related, by Wei-Min Chen and Zhennan Zhu
rm(list=ls(all=TRUE))
library(igraph)
data <- read.table(file="king_rel_Csativa.kin0", header=TRUE, stringsAsFactors=FALSE)[,c("ID1", "ID2", "InfType")]
Inf.color <- c("purple", "red", "green", "blue")
Inf.type <- c("Dup/MZ", "PO", "FS", "2nd")
relatives <- data[data$InfType %in% Inf.type, ]
for (i in 1:length(Inf.type)) relatives[relatives$InfType == Inf.type[i], "InfType"] <- i
colnames(relatives)[3] <- "color"
BuildPed <- function(v){
 buildType <- ""
 if(v[1]==3 && v[2]==3 && v[4]==2 && v[6]==1) buildType <- "2_GG/HalfSibs"
 else if(v[1]==3 && v[2]==3 && v[3]==1 && v[4]==2) buildType <- "2_MZtwins+1_Parent/Child"
 else if(v[1]==4 && v[2]==5 && v[3]==1 && v[4]==4) buildType <- "2_Parents+2_MZtwins"
 if(v[5]>0){
  s <- floor(sqrt(v[5]*2))+1
  if(s*(s-1)/2==v[5]){
   if(v[2]==v[5] && v[4]==0) buildType <- paste0(s, "_FullSiblings")
   else if(v[2]==v[5]+s && v[4]==s) buildType <- paste0("1_Parent+", s, "_FullSiblings")
   else if(v[2]==v[5]+s*2 && v[4]==s*2) buildType <- paste0("2_Parents+", s, "_FullSiblings")
   else buildType <- paste0(s, "_FullSiblings+", v[1]-s, "_Relatives")
  }else if(v[3]==0 && v[4]==0 && v[6]==0) buildType <- "Undetermined_FS_Only"
  else buildType <- "Undetermined_FS"
 }else if(v[4]==0 && v[6]==0){
  buildType <- ifelse(v[3]==1, "2_MZtwins", "Undetermined_MZ_Only")
 }else if(v[3]==0 && v[4]==0){
  buildType <- ifelse(v[6]==1, "2_Second-Degree_Relatives", "Undetermined_2nd_Only")
 }else if(v[3]==0 && v[6]==0){
  if(v[4]==1) buildType <- "1_Parent+1_Child"
  else if(v[4]==2) buildType <- "2_Parents+1_Child(Trio)"
  else buildType <- "Undetermined_PO_Only"}
if(buildType==""){
 if(v[3]>0) buildType <- "Undetermined_MZ"
 else if(v[4]>0) buildType <- "Undetermined_PO"}
 return(buildType)
}
g <- graph_from_data_frame(d = relatives, vertices = unique(c(relatives$ID1, relatives$ID2)), directed = FALSE)
imc <- cluster_infomap(g)
imc.membership <- membership(imc)
community.info <- cbind(imc$membership,imc$names)
colnames(community.info) <- c("membership", "ID")
community.rel <- merge(relatives, community.info, by.x = c("ID1"), by.y = c("ID"))
community.rel$membership <- as.numeric(as.character(community.rel$membership))
color_counts <- function(i) {
  sub.colors <- community.rel[community.rel[, "membership"]==i, "color"]
  return(sapply(1:4, function(y) sum(sub.colors==y)))}
colors <- t(sapply(1:length(imc), color_counts))
fam.info <- cbind(community.index=1:length(imc), sizes.node = sizes(imc), edge.colors=apply(colors, 1, sum), colors)
fam.info <- as.data.frame(fam.info)
all.counts <- aggregate(cbind(fam.info[0],counts=1),fam.info[,-1], length)
fam.info.counts <- merge(fam.info, all.counts, by= c("sizes.node","edge.colors","V4","V5","V6","V7"))
uniq.fam.info <- fam.info.counts[!duplicated(fam.info.counts[, c(1:6,8)]), ][,c(7, 1:6, 8)]
uniq.fam.info <- uniq.fam.info[order(uniq.fam.info$counts,decreasing=TRUE),]
all.counts <- uniq.fam.info[,"counts"]
uniq.cluster <- induced_subgraph(g, (1:length(V(g)))[imc.membership %in% uniq.fam.info[, "community.index"]])
all.names <- sapply(V(uniq.cluster)$name, function(x) membership(imc)[names(imc.membership)%in%x])
all.builds <- apply((uniq.fam.info[, -1]),1,BuildPed)
lo <- layout_(uniq.cluster, with_fr(), normalize())
LocationForACluster<-function(x){
  lo.local <- lo[all.names==x,]
  return(c(min(as.numeric(lo.local[,1])), max(as.numeric(lo.local[,1])), max(as.numeric(lo.local[,2]))))}
locations <- sapply(uniq.fam.info[, 1], LocationForACluster)
postscript("king_rel_Csativa_uniqfam0plot.ps", paper="letter", horizontal=T)
plot(uniq.cluster, vertex.color=NA, vertex.size=1, vertex.label=NA, layout=lo, asp=0,
  edge.color=Inf.color[as.numeric(E(uniq.cluster)$color)], main="All Unique Family Configurations in king_rel_Csativa")
text((locations[1,]+locations[2,])/2, locations[3,]+0.04, all.counts)
legend("bottomright", Inf.type, lty = 1, col = Inf.color, text.col = Inf.color, cex = 0.7, bty = "n")
dev.off()
rm(list=ls(all=TRUE))
