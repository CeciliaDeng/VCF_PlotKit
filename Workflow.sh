## Example pipeline

## Required input files
Genome=
Sample1VCF=
Sample2VCF=


## Build reference genome index if it's not done
samtools $Genome

java -Xmx4g -jar picard.jar CreateSequenceDictionary R=$Genome O=$Genome'.dict'


## Filter vcf

* Filter with mininum genotype depth (DP) 10 and mininum genotype quality (GQ) of 20
vcftools --vcf Sample1.vcf --out Sample1.Flt -minGQ 20 --minDP 10 --recode --recode-INFO-all

Alternatively: 
bcftools view -i 'MIN(FMT/DP) > 10 & MIN(FMT/GQ) > 20' Sample1.vcf.gz

* For VCF file with multiple samples, discard genotypes called below 50% across all individuals, and have a minor allele count 3 (ie, it has to be called in at least 1 homozygote, 1 heterozygote or 3 heterozygots)

vcftools --gzvcf raw.vcf.gz --max-missing 0.5 --mac 3 --minQ 20 --recode --recode-INFO-all --out flt.Scov0.5Mac3Q20

* Retrieve homozygous SNPs in sample1
java -Xmx4g -jar /software/bioinformatics/gatk-3.8.0/GenomeAnalysisTK.jar -T SelectVariants -R $Genome --variant $Sample1VCF -select 'vc.getGenotype("Sample1").isHomVar()' -o Sample1.homAlt.vcf

* Retrieve heteozygous SNPs in sample2
java -Xmx4g -jar /software/bioinformatics/gatk-3.8.0/GenomeAnalysisTK.jar -T SelectVariants -R $Genome --variant $Sample2VCF -select 'vc.getGenotype("Sample2").isHet()' -o Sample2.het.vcf

* Keep variant sites present in both Sample1 and Sample2
In this case, find variants that are homozygous in Sample1 but heterozygous in Sample2:

vcf-isec -n +2 Sample1.homAlt.vcf Sample2.het.vcf > Sample1_Homo.Sample2_Het.SNPs.vcf 

* Compress and index vcf files
bgzip file.vcf; tabix -p vcf file.vcf.gz


## Create density bin
BinSize=20000
binPrefix=20KB

vcftools --vcf Sample1_Homo.Sample2_Het.SNPs.vcf --SNPdensity $BinSize --out Sample1_Homo.Sample2_Het.SNPs_20KB_Bins


## Plot
Input: Sample1_Homo.Sample2_Het.SNPs_20KB_Bins.snpden
Output: 

