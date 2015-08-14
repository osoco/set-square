#!/bin/bash

function extract_volumes() {
    local _dockerfile="${1}"
    local _result=();
    local _aux;
    local _single;
    local _oldIFS="${IFS}";
    IFS=$'\n';
    for _aux in $(grep VOLUME "${_dockerfile}" | cut -d' ' -f 2- | sed -e 's/^ \+//g'); do
        IFS="${_oldIFS}";
        process_volume "${_aux}";
        for v in ${RESULT}; do
            _result[${#_result[@]}]="${v}";
        done
    done
    export RESULT=${_result[@]}
}                

function process_volume() {
    local _volume="${1}";
    local _result;
    local _single=0;
    if [ "${_volume#[}" == "${_volume}" ]; then
        _single=0; # true, single
    else
        _single=1; # false, multiple
    fi
    if [ ${_single} -eq 0 ]; then
        _result="${_aux}"
    else
        local _oldIFS="${IFS}";
        IFS='"';
        for item in $(echo ${_aux} | tr -d '[],'); do
            IFS="${_oldIFS}";
            _result="${_result} $(echo ${item} | sed -e 's/^"//g' | sed -e 's/"$//g')"
        done
        _result="$(echo "${_result}" | sed -e 's/^ //g')";
    fi
    export RESULT="${_result}";
}

DOCKERFILES_LOCATION=/Dockerfiles
RSNAPSHOT_CONF=/etc/rsnapshot.conf

sed -i -e 's/^backup/#backup/g' ${RSNAPSHOT_CONF}
for p in ${DOCKERFILES_LOCATION}/*; do
    extract_volumes "${p}";
    for v in ${RESULT}; do
        echo "Annotating ${v} for backup (defined as volume in ${p})"
        echo "backup ${v}/"$'\t'"localhost/" >> ${RSNAPSHOT_CONF}
    done
done
    
