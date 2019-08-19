FROM debian:buster
RUN apt-get update \
    && apt-get install -y \
        curl \
        locales \
        maven \
        openjdk-11-jdk-headless \
        python3 \
        python3-venv \
        --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && echo 'LANG="en_US.UTF-8"' > /etc/default/locale \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV USERNAME bruckner
ENV HOME /home/$USERNAME
RUN useradd --create-home --home-dir $HOME --shell /bin/bash $USERNAME \
    && chown -R $USERNAME:$USERNAME $HOME

WORKDIR $HOME
USER $USERNAME

# setup tomcat
RUN curl -LSsO https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.22/bin/apache-tomcat-9.0.22.tar.gz \
    && echo '9d3d93f8e03b5dc74e8d2ebc3f9daeb481485a391fb10289e23848063c23f52e8cf8566ebc7ff4f62c9b9f71591fad368a2bab487d31377c85a2607be3e029ff *apache-tomcat-9.0.22.tar.gz' > SHA512SUM \
    && sha512sum -c SHA512SUM \
    && mkdir tomcat \
    && tar xzf apache-tomcat-9.0.22.tar.gz -C $HOME/tomcat --strip-components=1 \
    && rm SHA512SUM apache-tomcat-9.0.22.tar.gz

# copy files
COPY app/ $HOME/app
COPY applicationData/data_src/ $HOME/applicationData/data_src
COPY applicationData/xsl/ $HOME/applicationData/xsl
COPY xslt-servlet/ $HOME/xslt-servlet

# set permissions
USER root
RUN chown -R bruckner:bruckner app/ applicationData/ xslt-servlet/
USER $USERNAME

# build and deploy xslt servlet
RUN cd xslt-servlet \
    && cp -r ../applicationData/xsl src/main/webapp/WEB-INF \
    && cp src/main/webapp/WEB-INF/xsl/process2work.xsl src/main/webapp/WEB-INF/xsl/work.xsl \
    && mvn package \
    && mv target/XSLTServlet.war ../tomcat/webapps

# setup app (python)
RUN cd app \
    && python3.7 -m venv .venv \
    && . .venv/bin/activate \
    && pip install -r requirements.txt \
    && sed -i 's/127\.0\.0\.1/0.0.0.0/' server.py

# setup nodejs
ENV NODE_VERSION node-v10.16.3-linux-x64
RUN curl -LSsO https://nodejs.org/dist/v10.16.3/$NODE_VERSION.tar.gz \
    && echo "2f0397bb81c1d0c9901b9aff82a933257bf60f3992227b86107111a75b9030d9  $NODE_VERSION.tar.gz" > SHA256SUM \
    && sha256sum -c SHA256SUM \
    && tar xzf $NODE_VERSION.tar.gz \
    && rm SHA256SUM $NODE_VERSION.tar.gz
USER root
RUN ln -s /home/$USERNAME/$NODE_VERSION/bin/node /usr/local/bin/node \
    && ln -s /home/$USERNAME/$NODE_VERSION/bin/npm /usr/local/bin/npm
USER $USERNAME

# setup app (js)
RUN cd app \
    && npm install \
    && npm run build

COPY docker-entrypoint.sh $HOME
ENTRYPOINT /home/$USERNAME/docker-entrypoint.sh
