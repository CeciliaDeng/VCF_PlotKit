#!/usr/bin/perl -w
use strict;

## Generate QUAL, SU (supporting evidence), DP, SR (split reads), GQ (genotyping quality) etc. dataset from vcf file for plotting
# Developed by Cecilia Deng

my ($vcfFile) = @ARGV;
my @fields = ('SU', 'DP', 'SR', 'GQ'); # generate plots for these fields
help() unless ($vcfFile);
print "$vcfFile is not found\n" and exit unless (-e $vcfFile);
generate_dataset($vcfFile);
exit();

sub help {
   print <<END;
Create QUAL, SU (supporting evidence), DP, SR (split reads), GQ (genotyping quality) etc. datasets from a SV vcf file and generate density plots
Usage:
    perl $0 input.vcf
END
    exit();
}

### Lumpy/svTyper: atributes and their order in FORMAT column may be different for SV features
sub generate_dataset {
   my $file = shift;
   my (%h, @a, @b, $qual, $tmp, @fmt) = ();
   open(IN, "<$file") or die "Can't open $file to read\n";
   while (my $line = <IN>) {
     next if ($line =~ m/^#/);
     @a = split /\t/, $line;
     $qual = ($a[5] =~ m/(\d+)/) ? $1 : 0;
     $h{QUAL} .= $qual . "\n";
     @fmt = split /:/, $a[8];
     my %fld = ();
     for my $i ( 0 .. $#fmt) {
 	 $fld{$fmt[$i]} = $i; # SU=>1, DP=>2,  ...
     }
     @b = split /:/, $a[9];
     
     foreach my $k (@fields) {
        next unless ($fld{$k});  # field not found in FORMAT
	$tmp = $b[$fld{$k}] || '';
        $tmp = -99 unless ($tmp =~ m/^\d+$/); # not a numeric value (eg ".")
	$h{$k} .= $tmp . "\n";
     }
   }
   close IN;

   return unless (%h);

   my $Rfile = $file . '.plot.R';
   open(RF, ">$Rfile") or die "Can't open $Rfile to write\n";
   foreach my $k (sort keys %h) {
	my $outFile=$file . '.' . $k . ".txt"; 
	open(OUT, ">$outFile"); 
	print OUT $h{$k}; 
	close OUT; 
	print "$k Saved in $outFile ...\n"; 
	print RF "data=scan(\"$outFile\")\npdf(\"$outFile", '.pdf")', "\nplot(density(data), main=\"$k\")\ndev.off()\n\n"; 
	if ($k eq "DP" || $k eq "QUAL" || $k eq "SU") {
	    print RF "pdf(\"$outFile", '.zoomIn.pdf")', "\nplot(density(data, from=0, to=250), main=\"$k\")\ndev.off()\n\n";
	}
   } 
   close RF;
   print "To plot:\n\tRscript $Rfile\n";
}

## to run:
#module load R
#Rscript $Rfile

