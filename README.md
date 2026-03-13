# CatchJunior Infra

캐치주니어의 인프라 및 CI/CD 설정. Jenkins 파이프라인, Docker Compose, AWS 배포, 모니터링 설정을 포함합니다.

## 기술 스택

- **CI/CD**: Jenkins (Declarative Pipeline)
- **컨테이너**: Docker & Docker Compose
- **클라우드**: AWS EC2, S3
- **모니터링**: Prometheus & Grafana

## 디렉토리 구조

```
CatchJunior_Infra/
├── jenkins/
│   └── Jenkinsfile          # 선언형 파이프라인 정의
├── docker/
│   ├── docker-compose.yml           # 전체 서비스 구성
│   ├── docker-compose.monitor.yml   # Prometheus + Grafana
│   └── dockerfiles/
│       ├── Dockerfile.back          # 백엔드 이미지
│       ├── Dockerfile.front         # 프론트엔드 이미지
│       └── Dockerfile.crawling      # 크롤러 이미지
├── prometheus/
│   └── prometheus.yml       # 스크레이핑 설정
└── grafana/
    └── dashboards/          # 대시보드 JSON
```

## CI/CD 파이프라인

```
GitHub Push
    │
    ▼
Jenkins (Webhook 수신)
    │
    ├─ 1. Checkout
    ├─ 2. Test (단위 테스트)
    ├─ 3. Build (Gradle / npm)
    ├─ 4. Docker Image Build & Push
    └─ 5. Deploy to AWS EC2 (SSH)
```

### Jenkinsfile 주요 단계

| Stage | 설명 |
|-------|------|
| `Checkout` | GitHub에서 소스 체크아웃 |
| `Test` | `./gradlew test` / `npm test` |
| `Build` | 빌드 아티팩트 생성 |
| `Dockerize` | Docker 이미지 빌드 및 레지스트리 푸시 |
| `Deploy` | EC2에 SSH 접속 후 `docker compose pull && up -d` |

## 로컬 개발 환경 실행

의존 인프라(PostgreSQL, Redis, Kafka, Elasticsearch)를 한 번에 실행합니다.

```bash
docker compose up -d
```

## 모니터링

```bash
# Prometheus + Grafana 실행
docker compose -f docker-compose.monitor.yml up -d
```

- **Prometheus**: `http://localhost:9090`
- **Grafana**: `http://localhost:3000` (admin / admin)

### 주요 모니터링 지표

- Kafka Consumer Lag (공고 처리 지연)
- Spring Boot Actuator 메트릭 (JVM, HTTP 응답시간)
- 에러 로그 알림

## AWS 인프라 구성

| 리소스 | 용도 |
|--------|------|
| EC2 | 애플리케이션 서버 (Back, Front, Kafka, ES) |
| S3 | 정적 에셋, 빌드 아티팩트 저장 |

## 시크릿 관리

민감 정보(DB 패스워드, FCM 키 등)는 Jenkins Credentials 또는 AWS Secrets Manager로 관리하며,
`.env` 파일은 절대 레포지토리에 커밋하지 않습니다.
