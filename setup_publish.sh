echo ""
echo "################################################################################"
echo " setup-docker-with-mesosdevrobot.sh"
echo " MANAGED SCRIPT"
echo " "
echo " env.props used to import/export environment variables"
echo "################################################################################"
echo ""

# load environment variables for other managed scripts
pwd

source env.props
export $(cut -d= -f1 env.props)

docker --version

ln -sf /mnt/mesos/sandbox/jenkins-config.json /root/.dockercfg

# save any environment variables for other managed scripts
#echo "SOME_VAR=${SOME_VAR}" >> env.props
