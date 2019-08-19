# XSLT Servlet

Transform uploaded XML (with provided params) and cache results.

## Dev Setup

`~/.m2/settings.xml`:

    <?xml version="1.0" encoding="UTF-8"?>
    <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
      https://maven.apache.org/xsd/settings-1.0.0.xsd">
      <localRepository/>
      <interactiveMode/>
      <usePluginRegistry/>
      <offline/>
      <pluginGroups/>
      <servers>
        <server>
          <id>TomcatServer</id>
          <username>maven</username>
          <password>maven</password>
        </server>
      </servers>
      <mirrors/>
      <proxies/>
      <profiles/>
      <activeProfiles/>
    </settings>

`$TOMCAT_HOME/conf/tomcat_users.xml`:

    <?xml version="1.0" encoding="UTF-8"?>
    <tomcat-users xmlns="http://tomcat.apache.org/xml"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
        version="1.0">
      <role rolename="manager-gui"/>
      <role rolename="manager-script"/>
      <user username="maven" password="maven" roles="manager-gui,manager-script" />
    </tomcat-users>

vim:

    autocmd FileType java setlocal shiftwidth=4 softtabstop=4
    let g:syntastic_java_checkers = ["javac"]
    au BufWritePost <buffer> Dispatch! mvn tomcat7:redeploy
    nnoremap <leader>r :!curl http://localhost:8080/Transform/<cr>

Also Tomcat default maximum POST data size is 2MB. Consider increasing
it by adding a maxPostSize attribute to the relevant Connector element
in `server.xml`. For example:

    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               maxPostSize="10485760"
               redirectPort="8443" />

## Client example

    const xml = '...'; // MEI data

    const formData = new FormData();
    formData.append('__xml', xml);
    formData.append('__xslID', 'analyseByKey');
    formData.append('profile', 'krumhansl');
    formData.append('windowSize', '4');

    axios.post('http://localhost:8080/Transform/', formData)
      .then(response => response.data)
      .then(data => console.log(data))
      .catch(error => console.log(error));
