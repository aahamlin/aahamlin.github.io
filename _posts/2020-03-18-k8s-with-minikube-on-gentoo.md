---
layout: post
title: Kubernetes with Minikube on Gentoo
---

Having rebuilt my Gentoo box and installed QEMU/KVM, last week I began playing around with `minikube`. Long-story-short my home machine is pretty much too weak to run more complex systems, like the Guestbook w/ ELK example or a simple Kafka setup. On Gentoo, minikube pulls in kubectl and golang dependencies. 

```
$ cat /etc/portage/package.use/minikube 
sys-cluster/minikube libvirt

$ cat /etc/portage/package.accept_keywords/minikube 
>=sys-cluster/minikube-1.0.1 ~amd64
>=sys-cluster/kubectl-1.17 ~amd64
```

Install minikube v1.6
```
$ emerge -av sys-cluster/minikube
```

I found everything I wanted to try required increasing the cpu and memory. And even then my machine simply can\'t seem to keep up.

```
minikube config set cpus 2
minikube config set memory 4096
minikube config set vm-driver kvm2

minikube start --network-plugin=cni --enable-default-cni
```


## Installing Guestbook and ELK

Reference: [https://kubernetes.io/docs/tutorials/stateless-application/guestbook-logs-metrics-with-elk/]([https://kubernetes.io/docs/tutorials/stateless-application/guestbook-logs-metrics-with-elk/)

Install Helm v2.16 \(k8s package manager\). I used `--oneshot` mode.

```
$ emerge -av app-admin/helm
```

Make very small because default helm install requested too much cpu, and I know that memory is already a problem.

```
$ helm install --name elasticsearch --set resources.requests.cpu=100m --set resources.requests.memory=256M --set esJavaOpts="-Xmx128m -Xms128m" --set antiAffinity="soft" elastic/elasticsearch

$ kubectl get pod -n default

$ helm install --name kibana --set resources.requests.cpu=100m --set resources.requests.memory=256M elastic/kibana

$ kubectl logs -f -n default -l app=kibana
```

The default dns names for ELASTICSEARCH_HOSTS and KIBANA_HOST were correct but before I realized that I look into how to find the DNS names of the pod services. See this article [https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/). Testing the name resolution of the elasticsearch-master from inside my kibana pod looked like this:
```
$ kubectl exec kibana-kibana-8d45596cd-gf2rg -- curl elasticsearch-master.default.svc.cluster.local:9200
```

Both filebeat and metricbeat can be installed using helm rather than the article guidance. But, there were errors running these successfully. Note: packetbeat was not available as helm package.

I had to be change the apiVersion and add a label selector for all filebeat, metricbeat, and packetbeat before deploying `{filebeat,metricbeat,packetbeat}-kubernetes.yaml` files. 

For example:
```
- apiVersion: extensions/v1beta1
+ apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: packetbeat-dynamic
  namespace: kube-system
  labels:
    k8s-app: packetbeat-dynamic
    kubernetes.io/cluster-service: "true"
spec:
+   selector:
+     matchLabels:
+       k8s-app: packetbeat-dynamic
  template:
    metadata:
      labels:

```

The article states you can access the Kibanan Dashboard but does not include steps to accomplish this. As the Kibana service uses a ClusterIP and not a NodePort address. Therefore, I used `kubectl edit svc/kibana-kibana` to change from type ClusterIP to NodePort. That exposed the Kibana Dashboard, accessible at `minikube service kibana-kibana --url`


## Installing Kafka


Reference: [https://dzone.com/articles/ultimate-guide-to-installing-kafka-docker-on-kuber](https://dzone.com/articles/ultimate-guide-to-installing-kafka-docker-on-kuber)

Install kafkacat. I used `--oneshot` mode.

```
$ cat /etc/portage/package.accept_keywords/kafkacat
# following example of a kafka service,
# https://dzone.com/articles/ultimate-guide-to-installing-kafka-docker-on-kuber
>=net-misc/kafkacat-1.5.0 ~amd64
# required by kafkacat-1.5.0
=dev-libs/avro-c-1.9.1 ~amd64
=dev-libs/libserdes-5.4.0 ~amd64
```

Follow the Calico articles install guidance as I am using NetworkManager.

```
sudo nano -w /etc/NetworkManager/conf.d/calico.conf
```

Here are the steps from the article, basically.

```
$ kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

$ kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml

$ kubectl apply -f metallb-config.yml

$ kubectl create -f zookeeper.yml

$ watch -n5 kubectl get pods,svc

```
 Once zookeeper is up and running.
 
```
$ kubectl create -f kafka-service.yml

$ kubectl describe svc kafka-service
Name:                     kafka-service
Namespace:                default
Labels:                   name=kafka
Annotations:              <none>
Selector:                 app=kafka,id=0
Type:                     LoadBalancer
IP:                       10.97.71.24
LoadBalancer Ingress:     192.168.39.240
Port:                     kafka-port  9092/TCP
TargetPort:               9092/TCP
NodePort:                 kafka-port  30347/TCP
Endpoints:                <none>
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type    Reason       Age   From                Message
  ----    ------       ----  ----                -------
  Normal  IPAllocated  40s   metallb-controller  Assigned IP "192.168.39.240"
```

Update the broker file with the ingress address and NodePort.

```
$ kubectl create -f kafka-broker.yml

$ watch -n5 kubectl get pods,svc

$ kubectl get pods,svc --all-namespaces
```

Then you can test Kafka using two terminals.

Consumer
kafkacat -b <ingressip>:9092 -t admintome-test

Producer:
cat ~/Documents/notes.txt | kafkacat -b 192.168.39.200 -t admintome-test

I have __not__ successfully sent a kafka message. My suspicion is that my home machine is simply not powerful enough. My machine is seriously memory bound and the minikube VM is doing a lot of swapping. 


Debug messages show that the broker is being contacted, then it seems to timeout before the work is done.

```
kafkacat -b <ingressip>:9092 -d broker -t admintome-test
```

Still need to investigate more...

