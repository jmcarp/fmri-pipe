#!/bin/bash

logdir="/data00/jmcarp/scripts/open/joblog"

for job in permjobs/*.m
do
  jobstrip=$job
  jobstrip=${jobstrip#*/}
  jobstrip=${jobstrip%*.}
  logname="$logdir/$jobstrip"
  echo "Working on job $job"
  matlab < $job >> $logname
done
