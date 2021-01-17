#!/bin/bash

echo =================================================
echo backup started:
echo `date`
echo =================================================

echo create backup directories
mkdir -p /media/mailcow/backup

echo collect backup data
export MAILCOW_BACKUP_LOCATION=/media/mailcow/backup
/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup all --delete-days 1

echo start transfer to remote
docker run --name restic --rm -i \
    -v $MAILCOW_BACKUP_LOCATION:/mailcow \
    -v {{ rclone_config_dir }}:/root/.config/rclone \
    -v {{ secrets_dir }}/restic-passwd:/pass \
    -e RESTIC_REPOSITORY=rclone:{{ nextcloud_rclone_backup_dir }} \
    --hostname {{ mailcow_subdomain }}.{{ domain_name }} \
    {{ restic_rclone_image_name }}:{{ restic_rclone_image_version }} \
    -p /pass backup /mailcow

echo delete local backup data


echo =================================================
echo backup ended:
echo `date`
echo =================================================