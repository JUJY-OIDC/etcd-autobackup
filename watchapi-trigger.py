import os
from kubernetes import client, config, watch
from kubernetes.stream import stream

# k8s 연결 인증 정보 불러오기
config.load_kube_config()   # 쿠버네티스 클러스터 연결
api_client = client.CoreV1Api()   # k8s api_client 객체 생성

# watch api 객체 생성
w_api = watch.Watch()
ns = os.getenv('NAMESPACE', 'default')

# watch API로 변경 사항 감지
for event in w_api.stream(api_client.list_namespaced_pod, namespace=ns):     # default ns의 파드에 대한 리소스 변경 감지
    if event['type'] == 'ADDED':    # 파드 추가 시의 로직
        print("New pod added:", event['object'].metadata.name)
    elif event['type'] == 'DELETED':    # 파드 삭제 시의 로직
        print("Pod deleted:", event['object'].metadata.name)
    elif event['type'] == 'MODIFIED':   # 파드 수정 시의 로직
        print("Pod modified:", event['object'].metadata.name)