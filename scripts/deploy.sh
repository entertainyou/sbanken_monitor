KEY_FILE=/tmp/travis_rsa
BUILD=_build/prod/rel/sbanken_monitor/
DEST_FOLDER=sbanken_monitor

function ssh_command {
    cmd=$1
    ssh -oStrictHostKeyChecking=no -i $KEY_FILE $DEPLOY_TARGET $cmd
}

ssh_command mkdir -p $DEST_FOLDER
ssh_command $DEST_FOLDER/bin/sbanken_monitor stop
scp -r $BUILD $DEPLOY_TARGET:~/
ssh_command ls $DEST_FOLDER


