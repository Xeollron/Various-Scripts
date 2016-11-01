#!/bin/bash
#this scrit requires tmux, lm-sensors and mprime to operate please install based on your distrobution
#please configure mprime in advance, recomended stress test is small FFTs on all threads
#please setup lm-sensors with command sensors-detect prior to running script


frontEnd(){
  tmux new-session -s primemonitor -d 'watch -n.1 "sensors"' #set sensor name to correct one for your system
  tmux split-window -h 'watch -n.1 "lscpu |grep MHz"'
  tmux split-window -v './mprime -t'
  primePID=$(ps ax | grep mprime | head -n1 | awk '{print $1}')
  loging &
  timer &
  tmux -2 attach-session -t primemonitor -d
}

loging(){
  peakTemp=0
  while :
  do
    #set sensor name to correct one for your system
	  tmpTemp=$(sensors coretemp-isa-0000 | grep "Core 0" | awk '{print $3}' | cut -c 2,3) #may need to pick different temp#, varies by system
    if [[ "$tmpTemp" -gt "$peakTemp" ]]; then
      peakTemp="$tmpTemp"
      echo "$peakTemp *C" > temp.log
    fi
	  sleep 1
  done
}

timer(){
  sleep 20m
  kill -2 $primePID &> /dev/null
  echo "Success" > run.log
}

frontEnd
