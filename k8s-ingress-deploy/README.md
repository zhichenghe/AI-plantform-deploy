### Setup Ngnix Ingress
```sh
# Install helm (https://kubernetes.github.io/ingress-nginx/deploy/#using-helm)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx/
helm -n kube-system upgrade --install nginx-ingress ingress-nginx/ingress-nginx -f ./nginx-ingress-value-file.yaml --version 3.34.0

# Grpc nginx (Optional)
# helm install -n networking grpc-ingress ingress-nginx/ingress-nginx -f grpc-ingress-value-file.yaml
```


### Setup Ngnix Ingress for locationmap
```sh
# Install helm (https://kubernetes.github.io/ingress-nginx/deploy/#using-helm)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx/
helm -n kube-system upgrade --install nginx-ingress ingress-nginx/ingress-nginx -f ./nginx-ingress-value-file-locationmap.yaml --version 3.34.0

# Grpc nginx (Optional)
# helm install -n networking grpc-ingress ingress-nginx/ingress-nginx -f grpc-ingress-value-file.yaml
```
