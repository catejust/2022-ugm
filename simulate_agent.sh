#!/bin/bash

# Make this script stop running if any command exits incorrectly (i.e. with exit code 1)
set -e

# Detect whether jq is installed or not, error if not
JQ=$( which jq )
[[ -z $JQ ]] && echo "Sorry you don't have jq installed, please apt-get install jq before continuing" && exit 1


# Default values -- typically use these when running this script via cron
server="server.company.com"
authToken="sdlkjasdlfkjsd"
clientID="test-id"
clientSecret="client_secret"
username="user@domain"
password="my_password"
domainRegisteredEndpoints=""


# Allowed input flags to override default values
# -h	API server host to interact with
# -t	Auth token if you already have one
# -i	API client ID to use
# -s	API client secret
# -u	Subscriber username
# -p	Subscriber password

while getopts :h:t:i:s:u:p: option
do
        case "${option}" in
        	h)	server=${OPTARG};;
        	t)	authToken=${OPTARG};;
        	i)	clientID=${OPTARG};;
        	s)	clientSecret=${OPTARG};;
        	u)	username=${OPTARG};;
        	p)	password=${OPTARG};;
        	\?)	echo -e "\nUm -$OPTARG ? No, that's not a valid option... \n" && exit 1 ;;
        	:)	echo -e "\nOption -$OPTARG requires an argument.\n" && exit 1 ;;
        esac
done
# we've processed input flags, now continue processing regular input arguments
shift $(( OPTIND - 1 ))


# What action to perform, Login, Logout, Lunch, etc
mainAction=$1

# On which group to perform the action.
# Groups are like shifts.. Jerry's in first shift, Matillo's in second shift
agentGroup=$2

# If mainAction or agentGroup aren't haven't yet been set
[ -z $mainAction ] || [ -z $agentGroup ] && echo -e "\nThe mainAction or agentGroup weren't supplied\n" && exit 1

declare -A first_names=([314]='Dorothée' [315]='Michael' [316]='Kristina' [317]='Margô' [318]='Wanda' [319]='Justin' [320]='Lisandro' [321]='Jose Angel' [322]='Christopher' [323]='Julie' [324]='Jeanne' [325]='Chantal' [326]='Fabiola' [327]='Donato' [328]='Mathieu' [329]='Robert' [330]='Ryan' [331]='Michaël' [332]='Stephen' [333]='Brian' [334]='Gilbert' [335]='Maria' [336]='Cebriœn' [337]='Timothé' [338]='Joaquím' [339]='Jonathan' [340]='Kevin' [341]='Evaristo' [342]='Adelina' [343]='Deanna' [344]='Anthony' [345]='Matthew' [346]='Jeanne' [347]='John' [348]='Fausto' [349]='Ale' [350]='Lupita' [351]='Fabiana' [352]='Lori' [353]='Emilio' [354]='Claude' [355]='Jill' [356]='Juliette' [357]='Abel' [358]='Cintia' [359]='Yolanda' [360]='Sergio' [370]='Mamta' [380]='Justin' [390]='James' [500]='Main' [6969]='Braedan' [8000]='Sales' [8001]='Support' [8003]='Marketing' [8004]='Accounting' [900]='Park' [901]='Park')

declare -A last_names=([314]='Chalamet' [315]='Hampton' [316]='Provencher' [317]='Johnson' [318]='Andrews' [319]='Fortier' [320]='Perković' [321]='Fojtíková' [322]='Johnson' [323]='Page' [324]='Buck' [325]='Potvin' [326]='Jara' [327]='Edwards' [328]='St-Laurent' [329]='Beaulieu' [330]='Lobo' [331]='Ferrero Rocher' [332]='Walters' [333]='Laflamme' [334]='Sullivan' [335]='Allard' [336]='Chandler' [337]='Sparks' [338]='Sigmarsdóttir' [339]='Brown' [340]='Mata' [341]='Silva Lima' [342]='Gonzales' [343]='Smith' [344]='Hardin' [345]='Medina' [346]='Pace' [347]='Fry' [348]='Raymond' [349]='Cavalcanti' [350]='Harvey' [351]='Roberts' [352]='Watson' [353]='Allard' [354]='Howell' [355]='Holden' [356]='Larouche' [357]='Boisvert' [358]='Perron' [359]='Mur' [360]='Paquette' [370]='Super' [380]='Super' [390]='Weatherson' [500]='Conference' [6969]='Shigley')

debug=1

#List of domains whose agents we'll be modifying
domain_list="test2 argirov regtest2 hkhella"

#List of which agents are in which group
test2_group1="202 216 220 228 235 240 252 256 260 266 270 274 278 312 316 320 324 330 334 338 327"
test2_group2="204 217 222 229 236 241 253 257 261 267 271 275 279 313 317 321 325 331 335 339 328"
test2_group3="214 218 226 230 237 242 254 258 262 268 272 276 280 314 318 322 326 332 336 340"
test2_group4="215 219 227 234 238 243 255 259 263 269 273 277 281 315 319 323 329 333 337 341"

