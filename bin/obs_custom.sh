#!/bin/bash

usage()
{
echo "custom.sh [-o obsnum] [-m cluster] [-a account] [-d dependancy] [-n norad]
        -m cluster              : the hpc cluster to process data in, default=garrawarla
        -a account              : the project id, default=mwasci
        -n norad                : the norad id
        -d dependancy           : dependant job id
        -o obsnum               : the obsid" 1>&2;
exit 1;
}

obsnum=
cluster="garrawarla"
project="mwasci"
dep=
norad=

while getopts 'o:m:a:d:n:' OPTION
do
    case "$OPTION" in
        n)
            norad=${OPTARG}
            ;;
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
        ? | : | h)
            usage
            ;;
    esac
done

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
script="${base}queue/custom_${obsnum}.sh"
cat ${base}bin/custom.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                -e "s:NORAD:${norad}:g" \
                                -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/custom_${obsnum}.o%A"
error="${base}queue/logs/custom_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} ${depend} -J Shift-stack-${norad} -M ${cluster} -A ${project} ${script}"
jobid=($(${sub}))
jobid=${jobid[3]}

# rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid}/"`
output=`echo ${output} | sed "s/%A/${jobid}/"`

echo "Submitted custom job as ${jobid}"








