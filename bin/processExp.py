#!/usr/bin/env python
import os
import sys
import collections
import pandas as pd
from functools import reduce

fList = os.listdir(".")
fList = [i for i in fList if i.endswith('.exp')]
smpList = [i.rstrip('.exp') for i in fList]
dList = [pd.read_csv(i, sep = "\t") for i in fList]

covList = [i.drop(['FPKM','TPM'], axis = 1) for i in dList]
fpkmList = [i.drop(['Coverage','TPM'], axis = 1) for i in dList]
tpmList = [i.drop(['FPKM','Coverage'], axis = 1) for i in dList]

for s,d in zip(smpList, covList): d.rename(columns = {'Coverage':s}, inplace = True)
for s,d in zip(smpList, fpkmList): d.rename(columns = {'FPKM':s}, inplace = True)
for s,d in zip(smpList, tpmList): d.rename(columns = {'TPM':s}, inplace = True)

annoCols = dList[0].columns.tolist()[0:6]
covDf = reduce(lambda left, right: pd.merge(left, right, how="outer", on=annoCols), covList)
fpkmDf = reduce(lambda left, right: pd.merge(left, right, how="outer", on=annoCols), fpkmList)
tpmDf = reduce(lambda left, right: pd.merge(left, right, how="outer", on=annoCols), tpmList)

covDf["Gene ID"] = list(map(lambda x: x.split(".")[0], covDf["Gene ID"].values.tolist()))
fpkmDf["Gene ID"] = list(map(lambda x: x.split(".")[0], fpkmDf["Gene ID"].values.tolist()))
tpmDf["Gene ID"] = list(map(lambda x: x.split(".")[0], tpmDf["Gene ID"].values.tolist()))

covDf.drop_duplicates("Gene ID", keep = 'first', inplace = True)
fpkmDf.drop_duplicates("Gene ID", keep = 'first', inplace = True)
tpmDf.drop_duplicates("Gene ID", keep = 'first', inplace = True)

covDf.to_csv("Gene.Coverage.withAnnot.tsv", sep = "\t", index = 0)
tpmDf.to_csv("Gene.TPM.withAnno.tsv", sep = "\t", index = 0)
fpkmDf.to_csv("Gene.FPKM.withAnno.tsv", sep = "\t", index = 0)

annoCols = annoCols[1:]
covDf.drop(annoCols, axis = 1, inplace = True)
tpmDf.drop(annoCols, axis = 1, inplace = True)
fpkmDf.drop(annoCols, axis = 1, inplace = True)

covDf.to_csv("Gene.Coverage.tsv", sep = "\t", index = 0)
tpmDf.to_csv("Gene.TPM.tsv", sep = "\t", index = 0)
fpkmDf.to_csv("Gene.FPKM.tsv", sep = "\t", index = 0)



