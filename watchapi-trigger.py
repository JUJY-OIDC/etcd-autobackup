import time, yaml
from kubernetes import client, config, watch, utils
from kubernetes import client as kubernetes_client

# k8s 연결 인증 정보 불러오기
config.load_kube_config()   # 쿠버네티스 클러스터 연결
api_client = client.CoreV1Api()   # k8s api_client 객체 생성
batch_api = client.BatchV1Api()  # k8s batch api_client 객체 생성

w_api = watch.Watch()   # watch api 객체 생성
k8s_client = kubernetes_client.ApiClient()  # load kubernetes client

def update_job_name(job_manifest):
    timestamp = str(int(time.time()))
    job_manifest['metadata']['name'] = f"etcd-backup-job-{timestamp}"

def watch_etcd_changes(ns):
    job_yaml_file="oci-etcd-backup-job.yaml"

    # Job을 Kubernetes 클러스터에 배포
    with open(job_yaml_file) as f:
        job_manifest = yaml.safe_load(f)

    update_job_name(job_manifest)

    # create pods with yaml file
    utils.create_from_yaml(k8s_client, yaml_objects=[job_manifest], namespace=ns)
    print("Job Deployed in namespace {}".format(ns))
    
def main():
    namespaces = [ns.metadata.name for ns in api_client.list_namespace().items]
    
    # 사용자가 제외하고자 하는 네임스페이스 리스트
    excluded_ns = ['calico-apiserver', 'calico-system', 'tigera-operator']
    
    for namespace in namespaces:
        print('------------------------')
        print(namespace)
        print('------------------------')
        if namespace in excluded_ns: continue
        else:
            resource_type = input('Enter resource type:' )
            for event in w_api.stream(getattr(api_client, "list_namespaced_{0}({1},watch=False)".format(resource_type,namespace))):
                time.sleep(7)
                resource = event['object']
                if event['type'] in ['ADDED', 'DELETED', 'MODIFIED', 'UPDATED']:
                    print("Resource changed: {0} {1}".format(event['type'], resource.metadata.name))

                watch_etcd_changes(namespace)

if __name__=='__main__':
    main()