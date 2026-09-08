#!/bin/bash

# ==========================================
# System Updates, Dependencies & OS Tuning
# ==========================================
dnf update -y
dnf install -y docker jq # jq is required to parse the JSON secret

# SonarQube requires higher max_map_count for its Elasticsearch engine
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
echo "vm.max_map_count=524288" >> /etc/sysctl.conf
echo "fs.file-max=131072" >> /etc/sysctl.conf

# ==========================================
# Docker Installation & Network Setup
# ==========================================
systemctl enable docker
systemctl start docker
docker network create sonar-network

# ==========================================
# Secure Credentials Fetch (AWS Secrets Manager)
# ==========================================
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region "${aws_region}" \
  --secret-id "${secret_id}" \
  --query SecretString \
  --output text)

DB_USER=$(echo $SECRET_JSON | jq -r '.username')
DB_PASS=$(echo $SECRET_JSON | jq -r '.password')

# ==========================================
# Persistent Storage: Volume 1 (PostgreSQL)
# ==========================================
PG_DEVICE="/dev/nvme1n1"
POSTGRES_DIR="/opt/sonarqube/postgres_data"

mkdir -p $POSTGRES_DIR

if [ -z "$(blkid -s TYPE -o value $PG_DEVICE)" ]; then
    mkfs -t ext4 $PG_DEVICE
fi

mount $PG_DEVICE $POSTGRES_DIR

PG_UUID=$(blkid -s UUID -o value $PG_DEVICE)
if ! grep -q "$PG_UUID" /etc/fstab; then
    echo "UUID=$PG_UUID $POSTGRES_DIR ext4 defaults,nofail 0 2" >> /etc/fstab
fi

# ==========================================
# Persistent Storage: Volume 2 (Bug / Issue History Data)
# ==========================================
BUG_DEVICE="/dev/nvme2n1"
BUG_DATA_DIR="/opt/sonarqube/data"

mkdir -p $BUG_DATA_DIR

if [ -z "$(blkid -s TYPE -o value $BUG_DEVICE)" ]; then
    mkfs -t ext4 $BUG_DEVICE
fi

mount $BUG_DEVICE $BUG_DATA_DIR

BUG_UUID=$(blkid -s UUID -o value $BUG_DEVICE)
if ! grep -q "$BUG_UUID" /etc/fstab; then
    echo "UUID=$BUG_UUID $BUG_DATA_DIR ext4 defaults,nofail 0 2" >> /etc/fstab
fi

# Create remaining non-ebs directories
mkdir -p /opt/sonarqube/logs
mkdir -p /opt/sonarqube/extensions

# SonarQube container runs as UID 1000. Grant it ownership of these directories.
chown -R 1000:1000 /opt/sonarqube/

# ==========================================
# 1. Launch PostgreSQL in Docker
# ==========================================
# Create a nested directory to avoid the ext4 lost+found error
mkdir -p /opt/sonarqube/postgres_data/pgdata
chown -R 999:999 /opt/sonarqube/postgres_data/pgdata

docker run -d \
  --name sonarqube-db \
  --network sonar-network \
  -e POSTGRES_USER="$DB_USER" \
  -e POSTGRES_PASSWORD="$DB_PASS" \
  -e POSTGRES_DB="$DB_USER" \
  -v /opt/sonarqube/postgres_data/pgdata:/var/lib/postgresql/data \
  --restart always \
  postgres:${postgres_version}

# ==========================================
# 2. Launch SonarQube in Docker
# ==========================================
docker run -d \
  --name "${sonar_container_name}" \
  --network sonar-network \
  -p ${sonar_host_port}:${sonar_container_port} \
  -e SONAR_JDBC_URL="jdbc:postgresql://sonarqube-db:5432/$DB_USER" \
  -e SONAR_JDBC_USERNAME="$DB_USER" \
  -e SONAR_JDBC_PASSWORD="$DB_PASS" \
  -v /opt/sonarqube/data:/opt/sonarqube/data \
  -v /opt/sonarqube/logs:/opt/sonarqube/logs \
  -v /opt/sonarqube/extensions:/opt/sonarqube/extensions \
  --restart always \
  "${sonar_image}"

# ==========================================
# 3. Automated S3 Backup Cron Job
# ==========================================
cat << EOF > /opt/sonarqube/backup_to_s3.sh
#!/bin/bash
TIMESTAMP=\$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="/tmp/sonarqube_db_backup_\$TIMESTAMP.sql"

docker exec sonarqube-db pg_dump -U "$DB_USER" "$DB_USER" > \$BACKUP_FILE
aws s3 cp \$BACKUP_FILE s3://${s3_backup_bucket}/sonarqube/\$BACKUP_FILE
rm \$BACKUP_FILE
EOF

chmod +x /opt/sonarqube/backup_to_s3.sh
echo "0 2 * * * root /opt/sonarqube/backup_to_s3.sh" >> /etc/crontab
