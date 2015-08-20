configfile: "config.yaml"


rule all:
    input:
        "log/setup_genome.done",
        "log/generate_varsets.done"

include: "rules/setup_genome.snake"
include: "rules/generate_varsets.snake"
include: "rules/addsnv.snake"


