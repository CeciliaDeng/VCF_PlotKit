## Cecilia Deng, plot variation density along chrs
outputname=commandArgs(trailingOnly=TRUE)


# set working directory
binSize=20000


distplot = function(files, binSize, chrom="Chr05", colors, zoom, column=3, ymax=5) {
  d = list()
  nf = length(files)
  xm = 0 
  ym = ymax
  for(i in 1:nf) {
    dd = read.table(files[i], head=T)
    d[[i]] = dd[dd[,1] == chrom,,drop=FALSE]
    xm = max(xm, d[[i]][,2])
    ym = max(ym, d[[i]][,column])
  }
  xlim = c(0, xm + binSize)
  ylim = c(0, ym)
  breaks = seq(xlim[1], xlim[2], by=binSize)
  nb = length(breaks) - 1
  count= matrix(0, nrow=nb, ncol=nf)
  if(missing(zoom)) zoom = xlim / 1e6
  if(missing(colors)) colors=rainbow(nf)  # hcl(seq(0,320,len=nf))
  for(i in 1:nf) {
    count[d[[i]][,2]/binSize + 1, i] = d[[i]][,column]
    x=(breaks[-1]-binSize/2)/1e6
    if(i == 1) 
      plot(x, count[,i], type="l", xlim=zoom, ylim=ylim, 
           col=colors[1], xlab=paste0(chrom, " (MB)"), ylab=colnames(dd)[column])
    else lines(x, count[,i], col=colors[i])
  }
  
  ## write filename on top of density plot of each Chr
  #legend("topright", files, lwd=1, col=colors)
}

distplot.all = function(files, binSize, colors, zoom, column=3, ymax=5) {
  dd = read.table(files[1], head=T)
  chroms = sort(as.character(unique(dd[,1])))
  nchroms = length(chroms)
  #nc = ceiling(sqrt(nchroms))
  nc = 4
  nr = ceiling(nchroms / nc)
  par(mfrow=c(nr, nc))
  for(i in 1:nchroms) 
    distplot(files, binSize, chrom=chroms[i], colors, zoom, column, ymax)
}

## plot
pdfname=paste(outputname,".pdf",sep="")
files=c("04.T337_hom.M9_het.20KB.density.snpden")
pdf(pdfname)
distplot.all(files, binSize, colors = c("red", "black"))
dev.off()




