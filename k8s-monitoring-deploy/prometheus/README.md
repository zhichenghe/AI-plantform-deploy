# Install
```
helm upgrade --install prometheus prometheus-community/prometheus --version 13.0.0 --namespace monitoring -f prometheus-values.yaml
helm upgrade --install grafana    stable/grafana    --version 5.5.5 --namespace monitoring -f grafana-values.yaml
```

# Login
```
# Get grafana login credential
# Username: admin
# Password:
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

# Upgrade
```
helm upgrade prometheus stable/prometheus --version 11.11.1 --namespace monitoring -f prometheus-values.yaml
helm upgrade grafana    stable/grafana    --version 5.5.5 --namespace monitoring -f grafana-values.yaml
```

# Install for locationmap k8s
```
helm upgrade --install prometheus prometheus-community/prometheus --version 13.0.0 --namespace monitoring -f prometheus-values-locationmap.yaml
```