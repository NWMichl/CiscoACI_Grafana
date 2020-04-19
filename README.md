# CiscoACI_Grafana
Demo about how to monitor Cisco ACI via REST-API with the TIG-Stack (Telegraf, InfluxDB, Grafana).

Visit my blog post over at https://nwmichl.net for full documentation.

## Shell scripts
apic_query.sh and apic_querysig.sh may live in the /etc/telegraf directory and provide a wrapper around the API Call.
Telegraf inputs.http doesn't support cookie handling, so I choose to break out to bash and use inputs.exec to parse the json response. Same for the cert / signature based authentication script, because nobody really wants to manual generate the signature and build the http header cookie by hand. 

## Telegraf configuration
.conf files live in the /etc/telegraf/telegraf.d directory and query all metrics to populate the Grafana dashboard of this demo

## Grafana 
The Dashboard is a first idea to visualize central Cisco ACI metrics and should help to get started developing own solutions.

![Cisco ACI Dashboard](https://github.com/NWMichl/CiscoACI_Grafana/blob/master/ciscoaci_dashboard.png)
