## king_rel_Tbaccata_relplot.R for KING --related, by Wei-Min Chen
rm(list=ls(all=TRUE))
postscript("king_rel_Tbaccata_relplot.ps", paper="letter", horizontal=T)
data<-c()
if(file.exists("king_rel_Tbaccata.kin")) data <- read.table(file="king_rel_Tbaccata.kin", header=T)
allcolors <- c("purple", "red", "green", "blue", "magenta", "gold", "black")
allrelatives <- c("MZ Twin", "Parent-Offspring", "Full Siblings", "2nd-Degree", "3rd-Degree", "More Distant", "Unrelated")
if(length(data$IBD1Seg)>0 & length(data$IBD2Seg)>0){
allpair <- data$PropIBD>0 | data$Kinship>0.04419
d0 <- data$Phi==0.5
d1.PO <- data$Phi==0.25 & data$Z0==0
d1.FS <- data$Phi==0.25 & data$Z0>0
d2 <- data$Phi>0.08839 & data$Phi<=0.17678
d3 <- data$Phi>0.04419 & data$Phi<=0.08839
dO <- data$Phi>0 & data$Phi<=0.04419
dU <- data$Phi==0 & allpair
plot(data$IBD1Seg[dU], data$IBD2Seg[dU], type="p", col = "black", cex.lab=1.2,
xlim=c(min(data$IBD1Seg[allpair]), max(data$IBD1Seg[allpair])),
ylim=c(min(data$IBD2Seg[allpair]), max(data$IBD2Seg[allpair])),
main = "IBD Segments In king_rel_Tbaccata Families",
xlab=expression(paste("Length Proportion of IBD1 Segments (", pi[1], ")", sep="")),
ylab=expression(paste("Length Proportion of IBD2 Segments (", pi[2], ")", sep="")))
points(data$IBD1Seg[d0], data$IBD2Seg[d0], col="purple")
points(data$IBD1Seg[d1.PO], data$IBD2Seg[d1.PO], col="red")
points(data$IBD1Seg[d1.FS], data$IBD2Seg[d1.FS], col="green")
points(data$IBD1Seg[d2], data$IBD2Seg[d2], col="blue")
points(data$IBD1Seg[d3], data$IBD2Seg[d3], col="magenta")
points(data$IBD1Seg[dO], data$IBD2Seg[dO], col="gold")
points(data$IBD1Seg[dU & data$PropIBD>0.08838835], data$IBD2Seg[dU & data$PropIBD>0.08838835], col="black")
points(data$IBD1Seg[d1.FS & data$IBD2Seg<0.08], data$IBD2Seg[d1.FS & data$IBD2Seg<0.08], col="green")
points(data$IBD1Seg[d1.PO & data$IBD1Seg+data$IBD2Seg<0.9], data$IBD2Seg[d1.PO & data$IBD1Seg+data$IBD2Seg<0.9], col="red")
abline(h = 0.08, col = "green", lty = 3, lwd = 2)
abline(a = 0.96, b = -1, col = "red", lty = 3, lwd = 2)
abline(a = 0.3535534, b = -0.5, col = "green", lty = 3, lwd = 2)
abline(a = 0.1767767, b = -0.5, col = "blue", lty = 3, lwd = 2)
abline(a = 0.08838835, b = -0.5, col = "magenta", lty = 3, lwd = 2)
abline(a = 0.04419, b = -0.5, col = "gold", lty = 3, lwd = 2)
legend("topright", allrelatives, col=allcolors, text.col=allcolors, pch=19, cex=1.2)
allpair <- data$PropIBD>0 | data$Kinship>0.04419
d0 <- data$Phi==0.5
d1.PO <- data$Phi==0.25 & data$Z0==0
d1.FS <- data$Phi==0.25 & data$Z0>0
d2 <- data$Phi>0.08839 & data$Phi<=0.17678
d3 <- data$Phi>0.04419 & data$Phi<=0.08839
dO <- data$Phi>0 & data$Phi<=0.04419
dU <- data$Phi==0 & allpair
plot(data$PropIBD[dU], data$Kinship[dU], type="p", col = "black", cex.lab=1.2,
xlim=c(min(data$PropIBD[allpair]), max(data$PropIBD[allpair])),
ylim=c(min(data$Kinship[allpair]), max(data$Kinship[allpair])),
main = paste("Kinship vs Proportion IBD (Corr=", round(cor(data$Kinship[data$PropIBD>0], data$PropIBD[data$PropIBD>0]),digit=3),") in king_rel_Tbaccata Families",sep=""),
xlab=expression(paste("Proportion of Genomes IBD (", pi,"=",pi[2]+pi[1]/2,")",sep="")),
ylab = expression(paste("Estimated Kinship Coefficient (", phi, ")",sep="")))
points(data$PropIBD[d0], data$Kinship[d0], col="purple")
points(data$PropIBD[d1.FS], data$Kinship[d1.FS], col="green")
points(data$PropIBD[d1.PO], data$Kinship[d1.PO], col="red")
points(data$PropIBD[d2], data$Kinship[d2], col="blue")
points(data$PropIBD[d3], data$Kinship[d3], col="magenta")
points(data$PropIBD[dO], data$Kinship[dO], col="gold")
points(data$PropIBD[dU & data$Kinship>0.088], data$Kinship[dU & data$Kinship>0.088], col="black")
abline(h = 0.35355, col = "purple", lty = 3)
abline(h = 0.17678, col = "green", lty = 3)
abline(h = 0.08838, col = "blue", lty = 3)
abline(h = 0.04419, col = "magenta", lty = 3)
abline(h = 0.02210, col = "gold", lty = 3)
abline(a = 0, b = 0.5, lty = 1)
abline(a = 0, b = 0.7071068, lty = 3)
abline(a = 0, b = 0.3535534, lty = 3)
abline(v = 0.70711, col = "purple", lty = 3)
abline(v = 0.35355, col = "green", lty = 3)
abline(v = 0.17678, col = "blue", lty = 3)
abline(v = 0.08838, col = "magenta", lty = 3)
abline(v = 0.04419, col = "gold", lty = 3)
text(x=0.35355, y=0.35355, "1st", adj=c(0,1), col="green")
text(x=0.17678, y=0.17678, "2nd", adj=c(0,1), col="blue")
text(x=0.08839, y=0.08839, "3rd", adj=c(0,1), col="magenta")
text(x=0.04419, y=0.04419, "4th", adj=c(0,1), col="gold")
legend("bottomright", allrelatives, col=allcolors, text.col=allcolors, pch=19, cex=1.2)
}else if(length(data$Kinship)>0){
d0 <- data$Phi==0.5
d1.PO <- data$Phi==0.25 & data$Z0==0
d1.FS <- data$Phi==0.25 & data$Z0>0
d2 <- data$Phi==0.125
dU <- data$Phi==0
dO <- !d0 & !d1.PO & !d1.FS & !d2 & !dU
plot(data$HomIBS0[dU], data$Kinship[dU], type="p", col = "black", cex.lab=1.3,
xlim=c(min(data$HomIBS0), max(data$HomIBS0)),
ylim=c(min(data$Kinship), max(data$Kinship)),
main = "Kinship vs IBS0 in king_rel_Tbaccata Families",
xlab="Proportion of Zero IBS In Minor Homozygote Pairs", ylab = "Estimated Kinship Coefficient")
points(data$HomIBS0[d0], data$Kinship[d0], col="purple")
points(data$HomIBS0[d1.PO], data$Kinship[d1.PO], col="red")
points(data$HomIBS0[d1.FS], data$Kinship[d1.FS], col="green")
points(data$HomIBS0[d2], data$Kinship[d2], col="blue")
points(data$HomIBS0[dO], data$Kinship[dO], col="gold")
points(data$HomIBS0[dU & data$Kinship>0.088], data$Kinship[dU & data$Kinship>0.088], col="black")
abline(h = 0.3536, col = "red", lty = 3)
abline(h = 0.1768, col = "green", lty = 3)
abline(h = 0.0884, col = "blue", lty = 3)
abline(h = 0.0442, col = "black", lty = 3)
legend("topright", allrelatives, col=allcolors, text.col=allcolors, pch=19, cex=1.2)
plot(data$HetConc[dU], data$Kinship[dU], type="p",
col = "black", cex.lab=1.3,
xlim = c(min(data$HetConc), max(data$HetConc[data$HetConc<0.8])),
ylim = c(min(data$Kinship), max(data$Kinship[data$HetConc<0.8])),
main = "Kinship vs Heterozygote Concordance In king_rel_Tbaccata Families",
xlab="Heterozygote Concordance Rate", ylab = "Estimated Kinship Coefficient")
points(data$HetConc[d1.PO], data$Kinship[d1.PO], col="red")
points(data$HetConc[d1.FS], data$Kinship[d1.FS], col="green")
points(data$HetConc[d2], data$Kinship[d2], col="blue")
points(data$HetConc[dO], data$Kinship[dO], col="gold")
points(data$HetConc[dU & data$Kinship>0.088], data$Kinship[dU & data$Kinship>0.088], col="black")
abline(h = 0.3536, col = "red", lty = 3)
abline(h = 0.1768, col = "green", lty = 3)
abline(h = 0.0884, col = "blue", lty = 3)
abline(h = 0.0442, col = "black", lty = 3)
legend("bottomright", allrelatives, col=allcolors, text.col=allcolors, pch=19, cex=1.2)
if(sum(d1.FS)>20){
y.cut <- 2^-2.5
x.FS <- quantile(data$HetConc[d1.FS], probs=c(0.1, 0.9))
y.FS <- quantile(data$Kinship[d1.FS], probs=c(0.1, 0.9))
slope.FS <- (y.FS[2]-y.FS[1]) / (x.FS[2]-x.FS[1])
a.FS <- y.FS[1]-x.FS[1]*slope.FS
abline(a=a.FS, b=slope.FS, col="green")
x.cut.FS <- (y.cut - a.FS)/slope.FS
}
if(sum(d2)>20){
x.d2 <- quantile(data$HetConc[d2], probs=c(0.9, 0.1))
y.d2 <- quantile(data$Kinship[d2], probs=c(0.9, 0.1))
slope.d2 <- (y.d2[2]-y.d2[1]) / (x.d2[2]-x.d2[1])
a.d2 <- y.d2[1]-x.d2[1]*slope.d2
abline(a=a.d2, b=slope.d2, col="blue")
x.cut.d2 <- (y.cut - a.d2)/slope.d2
x.cut <- sqrt(x.cut.d2 * x.cut.FS)
}
if(sum(d1.FS)>20 & sum(d2)>20){
print(c(x.cut.d2, x.cut.FS, x.cut))
abline(v=x.cut, col="purple", lty=3)
text(x=x.cut, y=0.3, labels=round(x.cut,digit=3),col="purple")
points(data$HetConc[d1.FS & data$HetConc < x.cut], data$Kinship[d1.FS & data$HetConc < x.cut], col="green")
}
}

