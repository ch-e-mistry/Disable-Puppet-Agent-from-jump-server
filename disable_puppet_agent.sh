#pmikaczo; script to disable puppet agent on described hosts. Script also print out, if puppet agent was disabled previously (no overwrite it. Default behavior if you set twice disable message, first-one will be vaild)
#EXAMPLE: ./disable_puppet_agent.sh pmikaczo 5 "disable due rollout disable message with spaces" source log_source

#!/bin/bash
USER=$1
TIMEOUT=$2
MESSAGE=$3
HOST_SOURCE=$4
LOG_DESTINATION=$5

if [ "$USER" == "" ] || [ "$TIMEOUT" == "" ] || [ "$MESSAGE" == "" ] || [ "$HOST_SOURCE" == "" ] || [ "$LOG_DESTINATION" == "" ] ; then
echo "Please use it with the following mode --> ./disable_puppet_agent.sh pmikaczo 5 disable_due_rollout_disable_message_with_spaces source log_destination

pmikaczo --> <username to SSH in to host>
5 --> <timeout value in SEC>
disable_due_rollout_disable_message_with_spaces --> <Puppet agent disable message>. Previously disable message will not overwritten
source --> <source where from read hosts>
log_destination --> <log filename where to log>
HINT --> For disable message with spaces you can use quotation marks"
exit
fi

export GREP_COLOR='1;31'
echo -e "Enter your LDAP password: "
stty -echo
read password
export password
stty echo
while read line
do
echo "------------------------------------------------------------"
echo "$line"
timeout $TIMEOUT sshpass -p $password ssh -oStrictHostKeyChecking=no -T -l $USER $line << SSH
echo "Server: \$(hostname)"
echo $password | script -q -c "sudo -s cat /var/lib/puppet/state/agent_disabled.lock &&  echo -e || echo -e 'PUPPET WILL BE DISABLED' && sudo -s puppet agent --disable '$MESSAGE' "
SSH
done < $HOST_SOURCE | tee -a $LOG_DESTINATION

echo  "Highlight hosts where puppet agent was disabled? Press n if you don't want this filter"
read -t 10 FILTER
echo "##########FILTERED RESULT##########"
if [ "$FILTER" = "n" ]; then
echo "Timout or you not choosed y"
else cat $LOG_DESTINATION | grep --color -E "\b(PUPPET WILL BE DISABLED|)\b"
fi
exit
