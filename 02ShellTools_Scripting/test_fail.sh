 #!/usr/bin/env bash

count=1

while true
do
    ./sometimes_fail.sh
    if [[ $? -ne 0 ]]; then
        echo "failed after $count times"
        break
    fi
    let count++
done

#  for ((count=1;;count++))
#  do
#      ./sometimes_fail.sh 2> out.log
#      if [[ $? -ne 0 ]]; then
#          echo "failed after $count times"
#          cat out.log
#          break

#      echo "$count try"
#      fi
#  done