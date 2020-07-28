#! /bin/sh
#
# Deploy website to actual hosting environment
#
# Any argument passed to the script will be added to the rsync command line.

REMOTE_USER=deb4664
REMOTE_HOST=halfje-bruin.nl
REMOTE_DIR=domains/${REMOTE_HOST}/public_html

SSH_KEYFILE=${HOME}/.ssh/halfje-bruin-ssh
LOCAL_DIR=./public/
LOG_DIR=./logs
EXCLUDES=.rsync-excludes

LOGFILE=${LOG_DIR}/deploy-"$(date '+%Y%m%d-%H%M%S')".log

mkdir -p ${LOG_DIR}
rm -rf ${LOCAL_DIR}

hugo && \
rsync "$@"  \
    --verbose \
    --archive \
    --checksum \
    --chmod=D775,F664 \
    --no-group \
    --no-times \
    --omit-dir-times \
    --delete-during \
    --exclude-from=${EXCLUDES} \
    --log-file=${LOGFILE} \
    --rsh="ssh -i '${SSH_KEYFILE}'" \
    ${LOCAL_DIR} \
    ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}
