# system imports
import os
import sys
import warnings
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import astropy.stats as stats
from collections import Counter as count
import pandas as pd
import pickle

# plotting specific
matplotlib.use('Qt5Agg')
plt.ion()

# LSST stack imports
try:
    import lsst.daf.persistence as dafPersist
    import lsst.afw.display as afwDisplay
    from lsst.ip.isr import IsrTask
    import lsst.afw.detection as afwDetection
except ImportError:
    warnings.warn('failed to import LSST modules')
