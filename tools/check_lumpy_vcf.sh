# To run it:
## sh ~/mytools/check_lumpy_vcf.sh lumpy_output.vcf
##
## Summarize SVs (DEL, DUP, INV, BND) in vcf file generated using lumpy
inFile=$1
echo $inFile
echo "==================="

## This works with Cecilia's VCF that have more details
## For example, 
## scaffold10004|size15228 10575   21091_1 N       ]scaffold10504|size14095:1467]N 974.90  .       SVTYPE=BND;STRANDS=-+:11;CIPOS=-3,2;CIEND=-3,2;CIPOS95=0,0;CIEND95=0,0;MATEID=21091_2;EVENT=21091;SU=11;PE=0;SR=11     GT:SU:PE:SR:GQ:SQ:GL:DP:RO:AO:QR:QA:RS:AS:ASC:RP:AP:AB1/1:11:0:11:84:974.90:-99,-10,-2:34:0:34:0:33:0:10:0:0:23:1
## 
#perl -lane 'BEGIN {%h=(); %ok=();} if (m/SVTYPE=(\S+?);/) {$type = $1; if ($type eq "BND") { $chr = $F[0]; if (m/EVENT=(\d+)/) {$event = $1; push @{$h{$event}}, $chr; }   } else {$ok{$type}++; } } END { foreach $k (sort keys %ok) { print "$k: $ok{$k}"; } ($trans, $inter) = (0, 0); foreach $k (keys %h) { if ($h{$k}->[0] ne $h{$k}->[1]) {$trans++;   } else {$inter++;  }  } print "BND/TRANSLOCATION: $trans\nBND/INTERCHROMOSOMAL (insertion or ONE SIDED INVERSION): $inter";  } ' $inFile

## This works for Andrew C's simplified output (like below) AND Cecilia's vcf with more details (like above)
## For example,
## LG1     989315  86_1    N       N]LG1:1060679]  0       .       .       GT:SU:PE:SR:GQ:SQ:GL:DP:RO:AO:QR:QA:RS:AS:ASC:RP:AP:AB  0/0:0:0:0:99:0.00:-0,-19,-63:64:64:0:63:0:31:0:0:32:0:0
## LG1     1060679 86_2    N       N]LG1:989315]   0       .       .       GT:SU:PE:SR:GQ:SQ:GL:DP:RO:AO:QR:QA:RS:AS:ASC:RP:AP:AB  0/0:0:0:0:99:0.00:-0,-19,-63:64:64:0:63:0:31:0:0:32:0:0
##
perl -lane 'BEGIN {%h=(); %ok=();} unless (m/^#/) { if ($F[2] =~ m/(\S+?)\_/) { push @{$h{$1}}, $F[0]; } else {$ok{$F[4]}++;} } END { foreach $k (sort keys %ok) { print "$k: $ok{$k}"; } ($trans, $inter) = (0, 0); foreach $k (keys %h) { if ($h{$k}->[0] ne $h{$k}->[1]) {$trans++;   } else {$inter++;  }  } print "BND/TRANSLOCATION: $trans\nBND/INTERCHROMOSOMAL (insertion or ONE SIDED INVERSION): $inter";  }' $inFile


echo
