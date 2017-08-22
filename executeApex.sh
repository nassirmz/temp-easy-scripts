echo "./executeApex.sh <username> <password> <path to script> <Sandbox List>"

# get input
username=$1
password=$2
executeCode=$3
sandboxList=${@:4}

if [ -z $username ]; then
	read -p 'username: ' username
fi

if [ -z $password ]; then
	read -s -p 'password: ' password
	echo ''
fi

if [ -z $executeCode ]; then
	read -p 'path to script: ' executeCode
fi

if [ -z sandboxList ]; then
	read -p 'sandbox list: ' sandboxList
fi

# prepare
loginUrl=test.salesforce.com
export https_proxy=http://10.132.40.23:80
export http_proxy=http://10.132.40.23:80

for sandbox in $sandboxList; do
	(
		echo sandbox $sandbox
		# login
		loginUsername=$username.$sandbox
		./force login -i=$loginUrl -u=$loginUsername -p=$password
	
		# run script
		./force apex $executeCode | tee logs/$(basename $executeCode)-$sandbox.log
	) &
done