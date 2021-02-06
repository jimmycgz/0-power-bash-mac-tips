#!/bin/bash

detect_os () {
# OS/Distro Detection
    # Try lsb_release, fallback with /etc/issue then uname command
    KNOWN_DISTRIBUTION="(Debian|Ubuntu|RedHat|CentOS|openSUSE|Amazon|Arista|SUSE)"
    DISTRIBUTION=$(lsb_release -d 2>/dev/null | grep -Eo $KNOWN_DISTRIBUTION  || grep -Eo $KNOWN_DISTRIBUTION /etc/issue 2>/dev/null || grep -Eo $KNOWN_DISTRIBUTION /etc/Eos-release 2>/dev/null || grep -m1 -Eo $KNOWN_DISTRIBUTION /etc/os-release 2>/dev/null || uname -s)
    export OS=""

    if [ $DISTRIBUTION = "Darwin" ]; then
        printf "\033[31mThis script does not support installing on the Mac.
    Please use the 1-step script available at https://app.datadoghq.com/account/settings#agent/mac.\033[0m\n"
        exit 1;

    elif [ -f /etc/debian_version -o "$DISTRIBUTION" == "Debian" -o "$DISTRIBUTION" == "Ubuntu" ]; then
        OS="Debian"
    elif [ -f /etc/redhat-release -o "$DISTRIBUTION" == "RedHat" -o "$DISTRIBUTION" == "CentOS" -o "$DISTRIBUTION" == "Amazon" ]; then
        OS="RedHat"
    # Some newer distros like Amazon may not have a redhat-release file
    elif [ -f /etc/system-release -o "$DISTRIBUTION" == "Amazon" ]; then
        OS="RedHat"
    # Arista is based off of Fedora14/18 but do not have /etc/redhat-release
    elif [ -f /etc/Eos-release -o "$DISTRIBUTION" == "Arista" ]; then
        OS="RedHat"
    # openSUSE and SUSE use /etc/SuSE-release
    elif [ -f /etc/SuSE-release -o "$DISTRIBUTION" == "SUSE" -o "$DISTRIBUTION" == "openSUSE" ]; then
        OS="SUSE"
    fi

    echo " OS Type detected: $OS"
}

apt_wait_chk () {
      echo " Waiting for apt to finish and release all locks"

  while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    echo " Checking /var/lib/dpkg/lock"
    sleep 5
  done

  if [ -f /var/log/unattended-upgrades/unattended-upgrades.log ]; then
    while sudo fuser /var/log/unattended-upgrades/unattended-upgrades.log >/dev/null 2>&1 ; do
      echo " Checking /var/log/unattended-upgrades/unattended-upgrades.log"
      sleep 2
    done
  fi
}

debian_task () {

    apt_wait_chk
    echo " Installing Java 8 for Ubuntu"
    curl -L -b -O https://pai-gm-midgar-shared-infra-assets.s3.ap-south-1.amazonaws.com/jdk-8u171-linux-x64.rpm
    sudo yum -y localinstall jdk-8u171-linux-x64.rpm

}

redhat_task () {
    sudo yum update -y
    sudo yum install -y java-1.8.0-openjdk
}

#Main task
detect_os

# Run tasks based on OS distributions
if [ $OS = "RedHat" ]; then
    redhat_task

elif [ $OS = "Debian" ]; then
    debian_task

elif [ $OS = "SUSE" ]; then
    sudo zypper install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
fi
