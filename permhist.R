library(ggplot2)

rootpath = '/data00/jmcarp/data/open/ds008'

figpath = sprintf('%s/figs.hist', rootpath)
if (!file.exists(figpath)) {
  dir.create(figpath)
}

lev = 'l2'

contrs = c(
  'go', 'sstop', 'fstop', 
  'stopvsgo', 'sstopvsgo', 'fstopvsgo', 'sstopvsfstop'
)
rois = c('rifc', 'psma', 'rstn')
params = c('despike', 'slice', 'realign', 'norm', 'smooth', 
           'hpf', 'cvi', 'catruns', 'basis', 'rpreg')

hist2 = function(contrs, rois, params, fparam) {

  data = readcon()
  
  for (contr in contrs) {
    sdata = data[data$contr==contr,]
    condir = sprintf('%s/%s', figpath, contr)
    levdir = sprintf('%s/%s', condir, lev)
    if (!file.exists(condir)) {
      dir.create(condir)
    }
    if (!file.exists(levdir)) {
      dir.create(levdir)
    }
    for (roi in rois) {
      roiz1t = sprintf('%s_z1t', roi)
      sform = sprintf('%s ~ %s', params[1], params[2])
      savdir = sprintf('%s/%s/nway', 
        levdir, roi)
      if (!file.exists(savdir)) {
        dir.create(sprintf('%s/%s', levdir, roi))
        dir.create(savdir)
      }
      ggp = ggplot(sdata, aes_string(x=roiz1t, fill=fparam))
      print(ggp + geom_histogram() + facet_grid(sprintf(sform)))
      #ggsave(sprintf('%s/perm_%s_%s_%s.pdf', savdir, params[1], params[2], fparam))
    }
  }

}

hist1 = function(contrs, rois, params, dosave) {
  
  data = readcon()

  for (contr in contrs) {
    sdata = data[data$contr==contr,]
    condir = sprintf('%s/%s', figpath, contr)
    levdir = sprintf('%s/%s', condir, lev)
    if (!file.exists(condir)) {
      dir.create(condir)
      dir.create(levdir)
    }
    for (roi in rois) {
      roiz1t = sprintf('%s_z1t', roi)
      savdir = sprintf('%s/%s', 
        levdir, roi)
      if (!file.exists(savdir)) {
        dir.create(savdir)
      }
      for (param in params) {
        ggp = ggplot(sdata, aes_string(x=roiz1t, fill=param))
        print(ggp + geom_histogram() + facet_grid(sprintf('%s~.', param)))
        if (dosave) {
          ggsave(sprintf('%s/perm_%s.pdf', savdir, param))
        }
      }
    }
  }
  
}

readcon = function() {

  fname = sprintf('%s/permstat/roicon.txt', rootpath)
  data = read.table(fname, header=TRUE)
  
  data$despike = factor(data$despike,
    levels=c('none', 'despike')
  )
  data$slice = factor(data$slice,
    levels=c('none', 'slice')
  )
  data$realign = factor(data$realign,
    levels=c('realign', 'unwarp')
  )
  data$norm = factor(data$norm,
    levels=c('func', 'anat', 'seg')
  )
  data$smooth = factor(data$smooth,
    levels=c('fwhm4', 'fwhm8', 'fwhm12')
  )

  data$hpf = factor(data$hpf, 
    levels=c('none', 'hpf128')
  )
  data$cvi = factor(data$cvi,
    levels=c('none', 'ar1')
  )
  data$catruns = factor(data$catruns,
    levels=c('none', 'catruns')
  )
  data$basis = factor(data$basis,
    levels=c('hrf', 'inf', 'fir')
  )
  data$rpreg = factor(data$rpreg, 
    levels=c('none', 'rp6', 'rp12', 'rp24')
  )
  
  return(data)

}
