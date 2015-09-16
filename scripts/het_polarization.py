#!bin/usr/python
'''
Heterozygote Polarization Script
usage:
bcftools view -M 2 <filename> | python het_polarization.py  | bcftools view -O b > <filename.het.polarized.bcf>

Tags variants 'pushed' to ref or alt as follows:

AA - Pushed towards reference
AB - Kept as het
BB - Pushed towards alternative
'''
 
import sys
import math

def phred2p(phred):
    return 10**(phred/-10.0)
 
def GL2PL(gl):
    """ Converts Genotype likelyhoods to phred scaled (PL) genotype likelyhoods. """
    return -int(gl*10)

def main():
    format_added = False
    for l in sys.stdin.xreadlines():
        l = l.strip()
        if l.startswith("#CHROM"):
            # Get Sample information and count
            samples = l.strip().split("\t")[9:]
        elif l.startswith("##FORMAT=<ID=GL,"):
            l = """##FORMAT=<ID=PL,Number=G,Type=Integer,Description="List of Phred-scaled genotype likelihoods">"""
        elif l.startswith("#"):
            # Add Info line for het polarization flag
            if l.startswith("##FORMAT") and format_added == False:
                format_added = True
                l = l + "\n##FORMAT=<ID=HP,Number=1,Type=String,Description=\"Flag used to mark whether a variant was polarized\">"
            # Pass comment lines.
        else:
            if l.split('\t')[8].find("GL") > 0:
                # Replace GL with PL scores.
                l = l.split('\t')
                GL_loc = l[8].split(":").index("GL")
                l[8] = l[8].replace("GL","PL")
                geno_set = []
                for k,v in enumerate(l[9:]):
                    GT = v.split(":")
                    GL_set = GT[GL_loc].split(",")
                    try:
                        GT[GL_loc] = ','.join([str(GL2PL(float(i))) for i in GL_set])
                    except:
                        GT[GL_loc] = ",".join(GL_set)
                    geno_set.append(':'.join(GT))
                    l = l[0:9] + geno_set
                l = '\t'.join(l)
            l = l.strip().split("\t")
            if l[8].find("PL") > -1:
                PL = l[8].split(":").index("PL")
                add_HP_flag = 0
                for k,v in enumerate(l[9:]):
                    PL_set = v.split(":")[PL].split(",")
                    v = v.split(":")
                    if len(PL_set) == 3:
                        PL_set = [phred2p(int(i)) for i in PL_set]
                        log_score = -math.log10(PL_set[0]/PL_set[2])
                        if add_HP_flag == 0:
                            if l[8].find("HP") == -1:
                                l[8] = l[8] + ":HP" 
                            add_HP_flag = 1
                        if (log_score < -2):
                            v[0] = "0/0"
                            if v[-1] not in ["AA","AB","BB"]:
                                l[k+9] = v + ["AA"]
                            else:
                                l[k+9] = v[0:-1] + ["AA"]
                        elif (log_score > 2):
                            v[0] = "1/1"
                            if v[-1] not in ["AA","AB","BB"]:
                                l[k+9] = v + ["BB"]
                            else:
                                l[k+9] = v[0:-1] + ["BB"]
                        else:
                            v[0] = "0/1"
                            if v[-1] not in ["AA","AB","BB"]:
                                l[k+9] = v + ["AB"]
                            else:
                                l[k+9] = v[0:-1] + ["AB"]
                    else:
                        l[k+9] = v + [":."]
                    l[k+9] = ":".join(l[k+9])
            l = "\t".join(l)
        sys.stdout.write(l + "\n")



if __name__ == '__main__':
    main()
