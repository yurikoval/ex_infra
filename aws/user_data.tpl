Content-Type: multipart/mixed; boundary="===============BOUNDARY=="
MIME-Version: 1.0


--===============BOUNDARY==
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0

#cloud-config

--===============BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash

DEPLOY_USER=${ec2_user}
DEPLOY_HOME=/home/$DEPLOY_USER

echo "Cloning repo ${git_repo}"
sudo -u $DEPLOY_USER -i git clone ${git_repo} $DEPLOY_HOME/app

while [ ! -f /tmp/dev.exs ]
do
  echo "/tmp/dev.exs is missing. Sleeping..."
  sleep 5
done

echo "Moving .env"
sudo -u $DEPLOY_USER -i mv /tmp/.env $DEPLOY_HOME/app/.env

echo "Moving dev.exs"
sudo -u $DEPLOY_USER -i mv /tmp/dev.exs $DEPLOY_HOME/app/config/dev.exs

echo "Running bin/setup"
sudo -u $DEPLOY_USER -i -- sh -c "cd $DEPLOY_HOME/app; bin/setup"

--===============BOUNDARY==
