# ETCD Auto Backup Service

### 프로젝트 소개
- etcd는 클러스터의 상태 정보 관리하기 위한 데이터 저장소로, 클러스터의 안정성과 신뢰성을 유지하는데 중요한 역할
- 기존 etcd backup service에서 나아가 auto-backup 기능과 버전 관리 기능을 제공
- 기존 etcd가 일정 시간이 지난 후 삭제되는 기능을 보완하여, 자주 접근되는 hot 데이터와 오래된 cold 데이터를 이중화 구조로 외부 저장소에 저장
- Helm 패키징을 통해 사용자의 편리성을 높여 낮은 진입 장벽 제공

### Architecture
- `watch-events.py`: watch api 감지
- `etcd-deployment.yaml`: watch api 프로그램 이미지를 실행
- `etcd-backup-configmap.yaml`: etcdctl 명령을 실행하고, snapshot을 oracle storage에 저장
- `etcd-backup-job.yaml`: configmap을 통해 저장된, snapshot 및 backup 작업을 수행

[아키텍처 사진]()

### What is Watch-API?
- Kubernetes API 서버와의 실시간 상호작용을 위한 메커니즘
- K8S Events-API vs Watch-API
> Events API :  클러스터에서 발생하는 이벤트에 대한 정보를 조회하는 API, 실시간보다는 과거의 이벤트 조회에 적합
> Watch-API: Kubernetes API 서버와 실시간으로 통신 및 리소스의 변경을 감지하고 모니터링

### Singleton Pattern
- Deployment를 통한 watch-api 감지 애플리케이션 배포
- Deployment에 Singleton Pattern을 적용
- Singleton Pattern :  동시에 하나의 어플리케이션 인스턴스만 활성
