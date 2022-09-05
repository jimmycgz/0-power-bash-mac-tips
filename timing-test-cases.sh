#!/bin/bash

# Benchmarking PostgreSQL in a loop with timing
# Usage:
# ./timing-test-cases.sh <read|write|pgbench|upgrade_cp|upgrade_nodepool> [LOOP_COUNT]

show_usage () {
  echo ""
  echo "Available Features:"
  echo ""  
  echo "* Run pgbench 200 times"
  echo " ${0} pgbench 200"
  echo ""  
  echo "* Summarize test result pgbench from the latest log file"  
  echo "  ${0} pgbench stat"
  echo ""  
  echo "* Run read db 1000 times"
  echo "  ${0} read 1000"
  echo ""  
  echo "* Summarize test result read queries from the latest log file"  
  echo "  ${0} read stat"
  echo ""  
  echo "* Run write db 1000 times"
  echo "  ${0} write 1000"
  echo ""  
  echo "* Run upgrade GKE Control Plane"
  echo "  ${0} upgrade_cp"
  echo ""  
  echo "* Run upgrade GKE Node Pool"
  echo "  ${0} upgrade_nodepool"
}

name_log_file () {
  LOG_PREFIX="__LOG__"
  LOG_PATH='/tmp/log'
  FULL_NAME=${0}
  SHORT_NAME="${FULL_NAME##*/}"
  BASE_NAME="${SHORT_NAME%.*}"
  export LOG_FILE=$LOG_PATH/$BASE_NAME-$TEST_CASE".log"
}

init_log () {
  BLK=" "
  CHK_TIME=`(date +%Y-%m-%d-%T)`
  if [ $ACTION -eq 1 ]; then
    MSG="$BLK$LOG_PREFIX$BLK$CHK_TIME Test case: $TEST_CASE"
  else
    MSG="$BLK$LOG_PREFIX$BLK$CHK_TIME Test case: $TEST_CASE $ACTION times"
  fi
  # Example: LOG 2022-08-26-15:43:02 Loop 5 times
  mkdir -p $LOG_PATH

  if [ -f $LOG_FILE ]; then
    mv $LOG_FILE ${LOG_FILE}-$CHK_TIME
  fi

  echo ' '
  echo $MSG
  echo ' '
  echo $MSG >$LOG_FILE
}

init_test_db () {
  export HOST_PGPOOL=postgresql-postgresql-ha-pgpool
  export INIT_QUERY="select \"name\" from tb01 where \"id\" = 1;"
  export WRITE_QUERY="update tb01 set \"name\" = md5(random()::text) where \"id\" = 1 returning \"name\";"
  export READ_QUERY="select \"name\" from tb01 where \"id\" = 1;"
  export DB=postgres
  pgbench -i -h $HOST_PGPOOL -U postgres $DB
}

init_test_upgrade () {
  export SOME_VAR="place holder"
}

log_test (){
  echo " "  
  echo " " >>$LOG_FILE
  CHK_TIME=`(date +%Y-%m-%d-%T)`
  LOG_LINE="$BLK$LOG_PREFIX$BLK$CHK_TIME$BLK$LOG_MSG"
  echo $LOG_LINE
  echo $LOG_LINE >>$LOG_FILE
}

timing_test_db () {
  # Format name convention for log file
  name_log_file

  if [[ $ACTION == "stat" ]]; then
    summary_test
  else
    init_log
    init_test_db
    for i in $(seq 1 $ACTION)
    do   
      export LOG_MSG="Starting Test $TEST_CASE"
      log_test
      case $TEST_CASE in
        read)
          export DB=gke_test_zonal
          psql -h $HOST_PGPOOL -U postgres $DB -c "$READ_QUERY"
          ;;
        write)
          export DB=gke_test_zonal        
          psql -h $HOST_PGPOOL -U postgres $DB -c "$WRITE_QUERY"        
          ;;
        pgbench)
          export DB=postgres
          pgbench -h $HOST_PGPOOL -U postgres $DB -c 20 -j 10 -T 7200       
          ;;
         *)
          echo "Invalid test case: $TEST_CASE" && (exit 1)
          ;;
        esac               

      if [ $? -ne 0 ]; then
        export LOG_MSG="Error from test case: $TEST_CASE"
        log_test
      else
        export LOG_MSG="Succeeded test case: $TEST_CASE"
        log_test
      fi
      sleep 0.5
    done
    summary_test
  fi
}

timing_upgrade_gke () {
  # Format name convention for log file
  name_log_file

  if [[ $ACTION == "stat" ]]; then
    summary_test
  else
    export ACTION=1
    init_log
    init_test_upgrade
    export LOG_MSG="Starting $TEST_CASE"
    log_test
    case $TEST_CASE in
      upgrade_cp)
        gcloud container clusters upgrade $CLUSTER_NAME --master --cluster-version $NEW_VERSION --region=$REGION
        ;;
      upgrade_nodepool)
        gcloud container clusters upgrade $CLUSTER_NAME --region $REGION --node-pool=$NODE_POOL --cluster-version $NEW_VERSION --project $PROJECT_ID
        ;;
       *)
        echo "Invalid test case: $TEST_CASE" && (exit 1)
        ;;
    esac

    if [ $? -ne 0 ]; then
      export LOG_MSG="Error from test case: $TEST_CASE"
      log_test
    else
      export LOG_MSG="Succeeded test case: $TEST_CASE"
      log_test
    fi
    summary_test
  fi
}

summary_test () {
    echo ""
    if [ ! -f $LOG_FILE ]; then
      echo "  Log file not found: $LOG_FILE"
    else
      ERROR_COUNT=$(cat $LOG_FILE | grep "Error" | wc -l)
      GOOD_COUNT=$(cat $LOG_FILE | grep "Succeeded" | wc -l)
      echo " "
      echo "Summary from Logfile: $LOG_FILE"
      echo "Successful queries: $GOOD_COUNT"
      echo "Failed queries:     $ERROR_COUNT"
    fi
}
# Start Here
# Loop 1~1000 times


if [ -z $2 ]; then
  ACTION=1000
else
  ACTION=$2
fi

case $1 in
  write)
    export TEST_CASE="write"
    timing_test_db
    ;;
  read)
    export TEST_CASE="read"
    timing_test_db
    ;;
  pgbench)
    export TEST_CASE="pgbench"
    timing_test_db
    ;;
  upgrade_cp)
    export TEST_CASE="upgrade_cp"
    timing_upgrade_gke
    ;;
  upgrade_nodepool)
    export TEST_CASE="upgrade_nodepool"
    timing_upgrade_gke
    ;;    
    
  *)
    echo "Wrong arguments"
    show_usage
    ;;
esac

echo ""
