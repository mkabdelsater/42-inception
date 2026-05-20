#!/bin/bash
set -e

# Create FTP user
if ! id "$FTP_USER" &>/dev/null; then
    useradd -m -s /bin/bash -G www-data "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    echo "FTP user '$FTP_USER' created and added to www-data group."
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
# We want both www-data and the FTP user to be able to read/write.
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html

echo "Starting vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf
