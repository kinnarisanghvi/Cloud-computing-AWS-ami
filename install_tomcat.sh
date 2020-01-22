#!/usr/bin/env bash

yum install java-1.8.0-openjdk.x86_64 -y
yum install -y wget
cd /tmp
wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
rpm -ivh mysql57-community-release-el7-9.noarch.rpm
yum install -y mysql-server
yum install -y mysql
yum install -y maven
yum install -y epel-release
yum install -y npm nodejs
yum install -y node git 
systemctl start mysqld
yum -y update
yum install -y ruby
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto
service codedeploy-agent status
service codedeploy-agent start
service codedeploy-agent status

wget https://s3.amazonaws.com/amazoncloudwatch-agent/centos/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

git clone https://github.com/etsy/statsd.git /usr/local/src/statsd/  
cd /usr/local/src/statsd/  
npm install  
npm install aws-cloudwatch-statsd-backend
mkdir /opt/tomcat
/sbin/iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
wget -q --no-cookies -S "http://mirrors.advancedhosters.com/apache/tomcat/tomcat-9/v9.0.17/bin/apache-tomcat-9.0.17.tar.gz"
tar -xf apache-tomcat-9.0.17.tar.gz
mv apache-tomcat-9.0.17/ /opt/tomcat/
echo "export CATALINA_HOME='/opt/tomcat/'" >> ~/.bashrc
useradd -r tomcat --shell /bin/false
chown -R tomcat:tomcat /opt/tomcat/
cat > /etc/systemd/system/tomcat.service << EOF
[Unit]
Description= Tomcat 9
After=syslog.target network.target

[Service]
User=tomcat
Group=tomcat
Type=forking
Environment=JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
Environment=CATALINA_PID=/opt/tomcat/apache-tomcat-9.0.17/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat/apache-tomcat-9.0.17
Environment=CATALINA_BASE=/opt/tomcat/apache-tomcat-9.0.17
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd:/dev/./urandom'
ExecStart=/opt/tomcat/apache-tomcat-9.0.17/bin/startup.sh
ExecStop=/opt/tomcat/apache-tomcat-9.0.17/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
touch /opt/aws/amazon-cloudwatch-agent/cloudwatch-config.json
cat > /opt/aws/amazon-cloudwatch-agent/cloudwatch-config.json << EOF
{
	"logs": {
		"logs_collected": {
			"files": {
				"collect_list": [
					{
						"file_path": "/opt/tomcat/apache-tomcat-9.0.17/logs/catalina.out",
						"log_group_name": "tomcat-logs",
						"log_stream_name": "{instance_id}"
					}
				],
                                "collect_list": [
					{
						"file_path": "/opt/tomcat/apache-tomcat-9.0.17/logs/csye6225.log",
						"log_group_name": "webapp-logs",
						"log_stream_name": "{instance_id}"
					}
				]
			}
		}
	},
	"metrics": {
		"metrics_collected": {
			"mem": {
				"measurement": [
					"mem_used_percent"
				],
				"metrics_collection_interval": 60
			},
			"statsd": {
				"metrics_aggregation_interval": 10,
				"metrics_collection_interval": 10,
				"service_address": "127.0.0.1:8125"
			},
			"swap": {
				"measurement": [
					"swap_used_percent"
				],
				"metrics_collection_interval": 60
			}
		}
	}
}
EOF
touch /usr/local/src/statsd/statsd-config.js
cat > /usr/local/src/statsd/statsd-config.js << EOF
{
    backends: [ "aws-cloudwatch-statsd-backend" ],
    cloudwatch:
    {
        iamRole: 'CloudWatchAgentServerRole',
        region: 'us-east-1'
    }
}
EOF
