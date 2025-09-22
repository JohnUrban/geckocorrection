#!/bin/bash


## ASSUMES YOU HAVE A DIRECTORY FULL OF BEDGRAPHS WITH FRAG COV IN BINS

##########################
### INPUTS
##########################
GECKO=$( which geckocorrection.py )	## 
FRAG_COV_BDG_DIR=			## Example: binCov_w100s100_BDG
YEASTGENOMEFA=				##




##########################
### FXN
##########################
function makeGcTab {
  GC=${1}
  SIG=${2}
  paste <( sort -k1,1 -k2,2n -k3,3n ${GC} ) <( sort -k1,1 -k2,2n -k3,3n ${SIG} ) | awk '$1==$5 && $2==$6 && $3==$7 {OFS="\t" ; print $1,$2,$3,$4,$8}'
}


##########################
### RUN
##########################
# get -gc
nucBed -fi ${YEASTGENOMEFA} -bed w100s100.bed | awk '!/^#/ {OFS="\t" ; print $1,$2,$3,$6}' > w100s100.gc.bed 
sortBed -g ${YEASTGENOMEFA}.genome -i w100s100.gc.bed > w100s100.gc.sorted.bed 

# 
OUTDIR=geckoCorr
mkdir -p ${OUTDIR}/bdg/control
mkdir -p ${OUTDIR}/bdg/medfe
mkdir -p ${OUTDIR}/bdg/madunits
mkdir -p ${OUTDIR}/dict
mkdir -p ${OUTDIR}/summary

## This will go through bedGraphs, make GC tables, and run GECKO on them.
for BDG in ${FRAG_COV_BDG_DIR}/*bedGraph ; do
  BASE=$( basename ${BDG} .bedGraph )
  OUTPRE=${OUTDIR}/${BASE}
  CONTROLPRE=${OUTDIR}/bdg/control/${BASE}
  MEDFEPRE=${OUTDIR}/bdg/medfe/${BASE}
  MADPRE=${OUTDIR}/bdg/madunits/${BASE}
  DICTPRE=${OUTDIR}/dict/${BASE}
  SUMMARYPRE=${OUTDIR}/summary/${BASE}
  makeGcTab w100s100.gc.sorted.bed ${BDG} > ${OUTPRE}.gc.tab
  ${GECKO} --table ${OUTPRE}.gc.tab --gccol 4 --sigcol 5 --scale 100 --header --control ${CONTROLPRE}.control --medfe ${MEDFEPRE}.medfe --madunits ${MADPRE}.madunits --dist ${DICTPRE}.dict > ${SUMMARYPRE}.gc.gecko.txt
  rm ${OUTPRE}.gc.tab
done

