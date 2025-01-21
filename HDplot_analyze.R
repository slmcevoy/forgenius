#if (!require("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")

#BiocManager::install("geneplotter")

library(geneplotter)
library(data.table)
rm(list=ls(all=TRUE))

#change settings here
setwd("/users/mcevoysu/scratch/scripts")

args = commandArgs(trailingOnly=TRUE)
outputdir <- args[1]

missing.results <- paste0(outputdir,"/SNPs.miss.lmiss")
HDplot.results <- paste0(outputdir,"/SNPs.depthsBias")

#import SNP list with no. of missing data
missing <- read.table(missing.results, sep="\t", header=TRUE, stringsAsFactors=F)
#missing data is given in haplotypes, has to becorrected
MISS_IND <- missing$N_MISS/2
#add SNP identifier
SNP.missing <- paste(missing$CHR,":",missing$POS, sep="")
#combine the two vectors
missing2 <- data.frame(SNP.missing, MISS_IND)
missing2$SNP.missing<-as.character(missing2$SNP.missing)

#import HD plot results (normally less SNPs than above)
HDplot <- read.table(HDplot.results, sep="\t", header=TRUE, stringsAsFactors=F)
#add SNP identifier
SNP.HDplot <- paste(HDplot$contig,":",HDplot$pos, sep="")
#create new table and remove unnecessary columns
HDplot2 <- cbind(SNP.HDplot, HDplot)
HDplot3 <- subset(HDplot2, select = -c(X, locus_ID))

#merge the two tables
table <- merge(missing2, HDplot3, by.x="SNP.missing", by.y="SNP.HDplot", all.x=T)

#calculate the correct H and AB
H <- as.numeric(table$num_hets)/(as.numeric(table$num_samples)-as.numeric(as.character(table$MISS_IND)))
AB <- pmax(table$depth_a,table$depth_b)/pmin(table$depth_a,table$depth_b)

#create and save final table
table2<-cbind(table,H,AB)
setnames(table2, old=c("ratio", "z"), new=c("RAF", "D"))
table2<-table2[!is.na(table2$contig),]
write.table(table2,paste0(outputdir,"/HDplot_results.txt"),sep="\t",quote=F, row.names=F)

#create a summary plot
#change thresholds here (this is just for plotting)
Hmax <- 0.6
RAFmin <- 0.2
RAFmax <- 0.8
Dmin <- -10
Dmax <- 10

# create a list of filtered SNPs
filt_table<-table2[table2$RAF<RAFmax & table2$RAF>RAFmin & table2$H<Hmax & table2$D < Dmax & table2$D > Dmin,]
write.table(filt_table,paste0(outputdir,"/HDplot_results_filt.txt"),sep="\t",quote=F, row.names=F)

# write a list with the variants to filter VCF with bcftools
discard<-table2[!table2$SNP.missing%in%filt_table$SNP.missing,]
write.table(discard[,3:4], paste0(outputdir,"/HD_SNP_list_toFilt.txt"), row.names=F, col.names=F, quote=F, sep="\t")

