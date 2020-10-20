FROM tomcat:8-jre8

RUN rm -rf $CATALINA_HOME/webapps/ROOT
COPY target/calculator.war $CATALINA_HOME/webapps/ROOT.war

CMD ["catalina.sh", "run"]
