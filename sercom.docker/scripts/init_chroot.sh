#!/bin/bash

echo "Checking whether $CHROOT_TEMPLATE_FOLDER is initialized or not..."
if [ "$(ls -A $CHROOT_TEMPLATE_FOLDER)" ]; then
        echo "An existing Sercom chroot was found at $CHROOT_TEMPLATE_FOLDER. Reusing chroot."
        echo "Mounting system FDs (/proc and /sys are required for command execution)"  
        mount -a
else
        echo "Creating chroot..."
        debootstrap --variant=buildd --arch i386 xenial "$CHROOT_TEMPLATE_FOLDER" http://mirrors.us.kernel.org/ubuntu/

        mkdir -p ${CHROOT_TEMPLATE_FOLDER}/home/sercom_backend/build 
        mkdir -p ${CHROOT_TEMPLATE_FOLDER}/home/sercom_backend/test 
        chown sercom_backend ${CHROOT_TEMPLATE_FOLDER}/home/sercom_backend/build  ${CHROOT_TEMPLATE_FOLDER}/home/sercom_backend/test 
        chgrp sercom_backend ${CHROOT_TEMPLATE_FOLDER}/home/sercom_backend/build  ${CHROOT_TEMPLATE_FOLDER}/home/sercom_backend/test 
        chmod ugo+wrx ${CHROOT_TEMPLATE_FOLDER}/home/sercom_backend/build  ${CHROOT_TEMPLATE_FOLDER}/home/sercom_backend/test 
        SERCOM_BACKEND_UID=$(id -u sercom_backend)
        mount -a

        echo "Adding $SERCOM_BACKEND_UID user and valgrind to chroot..."
        chroot "$CHROOT_TEMPLATE_FOLDER" useradd sercom_backend --uid $SERCOM_BACKEND_UID 
        chroot "$CHROOT_TEMPLATE_FOLDER" apt install -yq build-essential gcc g++ netbase net-tools tar valgrind python

        mkdir $CHROOT_TEMP_FOLDER/proc
        mkdir $CHROOT_TEMP_FOLDER/sys
        rsync --stats --itemize-changes --human-readable --archive --acls --delete-during --force --exclude /proc --exclude /sys "$CHROOT_TEMPLATE_FOLDER/" "$CHROOT_TEMP_FOLDER/"
        mount -a
fi


