# Lightweight CI/CD 플랫폼
### 시스템 개요 및 구현환경
개발자의 자동화 테스트/빌드/배포를 도와주기 위해 최소한의 기능만 포함한 Lightweight CI/CD 플랫폼을 개발하는 것이 목적이다.

###### 주요 목표
- [eShopOnContainers](https://github.com/dotnet-architecture/eShopOnContainers)와 같은 레퍼런스 플랫폼이다.
- Github API 연동, 컨테이너 생성, 삭제, 사용자 정의 스크립트 실행 등의 최소한의 기능만 포함한다.
- MSA 아키텍처를 활용하여 시스템을 개발한다.
- 최소한의 요구사항만 고려하여 개발을 진행한다.

###### Angular 및 Main 서비스 요구사항
- 웹 인터페이스 필요
- Firebase Auth를 통해 Github 로그인 구현
- 사용자의 ID 생성 및 Access Token 등록
- 저장소 CI/CD 활성화 비활성화 토글
- 사용자 저장소 목록

###### Controller 서비스 요구사항
- 분산된 서비스와 비동기 통신
- Worker 목록 정보 관리
- Worker 작업 할당
- 작업 상태보고

###### Worker 관리자 요구사항
- 분산된 Worker 그룹과 비동기 통신 및 관리

###### Worker 요구사항
- Docker 컨테이너를 관리하는 프로세스 필요
- 설정파일에 따라 Image Pulling 및 컨테이너 생성
- 컨테이너 삭제, 저장소 Clone, 사용자 스크립트 실행
- Github 저장소 Clone 및 설정 파일 읽어오기

###### 구현환경

Docker를 기본 인프라로 사용한다. API 서버간 비동기 통신을 위해 RabbitMQ를 사용하며, 요청된 작업 상태관리를 위해 MongoDB를 사용한다.
영구적으로 관리되어야 하는 데이터는 Postgres Database를 활용한다. 사용자 인터페이스는 Angular를 사용하며, OAuth 인증을 위해 Firebase Auth 라이브러리를 적용한다.
CI/CD 처리 트랜잭션에 Choreography-Based Saga 패턴을 적용한다.

- Github API: Github API 연계를 통해 사용자 정보 및 저장소 목록 정보를 읽어올 수 있다.
- Postgres Database: Main 서비스에서 영구적으로 데이터 저장하기 위해 사용한다.
- MongoDB: Controller 서비스에서 실시간 작업 로그 등을 저장하고 관리하기 위해 사용한다.
- Spring Cloud Stream & RabbitMQ: Main, Controller, Worker 서비스 간 비동기 메시지 통신을 위해 사용한다.
- Spring Cloud Gateway: API 게이트웨이, 인증, Rest API 라우팅을 위해 사용한다.
- Docker (docker-swarm mode): 컨테이너를 관리하기 위해 사용한다.
- Spring Cloud Circuit Breaker: Resiliency 구현을 위해 사용한다.
- Spring Boot: Rest API 구현을 귀해 사용한다.
- MyBatis3 or JPA: 데이터베이스 연결을 위해 사용한다.
- Angular 12: 웹 페이지 개발을 위해 사용한다.

###### 시스템 구성도

![class-diagram](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/ccw-lab/A/main/arch.puml)

###### 설치 환경 및 데모 서비스 캡쳐

# 각 서비스의 기능 및 설계
###### API 스펙 문서

[API 스펙 문서](https://raw.githubusercontent.com/ccw-lab/a-main/master/openapi.json) 는 Springdoc을 이용해 정의하였으며 Main 서비스의 API 스펙을 제공한다.

###### 비지니스 로직 



# 시스템의 개요 및 구현환경
##### 본인이 개발하고자 하는 시스템의 개요를 설명
-  시스템의 목적 및 구성에 대해 설명

##### 개발하고자 하는 시스템의 구현환경을 설명
- 서비스 구현환경 설명
- 특히, 필수요구사항을 구현하기 위해 사용할 도구들을 설명
- 설치한 환경을 화면 캡쳐하여 보여 주고, 데모 서비스 구현
