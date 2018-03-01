#!/usr/bin/perl -w
use strict;

## Generate DP, QD, MQM, etc. dataset from vcf file for plotting
# Developed by Cecilia Deng

my ($vcfFile) = @ARGV;

help() unless (-e $vcfFile);
generate_dataset($vcfFile);
exit();

sub help {
   print <<END;
Create DP, QD (quality by depth), mapping quality (MQM, MQMR, or MQ) datasets from a vcf file and generate density plots
Usage:
    perl $0 input.vcf
END
    exit;
}

sub generate_dataset {
   my $file = shift;
   my (%h, @a, $dp, $x, $qual) = ();
   open(IN, "<$file") or die "Can't open $file to read\n";
   while (my $line = <IN>) {
     next if ($line =~ m/^#/);
     @a = split /\t/, $line;
     if ($a[7] =~ m/DP=(\d+);/ ) { 
	$dp = $1; 
        $qual = ($a[5] =~ m/(\d+)/) ? $1 : 0;
	$x = int($qual/$dp); 
	$h{DP} .= $dp . "\n"; 
	$h{QD} .= $x . "\n"; 
        print STDERR "WARNING: Qual is $a[5]\n" unless ($a[5] =~ m/\d+/);
     }
     if ( $a[7] =~ m/MQM=(\d+)/ ) { 
	$h{MQM} .= $1 . "\n";
     } 
     if ( $a[7] =~ m/MQMR=(\d+)/ ) { 
	$h{MQMR} .= $1 . "\n";
     } 
     if ( $a[7] =~ m/MQ=(\d+)/) {
	$h{MQ} .= $1 . "\n";
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
	if ($k eq "DP") {
	    print RF "pdf(\"$outFile", '.zoomIn.pdf")', "\nplot(density(data, from=0, to=250), main=\"$k\")\ndev.off()\n\n";
	}
   } 
   close RF;
   print "To plot:\n\tRscript $Rfile\n";
}

## to run:
#module load R
#Rscript $Rfile

