workDir=`pwd`

inputFile=/output/genomic/plant/Actinidia/GBS_PS1_1.68.5/2016_SatishK_Slipstream/2016_CAGRF13148/Satish_CAGRF13148.Ploidy4.PS1.SNPs.0111.CallRate0.5_Cnt10.vcf

## Compress and index
cp $inputFile input.vcf


### Get DP, QD, MQM, MQMR for plotting
perl create_density_data.pl input.vcf

Rscript input.vcf.plot.R


### Compress and index
module load tabix
bgzip input.vcf
tabix -p vcf input.vcf.gz


## overall summary
bcftools stats input.vcf.gz > input.vcf.stats.txt


