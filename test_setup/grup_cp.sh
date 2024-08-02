#!/bin/sh
path=/home/test/tmp/testcase
dest=/home/test/test_setup/testcase
test_id=1
group=TG_6RD
while read -r testcase; do
	case "$testcase" in \#*) continue ;; esac
	echo "Test $test_id ::::: $testcase ::::: "
	#cp -r $path/$testcase .
	rsync -av --progress $path/$testcase $dest --exclude .svn
	((test_id=test_id+1))
	
done < $path/$group

group=TG_DSLITE
while read -r testcase; do
	case "$testcase" in \#*) continue ;; esac
	echo "Test $test_id ::::: $testcase ::::: "
	# Exclude .svn folder
	rsync -av --progress $path/$testcase $dest --exclude .svn
	((test_id=test_id+1))
	
done < $path/$group

group=TG_EOGRE
while read -r testcase; do
	case "$testcase" in \#*) continue ;; esac
	echo "Test $test_id ::::: $testcase ::::: "
	# Exclude .svn folder
	rsync -av --progress $path/$testcase $dest --exclude .svn
	((test_id=test_id+1))
	
done < $path/$group

group=TG_IPOGRE
while read -r testcase; do
	case "$testcase" in \#*) continue ;; esac
	echo "Test $test_id ::::: $testcase ::::: "
	# Exclude .svn folder.
	rsync -av --progress $path/$testcase $dest --exclude .svn
	((test_id=test_id+1))
	
done < $path/$group

group=TG_IPV4_BASIC
while read -r testcase; do
	case "$testcase" in \#*) continue ;; esac
	echo "Test $test_id ::::: $testcase ::::: "
	# Exclude .svn folder
	rsync -av --progress $path/$testcase $dest --exclude .svn
	((test_id=test_id+1))
	
done < $path/$group

group=TG_IPV4_MULTICAST
while read -r testcase; do
	case "$testcase" in \#*) continue ;; esac
	echo "Test $test_id ::::: $testcase ::::: "
	# Exclude .svn folder
	rsync -av --progress $path/$testcase $dest --exclude .svn
	((test_id=test_id+1))
	
done < $path/$group

group=TG_IPV6_BASIC
while read -r testcase; do
	case "$testcase" in \#*) continue ;; esac
	echo "Test $test_id ::::: $testcase ::::: "
	# Exclude .svn folder
	rsync -av --progress $path/$testcase $dest --exclude .svn
	((test_id=test_id+1))
	
done < $path/$group

group=TG_IPV6_MULTICAST
while read -r testcase; do
	case "$testcase" in \#*) continue ;; esac
	echo "Test $test_id ::::: $testcase ::::: "
	# Exclude .svn folder
	rsync -av --progress $path/$testcase $dest --exclude .svn
	((test_id=test_id+1))
	
done < $path/$group

group=TG_L2TP
while read -r testcase; do
	case "$testcase" in \#*) continue ;; esac
	echo "Test $test_id ::::: $testcase ::::: "
	# Exclude .svn folder
	rsync -av --progress $path/$testcase $dest --exclude .svn
	((test_id=test_id+1))
	
done < $path/$group