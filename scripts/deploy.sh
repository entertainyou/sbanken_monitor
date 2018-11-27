KEY_FILE=/tmp/travis_rsa
BUILD=_build/prod/rel/sbanken_monitor/releases/*/sbanken_monitor.tar.gz
DEST_FOLDER=sbanken_monitor

function ssh_command {
    cmd="$@"
    ssh -q -oStrictHostKeyChecking=no -i $KEY_FILE $DEPLOY_TARGET $cmd
}

ssh_command mkdir -p $DEST_FOLDER
ssh_command $DEST_FOLDER/bin/sbanken_monitor stop
ssh_command rm -rf $DEST_FOLDER/*
scp -q -oStrictHostKeyChecking=no -i $KEY_FILE -r $BUILD $DEPLOY_TARGET:~/ &&
    ssh_command tar -zxvf ~/sbanken_monitor.tar.gz -C $DEST_FOLDER &&
    ssh_command LANG=en_US.utf8 $DEST_FOLDER/bin/sbanken_monitor start


