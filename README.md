# CiscoACI_Grafana
Monitor Cisco ACI via REST-API with the TIG-Stack (Telegraf, InfluxDB, Grafana)
Visit my blog post over at nwmichl.net for full documentation.

## Shell scripts
apic_query.sh and apic_querysig.sh may live in the /etc/telegraf directory and provide an wrapper around the API Call.

## Telegraf configuration
.conf files live in the /etc/telegraf/telegraf.d directory and query all metrics to populate the Grafana dashboard of this demo

## Grafana 
The Dashboard is a first idea to visualize central Cisco ACI metrics, and should help to get started and develop own solutions.

![Cisco ACI Dashboard](link-to-image)
