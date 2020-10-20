FROM tomcat:8-jre8

RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY target/calculator.war /usr/local/tomcat/webapps/ROOT.war

CMD ["catalina.sh", "run"]
