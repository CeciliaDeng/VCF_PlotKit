workDir=`pwd`
inputDir=/powerplant/workspace/cflasc/Snapper/Structural_variants/11.SVTyper_charles_combined_cleaned
inputFile=FCH3N2VBBXX-wHAXPI027494-23_IR_lumpy_SVTyper.sorted.vcf

module load R
module load bcftools

ln -s $inputDir/$inputFile input.vcf

### Get DP, QD, MQM, MQMR for plotting
perl create_sv_density_data.pl input.vcf

Rscript input.vcf.plot.R



