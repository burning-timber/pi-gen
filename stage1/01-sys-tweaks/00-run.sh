#!/bin/bash -e

user_passwd=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16})
root_passwd=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16})

cat <<EOF > /pi-gen/deploy/users
${user_passwd}
${root_passwd}
EOF

install -d "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d"
install -m 644 files/noclear.conf "${ROOTFS_DIR}/etc/systemd/system/getty@tty1.service.d/noclear.conf"
install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"

on_chroot << EOF
if ! id -u ${FIRST_USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${FIRST_USER_NAME}
fi
echo "${FIRST_USER_NAME}:${user_passwd}" | chpasswd
echo "root:${root_passwd}" | chpasswd
EOF


