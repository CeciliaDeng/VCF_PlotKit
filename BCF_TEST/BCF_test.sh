## BCFtools is faster than vcftools

workDir=`pwd`
inputFile=/output/genomic/plant/Actinidia/GBS_PS1_1.68.5/2016_SatishK_Slipstream/2016_CAGRF13148/Satish_CAGRF13148.Ploidy4.PS1.SNPs.0111.CallRate0.5_Cnt10.vcf

#### Load modules
module load bcftools;
module load tabix;
module load texlive
module load miniconda2
source activate hrachd_sga



##### TEST 1: QC plots (eg. DP, QD, MQ etc.). All Good
## Retrieve DP field
#cat input.INFO.vcf | sed 's/^.*;DP=\([0-9]*\);.*$/\1/' > input.INFO.DP.txt

## Quality by depth (QD = Qual / DP)
#perl -lane 'BEGIN {$str="";} if ( $F[7] =~ m/DP=(\d+);/ ) { $dp = $1; $x = int($F[5]/$dp); $str .= $x . "\n"; } END {print $str;}' $inputFile > input.QD.txt


### Mapping quality (MQM, MQMR, or MQ). 
#perl -lane 'BEGIN {($mqm, $mqmr) =("", "");} if ( $F[7] =~ m/MQM=(\d+)/ ) { $mqm .= $1 . "\n";} if ( $F[7] =~ m/MQMR=(\d+)/ ) { $mqmr .= $1 . "\n";} END {print $mqm; print STDERR $mqmr;}' $inputFile > input.MQM.txt 2>input.MQMR.txt

## plots
#module load R
#Rscript plotDensity.R

### stats
#bcftools stats input.vcf.gz > input.vcf.stats.txt

## Keep sites with less than 30 samples with missing genotype:
## bcftools view -i 'N_MISSING <= 30' input.vcf.gz > input.Missing30.vcf.gz

## Keep sites having missing data rate <= 50%
## bcftools view -i 'F_MISSING <= 0.5' input.vcf.gz > input.MissingRate0.5.vcf.gz

## Other dynamically calculated features are:
# 	N_ALT: number of alternate alleles; 
#	N_SAMPLES: number of samples; 
# 	AC: count of alternate alleles; 
#	MAC: minor allele count (similar to AC but is always smaller than 0.5); 
#	AF: frequency of alternate alleles (AF=AC/AN); 
#	MAF: frequency of minor alleles (MAF=MAC/AN); 
#	AN: number of alleles in called genotypes; 
#	N_MISSING: number of samples with missing genotype; 
#	F_MISSING: fraction of samples with missing genotype

##### TEST 2: Stats of multiple files
baseDir=/input/genomic/plant/Malus/Resequencing/2017_JL_6cultivars/P101SC17050719_01/06.releasedata/results/4.SNP_VarDetect
f1=M9/M9.filted.SNP.vcf.gz
f2=T337/T337.filted.SNP.vcf.gz
f3=P2/P2.filted.SNP.vcf.gz


## good!
#bcftools stats /input/genomic/plant/Malus/Resequencing/2017_JL_6cultivars/P101SC17050719_01/06.releasedata/results/4.SNP_VarDetect/M9/M9.filted.SNP.vcf.gz > M9.filted.stats.txt

#plot-vcfstats -p M9/M9 M9.filted.stats.txt

## plot-vcfstats finished but with some warnings
#bcftools stats /input/genomic/plant/Malus/Resequencing/2017_JL_6cultivars/P101SC17050719_01/06.releasedata/results/4.SNP_VarDetect/M9/M9.filted.SNP.vcf.gz $baseDir/$f2 > M9_T337.filted.stats.txt

#plot-vcfstats -p M9_T337/M9_T337 -t M9.filted.SNP.vcf.gz -t T337.filted.SNP.vcf.gz -T M9_and_T337 M9_T337.filted.stats.txt



##### TEST 3: Keep sites with DP > 50, GQ (genotyping quality) > 20, MQ > 30, QUAL > 40; heterozygous (M9), homozygous (T337) 
##### Since Demo2 showed that DP peak is at 100, decide to filter with DP > 50
## ALL GOOD!
#bcftools view -i 'QUAL >40 && DP > 50 && GQ > 40 && MQ > 30' -g het $baseDir/$f1 > M9.filt2.het.vcf
#bcftools view -i 'QUAL >40 && DP > 50 && GQ > 40 && MQ > 30' -g hom $baseDir/$f2 > T337.filt2.hom.vcf



##### TEST 4: Intersect. Keep variant sites present in both M9.filt2.het.vcf and T337.filt2.hom.vcf
bgzip M9.filt2.het.vcf
bgzip T337.filt2.hom.vcf
tabix -p vcf M9.filt2.het.vcf.gz
tabix -p vcf T337.filt2.hom.vcf.gz
bcftools isec -n=2 -p M9_het.T337_hom M9.filt2.het.vcf.gz T337.filt2.hom.vcf.gz


