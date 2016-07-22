# docker-log-alert

This repository is a simple demo to showcase a couple of things using Docker.

  1. Sending logs securely to Graylog using the syslog tcp+tls logging driver
  2. Using Consul and Registrator to monitor services dynamically

### Usage

1. Generate the Syslog certs: `./docker-log-alert/tls/syslog/gen_certs.sh` (follow the prompts)
2. `EXTERNAL_IP=<host IP> docker-compose up -d` ... the EXTERNAL_IP is IP or address this is running on. For the client-side Graylog API calls.
3. Connect to graylog: `http://<EXTERNAL_IP>:9001` User: admin Pass: admin
   1. Go to "System/Input" -> "Content Packs" -> "Import Content Pack"
   2. Import the `./docker-log-alert/graylog/content_pack_nginx.json` content pack
   3. Under "Content Packs" click on "Web Servers" and then "Apply Content Pack"
4. `cd alerts`
5. `export CERT_PATH=$(pwd | sed 's/\/alerts//')`
6. `docker-compose up -d`
7. Run `./curl.sh` then enter in your Slack Webhook URL as well as channel
8. Scale the app `docker-compose scale app=10`
9. Simulate a failure
    1. `cd nginx`
    2. `echo fail > status` or `chmod 000 status`
10. In about 20s you should get an alert in Slack
11. Investigate the error in Graylog by searching for `NOT response_status: 200`
   
