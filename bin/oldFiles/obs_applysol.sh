#!/bin/bash

usage()
{
echo "applysol.sh [-o obsnum] [-m cluster] [-a account] [-d dependancy] [-q band 1] 
        -m cluster              : the hpc cluster to process data in, default=zeus
        -a account              : the project id, default=mwasci
        -d dependancy		: dependant job id
	-q band 1		: path to band 1 solution
        -o obsnum               : the obsid" 1>&2;
exit 1;
}

obsnum=
cluster="zeus"
project="mwasci"
dep=
band1=


while getopts 'o:m:a:d:q:' OPTION
do
    case "$OPTION" in
        d)
            dep=${OPTARG}
            ;;
        o)
            obsnum=${OPTARG}
            ;;
        m)
            cluster=${OPTARG}
            ;;
        a)
            project=${OPTARG}
            ;;
	q)
	    band1=${OPTARG}
	    ;;
        ? | : | h)
            usage
            ;;
    esac
done


# set the obsid to be the first non option
shift  "$(($OPTIND -1))"


# if obsid is empty then just pring help
if [[ -z ${obsnum} ]]
then
    usage
fi

if [[ ! -z ${dep} ]]
then
    depend="--dependency=afterok:${dep}"
fi

base=/astro/mwasci/sprabu/satellites/Space-Fest/

script="${base}queue/applysolution_${obsnum}.sh"
cat ${base}bin/applysolution.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/applysolution_${obsnum}.o%A"
error="${base}queue/logs/applysolution_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} ${depend} -M ${cluster} -A ${project} ${script} -a ${band1}"
jobid=($(${sub}))
jobid=${jobid[3]}

# rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid}/"`
output=`echo ${output} | sed "s/%A/${jobid}/"`

echo "Submitted applysolutions job as ${jobid}"


