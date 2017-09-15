echo './createHerokuApps <service-name e.g. bus-hrs for css-dev-bus-hrs-service-v1>'

# input
serviceName=$1
envs=(dev ma11 ra11 rs11 prod)

# prompt
if [ -z $serviceName ]; then
	read -p 'serviceName: ' serviceName
fi

# create apps
for env in ${envs[*]} ; do
	appName=css-$env-$serviceName-service
	echo creating app $appName
	heroku create -o farmersinsurance $appName
done