#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Waiting for external EBS volume to attach..."
sleep 30

DEVICE=$(lsblk -dn -o NAME | grep -E 'xvdf|nvme1n1' | head -n 1)

if [ -n "$DEVICE" ]; then
  echo "Formatting and mounting /dev/$DEVICE to /var/lib/jenkins..."
  mkfs.ext4 /dev/$DEVICE
  mkdir -p /var/lib/jenkins
  mount /dev/$DEVICE /var/lib/jenkins
  echo "/dev/$DEVICE /var/lib/jenkins ext4 defaults,nofail 0 2" >> /etc/fstab
else
  echo "ERROR: Data volume not found!"
fi

echo "Updating system and installing dependencies..."
dnf update -y
# Dynamically injecting the Java version requested by the environment
dnf install -y wget java-${java_version}-amazon-corretto-headless

echo "Adding Jenkins repository..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo "Installing Jenkins..."
dnf upgrade -y
dnf install -y jenkins

chown -R jenkins:jenkins /var/lib/jenkins

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

echo "Jenkins installation and volume setup complete."
