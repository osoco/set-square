defineEnvVar MONIT_CONF_FOLDER \
             "Monit's configuration folder" \
             "/etc/monit/conf.d";
defineEnvVar MONIT_CONF_FILE \
             "The Monit configuration file to make it check the root filesystem usage" \
             '${MONIT_CONF_FOLDER}/rootfs.conf';
defineEnvVar DISK_SPACE_THRESHOLD \
             "The threshold used to decide whether to send disk usage alerts" \
             "80%";
defineEnvVar DISK_SPACE_POSITIVES \
             "The number of positives within the specified cycles to decide whether to send disk usage alerts" \
             "5";
defineEnvVar DISK_SPACE_CYCLES \
             "The number of cycles used to decide whether to send disk usage alerts" \
             "15";
defineEnvVar INODE_USAGE_THRESHOLD \
             "The threshold used to decide whether to send inode usage alerts" \
             "90%";
defineEnvVar INODE_USAGE_POSITIVES \
             "The number of positives within the specified cycles to decide whether to send inode usage alerts" \
             "5";
defineEnvVar INODE_USAGE_CYCLES \
             "The number of cycles used to decide whether to send inode usage alerts" \
             "15";
