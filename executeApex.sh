echo "./executeApex.sh <username> <sandbox> <file path of script to execute> [<skip login>]"

username=$1
sandbox=$2
executeCode=$3
skipLogin=$4

if [ -z $username ]; then
  read -p 'username: ' username
fi

if [[ -z $password  && -z $skipLogin ]]; then
  read -s -p 'password: ' password
  echo ''
fi

if [ -z $sandbox ]; then
  read -p 'sandbox: ' sandbox
fi

if [ -z $executeCode ]; then
  read -p 'file path of script to execute: ' executeCode
fi

loginUrl=test.salesforce.com
loginUsername=$username.$sandbox

if [ -z $skipLogin ]; then
	./force login -i=$loginUrl -u=$loginUsername -p=$password
fi
./force apex $executeCode