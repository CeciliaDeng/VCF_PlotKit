workDir=`pwd`
inputDir=/path/to/11.SVTyper_clean
inputFile=FCH3N2VBBXX_lumpy_SVTyper.sorted.vcf

module load R
module load bcftools

ln -s $inputDir/$inputFile input.vcf

### Get DP, QD, MQM, MQMR for plotting
perl create_sv_density_data.pl input.vcf

Rscript input.vcf.plot.R



