#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from nipype.interfaces import fsl
from nipype.interfaces.fsl import MotionOutliers
import os.path
import subprocess
import os
from glob import glob
import sys
import pandas as pd
from nipype.interfaces.fsl import ImageStats

subjID = sys.argv[1]
ica_directory=f'../subjects/{subjID}/rest/rs_network.gica/groupmelodic.ica/'

# # get correls to template
correlfile=f'{ica_directory}/template_rsn_correlations_with_ICs.txt' 
split_outfile=f'{ica_directory}/melodic_IC_'
dmn_component=f'{ica_directory}/dmn_mni_uthresh.nii.gz'
cen_component=f'{ica_directory}/cen_mni_uthresh.nii.gz' 

 # get DMN, CEN
fslcc_info = pd.read_csv(correlfile, sep=' ', skipinitialspace=True, header=None)
list(fslcc_info)
fslcc_info.sort_values(by=[1, 2], ascending=False, inplace=True)
dmn_info = fslcc_info.loc[fslcc_info[1] == 1, :].values
cen_info = fslcc_info.loc[fslcc_info[1] == 2, :].values

roi1 = int(dmn_info[0, 0]-1)
roi2  = int(cen_info[0, 0]-1)

dmnfuncfile=split_outfile+'%0.4d.nii.gz' % roi1
cenfuncfile=split_outfile+'%0.4d.nii.gz' % roi2

os.system('cp %s %s' %(dmnfuncfile,dmn_component))
os.system('cp %s %s' %(cenfuncfile,cen_component))




