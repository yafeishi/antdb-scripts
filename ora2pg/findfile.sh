echo  "-------------------------------------`date`"
dir=$1
find $dir -maxdepth 2 -name "*$2*"  -exec ls -lhtr {} \;