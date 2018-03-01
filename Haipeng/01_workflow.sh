workDir=`pwd`
inputFile=/path/to/2018_Yinpei/indel/variants.filter.snp.vcf

module load R
module load bcftools

## Compress and index
#cp $inputFile input.vcf


### Get DP, QD, MQM, MQMR for plotting
perl create_density_data.pl input.vcf

Rscript input.vcf.plot.R


### Compress and index
module load tabix
bgzip input.vcf
tabix -p vcf input.vcf.gz


## overall summary
#bcftools stats input.vcf.gz > input.vcf.stats.txt


