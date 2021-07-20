#! /bin/sh
# A script to monitor uptime of websites,
# and notify by email if a website is down.

# SITES: COMMA-SEPARATED WEBSITES
# EMAILS: COMMA-SEPARATED EMAILS
SITES="https://www.parkviewneighbourhoodgarden.org,https://www.celpip.ca"
EMAILS="jimmycgz@gmail.com"

  for SITE in $(echo $SITES | tr "," " "); do
  if [ ! -z "${SITE}" ]; then
    RESPONSE=$(curl -s --head $SITE)
    if echo $RESPONSE | grep "301 Moved Permanently" > /dev/null
    # if echo $RESPONSE | grep "200 OK" > /dev/null
    then
      echo "The HTTP Server on ${SITE} is up!"
    else
      MESSAGE="The HTTP server at ${SITE} has failed to respond."
      for EMAIL in $(echo $EMAILS | tr "," " "); do
        SUBJECT="${SITE} (http) Failed"
        echo $MESSAGE $SUBJECT $EMAIL
        #echo $MESSAGE | mail -s "$SUBJECT" $EMAIL
        echo $SUBJECT
        echo "Alert sent to $EMAIL"
      done
    fi
  fi
done