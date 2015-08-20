configfile: "config.yaml"

varfiles = ["{0:0>2}".format(x) for x in range(1,config["num_location_files"] + 1)]

rule all:
    input:
        "log/setup_genome.done",
        expand("bam/{num}.snps.bam", num = varfiles)



include: "rules/setup_genome.snake"
include: "rules/generate_varsets.snake"
include: "rules/addsnv.snake"


