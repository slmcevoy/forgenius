library(tidyverse)

setwd("/users/mcevoysu/scratch/scripts/pi")

args = commandArgs(trailingOnly=TRUE)
species <- args[1]
version <- args[2]
subsets <- args[3]

popnt <- function(s,v,sets) { 
  pixydir <- paste0("/users/mcevoysu/scratch/output/pixy/",s)
  
  summary <- function(x) {
    x  %>%
    select(pop,count_diffs,count_comparisons,avg_pi) %>%
    group_by(pop) %>%
    summarize(All = sum(count_diffs) / sum(count_comparisons)) %>%
    add_row(pop = "All", All = (sum(x$count_diffs) / sum(x$count_comparisons)))
  }
  
  file_a <- paste0(pixydir,"/pixy_",s,v,"_pi_NAfilt.txt")
  dfa <- read_tsv(file_a,show_col_types = FALSE)
  h <- c("Pop", paste0(s,"_All",v))
  dfs <- list( dfa )
  
  if (sets == "yes" ) {
    file_r <- paste0(pixydir,"/pixy_",s,"_random",v,"_pi_NAfilt.txt")
    file_t <- paste0(pixydir,"/pixy_",s,"_target",v,"_pi_NAfilt.txt")
    dfr <- read_tsv(file_r,show_col_types = FALSE)
    dft <- read_tsv(file_t,show_col_types = FALSE)
    h <- c("Pop", paste0(s,"_All",v), paste0(s,"_Random",v), paste0(s,"_Target",v))
    dfs <- list( dfa, dfr, dft )
  }
  result <- as.data.frame( dfs %>%
            lapply( summary ))
  result <- result %>% 
    select(-contains("pop."))
  if (sets== "yes") {
    names(result)<-c("Pop", paste0(s,"_All",v), paste0(s,"_Random",v), paste0(s,"_Target",v))
  } else {
    names(result)<-c("Pop", paste0(s,"_All_",v))
  }

  write.table(result, file=paste0(s,v,"_pixy_summary.txt"), append = FALSE, sep = "\t", dec = ".",
            row.names = FALSE, col.names = TRUE, quote = FALSE)
}
popnt(species, version, subsets)
