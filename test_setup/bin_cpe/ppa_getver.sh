#ppacmd getversion -a > $1
#[ ! $? -eq 0 ] && ppacmd getversion > $1

cat /proc/mpe/mpefw_version > $1
[ ! $? -eq 0 ] && cat /proc/mpe/mpefw_version > $1

