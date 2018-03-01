baseDir=/input/genomic/plant/Malus/Resequencing/2017_JL_6cultivars/P101SC17050719_01/06.releasedata/results/4.SNP_VarDetect
f1=M9/M9.filted.SNP.vcf
f2=T337/T337.filted.SNP.vcf
f3=P2/P2.filted.SNP.vcf

## Compress and index
ln -s $baseDir/$f1 .
ln -s $baseDir/$f2 .
ln -s $baseDir/$f3 .

module load bcftools
module load tabix
module load R
module load texlive
module load miniconda2
source activate hrachd_sga


for sample in M9 T337 P2
do
   vcfFile=$sample'.filted.SNP.vcf'
   Rfile=$vcfFile'.plot.R'
   perl create_density_data.pl $vcfFile
   Rscript $Rfile
   bgzip $vcfFile
   tabix -p vcf $vcfFile
   gzFile=$vcfFile'.gz'
   statsFile=$vcfFile'.stats.txt'
   bcftools stats $gzFile > $statsFile
   plot-vcfstats -p $sample/$sample -T $sample $statsFile
done


