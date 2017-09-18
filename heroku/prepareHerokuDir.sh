echo './prepareHerokuDir.sh <service-name e.g. bus-hrs for css-dev-bus-hrs-service-v1> <dir> <optional origin> <optinal upstream>'

# input
serviceName=$1
dir=$2
origin=$3
upstream=$4
envs=(dev ma11 ra11 rs11 prod)

if [ -z $serviceName ]; then
  read -p 'serviceName: ' serviceName
fi
if [ -z $dir ]; then
	read -p 'dir: ' dir
fi

# init dir
if [ ! -d "$dir" ]; then
	echo $dir
	mkdir $dir
fi
cd $dir
git init

# origin
if [ $origin ]; then
	git remote add origin $origin
	git fetch origin
	git pull origin master
	echo 'origin set to' $origin
fi

# upstream
if [ $upstream ]; then
	echo 'upstream ' $upstream
	git remote add upstream $upstream
	git remote set-url  upstream no-push --push
	git fetch upstream
	echo 'upstream set to' $upstream
fi

# init script dir
rm -rf scripts
mkdir scripts
touch 'scripts/deploy.sh'
touch 'scripts/apps.config'
touch 'scripts/logs.sh'
chmod +x scripts/deploy.sh
chmod +x scripts/logs.sh

# apps config
for env in ${envs[*]} ; do
	echo $env css-$env-$serviceName-service >> scripts/apps.config
done

# deploy script
echo 'echo "./deploy.sh <optional -b to build> <env>"' >> scripts/deploy.sh
echo '' >> scripts/deploy.sh
echo '# input' >> scripts/deploy.sh
echo 'getopts b build' >> scripts/deploy.sh
echo 'shift "$((OPTIND-1))"' >> scripts/deploy.sh
echo 'env=$1' >> scripts/deploy.sh
echo '' >> scripts/deploy.sh
echo '# prompt input' >> scripts/deploy.sh
echo 'if [ -z $env ]; then' >> scripts/deploy.sh
echo '  read -p "env: " env' >> scripts/deploy.sh
echo 'fi' >> scripts/deploy.sh
echo '' >> scripts/deploy.sh
echo '# service directory' >> scripts/deploy.sh
echo 'cd "${0%/*}"/..' >> scripts/deploy.sh
echo '' >> scripts/deploy.sh
echo '# get app name' >> scripts/deploy.sh
echo 'appName=$(grep -i "$env" scripts/apps.properties | cut -f2 -d " ")' >> scripts/deploy.sh
echo '' >> scripts/deploy.sh
echo '# build' >> scripts/deploy.sh
echo 'if [ $build != ? ]; then' >> scripts/deploy.sh
echo '  echo "building"' >> scripts/deploy.sh
echo '  ./gradlew -Dhttp.proxyHost=10.132.40.23 -Dhttp.proxyPort=80 -Dhttps.proxyHost=10.132.40.23 -Dhttps.proxyPort=80 clean build' >> scripts/deploy.sh
echo 'fi' >> scripts/deploy.sh
echo '' >> scripts/deploy.sh
echo '# deploy' >> scripts/deploy.sh
echo 'export HTTPS_PROXY=http://10.132.40.23:80' >> scripts/deploy.sh
echo 'heroku deploy:jar build/libs/*.jar --app $appName' >> scripts/deploy.sh

# logs script
echo 'echo "./logs.sh <env>"' >> scripts/logs.sh
echo '' >> scripts/logs.sh
echo '# input' >> scripts/logs.sh
echo 'env=$1' >> scripts/logs.sh
echo '' >> scripts/logs.sh
echo '# prompt input' >> scripts/logs.sh
echo 'if [ -z $env ]; then' >> scripts/logs.sh
echo '  read -p "env: " env' >> scripts/logs.sh
echo 'fi' >> scripts/logs.sh
echo '' >> scripts/logs.sh
echo '# service directory' >> scripts/logs.sh
echo 'cd "${0%/*}"/..' >> scripts/logs.sh
echo '' >> scripts/logs.sh
echo '# get app name' >> scripts/logs.sh
echo 'appName=$(grep -i "$env" scripts/apps.properties | cut -f2 -d " ")' >> scripts/logs.sh
echo '' >> scripts/logs.sh
echo '# view logs' >> scripts/logs.sh
echo 'https_proxy=http://10.132.40.23:80 http_proxy=http://10.132.40.23:80 heroku logs --tail --app $appName' >> scripts/logs.sh