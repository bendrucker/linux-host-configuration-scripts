#!/bin/bash
END_OUTPUT="END_OF_OUTPUT"

cd ~ || exit && echo "$SPACER $END_OUTPUT $SPACER"

config_file_directory="$HOME/observe_config_files"

log ()
{
    echo "`date` $1" | sudo tee -a "/tmp/observe-install.log"
}

getConfigurationFiles(){
    local branch_replace="$1"
    local SPACER
    SPACER=$(generateSpacer)
    if [ ! -d "$config_file_directory" ]; then
      mkdir "$config_file_directory"
      log "$SPACER $config_file_directory CREATED $SPACER"
    else
      rm -f "${config_file_directory:?}"/*
      log "$SPACER"
      log "$config_file_directory DELETED"
      log "$SPACER"
      ls "$config_file_directory"
      log "$SPACER"
    fi

    if [ ! -f "$config_file_directory/osquery.conf" ]; then
      url="https://raw.githubusercontent.com/observeinc/linux-host-configuration-scripts/${branch_replace}/config_files/osquery.conf"
      filename="$config_file_directory/osquery.conf"

      log "$SPACER"
      log "filename = $filename"
      log "$SPACER"
      log "url = $url"
      curl "$url" > "$filename"

      log "$SPACER"
      log "$filename created"
      log "$SPACER"
    fi

    if [ ! -f "$config_file_directory/telegraf.conf" ]; then
      url="https://raw.githubusercontent.com/observeinc/linux-host-configuration-scripts/${branch_replace}/config_files/telegraf.conf"
      filename="$config_file_directory/telegraf.conf"

      log "$SPACER"
      log "filename = $filename"
      log "$SPACER"
      log "url = $url"
      curl "$url" > "$filename"

      log "$SPACER"
      log "$filename created"
      log "$SPACER"
    fi

    if [ ! -f "$config_file_directory/td-agent-bit.conf" ]; then
      url="https://raw.githubusercontent.com/observeinc/linux-host-configuration-scripts/${branch_replace}/config_files/td-agent-bit.conf"
      filename="$config_file_directory/td-agent-bit.conf"

      log "$SPACER"
      log "filename = $filename"
      log "$SPACER"
      log "url = $url"
      curl "$url" > "$filename"

      log "$SPACER"
      log "$filename created"
      log "$SPACER"
    fi

    if [ ! -f "$config_file_directory/observe-linux-host.conf" ]; then
      url="https://raw.githubusercontent.com/observeinc/linux-host-configuration-scripts/${branch_replace}/config_files/observe-linux-host.conf"
      filename="$config_file_directory/observe-linux-host.conf"

      log "$SPACER"
      log "filename = $filename"
      log "$SPACER"
      log "url = $url"
      curl "$url" > "$filename"

      log "$SPACER"
      log "$filename created"
      log "$SPACER"
    fi

    if [ ! -f "$config_file_directory/observe-jenkins.conf" ]; then
      url="https://raw.githubusercontent.com/observeinc/linux-host-configuration-scripts/${branch_replace}/config_files/observe-jenkins.conf"
      filename="$config_file_directory/observe-jenkins.conf"

      log "$SPACER"
      log "filename = $filename"
      log "$SPACER"
      log "url = $url"
      curl "$url" > "$filename"

      log "$SPACER"
      log "$filename created"
      log "$SPACER"
    fi

    if [ ! -f "$config_file_directory/osquery.flags" ]; then
      url="https://raw.githubusercontent.com/observeinc/linux-host-configuration-scripts/${branch_replace}/config_files/osquery.flags"
      filename="$config_file_directory/osquery.flags"

      log "$SPACER"
      log "filename = $filename"
      log "$SPACER"
      log "url = $url"
      curl "$url" > "$filename"

      log "$SPACER"
      log "$filename created"
      log "$SPACER"
    fi

    if [ ! -f "$config_file_directory/observe-installer.conf" ]; then
      url="https://raw.githubusercontent.com/observeinc/linux-host-configuration-scripts/${branch_replace}/config_files/observe-installer.conf"
      filename="$config_file_directory/observe-installer.conf"

      log "$SPACER"
      log "filename = $filename"
      log "$SPACER"
      log "url = $url"
      curl "$url" > "$filename"

      log "$SPACER"
      log "$filename created"
      log "$SPACER"
    fi
}

generateTestKey(){
  echo "${OBSERVE_TEST_RUN_KEY}"
}

if [ -f /etc/os-release ]; then
    #shellcheck disable=SC1091
    . /etc/os-release

    OS=$( echo "${ID}" | tr '[:upper:]' '[:lower:]')
    CODENAME=$( echo "${VERSION_CODENAME}" | tr '[:upper:]' '[:lower:]')
elif lsb_release &>/dev/null; then
    OS=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
    CODENAME=$(lsb_release -cs)
else
    OS=$(uname -s)
fi

# used for terminal output
generateSpacer(){
  echo "###########################################"
}

curlObserve(){
  local message="$1"
  local path_suffix="$2"
  local result="$3"

  curl https://"${OBSERVE_ENVIRONMENT}"/v1/http/script_validation/"${path_suffix}" \
  -H "Authorization: Bearer ${ingest_token}" \
  -H "Content-type: application/json" \
  -d "{\"data\": {\"datacenter\": \"${DEFAULT_OBSERVE_DATA_CENTER}\", \"host\": \"${DEFAULT_OBSERVE_HOSTNAME}\",\"result\": \"${result}\",\"message\": \"${message}\", \"os\": \"${TERRAFORM_REPLACE_OS_VALUE}\" }}"

}

printHelp(){
      log "$SPACER"
      log "## HELP CONTENT"
      log "$SPACER"
      log "### Required inputs"
      log "- Required --customer_id YOUR_OBSERVE_CUSTOMERID "
      log "- Required --ingest_token YOUR_OBSERVE_DATA_STREAM_TOKEN "
      log "## Optional inputs"
      log "- Optional --observe_host_name - Defaults to https://<YOUR_OBSERVE_CUSTOMERID>.collect.observeinc.com/ "
      log "- Optional --config_files_clean TRUE or FALSE - Defaults to FALSE "
      log "    - controls whether to delete created config_files temp directory"
      log "- Optional --ec2metadata TRUE or FALSE - Defaults to FALSE "
      log "    - controls fluentbit config for whether to use default ec2 metrics "
      log "- Optional --datacenter defaults to AWS"
      log "- Optional --appgroup id supplied sets value in fluentbit config"
      log "- Optional --branch_input branch of repository to pull scrips and config files from -Defaults to main"
      log "- Optional --validate_endpoint of observe_hostname using customer_id and ingest_token -Defaults to TRUE"
      log "- Optional --module to use for installs -Defaults to linux_host which installs osquery, fluentbit and telegraf"
      log "    can be combined with jenkins flag which add a config to fluentbit or only jenkons flag which only installs fluent bit with configs"
      log "- Optional --observe_jenkins_path used in combination with jenkins module - location of jenkins logs"
      log "- Optional --custom_fluentbit_config add an additional configuration file for fluentbit"
      log "***************************"
      log "### Sample command:"
      log "\`\`\` curl https://raw.githubusercontent.com/observeinc/linux-host-configuration-scripts/main/observe_configure_script.sh  | bash -s -- --customer_id YOUR_CUSTOMERID --ingest_token YOUR_DATA_STREAM_TOKEN --observe_host_name https://<YOUR_CUSTOMERID>.collect.observeinc.com/ --config_files_clean TRUE --ec2metadata TRUE --datacenter MY_DATA_CENTER --appgroup MY_APP_GROUP\`\`\`"
      log "***************************"
}

requiredInputs(){
      log "$SPACER"
      log "* Error: Invalid argument.*"
      log "$SPACER"
      printVariables
      printHelp
      log "$SPACER"
      log "$END_OUTPUT"
      log "$SPACER"
      exit 1

}

printVariables(){
      log "$SPACER"
      log "* VARIABLES *"
      log "$SPACER"
      log "customer_id: $customer_id"
      log "ingest_token: $ingest_token"
      log "observe_host_name: $observe_host_name"
      log "config_files_clean: $config_files_clean"
      log "ec2metadata: $ec2metadata"
      log "datacenter: $datacenter"
      log "appgroup: $appgroup"
      log "testeject: $testeject"
      log "validate_endpoint: $validate_endpoint"
      log "branch_input: $branch_input"
      log "module: $module"
      log "observe_jenkins_path: ${observe_jenkins_path}"
      log "$SPACER"
}

testEject(){
local bail="$1"
local bailPosition="$2"
if [[ "$bail" == "$bailPosition" ]]; then
    log "$SPACER"
    log "$SPACER"
    log " TEST EJECTION "
    log "Position = $bailPosition"
    log "$SPACER"
    log "$END_OUTPUT"
    log "$SPACER"
    log "$SPACER"
    exit 0;
fi
}

removeConfigDirectory() {
      rm -f -R "$config_file_directory"
}

validateObserveHostName () {
  local url="$1"
  # check for properly formatted url input - assumes - https://<customer-id>.collect.observe[anything]/
  # we can modify this rule to be specific as needed
  regex='^(https?)://[0-9]+.collect.observe[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*\/'


  if [[ $url =~ $regex ]]
  then
      log "$SPACER"
      log "$url IS valid"
      log "$SPACER"
  else
      log "$SPACER"
      log "$url IS NOT valid - example valid input - https://123456789012.collect.observeinc.com/"
      log "$SPACER"
      exit 1
  fi
}

includeFiletdAgent(){
  # Process modules
  IFS=',' read -a CONFS <<< "$module"
  for i in "${CONFS[@]}"; do
        log "includeFiletdAgent - $i"

        sudo cp "$config_file_directory/observe-installer.conf" /etc/td-agent-bit/observe-installer.conf;

        case ${i} in
            linux_host)
              sudo cp "$config_file_directory/observe-linux-host.conf" /etc/td-agent-bit/observe-linux-host.conf;
              ;;
            jenkins)
              sudo cp "$config_file_directory/observe-jenkins.conf" /etc/td-agent-bit/observe-jenkins.conf;
              ;;
            *)
              log "includeFiletdAgent function failed - i = $i"
              log "$SPACER"
              log "$END_OUTPUT"
              log "$SPACER"
              exit 1;
              ;;
        esac
  done

  #install custome config if exists
  if ! [ -z ${custom_fluentbit_config}]
  then
    sudo cp ${custom_fluentbit_config} /etc/td-agent-bit/observe-custom-config.conf
  fi
}

setInstallFlags(){
  # Process modules
  log "$SPACER"
  log "setInstallFlags - module=$module"
  log "$SPACER"

  IFS=',' read -a CONFS <<< "$module"
  for i in "${CONFS[@]}"; do
        log "setInstallFlags - $i"

        case ${i} in
            linux_host)
            log "setInstallFlags linux_host flags"
              osqueryinstall="TRUE"
              telegrafinstall="TRUE"
              fluentbitinstall="TRUE"
              ;;
            jenkins)
              fluentbitinstall="TRUE"
              ;;
            *)
              log "setInstallFlags function failed - i = $i"
              log "$SPACER"
              log "$END_OUTPUT"
              log "$SPACER"
              exit 1;
              ;;
        esac
  done
}

printMessage(){
  local message="$1"
  log
  log "$SPACER"
  log "$message"
  log "$SPACER"
  log
}

SPACER=$(generateSpacer)

log "$SPACER"
log "Script starting ..."

log "$SPACER"
log "Validate inputs ..."

customer_id=0
ingest_token=0
observe_host_name_base=
config_files_clean="FALSE"
ec2metadata="FALSE"
datacenter="AWS"
testeject="NO"
appgroup="UNSET"
branch_input="main"
validate_endpoint="TRUE"
module="linux_host"
osqueryinstall="FALSE"
telegrafinstall="FALSE"
fluentbitinstall="FALSE"
observe_jenkins_path="/var/lib/jenkins/"


if [ "$1" == "--help" ]; then
  printHelp
  log "$SPACER"
  log "$END_OUTPUT"
  log "$SPACER"
  exit 0
fi

if [ $# -lt 4 ]; then
  requiredInputs
fi

    # Parse inputs
    while [ $# -gt 0 ]; do
    echo "required inputs $1 $2 $# "
      case "$1" in
        --customer_id)
          customer_id="$2"
          ;;
        --ingest_token)
          ingest_token="$2"
          ;;
        --observe_host_name)
          observe_host_name_base="$2"
          ;;
        --config_files_clean)
          config_files_clean="$2"
          ;;
        --ec2metadata)
          ec2metadata="$2"
          ;;
        --datacenter)
          datacenter="$2"
          ;;
        --appgroup)
          appgroup="$2"
          ;;
        --testeject)
          testeject="$2"
          ;;
        --branch_input)
          branch_input="$2"
          ;;
        --module)
          module="$2"
          ;;
        --validate_endpoint)
          validate_endpoint="$2"
          ;;
        --observe_jenkins_path)
          observe_jenkins_path="$2"
          ;;
        --custom_fluentbit_config)
          custom_fluentbit_config="$2"
          ;;
        *)

      esac
      shift
      shift
    done

    if [ "$customer_id" == 0 ] || [ "$ingest_token" == 0 ]; then
      requiredInputs
    fi

# Custruct the per-customer-id ingest host name.
if [ -z "$observe_host_name_base" ]; then
  observe_host_name_base="https://${customer_id}.collect.observeinc.com/"
fi

validateObserveHostName "$observe_host_name_base"

observe_host_name=$(echo "$observe_host_name_base" | sed -e 's|^[^/]*//||' -e 's|/.*$||')

log "$SPACER"
log "customer_id: ${customer_id}"
log "ingest_token: ${ingest_token}"
log "observe_host_name_base: ${observe_host_name_base}"
log "observe_host_name: ${observe_host_name}"
log "config_files_clean: ${config_files_clean}"
log "ec2metadata: ${ec2metadata}"
log "datacenter: ${datacenter}"
log "appgroup: ${appgroup}"
log "testeject: ${testeject}"
log "validate_endpoint: ${validate_endpoint}"
log "branch_input: ${branch_input}"
log "module: ${module}"
log "observe_jenkins_path: ${observe_jenkins_path}"
log "custom_fluentbit_config: ${custom_fluentbit_config}"

setInstallFlags

printMessage "osqueryinstall = $osqueryinstall"
printMessage "telegrafinstall = $telegrafinstall"
printMessage "fluentbitinstall = $fluentbitinstall"


OBSERVE_ENVIRONMENT="$observe_host_name"

DEFAULT_OBSERVE_HOSTNAME="${HOSTNAME}"

DEFAULT_OBSERVE_DATA_CENTER="$datacenter"

if [ "$validate_endpoint" == TRUE ]; then

    log "$SPACER"
    log "Validate customer_id / ingest token ..."
    log "$SPACER"
    log

    curl_endpoint=$(curl https://"${OBSERVE_ENVIRONMENT}"/v1/http/script_validation \
    -H "Authorization: Bearer ${ingest_token}" \
    -H "Content-type: application/json" \
    -d "{\"data\": {  \"datacenter\": \"${DEFAULT_OBSERVE_DATA_CENTER}\",\"host\": \"${DEFAULT_OBSERVE_HOSTNAME}\",\"message\": \"validating customer id and token\", \"os\": \"${TERRAFORM_REPLACE_OS_VALUE}\", \"result\": \"SUCCESS\",  \"script_run\": \"${DEFAULT_OBSERVE_DATA_CENTER}\" ,  \"OBSERVE_TEST_RUN_KEY\": \"${OBSERVE_TEST_RUN_KEY}\"}}")

    validate_endpoint_result=$(echo "$curl_endpoint" | grep -c -Po '(?<="ok":)(true)')

    if ((validate_endpoint_result != 1 )); then
        log "$SPACER"
        log "Invalid value for customer_id or ingest_token"
        log "$curl_endpoint"
        log "$SPACER"
        log "$END_OUTPUT"
        log "$SPACER"
        exit 1
    else
        log "$SPACER"
        log "Successfully validated customer_id and ingest_token"
    fi

    log

fi

log "$SPACER"
log "Values for configuration:"
log "$SPACER"
log "    Environment:  $OBSERVE_ENVIRONMENT"
log
log "    Data Center:  $DEFAULT_OBSERVE_DATA_CENTER"
log
log "    Hostname:  $DEFAULT_OBSERVE_HOSTNAME"
log
log "    Customer ID:  $customer_id"
log
log "    Customer Ingest Token:  $ingest_token"

testEject "${testeject}" "EJECT1"

log "$SPACER"

getConfigurationFiles "$branch_input"

log "$SPACER"

cd "$config_file_directory" || (exit && log "$SPACER CONFIG FILE DIRECTORY PROBLEM - $(pwd) - $config_file_directory - $END_OUTPUT $SPACER")

sed -i "s/REPLACE_WITH_DATACENTER/${DEFAULT_OBSERVE_DATA_CENTER}/g" ./*

sed -i "s/REPLACE_WITH_HOSTNAME/${DEFAULT_OBSERVE_HOSTNAME}/g" ./*

sed -i "s/REPLACE_WITH_CUSTOMER_INGEST_TOKEN/${ingest_token}/g" ./*

sed -i "s/REPLACE_WITH_OBSERVE_ENVIRONMENT/${OBSERVE_ENVIRONMENT}/g" ./*

sed -i "s:REPLACE_WITH_OBSERVE_JENKINS_PATH:${observe_jenkins_path}:g" ./*

if [ "$ec2metadata" == TRUE ]; then
    sed -i "s/#REPLACE_WITH_OBSERVE_EC2_OPTION//g" ./*
fi

if [ "$appgroup" != UNSET ]; then
    sed -i "s/#REPLACE_WITH_OBSERVE_APP_GROUP_OPTION/Record appgroup ${appgroup}/g" ./*
fi

testEject "${testeject}" "EJECT2"

# https://docs.observeinc.com/en/latest/content/integrations/linux/linux.html



#####################################
# BASELINEINSTALL - START
#####################################

case ${OS} in
    amzn|amazonlinux)

    log "Amazon OS"

      #####################################
      # osquery
      #####################################
      if [ "$osqueryinstall" == TRUE ]; then

        printMessage "osquery"

        curl -L https://pkg.osquery.io/rpm/GPG | sudo tee /etc/pki/rpm-gpg/RPM-GPG-KEY-osquery

        sudo yum-config-manager --add-repo https://pkg.osquery.io/rpm/osquery-s3-rpm.repo
        sudo yum-config-manager --enable osquery-s3-rpm-repo
        sudo yum install osquery -y
        sudo service osqueryd start 2>/dev/null || true
        sudo systemctl enable osqueryd

        # ################
        sourcefilename=$config_file_directory/osquery.conf
        filename=/etc/osquery/osquery.conf


        osquery_conf_filename=/etc/osquery/osquery.conf

        if [ -f "$filename" ]
        then
            sudo mv "$filename"  "$filename".OLD
        fi

        sudo cp "$sourcefilename" "$filename"

        sourcefilename=$config_file_directory/osquery.flags
        filename=/etc/osquery/osquery.flags
        osquery_flags_filename=/etc/osquery/osquery.flags

        if [ -f "$filename" ]
        then
            sudo mv "$filename"  "$filename".OLD
        fi

        sudo cp "$sourcefilename" "$filename"

        sudo service osqueryd restart

      fi
      # #####################################
      # # fluent
      # #####################################
      if [ "$fluentbitinstall" == TRUE ]; then

      printMessage "fluent"

sudo tee /etc/yum.repos.d/td-agent-bit.repo > /dev/null << EOT
[td-agent-bit]
name = TD Agent Bit
baseurl = https://packages.fluentbit.io/amazonlinux/2/\$basearch/
gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
enabled=1
EOT

      sudo yum install td-agent-bit -y

      sourcefilename=$config_file_directory/td-agent-bit.conf
      filename=/etc/td-agent-bit/td-agent-bit.conf

      td_agent_bit_filename=/etc/td-agent-bit/td-agent-bit.conf



      if [ -f "$filename" ]
      then
          sudo mv "$filename"  "$filename".OLD
      fi

      sudo cp "$sourcefilename" "$filename"

      includeFiletdAgent

      sudo service td-agent-bit restart
      sudo systemctl enable td-agent-bit

    fi
      # #####################################
      # # telegraf
      # #####################################
      if [ "$telegrafinstall" == TRUE ]; then

      printMessage "telegraf"

sudo tee /etc/yum.repos.d/influxdb.repo > /dev/null << EOT
[influxdb]
name = InfluxDB Repository - RHEL
baseurl = https://repos.influxdata.com/rhel/7/\$basearch/stable/
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOT

      sudo yum install telegraf -y

      sourcefilename=$config_file_directory/telegraf.conf
      filename=/etc/telegraf/telegraf.conf

      telegraf_conf_filename=/etc/telegraf/telegraf.conf

      if [ -f "$filename" ]
      then
          sudo mv "$filename"  "$filename".OLD
      fi

      sudo cp "$sourcefilename" "$filename"

      sudo service telegraf restart

    fi
      ################################################################################################
      ################################################################################################
          ;;

   ################################################################################################
    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
   ################################################################################################
    # rhel|centos
    #####################################
    #####################################
    rhel|centos)
      log "RHEL OS"
      #####################################
      # osquery
      #####################################
      if [ "$osqueryinstall" == TRUE ]; then
        printMessage "osquery"

        sudo yum install yum-utils -y

        curl -L https://pkg.osquery.io/rpm/GPG | sudo tee /etc/pki/rpm-gpg/RPM-GPG-KEY-osquery

        sudo yum-config-manager --add-repo https://pkg.osquery.io/rpm/osquery-s3-rpm.repo

        sudo yum-config-manager --enable osquery-s3-rpm-repo

        sudo yum install osquery -y


        # ################
        sourcefilename=$config_file_directory/osquery.conf
        filename=/etc/osquery/osquery.conf

        osquery_conf_filename=/etc/osquery/osquery.conf

        if [ -f "$filename" ]
        then
            sudo mv "$filename"  "$filename".OLD
        fi

        sudo cp "$sourcefilename" "$filename"

        sourcefilename=$config_file_directory/osquery.flags
        filename=/etc/osquery/osquery.flags

        osquery_flags_filename=/etc/osquery/osquery.flags

        if [ -f "$filename" ]
        then
            sudo mv "$filename"  "$filename".OLD
        fi

        sudo cp "$sourcefilename" "$filename"

        sudo service osqueryd restart
        sudo systemctl enable osqueryd
    fi
      # #####################################
      # # fluent
      # #####################################
      if [ "$fluentbitinstall" == TRUE ]; then
      printMessage "fluent"

cat << EOF | sudo tee /etc/yum.repos.d/td-agent-bit.repo
[td-agent-bit]
name = TD Agent Bit
baseurl = https://packages.fluentbit.io/centos/\$releasever/\$basearch/
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
enabled=1
EOF

      sudo yum install td-agent-bit -y

      sudo service td-agent-bit start

      sourcefilename=$config_file_directory/td-agent-bit.conf
      filename=/etc/td-agent-bit/td-agent-bit.conf

      td_agent_bit_filename=/etc/td-agent-bit/td-agent-bit.conf

      if [ -f "$filename" ]
      then
          sudo mv "$filename"  "$filename".OLD
      fi

      sudo cp "$sourcefilename" "$filename"

      includeFiletdAgent

      sudo service td-agent-bit restart
      sudo systemctl enable td-agent-bit

    fi
      # #####################################
      # # telegraf
      # #####################################
      if [ "$telegrafinstall" == TRUE ]; then
      printMessage "telegraf"

cat << EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 0
gpgkey = https://repos.influxdata.com/influxdb.key
EOF

      sudo yum install telegraf -y

      sourcefilename=$config_file_directory/telegraf.conf
      filename=/etc/telegraf/telegraf.conf

      telegraf_conf_filename=/etc/telegraf/telegraf.conf

      if [ -f "$filename" ]
      then
          sudo mv "$filename"  "$filename".OLD
      fi

      sudo cp "$sourcefilename" "$filename"

      yum install ntp -y

      sudo service telegraf restart

    fi
      ################################################################################################
      ################################################################################################
          ;;

    ubuntu)
      log "UBUNTU OS"
      #####################################
      # osquery
      #####################################
      if [ "$osqueryinstall" == TRUE ]; then

      printMessage "osquery"

      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B

      if ! grep -Fq https://pkg.osquery.io/deb /etc/apt/sources.list.d/osquery.list
      then
sudo tee -a /etc/apt/sources.list.d/osquery.list > /dev/null << EOT
deb [arch=amd64] https://pkg.osquery.io/deb deb main
EOT
      fi

      sudo apt-get update
      sudo apt-get install -y osquery
      sudo service osqueryd start 2>/dev/null || true

      # ################
      sourcefilename=$config_file_directory/osquery.conf
      filename=/etc/osquery/osquery.conf

      osquery_conf_filename=/etc/osquery/osquery.conf

      if [ -f "$filename" ]
      then
          sudo mv "$filename"  "$filename".OLD
      fi

      sudo cp "$sourcefilename" "$filename"

      sourcefilename=$config_file_directory/osquery.flags
      filename=/etc/osquery/osquery.flags

      osquery_flags_filename=/etc/osquery/osquery.flags

      if [ -f "$filename" ]
      then
          sudo mv "$filename"  "$filename".OLD
      fi

      sudo cp "$sourcefilename" "$filename"

      sudo service osqueryd restart
      sudo systemctl enable osqueryd

      fi

      # #####################################
      # # fluent
      # #####################################
      if [ "$fluentbitinstall" == TRUE ]; then
      printMessage "fluent"

      wget -qO - https://packages.fluentbit.io/fluentbit.key | sudo apt-key add -

      echo deb https://packages.fluentbit.io/ubuntu/"${CODENAME}" "${CODENAME}" main | sudo tee -a /etc/apt/sources.list

      sudo apt-get update
      sudo apt-get install -y td-agent-bit
      sudo service td-agent-bit start

      sourcefilename=$config_file_directory/td-agent-bit.conf
      filename=/etc/td-agent-bit/td-agent-bit.conf

      td_agent_bit_filename=/etc/td-agent-bit/td-agent-bit.conf

      if [ -f "$filename" ]
      then
          sudo mv "$filename"  "$filename".OLD
      fi

      sudo cp "$sourcefilename" "$filename"

      includeFiletdAgent

      sudo service td-agent-bit restart
      sudo systemctl enable td-agent-bit

    fi
      # #####################################
      # # telegraf
      # #####################################
      if [ "$telegrafinstall" == TRUE ]; then
      printMessage "telegraf"

      wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
          #shellcheck disable=SC1091
      source /etc/lsb-release
      if ! grep -Fq https://repos.influxdata.com/"${DISTRIB_ID,,}" /etc/apt/sources.list.d/influxdb.list
      then
sudo tee -a /etc/apt/sources.list.d/influxdb.list > /dev/null << EOT
deb https://repos.influxdata.com/"${DISTRIB_ID,,}" "${DISTRIB_CODENAME}" stable
EOT
      fi

      sudo apt-get update
      sudo apt-get install -y telegraf
      sudo apt-get install -y ntp

      sourcefilename=$config_file_directory/telegraf.conf
      filename=/etc/telegraf/telegraf.conf

      telegraf_conf_filename=/etc/telegraf/telegraf.conf

      if [ -f "$filename" ]
      then
          sudo mv "$filename"  "$filename".OLD
      fi

      sudo cp "$sourcefilename" "$filename"

      sudo service telegraf restart

      fi
          ;;
      ################################################################################################
      ################################################################################################
    *)
        log "Unknown OS"
        log "$SPACER"
        log "$END_OUTPUT"
        log "$SPACER"
        exit 1;
          ;;
  esac


if [ "$fluentbitinstall" == TRUE ]; then
  log "$SPACER"
  log "Check Services"
  log "$SPACER"
  log
  log "$SPACER"
  log "td-agent-bit status"

  if systemctl is-active --quiet td-agent-bit; then
    log td-agent-bit is running

    curlObserve "td-agent-bit is running" "td-agent-bit" "SUCCESS"

  else
    log td-agent-bit is NOT running

    curlObserve "td-agent-bit is NOT running" "td-agent-bit" "FAILURE"

    sudo service td-agent-bit status
  fi




  log "$SPACER"
  log "Check status - sudo service td-agent-bit status"
  log "Config file location: ${td_agent_bit_filename}"
  log

fi
log "$SPACER"

if [ "$osqueryinstall" == TRUE ]; then
  log "osqueryd status"

  if systemctl is-active --quiet osqueryd; then
    log osqueryd is running

  curlObserve "osqueryd is running" "osqueryd" "SUCCESS"

  else
    log osqueryd is NOT running

    curlObserve "osqueryd is NOT running" "osqueryd" "FAILURE"

    sudo service osqueryd status
  fi
  log "$SPACER"
  log "Check status - sudo service osqueryd status"

  log "Config file location: ${osquery_conf_filename}"

  log "Flag file location: ${osquery_flags_filename}"
  log

fi

if [ "$telegrafinstall" == TRUE ]; then
    log "$SPACER"
    log "telegraf status"

    if systemctl is-active --quiet telegraf; then
      log telegraf is running

      curlObserve "telegraf is running" "telegraf" "SUCCESS"

    else
      log telegraf is NOT running

      curlObserve "telegraf is NOT running" "telegraf" "FAILURE"

      sudo service telegraf status
    fi
    log "$SPACER"
    log "Check status - sudo service telegraf status"

    log "Config file location: ${telegraf_conf_filename}"
    log
    log "$SPACER"
    log
    log "$SPACER"
    log "Datacenter value:  ${DEFAULT_OBSERVE_DATA_CENTER}"
fi

if [ "$config_files_clean" == TRUE ]; then
  removeConfigDirectory
fi


#####################################
# BASELINEINSTALL - END
#####################################

log "$SPACER"
log "$END_OUTPUT"
log "$SPACER"
