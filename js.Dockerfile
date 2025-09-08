FROM lugo-vs

RUN sudo curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash - \
 && sudo apt-get install -y nodejs \
 && sudo npm install -g npm