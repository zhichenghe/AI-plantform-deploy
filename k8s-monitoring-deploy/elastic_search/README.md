```
helm repo add elastic https://helm.elastic.co

helm -n monitoring upgrade --version=7.14.0 --install elasticsearch elastic/elasticsearch -f elasticsearch-values.yaml
helm -n monitoring upgrade --version=7.13.2 --install kibana elastic/kibana -f kibana-values.yaml
helm -n monitoring upgrade --version=7.13.2 --install filebeat elastic/filebeat -f filebeat-values.yaml
helm -n monitoring upgrade --version=7.14.0 --install metricbeat elastic/metricbeat -f metricbeat-values.yaml
helm -n monitoring upgrade --version=7.14.0 --install apm-server elastic/apm-server -f apm-server-values.yaml

# Heart-beat
kubectl apply -f heartbeat-kubernetes.yaml
`````


# for maplocatization_k8s
```
helm repo add elastic https://helm.elastic.co
helm -n monitoring upgrade --version=7.13.2 --install filebeat elastic/filebeat -f maplocalization-filebeat-values.yaml
```