import subprocess
from etcd import Client

def deploy_kubernetes_job():
    # Job YAML 파일 경로
    job_yaml_path = "etcd-backup-job.yaml"

    # kubectl apply 커맨드 명령 실행
    subprocess.run(["kubectl", "apply", "-f", job_yaml_path])

    print("Kubernetes Job이 배포되었습니다!")

def watch_etcd_changes():
    # etcd에 연결
    client = Client(host='localhost', port=2379)

    # 변경사항 감지를 위해 etcd의 모든 키 사용
    key = '/'

    # 감지 시작
    watcher = client.watch(key, recursive=True)

    # 이벤트 반복 처리
    for event in watcher:
        # 이벤트 처리
        print("detected change from etcd:", event)

        # Kubernetes Job 배포
        deploy_kubernetes_job()

# 변경사항 감지 및 변경 발생 시 Kubernetes Job 배포 시작
watch_etcd_changes()
