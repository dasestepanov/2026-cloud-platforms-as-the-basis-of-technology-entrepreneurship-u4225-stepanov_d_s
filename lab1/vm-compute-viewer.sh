#!/usr/bin/env bash
set -uo pipefail
exec > >(tee /var/log/lab1-compute-viewer.log /dev/ttyS0) 2>&1
printf '\nLAB1_COMPUTE_VIEWER_BEGIN\n'
printf 'VM: '; hostname
printf 'Service account: '
curl -fsS -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email
printf '\n'
gcloud auth list --filter=status:ACTIVE --format='value(account)'
mapfile -t lab_files < /var/tmp/lab1/files.txt
if [ "${#lab_files[@]}" -ne 3 ]; then
  printf 'Missing original object list\n'
  exit 1
fi
mkdir -p /var/tmp/lab1/compute-viewer
gcloud storage cp "${lab_files[@]}" /var/tmp/lab1/compute-viewer/
lab_copy_status=$?
printf 'COPY_EXIT_CODE=%s\n' "$lab_copy_status"
ls -lah /var/tmp/lab1/compute-viewer/
printf 'Files copied with the previous role remain on disk:\n'
ls -lah /var/tmp/lab1/storage-admin/
printf 'LAB1_COMPUTE_VIEWER_END\n'
