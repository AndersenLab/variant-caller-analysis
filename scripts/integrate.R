library(dplyr)
library(readr)
library(tidyr)
library(data.table)



spikein_files <- dir(path="spikeins", pattern = ".*\\.txt", full.names = TRUE)
varset_files  <- dir(path="varsets", pattern = ".*\\.txt", full.names = TRUE)
vcf_files     <- dir(path="vcf_processed", pattern = ".*\\.txt", full.names = TRUE)

#
# Load Spikeins
#

spikeins <- do.call(bind_rows, lapply(spikein_files, function(x) { 
  read_tsv(x, col_names = c("snv",
                            "chrom_pos",
                            "POS",
                            "change",
                            "avgoutcover",
                            "avgoutcover2",
                            "spikein_snvfrac",
                            "maxfrac")) %>%
    mutate(num = str_match(x, "[0-9]+")[[1]]) %>%
    distinct() %>%
    dplyr::select(-snv, -avgoutcover2) %>%
    separate(col = "chrom_pos", into = c("CHROM"), sep = ":", extra = "drop")
}))

#
# Load Varsets
# 

varsets <- do.call(bind_rows, lapply(varset_files, function(x)  {
  read_tsv(x, col_names = c("CHROM", "POS", "POS2", "FREQ")) %>%
    dplyr::select(-POS2, -FREQ) %>%
    mutate(num = str_match(x, "[0-9]+")[[1]]) %>%
    left_join(spikeins, by = c("CHROM", "POS", "num")) %>%
    mutate(successful_spikein = ifelse(!is.na(change), TRUE, FALSE)) %>%
    group_by(CHROM, POS) %>%
    distinct()
}))


#
# Load Variants
#

variants <- do.call(bind_rows, lapply(vcf_files, function(x) {
  read_tsv(x)
})) %>% 
  separate(varfile, sep = "[\\/|\\.]", into = c("drop","num","grouping", "call_method"), extra = "drop") %>%
  dplyr::select(num, CHROM, POS, everything(), -drop) %>%
  filter(INDEL == 0)

#
# Join Variants
#

results <- left_join 

