# system imports
import sys
import os
import warnings
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('Qt5Agg')
plt.ion()

# LSK defaults


# LSST stack imports
try:
    import lsst.daf.persistence as dafPersist
    import lsst.afw.display as afwDisplay
    from lsst.ip.isr import IsrTask
    import lsst.afw.detection as afwDetection
except ImportError:
    warnings.warn('failed to import LSST modules')
