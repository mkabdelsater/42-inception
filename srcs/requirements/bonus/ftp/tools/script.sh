#!/bin/bash
set -e

# Create FTP user
if ! id "$FTP_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    echo "FTP user '$FTP_USER' created."
fi

# Configure vsftpd
cat > /etc/vsftpd.conf << EOF
# Listen on IPv4
listen=YES
listen_ipv6=NO

# Enable anonymous access?
anonymous_enable=NO

# Enable local users?
local_enable=YES

# Enable uploading?
write_enable=YES

# Local umask
local_umask=022

# Display directory messages?
dirmessage_enable=YES

# Log settings
xferlog_enable=YES
connect_from_port_20=YES

# Chroot settings
chroot_local_user=YES
allow_writeable_chroot=YES

# Path settings
local_root=/var/www/html

# Secure settings
secure_chroot_dir=/var/run/vsftpd/empty

# Passive mode settings (for Docker)
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40005
pasv_address=${DOMAIN_NAME}

# Other settings
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
EOF

echo "$FTP_USER" > /etc/vsftpd.userlist

# Ensure permissions on the volume
# Note: www-data (UID 33) owns the volume in WordPress container.
# We might need to adjust UIDs or use a shared group if we want both to write.
# For simplicity, we'll just make sure the user can access it.
chown -R "$FTP_USER:$FTP_USER" /var/www/html

echo "Starting vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf
