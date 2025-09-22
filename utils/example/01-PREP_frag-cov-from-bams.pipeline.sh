
#!/bin/bash
# exit when any command fails
set -e
#################################################################

## 
export TOPDIR=


## GET WORKFLOWS AND FUNCTIONS
export FXNSFILE=00-functions.txt
source ${FXNSFILE}
source ${VARSFILE}



## MANUAL VARS
export BAMDIR=${TOPDIR}/bamdir
export G=
export W=100
export S=100
export P=8


## Optionally change
export MAX_SIMULTANEOUS_JOBS=4  # Will only launch jobs such that this is the most running. Default: 2. (Used to be 8).
export SLEEP_WAIT_TIME=10       # Will check number of jobs running every X seconds. Default: 10.



## AUTOMATED VARS
export BINBED=w${W}s${S}.bed
export BINBDG=binCov_w${W}s${S}_BDG
export BINBW=binCov_w${W}s${S}_BW


echo "WD" $PWD


## Requirements in environment: bedtools, bedGraphToBigWig
## Check for required tools
for TOOL in bedtools bedGraphToBigWig; do
    if ! command -v $TOOL &> /dev/null; then
        echo "$TOOL could not be found. Please install it to proceed."
        exit 1
    fi
done

## Check that BAMDIR exists
if [ ! -d "$BAMDIR" ]; then
    echo "BAMDIR $BAMDIR does not exist. Please check the path."
    exit 1
fi

## GET FRAGMENT COV
genome_frag_cov gcovBDG ${BAMDIR}/*.bam || true
bdg2bw gcovBW gcovBDG/*.bedGraph || true


## BINNING
## Binning -- 500 bp bins was used with <10m 50 bp SE reads ; these are >10m 2x75 bp, and Im using frag cov... ; could easily use 50 or 100 bp...
makewindows ${W} ${S} > ${BINBED} || true
bigWigAverageOverBedLoop ${BINBED} ${BINBDG} gcovBW/*.bw || true
bdg2bw ${BINBW} ${BINBDG}/*.bedGraph || true



