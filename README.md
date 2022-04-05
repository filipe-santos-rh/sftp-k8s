## Prerequisites

### Create a new project to host the SFTP pod  
`oc new-project sftp`  

### Create a ConfigMap that will host your private key  
*In the below example, I am using a ConfigMap, however a Secret could be used instead.  If you decide to use a secret, you will also need to update the reference within the pod-svc.yaml file*  
`oc create configmap hostkey --from-file=/Path/To/Private/Key`  


### Create a ConfigMap that will host the public Key  
*In the below example, I am using a ConfigMap, however a Secret could be used instead.  If you decide to use a secret, you will also need to update the reference within the pod-svc.yaml file*  
`oc create configmap authorizedkeys --from-file=/Path/To/Public/Key`  

### Build and push the image that will be used to the Internal Registry
`podman build --tag sftp:latest -f Dockerfile`

### Retrieve your Openshift Token  
`oc whoami -t`  

### Retrieve the exposed route for you internal registry  
`HOST=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')`  

### Login to the registry  
`podman login -u'<Username>' -p=<Token> $HOST`  

### TAG the image to the registry  
`podman tag localhost/sftp:latest $HOST/sftp/sftp:latest`  

### Push the image to the registry  
`podman push $HOST/sftp/sftp:latest`

### Deploy the sftp application and service  
`oc create -f pod-svc.yaml`  

## How to connect to the service

The user that is being created within the script is `sre-user`.  

Here is an example of how to establish a connexion:  
`sftp -i /Path/To/Private/Key -P 2222 sre-user@sftp-svc`

If you must access the service from the outside world, you will need to create a NodePort or LoadBalancer Type service.  

Here is an example of LoadBalancer Port:  
```
apiVersion: v1
kind: Service
metadata:
  name: sftp-lb
  namespace: sftp
spec:
  ports:
  - name: sftp
    port: 2222
  loadBalancerIP:
  type: LoadBalancer 
  selector:
    run: sftp
```

Once the service is create, retrieve the External-IP:  
`SVC=$(oc get svc sftp-lb | awk {'print $4'} | grep -v EXTERNAL-IP)`

To connect:  
`sftp -i /Path/To/Private/Key -P 2222 sre-user@$SVC`

