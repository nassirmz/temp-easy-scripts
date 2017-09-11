echo './prepareHerokuDir.sh <service-name e.g. bus-hrs for css-dev-bus-hrs-service-v1> <dir> <optional origin> <optinal upstream>'

serviceName=$1
dir=$2
origin=$3
upstream=$4
envs=(dev ma11 ra11 rs11 prod)

echo serviceName $serviceName
echo dir $dir

if [ -z $serviceName ]; then
  read -p 'serviceName: ' serviceName
fi
if [ -z $dir ]; then
	read -p 'dir: ' dir
fi


if [ ! -d "$dir" ]; then
	echo $dir
	mkdir $dir
fi
cd $dir
git init

for env in ${envs[*]} ; do
	git remote add heroku-$env https://git.heroku.com/css-$env-$serviceName-service-v1.git
done

if [ $origin ]; then
	echo 'origin ' $origin
	git remote add origin $origin
	git fetch origin
	git pull origin master
fi

if [ $upstream ]; then
	echo 'upstream ' $upstream
	git remote add upstream $upstream
	git remote set-url  upstream no-push --push
	git fetch upstream
fi

echo 'done success'

mkdir scripts
touch 'scripts/deploy.sh'
chmod +x scripts/deploy.sh

echo 'echo "./deploy.sh <env>"' > scripts/deploy.sh
echo 'env=$1' >> scripts/deploy.sh
echo 'if [ -z $env ]; then' >> scripts/deploy.sh
echo '  read -p 'env: ' env' >> scripts/deploy.sh
echo 'fi' >> scripts/deploy.sh
echo 'cd "${0%/*}"/..' >> scripts/deploy.sh
echo './gradlew clean build' >> scripts/deploy.sh
echo 'heroku deploy:jar build/libs/*.jar --remote heroku-$env' >> scripts/deploy.sh