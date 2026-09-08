#!/bin/bash

# ==========================================
# Injected Terraform Variables
# ==========================================
APP_DIR="${app_dir}"
NEXUS_VERSION="${nexus_version}"
JAVA_PACKAGE="${java_package}"
NEXUS_USER="${nexus_user}"

# Derived bash variables (No need to pass these from tfvars)
NEXUS_TARBALL="nexus-unix-x86-64-$NEXUS_VERSION.tar.gz"
NEXUS_DOWNLOAD_URL="https://download.sonatype.com/nexus/3/$NEXUS_TARBALL"
NEXUS_EXTRACTED_DIR="nexus-$NEXUS_VERSION"

# ==========================================
# Installation & Configuration
# ==========================================

yum update -y
yum install -y wget tar gzip $JAVA_PACKAGE

mkdir -p $APP_DIR
cd $APP_DIR

wget $NEXUS_DOWNLOAD_URL
tar -zxvf $NEXUS_TARBALL
mv $NEXUS_EXTRACTED_DIR nexus
rm -rf $NEXUS_TARBALL

useradd $NEXUS_USER

chown -R $NEXUS_USER:$NEXUS_USER $APP_DIR/nexus $APP_DIR/sonatype-work

echo "run_as_user=\"$NEXUS_USER\"" > $APP_DIR/nexus/bin/nexus.rc

cat > /etc/systemd/system/nexus.service <<EOF
[Unit] 
Description=Nexus Repository Manager Service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=$NEXUS_USER
Group=$NEXUS_USER
ExecStart=$APP_DIR/nexus/bin/nexus start
ExecStop=$APP_DIR/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nexus
systemctl start nexus
