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
chmod +x scripts/deploy.sh

# apps config
for env in ${envs[*]} ; do
	echo $env css-$env-$serviceName-service- >> scripts/apps.config
done

echo 'echo "./deploy.sh <optional -b to build> <env> <optional version defaults v1>"' >> scripts/deploy.sh
echo '' >> scripts/deploy.sh
echo 'getopts b build' >> scripts/deploy.sh
echo 'shift "$((OPTIND-1))"' >> scripts/deploy.sh
echo 'env=$1' >> scripts/deploy.sh
echo 'version=$2' >> scripts/deploy.sh
echo '' >> scripts/deploy.sh
echo 'if [ -z $env ]; then' >> scripts/deploy.sh
echo '  read -p "env: " env' >> scripts/deploy.sh
echo 'fi' >> scripts/deploy.sh
echo '' >> scripts/deploy.sh
echo 'if [ -z $version ]; then' >> scripts/deploy.sh
echo '  version=v1' >> scripts/deploy.sh
echo 'fi' >> scripts/deploy.sh
echo '' >> scripts/deploy.sh
echo 'cd "${0%/*}"/..' >> scripts/deploy.sh
echo '' >> scripts/deploy.sh
echo 'appPrefix=$(grep "$env" scripts/apps.config | cut -f2 -d " ")' >> scripts/deploy.sh
echo 'if [ $build != ? ]; then' >> scripts/deploy.sh
echo '  echo "building"' >> scripts/deploy.sh
echo '  ./gradlew -Dhttp.proxyHost=10.132.40.23 -Dhttp.proxyPort=80 -Dhttps.proxyHost=10.132.40.23 -Dhttps.proxyPort=80 clean build' >> scripts/deploy.sh
echo 'fi' >> scripts/deploy.sh
echo 'export HTTPS_PROXY=http://10.132.40.23:80' >> scripts/deploy.sh
echo 'heroku deploy:jar build/libs/*.jar --app $appPrefix$version' >> scripts/deploy.sh