argirov_group1="101 107 111 115 119 130"
argirov_group2="104 108 112 116 120 200"
argirov_group3="104wp 109 113 117 121"
argirov_group4="105 110 114 118 129"

regtest2_group1="200 204 210 402"
regtest2_group2="201 205 212 403"
regtest2_group3="202 206 297 404"
regtest2_group4="203 208 401"

hkhella_group1="1300 1304"
hkhella_group2="1301 1305"
hkhella_group3="1302 1306"
hkhella_group4="1303 1307"


# Check whether we already have an auth token
if [ -f /tmp/authToken ]; then
        echo -e "\nLooks like we have an auth token stored, we'll try to use it"
        authToken=$( < /tmp/authToken )
	echo "We'll try the auth token $authToken"
fi




# Function just to break out the curl functionality from updateDomainGroups to allow for proper handling of HTTP 401s
function curlForDomainGroups () {
	curlReply=$( curl -sw '\n%{http_code}' -k https://$server/ns-api/ -dclient_id=$clientID -H "Authorization: Bearer $authToken"  -dobject=agent -daction=read -ddomain=$1 -dqueue="*" -dformat=json )
        rCode=$( echo "$curlReply" | tail -n1 )
        if [ $rCode == 401 ]; then
		dOoAuth
		curlForDomainGroups $1
	elif [[ $rCode -ne 200 && $rCode -ne 202 ]]; then
		echo -e "\n\n`date +%Y%m%d\ %H:%M:%S` HTTP $rCode -- something's gone terribly wrong\n" && exit 1
	fi
	domainRegisteredEndpoints=$( echo "$curlReply" | head -n1 )
}




# Called at the beginning of this script, checks which agent devices are registered then filters the domain groups to only registered devices
# Better simulates the real world since the portal won't allow agents to change status without a registered device
# Prevents a bug where old code (portal 1226) would show agents online despite not having a registered device
function updateDomainGroups () {
	for domain in $domain_list; do
		domainRegisteredEndpoints=""
		curlForDomainGroups $domain
		domainEndpoints=$( echo "$domainRegisteredEndpoints" | jq -r '.[] | select(.["entry_device"]=="reg") | .device' | uniq )
		domainGroup=$( echo "$domain""_group""$agentGroup" )

		eval newGroup=\$$domainGroup
		newGroupList=""
		for device in $newGroup; do
			grepResult=$( echo $domainEndpoints | grep -o $device ) || true
			[[ -n $grepResult ]] && newGroupList+="$grepResult "
		done
		eval "$domainGroup=\$newGroupList"
		eval echo "`date +%Y%m%d\ %H:%M:%S` Updated $domainGroup to \$$domainGroup" >> /var/log/agents.log

	done
}




# parameters:
# $1 - mode
### Login/Break/Meeting/Lunch
# $2 - action
### normally Create
# $3 - user
### user@domain
# $4 - domain


function agentLog() {
	rCode=$( curl -sw %{response_code} -X POST https://$server/ns-api/ -m 300 -dclient_id=$clientID -H "Authorization: Bearer $authToken" -dobject="agentlog" -dmode=$1 -daction=$2 -did=$3@$4 -duid=$3@$4 -ddomain=$4 )
	[ ! -z $debug ] && echo "`date +%Y%m%d\ %H:%M:%S` $1 $3@$4" >> /var/log/agents.log
	if [ $rCode == 401 ]; then
		#echo -e "\n\n401 Unauthorized, let's get a new token\n"
		dOoAuth
		agentLog $1 $2 $3 $4 $5
	elif [[ $rCode -ne 200 && $rCode -ne 202 ]]; then
        echo -e "\n\n`date +%Y%m%d\ %H:%M:%S` HTTP $rCode -- something's gone terribly wrong\n" && exit 1
	fi
}


# parameters:
# $1 - domain
# $2 - user
# $3 - queue
# $4 - entry option
# $5 - entry action
# $6 - action (create / update )

function updateAgent() {
#	echo -e "\nupdateAgent $2@$1"
	[ -z $6 ] && action="update" || action=$6
	rCode=$( curl -sw %{response_code} -X POST -k https://$server/ns-api/ -dclient_id=$clientID -H "Authorization: Bearer $authToken" -dobject=agent -daction=$action -ddomain=$1 -dqueue="4321" -ddevice=sip:$2@$domain -dentry_option=$4 -dentry_action=$5 )
	[ ! -z $debug ] && echo "`date +%Y%m%d\ %H:%M:%S` $4 $2@$1" >> /var/log/agents.log
	if [ $rCode == 401 ]; then
		#echo -e "\n\n401 Unauthorized, let's get a new token\n"
		dOoAuth
		updateAgent $1 $2 $3 $4 $5
	elif [[ $rCode -ne 200 && $rCode -ne 202 ]]; then
        echo -e "\n\n`date +%Y%m%d\ %H:%M:%S` HTTP $rCode -- something's gone terribly wrong\n" && exit 1
	fi
}


# parameters:
# $1 - domain
# $2 - user
# $3 - message

function updateSubscriber() {
	rCode=$( curl -sw %{response_code} -X POST -k https://$server/ns-api/ -dclient_id=$clientID -H "Authorization: Bearer $authToken" -dobject="subscriber" -daction="update" -ddomain=$1 -duser=$2 --data-urlencode first_name=${first_names[$2]} --data-urlencode last_name=${last_names[$2]} -dmessage=$3 -dnoAuditLog="yes" )
	[ ! -z $debug ] && echo "`date +%Y%m%d\ %H:%M:%S` $3 subscriber $2@$1" >> /var/log/agents.log
	if [ $rCode == 401 ]; then
		#echo -e "\n\n401 Unauthorized, need to get a new access token\n" && exit 1
		echo -e "\n\n401 Unauthorized, let's get a new token\n"
		dOoAuth
		updateSubscriber $1 $2 $3
	elif [[ $rCode -ne 200 && $rCode -ne 202 ]]; then
        echo -e "\n\n`date +%Y%m%d\ %H:%M:%S` HTTP $rCode -- something's gone terribly wrong\n" && exit 1
	fi
}


# Not much to see here..
function dOoAuth () {
	oAuthReply=$( curl -vX POST -k https://$server/ns-api/oauth2/token -dgrant_type=password -dclient_id=$clientID -d client_secret=$clientSecret -dusername=$username --data-urlencode password="$password" )
	authToken=$( echo "$oAuthReply" | jq -r '.access_token')
	[[ ! -z $authToken ]] && echo $authToken > /tmp/authToken || echo "`date +%Y%m%d\ %H:%M:%S` unable to get authToken - oAuthReply was $oAuthReply" >> /var/log/agents.log
	refreshToken=$( echo $oAuthReply | cut -d":" -f6 | cut -d"\"" -f2 )
}



# where the magic happens

# log what action is being performed
echo "`date +%Y%m%d\ %H:%M:%S` $mainAction group $agentGroup" >> /var/log/agents.log

# update the domain groups to only perform actions on registered devices
updateDomainGroups

# run this code block once for each domain referenced in $domain_list
for domain in $domain_list; do
	# dynamically construct the variable name for the domain and group
	domainGroup=$( echo "$domain""_group""$agentGroup" )
	# indirectly reference the value of the domain group.. i.e. get its agents
	eval newGroup=\$$domainGroup

		case "$mainAction" in

		login) 	for i in $newGroup; do
					sleep $(((`date +%-S`*`date +%-S`+1)%90))
					agentLog Login create $i $domain
					updateAgent $domain $i notUsed immediate make_im
					agentLog Auto create $i $domain
					updateSubscriber "$domain" $i '<null>'
				done & ;;

		logout)	for i in $newGroup; do
					sleep $(((`date +%-S`*`date +%-S`+1)%90))
          				updateAgent $domain $i notUsed manual make_ma
					agentLog Manual create $i $domain
					updateSubscriber "$domain" $i '<null>'
					# cause agents whose extension is divisble by a random selection of 2,3,6, or 4
					# to "forget" to logout of the portal at the end of their shift
					[[ $((i %  $(((`date +%-S`*`date +%-S`+1)%7 + 1)) )) -eq 0 ]] && echo "`date +%Y%m%d\ %H:%M:%S` Agent $i@$domain forgot to logout" >> /var/log/agents.log || agentLog Logout create $i $domain
				done & ;;

    		unavailable) for i in $newGroup; do
       					sleep $(((`date +%-S`*`date +%-S`+1)%90))
        				updateAgent $domain $i notUsed manual make_ma
        				agentLog Manual create $i $domain
					updateSubscriber "$domain" $i 'Unavailable'
        			done & ;;

		break)	for i in $newGroup; do
					sleep $(((`date +%-S`*`date +%-S`+1)%90))
					agentLog Break create $i $domain
					updateAgent $domain $i notUsed manual make_ma
					updateSubscriber $domain $i Break
				done & ;;

		lunch)	for i in $newGroup; do
					sleep $(((`date +%-S`*`date +%-S`+1)%90))
					agentLog Lunch create $i $domain
					updateAgent $domain $i notUsed manual make_ma
					updateSubscriber $domain $i Lunch
				done & ;;

		web)	for i in $newGroup; do
					sleep $(((`date +%-S`*`date +%-S`+1)%90))
					agentLog Web create $i $domain
					updateAgent $domain $i notUsed manual make_ma
					updateSubscriber $domain $i Web
				done & ;;

		done)	for i in $newGroup; do
					sleep $(((`date +%-S`*`date +%-S`+1)%90))
					agentLog Auto create $i $domain
					#updateAgent $domain $i notUsed immediate make_im
					updateAgent $domain $i notUsed immediate make_im create
					updateSubscriber $domain $i '<null>'
				done & ;;
		esac
done
