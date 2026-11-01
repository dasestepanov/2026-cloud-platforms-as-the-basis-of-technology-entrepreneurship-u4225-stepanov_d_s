#!/usr/bin/env bash
set -euo pipefail
exec > >(tee /var/log/lab1-storage-admin.log /dev/ttyS0) 2>&1
printf '\nLAB1_STORAGE_ADMIN_BEGIN\n'
printf 'VM: '; hostname
printf 'Service account: '
curl -fsS -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email
printf '\n'
gcloud auth list --filter=status:ACTIVE --format='value(account)'
gcloud storage buckets describe gs://lab1-bucket-itmo --format='yaml(name,location,storage_class)'
mkdir -p /var/tmp/lab1/storage-admin
gcloud storage ls 'gs://lab1-bucket-itmo/**' > /var/tmp/lab1/bucket-list.txt
awk '/^gs:\/\// && !/\/$/ {print; n++; if(n==3) exit}' /var/tmp/lab1/bucket-list.txt > /var/tmp/lab1/files.txt
mapfile -t lab_files < /var/tmp/lab1/files.txt
if [ "${#lab_files[@]}" -ne 3 ]; then
  printf 'Expected three objects, found %s\n' "${#lab_files[@]}"
  exit 1
fi
printf 'Selected objects:\n'
cat /var/tmp/lab1/files.txt
gcloud storage cp "${lab_files[@]}" /var/tmp/lab1/storage-admin/
ls -lah /var/tmp/lab1/storage-admin/
printf 'LAB1_STORAGE_ADMIN_SUCCESS\n'
