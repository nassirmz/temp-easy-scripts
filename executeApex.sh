echo "./executeApex.sh <sandbox> <path to script> <username> <password>"

sandbox=$1
executeCode=$2
username=$3
password=$4

if [ -z $sandbox ]; then
  read -p 'sandbox: ' sandbox
fi

if [ -z $executeCode ]; then
  read -p 'path to script: ' executeCode
fi

if [ -z $username ]; then
  read -p 'username: ' username
fi

if [[ -z $password  && -z $skipLogin ]]; then
  read -s -p 'password: ' password
  echo ''
fi

loginUrl=test.salesforce.com
loginUsername=$username.$sandbox

#if [ -z $skipLogin ]; then
#	./force login -i=$loginUrl -u=$loginUsername -p=$password
#fi

export SFDX_LOG_LEVEL=DEBUG
./force apex $executeCode