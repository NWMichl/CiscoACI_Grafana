[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/NWMichl/CiscoACI_Grafana)
# Monitor Cisco ACI via REST-API
Demo about how to monitor Cisco ACI via REST-API and the TIG-Stack (Telegraf, InfluxDB, Grafana).

![Cisco ACI TIG-Stack](https://github.com/NWMichl/CiscoACI_Grafana/blob/master/ACI_TIG-Stack.jpg)

## Use Case Description
Modern controller based networks are quite different from a monitoring perspective, all the fancy network abstraction information is hiding behind this thing called API. SNMP might still be there, but is missing most of the interesting bits like health scores, faults and Tenant/App/Policy based metrics.
Cisco ACI is one of the few ‘API-first’ network solutions on the market, meaning really every bit of information is available via the programmable interface. You might monitor single fabric nodes via established SNMP processes, this demo though is all about the interesting metrics exposed by REST-API on the controller named APIC.
The TIG-Stack (Telegraf, InfluxDB, Grafana) covers 200 different input sources, a scalable time series database and a powerful dashboard front-end – all you need for a single holistic view over the whole infrastructure stack. 

## Installation

### Telegraf, InfluxDB, Grafana

First of all, you need a working TIG-Stack. The installation is pretty simple and not in the scope of this demo. In addition to that, your Telegraf instance needs curl and in the case of signature based authentication: OpenSSL.

    sudo yum install curl
    sudo yum install openssl

### Shell scripts
apic_query.sh and apic_querysig.sh may live in the /etc/telegraf directory and provide a wrapper around the API Call.
The Telegraf inputs.http doesn't support cookie handling, so I decided to break out to bash and use inputs.exec to parse the json response. Same for the cert / signature based authentication script, because nobody really wants to generate the signature and build the http header cookie by hand. Keep in mind that all user/password based API Calls are rate limited by the NGINX process at the APIC. So, depending on the scope and frequency you are better off with cert based access.

## Configuration
### Cisco ACI
On the APIC side, just create a dedicated Telegraf user with admin role and read-only rights on all security domains.
In case you want to use cert based authentication, generate a X509 cert with CN=APIC username.

    $openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -keyout telegraf.key -out telegraf.crt -subj '/CN=telegraf/O=NWMICHL/C=DE' 

The telegraf.key file is your private key, should be kept secret (in your /etc/telegraf/ directory ;-) and will be used to sign API-Calls to authenticate every request. The public key has to be installed at the APIC for the telegraf user. Set the User Certificate Attribute to the certificate DN (telegraf) and copy/paste the output of ‘cat telegraf.crt’ to the APIC (User Certificates, click +). The Certificate Name should be in the form <username>.crt for the following bash script to work. After submit, the new certificate should be active.

### Telegraf
To read metrics from the APIC, the two shell scripts can now be invoked by the Telegraf inputs.exec plugin. Every API call gets a dedicated Telegraf configuration file to live in the /etc/telegraf/telegraf.d/ directory, because the API path / operation is different depending on the requested information. The five examples in this repository query all metrics to populate the Grafana dashboard of this demo.

## Usage

Example bash execution of the two shell scripts would look like this:

    sh /etc/telegraf/apic_query.sh sandboxapicdc.cisco.com /api/class/fabricHealthTotal.json telegraf telegraf

    sh /etc/telegraf/apic_querysig.sh sandboxapicdc.cisco.com /api/class/fabricHealthTotal.json telegraf telegraf.key

Before reloading Telegraf to accept the new configuration, you can test the agent to show what lines will be added to the InfluxDB.

    $telegraf --test --config-directory /etc/telegraf/telegraf.d --input-filter exec

    $sudo systemctl reload telegraf

### Grafana Dashboard

The Dashboard is a first idea to visualize central Cisco ACI metrics and should help to get started developing own solutions. The dashboard.json can be downloaded from github and imported via Grafana / click + / choose Import. Just enter a name, the database source and change the UID if needed.

![Cisco ACI Dashboard](https://github.com/NWMichl/CiscoACI_Grafana/blob/master/ciscoaci_dashboard.png)

## DevNet Sandbox 
APIC Sandbox to play with, just in case: https://developer.cisco.com/docs/aci/#!sandbox

## Getting help

Feel free to visit my blog at http://nwmichl.net/2020/04/19/monitor-cisco-aci-via-rest-api/ for full documentation of the ACI vs. TIG process.
