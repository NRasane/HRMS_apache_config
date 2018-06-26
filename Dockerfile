FROM ubuntu:14.04

MAINTAINER Nikhil Rasane

VOLUME ["/var/www/html"]

ENV GRADLE_VERSION 4.7

#install php apache mongodb node.js java8 react.js and relevant pkgs 
RUN apt-get update && \
    apt-get install -y \
      apache2 \
      php5 \
      php-pear \
      php5-dev \
      php5-cli \
      libapache2-mod-php5 \
      php5-gd \
      php5-json \
      php5-ldap \
      php5-mysql \
      php5-pgsql \
      vim \
      curl \
      unzip \
      sudo \
      wget \
      nano

RUN apt-get -y install python-software-properties git build-essential

###install mongodb####

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5

RUN echo "deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list

RUN apt-get update

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

RUN apt-get install -y nodejs

RUN apt-get install -y mongodb-org

#####install JAVA8 #####

## add webupd8 repository
RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu "$(lsb_release -sc)" main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu "$(lsb_release -sc)" main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get update  && \
    \
    \
    echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    apt-get install -y oracle-java8-installer oracle-java8-set-default  && \
    \
    \
    echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk8-installer  && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*



## Define JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


#### Install gradle #############################

RUN cd /usr/lib \
 && curl -fl https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle-bin.zip \
 && unzip "gradle-bin.zip" \
 && ln -s "/usr/lib/gradle-${GRADLE_VERSION}/bin/gradle" /usr/bin/gradle \
 && rm "gradle-bin.zip"

## Set Appropriate Environmental Variables
ENV GRADLE_HOME /usr/lib/gradle
ENV PATH $PATH:$GRADLE_HOME/bin



################ Add jenkins user/group #############
RUN groupadd -g 1001 jenkins \
 && useradd -m -d /home/jenkins -s /bin/bash -g jenkins -u 1001 jenkins \
 && gpasswd -a jenkins root

# Enable jenkins to read/write in tmp folder
#RUN chown -R 1001:1001 /tmp

# Enable passwordless sudo for users under the "wheel" group
RUN sed -i.bkp -e 's/#\s%root.*NOPASSWD.*/%root ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

# Fix issue: 'sudo: sorry, you must have a tty to run sudo'
RUN sed -i.bkp -e 's/Defaults.*requiretty.*/# Defaults requiretty/g' /etc/sudoers

# Add jenkins to the docker group
RUN groupadd docker \
&& usermod -aG docker jenkins

RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

################################
USER root

#COPY orangehrm-3.0.1 /var/www/html/orangehrm-3.0.1
RUN chmod 777 /var/www/html/
#COPY sites-available /etc/apache2/
#COPY sites-enabled/* /etc/apache2/sites-enabled/000-default.conf

RUN chmod 777 /etc/apache2/

#COPY apache_default /etc/apache2/sites-available/000-default.conf
#COPY run /usr/local/bin/run
#RUN chmod +x /usr/local/bin/run
#RUN a2enmod rewrite
#RUN service apache2 start

EXPOSE 80 8090
#CMD ["/usr/local/bin/run"]
#ENTRYPOINT ["/usr/sbin/apache2ctl", “-D”, “FOREGROUND”]
#ENTRYPOINT ["/usr/sbin/service", “apache2”, “start”]

CMD /usr/sbin/apache2ctl -D FOREGROUND
