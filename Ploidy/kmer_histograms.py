#!/usr/bin/env python
# coding: utf-8

# In[1]:

# On krapbook with Tim's known haploid/diploid yeasts
import plotly.express as px
import plotly
import pandas as pd
import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--khist", metavar="khist_file", required=True, action="store")
parser.add_argument("--peaks", metavar="peaks_file", required=True, action="store")
args = parser.parse_args()

hist = args.khist
peaks = args.peaks

prefix = os.path.split(hist)[1].split(".")[0] 

hist = pd.read_csv(hist, sep = "\t")
peaks = pd.read_csv(peaks, sep="\t", skiprows=range(0,13))

fig = px.line(hist, x="#Depth", y="Count", title="Paraphysoderma sp. (diploid)")
fig.update_xaxes(range=[0,600], title = "Depth")
fig.update_yaxes(range=[0,peaks["max"].max()*1.25])

#fig.show()
plotly.io.orca.config.executable = '/usr/local/bin/orca'
fig.write_image(file=f"{prefix}_kmers.pdf", format="pdf")

