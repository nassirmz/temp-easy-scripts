echo './addAddonHerokuApps <service-name e.g. bus-hrs for css-dev-bus-hrs-service-v1> <addon name e.g. heroku-postgresql:hobby-dev>'

# input
serviceName=$1
addonName=$2
envs=(dev ma11 ra11 rs11 prod)

# prompt
if [ -z $serviceName ]; then
	read -p 'serviceName: ' serviceName
fi

if [ -z $addonName ]; then
	read -p 'addonName: ' addonName
fi

# add addons
for env in ${envs[*]} ; do
	appName=css-$env-$serviceName-service
	echo adding addon to app $appName
	heroku addons:create $addonName -a $appName
done