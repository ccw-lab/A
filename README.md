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
##### API 스펙 문서

[API 스펙 문서](https://raw.githubusercontent.com/ccw-lab/a-main/master/openapi.json) 는 Springdoc을 이용해 정의하였으며 Main 서비스의 API 스펙을 제공한다.

##### Main 서비스 

###### Github 연계기능
- 사용자의 JWT 토큰을 이용하여 Github API 연결을 위한 AccessToken을 가져올 수 있다.
- AccessToken을 이용하여 사용자 정보, 저장소 목록을 가져올 수 있다.

###### 저장소 CI/CD 활성화 요청 절차
1. 사용자가 특정 저장소에 CI/CD를 활성화/비활성화 한다.
2. 데이터베이스에 해당 저장소에 대한 활성화 여부를 저장한다.
3. 사용자가 요청하기전 까지 CI/CD 작업을 시작하지 않는다.

###### CI/CD 작업요청 절차
1. 사용자가 CI/CD 시작 요청을 하였을 때, Main 서비스는 RabbitMQ을 통해 Controller 서비스에 CI/CD 작업 시작을 요청한다.
2. RabbitMQ을 통해 Controller 서비스의 작업 상태를 보고 받는다. (성공, 실패, 진행에 관련된 보고)
3. 보고 받을때 마다 사용자에게 최신 상태로 데이터베이스를 업데이트 한다.

###### CI/CD 작업 상태확인 기능
- 사용자는 현재 CI/CD 작업 로그를 볼 수 있다. (단순 리프레시를 통해)
- 과거 CI/CD 작업의 처리 결과를 목록에서 확인할 수 있다.

###### CI/CD 작업중단 요청 절차
1. 사용자가 중단 요청을 하였을때 Main 서비스는 RabbitMQ을 통해 Controller 서비스에 CI/CD 작업 중단을 요청한다.
2. 요청과 마찬가지로 보고를 받고 데이터베이스를 업데이트 한다.

##### Controller 서비스

###### CI/CD 작업요청 절차
1. Main 서비스로 부터 작업요청을 받는다.
2. 등록된 Worker 목록에서 최근에 선택받지 못한 하나를 선택한다.
3. CI/CD 작업 수행메세지를 RabbitMQ를 통해 전달한다.
4. (모든 Worker가 작업을 수행할 수 없을 경우) Main 서비스에게 실패 보고를 전달한다. 또한 DB에 기록한다.
5. (만약 해당 Worker가 작업을 수행할 수 없을 경우) 다시 2번으로 이동한다. 또한 DB에 기록한다.
6. Main 서비스에게 시작 보고를 전달한다. 그리고 DB에 기록한다.

###### CI/CD 작업로그 전달 절차
1. Worker로 부터 작업로그를 전달받는다.
2. 로컬 MongoDB에 작업로그를 저장한다.
3. Main 서비스에게 작업로그 또는 작업결과를 보고한다.

###### CI/CD 작업 타임아웃
1. 타임아웃을 초과하였을 경우 실패를 기록하고 보고한다. (예를들어 10분)

###### Worker 등록 절차
1. Worker는 RabbitMQ를 통해 Worker 이름을 보낸다.
2. Worker 이름을 데이터베이스에 등록한다.

##### Worker 서비스

- 주로, 로컬에 설치된 Docker를 제어하는 서비스이다.
- 동기적인 명령으로만 구성된 스크립트만 정상적으로 수행할 수 있다.

###### Worker 서비스 재시작 시 컨테이너 정리
1) Spring Boot 시작과 함께, 모든 컨테이너를 중지 및 삭제한다.

###### CI/CD 작업수행 및 종료 절차
1. 메모리 등 작업을 수행할 리소스가 충분한지 확인한다.
2. 작업에 해당되는 임시 디렉토리를 생성하고 저장소를 Clone 및 특정 Commit으로 Checkout 한다.
3. 요청한 이미지로 컨테이터를 생성하고 임시 디렉토리를 마운트 한다.
4. CI/CD 스크립트를 순서대로 실행한다. (가장 앞에는 시작을 알리는 파일생성 등)
5. 스크립트의 종료 신호(종료 파일생성 등)를 확인 한 뒤, Controller 서비스에 결과를 보고한다.
6. 임시 디렉토리를 삭제한다.
7. 컨테이너를 중지 및 삭제한다.

###### CI/CD 스크립트 수행 과정에서 문제가 발생할 경우
- 모든 작업 수행에는 타임아웃을 둔다. 초과할 경우 실패를 보고한다.
- 스크립트를 대신 실행해주는 프로세스를 두어 실패를 캐치할 수 있다. (모든 컨테이너에서 실행가능한 프로그램 이여야 함)

##### RabbitMQ

- 인가되지 않은 Worker가 접속할 수 없도록 인증을 사용한다.
- 2가지 채널을 운영한다. (controller 채널과 worker 채널, 필요에 따라 증가할 수 있음) 

# 시스템의 개요 및 구현환경
##### 본인이 개발하고자 하는 시스템의 개요를 설명
-  시스템의 목적 및 구성에 대해 설명

##### 개발하고자 하는 시스템의 구현환경을 설명
- 서비스 구현환경 설명
- 특히, 필수요구사항을 구현하기 위해 사용할 도구들을 설명
- 설치한 환경을 화면 캡쳐하여 보여 주고, 데모 서비스 구현
