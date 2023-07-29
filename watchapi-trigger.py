import time, yaml
from kubernetes import client, config, watch, utils
from kubernetes import client as kubernetes_client

# k8s 연결 인증 정보 불러오기
config.load_kube_config()   # 쿠버네티스 클러스터 연결
api_client = client.CoreV1Api()   # CoreV1API 객체 생성
deploy_api_client = client.AppsV1Api() # AppsV1API 객체 생성

w_api = watch.Watch()   # watch api 객체 생성
k8s_client = kubernetes_client.ApiClient()  # load kubernetes client
job_yaml_file = "oci-etcd-backup-job.yaml"

# check if kube-system pod is system-critical or user-created
def is_system_pod(pod):
    return pod.metadata.labels.get("kube-system", False)

# unique identifier for `etcd-backup-job`
def updateJobName(job_manifest):
    timestamp = str(int(time.time()))
    job_manifest['metadata']['name'] = f"oci-etcd-backup-job-{timestamp}"

# job trigger function
def jobTriggerEvent(ns, resource):
    # Job을 Kubernetes 클러스터에 배포
    with open(job_yaml_file) as f:
        job_manifest = yaml.safe_load(f)

    updateJobName(job_manifest)

    ### not working ###
    if ns == "kube-system" and is_system_pod(resource):
        print("Skipping job deployment for kube-system system-critical pod: {}".format(resource.metadata.name))
        return

    # create pods with yaml file
    utils.create_from_yaml(k8s_client, yaml_objects=[job_manifest], namespace=ns)
    print("Job Deployed in namespace {} \n".format(ns))

# trigger job when Deployment object is deployed
def watchEtcdChanges(namespace, resource, event):
    if event in ["ADDED", "DELETED"]:
        print(f"{resource.metadata.name} has been {event}")

        jobTriggerEvent(namespace, resource)

def main():
    custom_ns = 'etcd-autobackup'
    # namespaces = [ns.metadata.name for ns in api_client.list_namespace().items]

    # 사용자가 제외하고자 하는 네임스페이스 리스트
    excluded_ns = ["calico-apiserver", "calico-system", "tigera-operator", "kube-system"]

    for event in w_api.stream(getattr(api_client, "list_RESOURCE_for_all_namespaces")):
        time.sleep(5)
        resource = event['object']
        event_type = event['type']
        
        if ("etcd-backup-job" in resource.metadata.name) or (resource.metadata.namespace in excluded_ns): continue
        watchEtcdChanges(custom_ns, resource, event_type)

if __name__=='__main__':
    main()
