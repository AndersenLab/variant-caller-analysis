from subprocess import check_output

configfile: "config.yaml"

varfiles = ["{0:0>2}".format(x) for x in range(1,config["num_location_files"] + 1)]

chrom = ["I","II","III","IV","V","X"]
var_call = ["-m","-c"]
grouping = ["individual", "joint"]


rule all:
    input:
        "log/setup_genome.done",
        expand("bam/{num}.{grouping}.snps.sorted.bam", num = varfiles, grouping = grouping),
        expand("bam/{num}.{grouping}.snps.sorted.bam.bai", num = varfiles, grouping = grouping),
        expand("spikeins/{num}.txt", num = varfiles),
        expand("vcf/{num}.{grouping}.{var_call}.vcf.gz", num = varfiles,  grouping = grouping, var_call = var_call),
        expand("vcf_processed/{num}.{grouping}.{var_call}.txt", num = varfiles,  grouping = grouping, var_call = var_call)


rule download_picard:
    output:
        "tools/picard.jar"
    shell:
        """
            mkdir -p tools
            wget -O - https://github.com/broadinstitute/picard/releases/download/1.138/picard-tools-1.138.zip > tools/picard-tools-1.138.zip
            unzip -d tools tools/picard-tools-1.138.zip
            mv tools/picard-tools-1.138/* tools/
            rm -d tools/picard-tools-1.138.zip tools/picard-tools-1.138/
        """


include: "rules/setup_genome.snake"
include: "rules/generate_varsets.snake"
include: "rules/addsnv.snake"
include: "rules/call_variants.snake"


