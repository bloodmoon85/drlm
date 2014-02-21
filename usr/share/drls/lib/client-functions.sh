# file with default client functions to implement.
# $CLIDB is the defaul.conf variable of Client file

function exist_client_id () {
  local CLI_ID=$1
  grep -w $CLI_ID $CLIDB|awk -F":" '{print $1}'|grep $CLI_ID &> /dev/null
  if [ $? == 0 ];then return 0; else return 1; fi
  
# Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
}

function exist_client_name(){
  local CLI_NAME=$1
  grep -w $CLI_NAME $CLIDB|awk -F":" '{print $2}'|grep $CLI_NAME &> /dev/null
  if [ $? == 0 ];then return 0; else return 1; fi

# Check if parameter $1 is ok and if exists client with this name in database. Return 0 for ok , return 1 not ok.
}

function get_cient_id_by_name(){
  local CLI_NAME=$1
# Check if parameter $1 is ok
  grep -w $CLI_NAME $CLIDB|awk -F":" '{print $2}'|grep $CLI_NAME &> /dev/null 
  if [ $? == 0 ]
  then 
	# Get client id from database and return it
	CLI_ID=`grep -w $CLI_NAME $CLIDB|awk -F":" '{print $1}'`
	eval echo $CLI_ID
	return 0
  else 
	# Error client not exist "exit X"?
	return 1
  fi
}

function get_client_ip(){
  local CLI_ID=$1
# Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
	# Get client ip from database and return it
	CLI_IP=`grep -w $CLI_ID $CLIDB|awk -F":" '{print $4}'`
	eval echo $CLI_IP
	return 0
  else
	# Error client not exist "exit X"?
	return 1
  fi
}

function get_client_name(){
  local CLI_ID=$1
# Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
	# Get client name from database and return it
	CLI_NAME=`grep -w $CLI_ID $CLIDB|awk -F":" '{print $2}'`
	eval echo $CLI_NAME
	return 0
  else
	# Error client not exist "exit X"?
	return 1
  fi
}

function get_client_mac(){
 local CLI_ID=$1
  # Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
	# Get client mac from database and return it
	CLI_MAC=`grep -w $CLI_ID $CLIDB|awk -F":" '{print $3}'`
	eval echo $CLI_MAC	
	return 0
  else
	# Error client not exist "exit X"?
	return 1
  fi
}

function check_client_connectivity () {
  local CLI_ID=$1
# Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
	# Chek if client is available. Return 0 for ok, return 1 not ok.
  	CLI_IP=`grep -w $CLI_ID $CLIDB|awk -F":" '{print $4}'`
	ping  -c 1 -t 2 $CLI_IP &>/dev/null
	if [ $? -eq 0 ];then return 0; else return 1;fi
  else
	# Error client not exist "exit X"?
	return 1

  fi
}

function check_client_ssh () {
  local CLI_ID=$1
# Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
        # Get IP and NAME  
        CLI_IP=$(get_client_ip $CLI_ID)
        CLI_NAME=$(get_client_name $CLI_ID)
        #get hostname to compare with cliname , if ok , return client name
        CLI_NAME_CHECK=$(ssh -o BatchMode=yes -o ConnectTimeout=33 drls@$CLI_IP hostname -s)
        if [ $? -eq 0 ]
        then
#                if [ "$CLI_NAME" = "$CLI_NAME_CHECK" ];then return 0; else return 1;fi
		return 0
        else
                return 1
        fi
  else
        return 1

  fi
}

function add_client (){
  local CLI_ID="" 
  local CLI_NAME=$1
  local CLI_MAC=$2
  local CLI_IP=$3
  local CLI_NET=$4
  	CLI_ID=$(tail -1 $CLIDB|awk -F":" '{print $1 + 1}')
	echo $CLI_ID:$CLI_NAME:$CLI_MAC:$CLI_IP:$CLI_NET >> $CLIDB
	if [ $? == 0 ];then eval echo $CLI_ID; else return 1; fi
} 


function del_client_id(){
  local CLI_ID=$1
  if exist_client_id "$CLI_ID";
  then
	num_line=$(grep -nr ^$CLI_ID $CLIDB |awk -F":" '{print $1}')
	num_line=$num_line"d"
	echo $num_line
	sed -i "$num_line" $CLIDB
  else
	#Client not exist
 	return 1
  fi
}

function check_client_mac (){
  local CLI_NAME=$1
  local CLI_IP=$2
  local CLI_MAC=$3
        ping  -c 1 -t 2 $CLI_IP &>/dev/null
        if [ $? -eq 0 ];
        then
                local REAL_MAC=$(arp -a [ $CLI_NAME|$CLI_IP ] | awk '{print $4}' | tr ":" "-" | tr [a-z] [A-Z])
                if [ "${REAL_MAC}" == "${CLI_MAC}" ]
                then
                        return 0; 
                else 
                        return 1;
                fi
        fi 
}

function exist_client_mac () {
  local CLI_MAC=$1
    grep -w $CLI_MAC $CLIDB|awk -F":" '{print $3}'|grep $CLI_MAC &> /dev/null
      if [ $? == 0 ];then return 0; else return 1; fi
        
      # Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
      }

