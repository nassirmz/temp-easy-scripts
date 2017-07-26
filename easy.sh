echo './easy.sh <css Y/B(build)/N> <sf Y/N> <sf-branch|commit> <env> <optional user> <optional password>'

source easy.config

baseCommit=$3
sandbox=$4
username=$5
password=$6

if [ -z $username ]; then
	username=manuk.hovanesian@farmersinsurance.com
fi

if [ -z $password ]; then
	read -s -p 'password: ' password
	echo ''
fi

if [[ $1 =~ ^[Yy]$ ]]
then
	pushd $cssDirectory/scripts
	./deploy.sh $username $password $sandbox &
	popd
fi

if [[ $1 =~ ^[Bb]$ ]]
then
	pushd $cssDirectory/scripts
	(grunt build; ./deploy.sh $username $password $sandbox) &
	popd
fi

if [[ $2 =~ ^[Yy]$ ]]
then
	pushd $sfDirectory/scripts
	(
		./find-dif.sh ${baseCommit}
		classes=$(cat classes-modified.txt)
		pages=$(cat pages-modified.txt)
		./create-package.sh "$classes" "$pages"
		./retrieve.sh $username $password $sandbox
		./deploy.sh $username $password $sandbox
	) &
	popd
fi

wait
echo DONE PUSHING CSS / SF