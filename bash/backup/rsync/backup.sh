#!/bin/bash
sh backup-rsync.sh -F -R cos@sil-15 -RD /home/cos -LD /media/${USER}/backup
