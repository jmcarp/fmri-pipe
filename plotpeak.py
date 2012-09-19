import surfer
from pylab import *

homedir = '/data00/jmcarp/data/open/ds008'
statdir = '%s/permstat' % (homedir)
figdir = '%s/figs' % (homedir)

mycm = matplotlib.colors.LinearSegmentedColormap('mycm', cm.datad['jet'], 256)
colgrid = matplotlib.colors.makeMappingArray(256, mycm)

def batchroiplot(rois):
  
  peak = readpeak()
  contrs = list(set([k.split('_')[0] for k in peak[0] if k]))
  
  pscale = {}
  
  for roi in rois:
    
    pscale[roi] = {}
    
    for contr in contrs:
      
      uniq = getuniqpeak(contr, roi, peak)
      ctmin = uniq[0]['ct']
      ctmax = uniq[-1]['ct']
      
      pscale[roi][contr] = [ctmin, ctmax]
      
      for hem in ['lh', 'rh']:
        
        outname = '%s/%s/l2/surf_peak_%s_%s' % (figdir, contr, roi, hem)
        makeplot(uniq, hem, ctmin, ctmax,
          outname=outname, views=['lat', 'med'],
          roi=roi, contour=True)
  
  return pscale

def batchplot():
  
  peak = readpeak()
  contrs = list(set([k.split('_')[0] for k in peak[0] if k]))
  
  pscale = {}
  
  for contr in contrs:
    
    print 'Working on contrast %s...' % (contr)
    # Hack: Switch left and right hemispheres
    uniq = { 
      'lh' : getuniqpeak(contr, 'rh', peak),
      'rh' : getuniqpeak(contr, 'lh', peak)
    }
    ctmin = min(uniq['lh'][0]['ct'], uniq['rh'][0]['ct'])
    ctmax = max(uniq['lh'][-1]['ct'], uniq['rh'][-1]['ct'])
    
    pscale[contr] = [ctmin, ctmax]
    
    for hem in ['lh', 'rh']:
      
      print 'Working on hemisphere %s...' % (hem)
      outname = '%s/%s/l2/surf_peak_%s' % (figdir, contr, hem)
      makeplot(uniq[hem], hem, ctmin, ctmax,
        outname=outname, views=['lat', 'med'])
  
  return pscale

def getuniqpeak(contr, hem, peaks):
  
  field = '%s_mm_%s' % (contr, hem)
  coord = [peak[field] for peak in peaks]
  for cidx in range(len(coord)):
    ctmp = [int(round(float(pos))) for pos in coord[cidx].split(':')]
    coord[cidx] = tuple(ctmp)
  
  ucoord = list(set(coord))
  udict = [0] * len(ucoord)
  
  for uidx in range(len(ucoord)):
    utmp = ucoord[uidx]
    cttmp = len([c for c in coord if c == utmp])
    udict[uidx] = {'coord' : list(utmp), 'ct' : cttmp}
  
  udict = sorted(udict, key=lambda x: x['ct'])
  
  return udict

def makeplot(udict, hem, ctmin, ctmax, outname=None, views=None, roi=None, contour=False, fmt='png'):
  
  brain = surfer.Brain('fsaverage', hem, 'inflated',
    config_opts={'background' : 'black'})
  
  vmin = log10(ctmin)
  vmax = log10(ctmax)
  vrng = vmax - vmin
  
  for uidx in range(len(udict) - 1, -1, -1):
    utmp = udict[uidx]['coord']
    cttmp = udict[uidx]['ct']
    scct = (log10(cttmp) - vmin) / vrng
    colidx = round(255 * scct)
    brain.add_foci(array(utmp), map_surface='white', \
      scale_factor = 0.375, color=tuple(colgrid[colidx][:-1]))
  
  if contour:
    brain.add_contour_overlay(
      '/data00/jmcarp/data/open/ds008/roimask/surf_dil%s_%s.nii' % (roi, hem), 
      min=0, max=0.05
    )

  if outname:
    brain.save_imageset(outname, views, fmt)
  
  return brain

def readpeak():
  
  peakfile = '%s/peak.txt' % (statdir)
  peaklines = open(peakfile, 'r').readlines()
  
  peaklines = [line.strip().split(',') for line in peaklines]
  peakvars = peaklines[0]
  peakdata = peaklines[1:]
  
  peaklist = []
  for peak in peakdata:
    peaklist.append(dict(zip(peakvars, peak)))
  
  return peaklist
