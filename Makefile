# Makefile for deploying Kubernetes resources

.PHONY: deploy
deploy: create-cluster check-cluster-deployed deploy-nginx-controller deploy-postgres deploy-imply-helm deploy-ingress-controller update-hosts check-ingress-installed

create-cluster:
	kind create cluster --config kind-cluster/kube-demo-cluster.yaml

check-cluster-deployed:
	@echo "Waiting for the cluster to be ready..."
	@while ! kubectl get nodes > /dev/null 2>&1; do sleep 2; done
	@echo "Cluster is ready."

deploy-nginx-controller:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	@echo "Waiting for the nginx controller to be up..."
	@while ! kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{range .items[*]}{.status.phase}{"\n"}{end}' | grep -q Running; do sleep 2; done
	@echo "Nginx controller is up."

deploy-postgres:
	kubectl apply -f postgressql/postgres-config.yaml
	kubectl apply -f postgressql/postgres-pvc-pv.yaml
	kubectl apply -f postgressql/postgres-deployment.yaml
	kubectl apply -f postgressql/postgres-service.yaml
	@echo "Waiting for the postgres-pod to be ready..."
	@while ! kubectl get pods -l app=postgres -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}' | grep -q Running; do sleep 2; done
	@echo "Postgres pod is ready."
	@POSTGRES_POD_NAME=$$(kubectl get pods -l app=postgres -o jsonpath='{.items[0].metadata.name}'); \
	echo "Waiting for PostgreSQL server to become ready..."; \
	while ! kubectl exec -it $$POSTGRES_POD_NAME -- pg_isready -U admin; do sleep 2; done; \
	echo "PostgreSQL server is ready."; \
	sleep 5; \
	kubectl exec -it $$POSTGRES_POD_NAME -- bash -c 'psql -U admin -d postgres -c "CREATE DATABASE \"imply-manager\" WITH OWNER \"admin\" ENCODING '\''UTF8'\'';"'

deploy-imply-helm:
	helm install imply ./imply

deploy-ingress-controller:
	kubectl apply -f ngix-controller/ingress.yaml

update-hosts:
	@echo "****** Enter your Admin Password To update your /etc/hosts file *******"
	@echo "Updating /etc/hosts file..."
	@echo '127.0.0.1       manager.testzone.io' | sudo tee -a /etc/hosts
	@echo '127.0.0.1       query.testzone.io' |  sudo tee -a /etc/hosts
	@echo "Hosts file updated."

check-ingress-installed:
	@echo "Waiting for the ingress to be installed..."
	@while ! kubectl get ingress nginx-ingress -o jsonpath='{.status.loadBalancer.ingress}' | grep -q 'hostname\|ip'; do sleep 2; done
	@echo "Ingress installed."
	@kubectl get ingress nginx-ingress
	@echo "Imply Enterprise is installed Successfully."

.PHONY: destroy
destroy:
	kind delete cluster
	@echo "Kind cluster deleted."
