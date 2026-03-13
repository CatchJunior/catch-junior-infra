COMPOSE_DIR  = docker
COMPOSE_FILE = $(COMPOSE_DIR)/docker-compose.yml
MONITOR_FILE = $(COMPOSE_DIR)/docker-compose.monitor.yml
ENV_FILE     = $(COMPOSE_DIR)/.env

.PHONY: up down restart logs ps monitor monitor-down clean help

## 기본 인프라 (Postgres, Redis, Kafka, ES) 실행
up:
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up -d
	@echo ""
	@echo "✅ 인프라 기동 완료"
	@echo "   Kafka UI  → http://localhost:8989"
	@echo "   Postgres  → localhost:5432"
	@echo "   Redis     → localhost:6379"
	@echo "   Kafka     → localhost:9092"
	@echo "   ES        → http://localhost:9200"

## 기본 인프라 중지
down:
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down

## 기본 인프라 재시작
restart: down up

## 모니터링 (Prometheus + Grafana) 실행 — 기본 인프라 먼저 실행 필요
monitor:
	docker compose -f $(MONITOR_FILE) --env-file $(ENV_FILE) up -d
	@echo ""
	@echo "✅ 모니터링 기동 완료"
	@echo "   Prometheus → http://localhost:9090"
	@echo "   Grafana    → http://localhost:3001  (admin / admin)"

## 모니터링 중지
monitor-down:
	docker compose -f $(MONITOR_FILE) --env-file $(ENV_FILE) down

## 전체 실행 (인프라 + 모니터링)
all: up monitor

## 전체 중지
all-down: monitor-down down

## 컨테이너 로그 (서비스명 지정 가능: make logs s=kafka)
logs:
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) logs -f $(s)

## 컨테이너 상태 확인
ps:
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) ps

## 볼륨 포함 완전 삭제 (데이터 초기화)
clean:
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down -v
	docker compose -f $(MONITOR_FILE) --env-file $(ENV_FILE) down -v
	@echo "⚠️  볼륨 삭제 완료 — 모든 데이터가 초기화되었습니다."

## 도움말
help:
	@echo ""
	@echo "사용 가능한 명령어:"
	@echo "  make up           기본 인프라 실행"
	@echo "  make down         기본 인프라 중지"
	@echo "  make restart      기본 인프라 재시작"
	@echo "  make monitor      모니터링 실행"
	@echo "  make monitor-down 모니터링 중지"
	@echo "  make all          전체 실행"
	@echo "  make all-down     전체 중지"
	@echo "  make logs         전체 로그 (make logs s=kafka 로 특정 서비스)"
	@echo "  make ps           컨테이너 상태"
	@echo "  make clean        볼륨 포함 전체 삭제"
	@echo ""
