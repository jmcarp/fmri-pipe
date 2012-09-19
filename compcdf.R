

library(ggplot2)

rootpath = '/data00/jmcarp/data/fbirn/site0009'
figpath = sprintf('%s/fig', rootpath)

plottwoway = function(roi, params, fparam) {

  fname = sprintf('%s/permstat/roicon.txt', rootpath)
  data = read.table(fname, header=TRUE)

  data$rpreg = factor(data$rpreg,
    levels=c('none', 'rp6', 'rp12', 'rp24')
  )
  data$smooth = factor(data$smooth,
    levels=c('fwhm4', 'fwhm8', 'fwhm12')
  )
  data$gscale = factor(data$gscale,
    levels=c('none', 'scaling')
  )
  data$hpf = factor(data$hpf,
    levels=c('none', 'hpf128')
  )
  
  roistat = sprintf('%s_stat', roi)
  sform = sprintf('%s ~ %s', params[1], params[2])
  ggp = ggplot(data, aes_string(x=roistat, fill=fparam))
  ggp + geom_histogram() + facet_grid(sprintf(sform))
  ggsave(sprintf('%s/nway/perm_hist_%s_%s_%s_%s.pdf', figpath, roi, params[1], params[2], fparam))

}

checktwoway = function(dv, cols, nbins, data) {
  
  ncol = length(cols)
  npair = ncol * (ncol - 1) / 2
  pdata = dataFrame(colClasses=c(), npair)
  pdata$col1 = rep('null', npair)
  pdata$col2 = rep('null', npair)
  pdata$pval = rep(0.0, npair)
  rowct = 1
  for (colidx1 in 1 : (ncol - 1)) {
    for (colidx2 in (colidx1 + 1) : ncol) {
      colpair = c(cols[colidx1], cols[colidx2])
      ptmp = getbins(dv, colpair, nbins, data)
      pdata$col1[rowct] = cols[colidx1]
      pdata$col2[rowct] = cols[colidx2]
      pdata$pval[rowct] = ptmp
      rowct = rowct + 1
    }
  }

  return(pdata)
  
}

getbins = function(dv, cols, nbins, data) {
  
  levlist = c()
  for (col in cols) {
    levlist = c(levlist, list(levels(data[,col])))
  }
  
  levmat = expand.grid(levlist)
  names(levmat) = cols
  ncell = dim(levmat)[1]
  
  bins = hist(data[,dv], nbins)
  enbins = length(bins$counts)

  bindata = data.frame(ct=1:(ncell*enbins))
  startidx = 1
  for (cellidx in 1 : ncell) {
    subdata = data
    for (col in cols) {
      subdata = subset(subdata, subdata[,col] == levmat[cellidx, col])
    }
    stopidx = startidx + enbins - 1
    bintmp = hist(subdata[,dv], bins$breaks)
    for (col in cols) {
      bindata[startidx:stopidx, col] = levmat[cellidx, col]
    }
    bindata[startidx:stopidx, 'ct'] = cumsum(bintmp$counts)
    bindata[startidx:stopidx, 'bin'] = 1 : enbins
    startidx = startidx + enbins
  }

  bindata$bin = factor(bindata$bin)

  form = as.formula(paste('ct ~ ', paste(cols, collapse=' * '), ' * bin'))
  model = glm(form, family=poisson, data=bindata)
  model = anova(model, test='Chisq')

  mdim = dim(model)
  print(model)
  print(model[mdim[1], mdim[2]])
  return(model[mdim[1], mdim[2]])
  
}
