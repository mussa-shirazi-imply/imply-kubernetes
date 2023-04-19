# imply-kubernetes
 

 ### Create Kind cluster

create the cluster using the default cluster name kind
  
`kind create cluster --config kind-cluster/kube-demo-cluster.yaml`


### Check Cluster nodes

`kubectl get nodes`

output should look like below 

```
NAME                 STATUS   ROLES           AGE     VERSION
kind-control-plane   Ready    control-plane   2m33s   v1.26.3
kind-worker          Ready    <none>          2m14s   v1.26.3
kind-worker2         Ready    <none>          2m14s   v1.26.3
```


### Create NGINX ingress controller

apply the follow command to deploy the Nginx Ingress controller

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

```

you need to wait minute or two for the pods `ingress-nginx` namespace 

```
 kubectl get pods -n ingress-nginx
```

```
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-bgdgq        0/1     Completed   0          3m4s
ingress-nginx-admission-patch-8p447         0/1     Completed   0          3m4s
ingress-nginx-controller-6bdf7bdbdd-vmjsr   1/1     Running     0          3m4s

```

## Deplay `postgressql`


Postgress is use to store metadata information about druid cluster is important have running pod for postgress

### apply the config map file `postgres-config.yaml`

the config map file `postgres-config.yaml` is located in the ./postgresssql  folder . You can review for more detail. Config map is used to store user name and password for the postgress


`
kubectl apply -f postgressql/postgres-config.yaml
`

confirm the config map is applied 

`
kubectl get configmap
`

```
NAME               DATA   AGE
kube-root-ca.crt   1      3m5s
postgres-config    3      10s

```

### create persistent volume file `postgres-pvc-pv.yaml`

Create the persistent valume claim for the postgress. to review the file look for the file `postgres-pvc-pv.yaml` in `postgresssql` folder. Since this the dev envrinoment we are going to use 1gb storge.

For more detail on persistent valume and persistent valume claims `https://kubernetes.io/docs/concepts/storage/persistent-volumes/`


`
kubectl apply -f postgressql/postgres-pvc-pv.yaml

`
### confirm the pv and pvc is deployed

```
kubectl get pv


NAME                 CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                       STORAGECLASS   REASON   AGE
postgres-pv-volume   1Gi        RWX            Retain           Bound    default/postgres-pv-claim   manual                  28s

```
```
kubectl get pvc

NAME                STATUS   VOLUME               CAPACITY   ACCESS MODES   STORAGECLASS   AGE
postgres-pv-claim   Bound    postgres-pv-volume   1Gi        RWX            manual         17s

```


### deploy postgress deployment file `postgres-deployment.yaml`

Create and review the `postgres-deployment.yaml` file in `postgresssql` folder. The file will deploy single pod of postgress which is running on port `5432` . It uses the config map we created `postgres-config` earlier to fetch env variables.And uses the persistentVolumeClaim `postgres-pv-claim` we created earlier to store the data. 


```
kubectl apply -f postgressql/postgres-deployment.yaml

```

get the pods 

```
kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
postgres-7454f995b-hzsjs   1/1     Running   0          29s

```

### ceate postgress service `postgres-service.yaml`

I think step we will create postgress service. In Kubernetes, a Service is a method for exposing a network application that is running as one or more Pods in your cluster. There are different type of service like `ClusterIP, NodePort, LoadBalancer, and Ingress` . More detail on the blog `https://medium.com/devops-mojo/kubernetes-service-types-overview-introduction-to-k8s-service-types-what-are-types-of-kubernetes-services-ea6db72c3f8c` . We are going to use node port. Look at the file `postgres-service.yaml` in `postgress` folder. 



```
kubectl apply -f postgressql/postgres-service.yaml

```

##### confirm the service is added 

```
kubectl get services
```

As you can see the port `30151` is added and mapping with postgress port `5432`

```
kubectl get service
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
kubernetes   ClusterIP   10.96.0.1     <none>        443/TCP          75m
postgres     NodePort    10.96.49.43   <none>        5432:30151/TCP   14s

```


## Create Imply Manager database

### Login postgres pod

Get posgress pod name

```
kubectl get pods

NAME                       READY   STATUS    RESTARTS   AGE
postgres-7454f995b-trz6f   1/1     Running   0          25m

```

Login to postgres pod, replace postgres-7454f995b-trz6f with yours postgres pod name

```
kubectl exec -it postgres-7454f995b-trz6f bash
```

From the postgres pod

```
psql -h postgres.default.svc.cluster.local -U admin --password postgresdb -p 5432

```
The password from the postgres config map: psltest

```
# Command result:
#Password for user admin:
#psql (10.1)
#Type "help" for help.
#
#postgresdb=#

```

execute the following command from the psql shell 

```
CREATE DATABASE "imply-manager" WITH OWNER "admin" ENCODING 'UTF8';

```
 check databases using 

 ```
postgresdb=# \l
                                   List of databases
     Name      |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
---------------+----------+----------+------------+------------+-----------------------
 imply-manager | admin    | UTF8     | en_US.utf8 | en_US.utf8 |
 postgres      | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 postgresdb    | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
               |          |          |            |            | postgres=CTc/postgres
 template1     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
               |          |          |            |            | postgres=CTc/postgres
(5 rows)

 ```


 exit from the `psql` pod 

```
use 

 ^Z

and then 

exit

 ```


## Add the DNS record to the host file 


`

`

## Imply Helm chat deployment 




## Ingress Controller


```
kubectl apply -f ngix-controller/ingress.yaml

```