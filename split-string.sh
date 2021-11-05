#!/bin/bash
mkdir -p $HOME/Downloads/actual-log

LOG_FILES="label_log_gce2021-08-05T15:52:55UTC.csv label_log_gcs2021-08-04T17:02:43UTC.csv label_log_bq2021-08-04T17:46:11UTC.csv label_log_gce2021-08-05T17:19:48UTC.csv label_log_gcs2021-08-05T18:31:54UTC.csv label_log_bq2021-08-05T18:40:47UTC.csv label_log_gce2021-08-05T18:01:01UTC.csv"

for LOG_FILE in $LOG_FILES;do
  # echo $LOG_FILE
  gcloud compute scp --recurse revi-sandbox-sada-label-auto:/home/proj/actual-log/$LOG_FILE $HOME/Downloads/actual-log
done