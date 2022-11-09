#########################
# Sets of rules for MACS2 peak calling
#########################

rule call_narrow_peaks:
    input:
        map_sorted      = RESULT_DIR + "mapped/{sample}.sorted.bam"
    output:
        narrowPeak      = RESULT_DIR + "macs2/{sample}_peaks.narrowPeak",
    params:
        name            =   "{sample}",
        format          =   str(config["macs2"]["format"]),
        genomesize      =   str(config["macs2"]["genomesize"]),
        outdir          =   str(config["macs2"]["outdir"]),
    message:
        "Calling narrowPeak for {wildcards.sample}"
    log:
        RESULT_DIR + "logs/macs2/{sample}_peaks.narrowPeak.log",
    singularity:'docker://biowardrobe2/macs2:v2.1.1'
    shell:
        """
        macs2 callpeak -t {input} {params.format} {params.genomesize} \
        --name {params.name} --nomodel --bdg -q 0.05 \
        --outdir {params.outdir}/ 2>{log}
        """
