import os
from kubernetes import client, config, watch
from kubernetes.stream import stream

# k8s 연결 인증 정보 불러오기
config.load_kube_config()   # 쿠버네티스 클러스터 연결
api_client = client.CoreV1Api()   # k8s api_client 객체 생성
batch_api = client.BatchV1Api()  # k8s batch api_client 객체 생성

w_api = watch.Watch()   # watch api 객체 생성
ns = os.getenv('NAMESPACE', 'default')  # job을 배포할 ns

# watch API로 변경 사항 감지
for event in w_api.stream(api_client.list_pod_for_all_namespaces):     # 모든 네임스페이스의 파드에 대한 리소스 변경 감지
    resource = event['object']
    if event['type'] in ['ADDED', 'DELETED', 'MODIFIED']:    # 리소스 변경 시의 로직
        print("Resource changed: {0} {1}".format(event['type'], resource.metadata.name))

        # job = client.V1Job(api_version="batch/v1", kind="Job", metadata=client.V1ObjectMeta(name="nginx"))
        # batch_api.create_namespaced_job(namespace=ns, body=job)
