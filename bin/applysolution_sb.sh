#! /bin/bash -l
#SBATCH --export=NONE
#SBATCH -p workq
#SBATCH --time=2:00:00
#SBATCH --ntasks=12
#SBATCH --mem=40GB
#SBATCH -J applySol
#SBATCH --mail-type FAIL,TIME_LIMIT,TIME_LIMIT_90
#SBATCH --mail-user sirmcmissile47@gmail.com

start=`date +%s`
module load singularity
shopt -s expand_aliases
source /astro/mwasci/sprabu/aliases

set -x

{

obsnum=OBSNUM
base=BASE
band1Path=
band2Path=
band3Path=
band4Path=

while getopts 'a:b:c:d:' OPTION
do
    case "$OPTION" in
        a)
            band1Path=${OPTARG}
            ;;
        b)
            band2Path=${OPTARG}
            ;;
        c)
            band3Path=${OPTARG}
            ;;
        d)
            band4Path=${OPTARG}
            ;;
    esac
done


datadir=${base}processing/${obsnum}


cd ${datadir}

applysolutions ${obsnum}_068-079.ms ${band1Path}

applysolutions ${obsnum}_107-108.ms ${band2Path}

applysolutions ${obsnum}_112-114.ms ${band3Path}

applysolutions ${obsnum}_147-153.ms ${band4Path}




end=`date +%s`
runtime=$((end-start))
echo "the job run time ${runtime}"


}

