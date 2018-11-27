KEY_FILE=/tmp/travis_rsa

echo Key $KEY_FILE
echo Target $DEPLOY_TARGET
which ssh
ssh -oStrictHostKeyChecking=no -i $KEY_FILE $DEPLOY_TARGET pwd
