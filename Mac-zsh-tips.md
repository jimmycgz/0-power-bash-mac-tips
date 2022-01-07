# Collection of best practice on Mac Terminal, saimiliar but different than Linux
The syntax is somehow different between MacOs and Ubuntu, especailly for `sed` and for_loop in a list of string

## Sed in Mac: Find and replace

```
# change the node pool from n2 to n2d for the while line of nodeSelector
export NEW_POOL='sandbox-n2d'
export FILE='deploy.yaml'
sed -i '' -e "s/nodeSelector.*/nodeSelector: ${NEW_POOL}/g" $FILE
# replace the line of myNodePool with double quotes 
sed -i '' -e "s/myNodePool=.*/myNodePool=\"${NEW_POOL}\"/g" $FILE
```
## For loop in a list of string
```
for NAME in {"Mike","Cassie","Elisa"}; do
  echo "Hi $NAME"
done

declare -a arr=("element1" "element2" "element3")

for i in "${arr[@]}"
do
   echo "$i"
done
```
## for loop 10 times
```
for i in {1..10}
do
   echo "Welcome $i times"
done
```
## for loop 99 times, use same digit format 01~99, same as Ubuntu
```
for i in $(seq -f "%02g" 1 99)
do 
  echo $i && sleep 1;
done
```

## Loop from a file, read each line
Better way of trimming leading whitespace, interpreting backslash sequences, and skipping the last line if it's missing a terminating linefeed. If these are concerns, you can do:
```
while IFS="" read -r p || [ -n "$p" ]
do
  printf '%s\n' "$p"
done < peptides.txt
```

## Check Availability of Website to a log file

```
cat chk-web.sh

#!/bin/bash

echo " "
echo " " >>/home/ubuntu/chk-web.txt
CHK_TIME=`(date +%Y-%m-%d-%T)`
HTML_TXT=`(curl https://ddfd.com:8443 -k|grep "DOCTYPE HTML")`

if [ -z "$HTML_TXT" ]; then
        HTML_TXT="HTML Head Error"
fi

IP=`(ping dedfd.com -w 5 |egrep -o '([0-9]+\.){3}[0-9]+')`
BLK=' '
MSG="$IP$BLK$HTML_TXT$BLK$CHK_TIME"
echo $MSG
echo $MSG >>/home/ubuntu/chk-web.txt

#sleep (300)
```
Features:

* Show date and time 

* Find IP from a string by egrep

* Find HTML head from curl command

Output in the log file:
```
cat chk-web.txt

xxx.xxx.xxx.3x <!DOCTYPE HTML> 2018-12-21-13:50:02


xxx.xxx.xxx.3x <!DOCTYPE HTML> 2018-12-21-13:52:01

xxx.xxx.xxx.3x <!DOCTYPE HTML> 2018-12-21-13:53:01
xxx.xxx.xxx.3x HTML Head Error 2018-12-21-13:51:01

xxx.xxx.xxx.3x <!DOCTYPE HTML> 2018-12-21-13:54:01

``` 

## Run cron job every minute, every 5 minutes, 13:00 UTC first Saturday of each month

```
* * * * * /bin/sh /home/ubuntu/chk-web.sh
*/5 * * * * /bin/sh /home/ubuntu/chk-web.sh
0 13 1-7 * 6 /bin/sh /home/ubuntu/chk-web.sh
(Here, 6 means the 6th day of the week, 1-7 means any day during the first and 7th day of month)
```


##Remove the old key pair 
```
idssh=`cat ~/.ssh/id_rsa.pub | awk '{print $2}'` 
ssh "old-nov" ec2-user@xxx.x.x.2 "sed -i '/$idssh/{d}' .ssh/authorized_keys" 
ssh -i "old-nov-new.pem" ec2-user@xxx.x.x.2 
ssh -i "old-nov" ec2-user@xxx.x.x.2 
```

## Copy files from local linux to remote linux 

```
Cd folder_where_id_rsa 
Scp test.py ec2-user@ip:    copy file from current folder to remote:/home 
scp ec2-user@xxx.x.x.2.compute.amazonaws.com.cn:/home/ec2-user/test.py ttt.py  
scp /your_folder/test.py ec2-user@xxx.x.x.2.compute.amazonaws.com.cn:/home/ec2-user 
```
  

## Check all group IDs 
```
cat /etc/group 
```
 
## Check all users 
```
Cat /etc/passwd 
```
## Change ownership  
```
Sudo chown -R web-data folder-name 
sudo chown -R 33:33 cms  
```
 
## Compress files 
```
Tar -czvf docker-log.tar.gz . 
```
 
## Trim string between Begin_str and End_str

 eg: getting the key value from file nuralogix_dev.pub 

```
awk '/---- END SSH2 PUBLIC KEY ----/ { p = 0 }; p; /Comment: "imported-openssh-key"/ { p = 1 }' ~/.ssh/key.old.pub 
 
cat key.old.pub

---- BEGIN SSH2 PUBLIC KEY ---- 

Comment: "imported-openssh-key" 

AAAAB3N1yc2EAAtest test test test test test test IpdQ 

9aC1ytest test test test test test test IphHF 

/C1yc2EAAtest test test test test test test Ip1tG 

yEAAtest test test test test test test IpKMm 

sKAtest test test test test test test Ip7oF 

s4aAtest test test test test test test IpGxR 

---- END SSH2 PUBLIC KEY ---- 

``` 

