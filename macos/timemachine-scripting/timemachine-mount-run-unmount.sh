#!/usr/bin/env zsh -f
#
# https://talk.macpowerusers.com/t/any-way-to-automate-a-time-machine-backup-mount-backup-unmount/16758/10
# https://gist.github.com/tjluoma/8c8a05c217daa2de085c9c07531805b3
#
# Purpose: 	Once you set the DEVICE,
#			this script will mount your Time Machine drive,
#			run Time Machine,
#			and then unmount the drive
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2020-04-20
#
# THIS SCRIPT IS INTENDED TO LIVE AT /usr/local/bin, and run via a .plist as a service once per day
# cp ./timemachine-mount-run-unmount.sh /usr/local/bin/
#
	## To find the device, mount the Time Machine drive and then run this command in Terminal:
	#
	#	mount | egrep '^/dev/' | sed -e 's# (.*#)#g' -e 's# on /# (/#g'
	#
	# and you will see a bunch of entries like this
	#
	#	/dev/disk2s1 (/Volumes/MBA-Clone - Data)
	#	/dev/disk3s5 (/Volumes/Storage)
	# 	/dev/disk4s6 (/Volumes/MBA-Clone)
	#
	# You need to set
	#
	#	DEVICE='/dev/disk3s5'
	#
	# or whatever is correct for your Time Machine drive

# TODO this is current as of 2/2024 on hammacm2
DEVICE='/dev/disk4s3'


################################################################################################

LOG="/tmp/km-timemachine-mount-run-unmount.log"

if [[ -e "$HOME/.path" ]]; then
	source "$HOME/.path"
else
	PATH="$HOME/scripts:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin"
fi

zmodload zsh/datetime

TIME=$(strftime "%Y-%m-%d--%H.%M.%S" "$EPOCHSECONDS")

function timestamp { strftime "%Y-%m-%d--%H.%M.%S" "$EPOCHSECONDS" }

STATUS=$(tmutil currentphase)

if [[ "$STATUS" != "BackupNotRunning" ]]; then
	echo "Error [`timestamp`]: Time Machine status is '$STATUS'. Should be 'BackupNotRunning'." \
	| tee -a "$LOG"

	exit 1
fi

	# if you have multiple Time Machine destinations, this might not give you the right info
	# I'm assuming you only have one
TM_DRIVE_NAME=$(tmutil destinationinfo | egrep '^Name  ' | sed 's#^Name  *: ##g' | head -1)

MNTPNT="/Volumes/$TM_DRIVE_NAME"

if [[ -d "$MNTPNT" ]]; then
	echo "$MNTPNT' is already mounted". >>| "$LOG"
else
	if [[ "$DEVICE" == "" ]]
	then
		echo "[Fatal Error]: the 'DEVICE' variable is not set" | tee -a "$LOG"
		exit 1
	fi

	# important to use just one volume; doing whole disk didn't work
	diskutil mount "$DEVICE"
fi

if [[ ! -d "$MNTPNT" ]]; then
	echo "[Fatal Error at `timestamp`]: Failed to mount '$MNTPNT'." | tee -a "$LOG"
	/usr/bin/osascript -e 'display notification "Problem with time machine mount; see log in /tmp/ ; note that macos may use different disk number after upgrade, until 2nd reboot."'
	exit 1
fi

# seems to work w/o dest ID; assumes same (preset) destination ID
# TM_BACKUP_ID=$(tmutil destinationinfo | egrep '^ID  ' | sed 's#^ID  *: ##g' | head -1)
# echo "Starting backup at `timestamp` using ID: $TM_BACKUP_ID"

	# `caffeinate -i` is optional but keeps your Mac from sleeping
# caffeinate -i tmutil startbackup --block --destination "$TM_BACKUP_ID" >> "$LOG" 2>&1

echo "Starting backup at `timestamp`"
caffeinate -ims tmutil startbackup --block >> "$LOG" 2>&1

EXIT="$?"

if [[ "$EXIT" == "0" ]]; then
	echo "tmutil finished successfully at `timestamp`." >>| "$LOG"
else
	echo "tmutil failed (Exit = $EXIT) at `timestamp`." | tee -a "$LOG"

	/usr/bin/osascript -e 'display notification "Problem with time machine backup; see log in /tmp/"'

	exit 1
fi

TRIES=100
while [[ -d "$MNTPNT" && TRIES -gt 0 ]]; do
		# this will try to unmount the drive 100 times, waiting 10s in between

	echo "Trying to unmount '$MNTPNT' at `timestamp`, attempt #$TRIES..." >>| "$LOG"

	# unmounting whole disk failed; just unmount volume
	diskutil unmount "$MNTPNT"

	sleep 10
	TRIES=$(($TRIES-1))
done

echo "Finished successfully at `timestamp`" >>| "$LOG"

exit 0
#EOF
