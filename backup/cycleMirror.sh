#!/bin/bash

SRCDIR='/tmp/bktest/'
TGTUSER='root'
TGTHOSTIP=''
TGTBASEDIR='/tmp/bktest/'
TGTSUBDIR=''

GENNUM=$(cat ./cycleMirrorNum)

if [[ ! "${GENNUM}" =~ ^[0-9]+$ ]]; then
    logger -p local0.err "$0: Not get GENNUM. Check file [cycleMirrorNum]."
    exit 1
fi

GENOVERCHKFLG=1

while read line;do
    if [ "${GENNUM}" = "$(echo ${line}|awk -F',' '{print $1}')" ]; then
        TGTHOSTIP=$(echo ${line}|awk -F',' '{print $2}')
        TGTSUBDIR=$(echo ${line}|awk -F',' '{print $3}')
        GENOVERCHKFLG=0
        break
    fi
done < ./cycleMirror.list


if [ 1 -eq "${GENOVERCHKFLG}" ];then
    line=$(awk 'NR==1' ./cycleMirror.list)
    GENNUM=$(echo ${line}|awk -F',' '{print $1}')
    TGTHOSTIP=$(echo ${line}|awk -F',' '{print $2}')
    TGTSUBDIR=$(echo ${line}|awk -F',' '{print $3}')
fi


# -----rsync input check start-----
if [[ ! "${SRCDIR}" =~ ^[[:graph:]]+$ ]]; then
    logger -p local0.err "$0: SRCDIR is not accept blanc. Check file [cycleMirror.sh]."
    exit 1
fi

if [[ "${SRCDIR}" =~ ^/$ ]]; then
    logger -p local0.err "$0: SRCDIR is not accept /. Check file [cycleMirror.sh]."
    exit 1
fi

if [[ ! "${TGTUSER}" =~ ^[[:graph:]]+$ ]]; then
    logger -p local0.err "$0: TGTUSER is not accept blanc. Check file [cycleMirror.sh]."
    exit 1
fi

if [[ ! "${TGTHOSTIP}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    logger -p local0.err "$0: TGTHOSTIP error. Check file [cycleMirror.list]."
    exit 1
fi

if [[ ! "${TGTBASEDIR}" =~ ^[[:graph:]]+$ ]]; then
    logger -p local0.err "$0: TGTBASEDIR is not accept blanc. Check file [cycleMirror.sh]."
    exit 1
fi

if [[ "${TGTBASEDIR}" =~ ^/$ ]]; then
    logger -p local0.err "$0: TGTBASEDIR is not accept /. Check file [cycleMirror.sh]."
    exit 1
fi

if [[ "${TGTSUBDIR}" =~ ^/$ ]]; then
    logger -p local0.err "$0: TGTSUBDIR is not accept /. Check file [cycleMirror.sh]."
    exit 1
fi

if [[ ! "${TGTSUBDIR}" =~ ^[[:graph:]]+$ ]]; then
    logger -p local0.err "$0: TGTSUBDIR is not accept blanc. Check file [cycleMirror.list]."
    exit 1
fi
# -----rsync input check end-----

rsync -az --delete ${SRCDIR} ${TGTUSER}@${TGTHOSTIP}:${TGTBASEDIR}${TGTSUBDIR}
CODE=$?
if [ 0 -ne "${CODE}" ]; then
    logger -p local0.err "$0: rsync error. return code [${CODE}]"
    exit 1
fi

echo -n $((${GENNUM}+1)) > ./cycleMirrorNum
CODE=$?
if [ 0 -ne "${CODE}" ]; then
    logger -p local0.err "$0: echo file:cycleMirrorNum. return code [${CODE}]"
    exit 1
fi

exit 0

