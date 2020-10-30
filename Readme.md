#HOW TO SETUP AN ADMISSION VALIDATOR 

<b>MINISHIFT SETUP</b>
<hr/>

 - Enable Admission webhook plugin for minishift by running this on terminal
   ```
    minishift openshift config set --target=kube --patch '{
        "admissionConfig": {
            "pluginConfig": {
                "ValidatingAdmissionWebhook": {
                    "configuration": {
                        "apiVersion": "apiserver.config.k8s.io/v1alpha1",
                        "kind": "WebhookAdmission",
                        "kubeConfigFile": "/dev/null"
                    }
                },
                "MutatingAdmissionWebhook": {
                    "configuration": {
                        "apiVersion": "apiserver.config.k8s.io/v1alpha1",
                        "kind": "WebhookAdmission",
                        "kubeConfigFile": "/dev/null"
                    }
                }
            }
        }
    }'
   ```
 - Enable cert signing plugin for minishift 
   
    ```
    minishift openshift config set --target=kube --patch '{
    		"kubernetesMasterConfig": {
    		    "controllerArguments": {
    		        "cluster-signing-cert-file": ["/etc/origin/master/ca.crt"],
    		        "cluster-signing-key-file": ["/etc/origin/master/ca.key"]
    			  }
    		}
    }'
    ``` 
 - Create a csr ```deploy/artifacts/demo-csr.sh``` to generate ```server.csr``` and ```server-key.pem``` 
 - Create ```CertificateSigningRequest``` using ```deploy/artifacts/signing-request.yaml``` (add base encoded server.csr in request field)
 - Approve the certificate 
   
    ```
      kubectl certificate admission-webhook.kso-control.svc approve
    ```
 - Download the client certificate using
     
     ```
       oc get csr admission-webhook.kso-control.svc -o jsonpath='{.status.certificate}' \
           | base64 --decode > server.crt 
     ```
 - Use cluster's CA cert using 
   
    ```
      oc config view --raw -o yaml | grep 'certificate-authority-data:' | cut -d: -f2- | base64 --decode > ca.crt
    ```   
 - Convert CA cert from .crt to .pem format using (same for server.crt)
   
   ```
     openssl x509 -in certs/ca.crt -out certs/ca.pem  
   ```
   
 - Create secrets for the client certs using 
   
   ```
      oc create secret generic admission-webhook -n kso-control \
        --from-file=key.pem=certs/server-key.pem \
        --from-file=cert.pem=certs/server.pem
   ```
 
 - Create ```Deployment``` and ```Service``` for the webhook validator using ```deploy/artifacts/deployment.yaml```.
 
 - Create ```ValidatingWebhookConfiguration``` Object using ```deploy/artifacts/WebhookConfig.yaml```.