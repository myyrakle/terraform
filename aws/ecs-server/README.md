# ecs-server

## 개요

- ECS Fargate룰 기반으로 구성된 서버 및 CI/CD 설정입니다.

## 리소스 구성

1. ECS (Fargate + Auto Scaling)
2. ECR
3. Elastic Loadbalancer
4. Code Pipeline
5. S3

## before

1. docker 디렉터리에서 원하는 환경의 buildspec.yml과 Dockerfile, run.sh를 선택하고, 그것을 배포하고자 하는 프로젝트 github 루트 경로에 저장해서 push합니다.
2. 서버에는 status code 200 응답을 반환하는 health check API가 존재해야 합니다.
3. 서버는 프로덕션 버전에서 80 포트로 실행되어야 합니다.

## required parameter

1. region: 리전 정보입니다. 서울이라면 ap-northeast-2 값을 넘겨줍니다.
2. vpc_id: vpc id입니다. 2개 이상의 AZ 서브넷이 있어야 합니다.

## info

1. cloudformation 초기 구성에는 5분 정도 걸립니다.
2. code pipeline 최초 완료시에는 3분 정도 걸립니다.

## after

1. 동작 확인 후 Cloudflare 등에서 로드밸런서의 도메인 레코드를 설정해줍니다. [참고](https://blog.naver.com/sssang97/222913100848)
2. 필요하다면 code pipeline에서 슬랙 알림을 추가해줍니다.