if(!file.exists("king_rel_Tbaccata.kin0")) quit()
data <- read.table(file = "king_rel_Tbaccata.kin0", header=T)
if(length(data$IBD1Seg)>0 & length(data$IBD2Seg)>0){
d0 <- data$IBD2Seg>0.7
d1.PO <- (!d0) & data$IBD1Seg+data$IBD2Seg>0.96 | (data$IBD1Seg+data$IBD2Seg>0.9 & data$IBD2Seg<0.08)
d1.FS <- (!d0) & (!d1.PO) & data$PropIBD>0.35355 & data$IBD2Seg>=0.08
d2 <- data$PropIBD>0.17678 & data$IBD1Seg+data$IBD2Seg<=0.9 & (!d1.FS)
d3 <- data$PropIBD>0.08839 & data$PropIBD<=0.17678
d4 <- data$PropIBD>0.04419 & data$PropIBD<=0.08839
dU <- data$PropIBD>0 & data$PropIBD<=0.04419
plot(data$IBD1Seg[dU], data$IBD2Seg[dU], type="p", col = "black", cex.lab=1.2,
xlim=c(min(data$IBD1Seg), max(data$IBD1Seg)),
ylim=c(min(data$IBD2Seg), max(data$IBD2Seg)),
main = "IBD Segments In Inferred king_rel_Tbaccata Relatives",
xlab=expression(paste("Length Proportion of IBD1 Segments (", pi[1], ")",sep="")),
ylab=expression(paste("Length Proportion of IBD2 Segments (", pi[2], ")",sep="")))
points(data$IBD1Seg[d0], data$IBD2Seg[d0], col="purple")
points(data$IBD1Seg[d1.PO], data$IBD2Seg[d1.PO], col="red")
points(data$IBD1Seg[d1.FS], data$IBD2Seg[d1.FS], col="green")
points(data$IBD1Seg[d2], data$IBD2Seg[d2], col="blue")
points(data$IBD1Seg[d3], data$IBD2Seg[d3], col="magenta")
points(data$IBD1Seg[d4], data$IBD2Seg[d4], col="gold")
abline(h = 0.08, col = "green", lty = 3, lwd = 2)
abline(a = 0.96, b = -1, col = "red", lty = 3, lwd = 2)
abline(a = 0.3535534, b = -0.5, col = "green", lty = 3, lwd = 2)
abline(a = 0.1767767, b = -0.5, col = "blue", lty = 3, lwd = 2)
abline(a = 0.08838835, b = -0.5, col = "magenta", lty = 3, lwd = 2)
abline(a = 0.04419, b = -0.5, col = "gold", lty = 3, lwd = 2)
allcolors <- c("purple", "red", "green", "blue", "magenta", "gold", "black")
legend("topright", c("Inferred MZ", "Inferred PO", "Inferred FS", "Inferred 2nd", "Inferred 3rd", "Inferred 4th", "Inferred UN"),
  col=allcolors, text.col = allcolors, pch = 19, cex = 1.2)
}
if(length(data$IBD1Seg)>0 & length(data$IBD2Seg)>0){
d0 <- data$IBD2Seg>0.7
d1.PO <- (!d0) & data$IBD1Seg+data$IBD2Seg>0.96 | (data$IBD1Seg+data$IBD2Seg>0.9 & data$IBD2Seg<0.08)
d1.FS <- (!d0) & (!d1.PO) & data$PropIBD>0.35355 & data$IBD2Seg>=0.08
d2 <- data$PropIBD>0.17678 & data$IBD1Seg+data$IBD2Seg<=0.9 & (!d1.FS)
d3 <- data$PropIBD>0.08839 & data$PropIBD<=0.17678
d4 <- data$PropIBD>0.04419 & data$PropIBD<=0.08839
dU <- data$PropIBD<=0.04419
plot(data$PropIBD[d1.FS], data$Kinship[d1.FS], type="p", col="green", cex.lab=1.2,
xlim=c(min(data$PropIBD), max(data$PropIBD)),
ylim=c(min(data$Kinship), max(data$Kinship)),
main = paste("Kinship vs Proportion IBD (Corr=", round(cor(data$Kinship[data$PropIBD>0], data$PropIBD[data$PropIBD>0]),digit=3),") in Inferred king_rel_Tbaccata Relatives",sep=""),
xlab=expression(paste("Proportion of Genomes IBD (", pi,"=",pi[2]+pi[1]/2,")",sep="")), 
ylab = expression(paste("Estimated Kinship Coefficient (", phi, ")",sep="")))
points(data$PropIBD[d1.PO], data$Kinship[d1.PO], col="red")
points(data$PropIBD[d0], data$Kinship[d0], col="purple")
points(data$PropIBD[d2], data$Kinship[d2], col="blue")
points(data$PropIBD[d3], data$Kinship[d3], col="magenta")
points(data$PropIBD[d4], data$Kinship[d4], col="gold")
points(data$PropIBD[dU], data$Kinship[dU], col="black")
abline(h = 0.35355, col = "purple", lty = 3)
abline(h = 0.17678, col = "green", lty = 3)
abline(h = 0.08839, col = "blue", lty = 3)
abline(h = 0.04419, col = "magenta", lty = 3)
abline(h = 0.02210, col = "gold", lty = 3)
abline(a = 0, b = 0.5, lty = 1)
abline(a = 0, b = 0.7071068, lty = 3)
abline(a = 0, b = 0.3535534, lty = 3)
abline(v = 0.70711, col = "purple", lty = 3)
abline(v = 0.35355, col = "green", lty = 3)
abline(v = 0.17678, col = "blue", lty = 3)
abline(v = 0.08839, col = "magenta", lty = 3)
abline(v = 0.04419, col = "gold", lty = 3)
text(x=0.35355, y=0.35355, "1st", adj=c(0,1), col="green")
text(x=0.17678, y=0.17678, "2nd", adj=c(0,1), col="blue")
text(x=0.08839, y=0.08839, "3rd", adj=c(0,1), col="magenta")
text(x=0.04419, y=0.04419, "4th", adj=c(0,1), col="gold")
legend("bottomright", c("Inferred MZ", "Inferred PO", "Inferred FS", "Inferred 2nd", "Inferred 3rd", "Inferred 4th", "Inferred UN"),
col=allcolors, text.col = allcolors, pch = 19, cex = 1.2)
}
dev.off()
rm(list=ls(all=TRUE))
