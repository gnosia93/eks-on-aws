![](https://github.com/gnosia93/eks-on-aws/blob/main/images/eks-on-aws-archi-2.png)

  이 워크샵은 EKS 환경으로 어플리케이션 이동하고자 하는 스프링 개발자들을 위해 만들어 졌습니다.  

* [#1. 기본 인프라 구성](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/basic-infra.md)

* [#2. EKS 클러스터 설치](https://github.com/gnosia93/container-on-aws/blob/main/tutorial/eks-cluster-launch.md)

* [#3. 데이터베이스 스키마 생성](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/database-schema.md)

* #4. 스프링 부트 어플리케이션 만들기

  * [프로젝트 생성](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/springboot-shop.md)

  * [스프링 부트 어플리케이션 개발](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/springboot-devel.md)

  * [스프링 부트 - Redis 분산락 구현 (상품 판매수량 제한)](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/springboot-distlock.md)
  
  * 스프링 부트 - 로그인 구현
    * [Redis 세션 기반 인증](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/springboot-session.md)
    * [JWT 토큰 기반 인증](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/springboot-jwt.md)(p)
 
  * [스프링 부트 - Secret Manager 데이터베이스 설정 분리 / 암호화](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/springboot-secretmanager.md)
 
  * [스프링 부트 - 환경변수로 Properties 값 주입하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/springboot-env.md)
  
  * [스프링 부트 - 액츄에이터로 health check 설정하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/springboot-actuator.md) 

  * [스프링 부트 - Swagger 설정 및 URL 테스트](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/springboot-postman.md)


    
* [#5. AWS CodePipeline CI 구성하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-codepipe-line.md)


* #6. EKS 에 어플리케이션 배포하기

  - [Nginx 배포해 보기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-nginx-deploy.md)

  - [스프링 부트 수동 배포하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-manual-deploy.md)

  - [ArgoCD 로 GitOps 구현하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-argo-cd.md)

 
* [#7. Fluent Bit로 EKS 어플리케이션 로그 수집하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-logging.md)

* #8. 클러스터 오토 스케일링

  - [HPA (HorizontalPodAutoscaler)](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-hpavpa.md)
    
  - [Cluster AutoScaler 설치](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-ca.md)

  - [Karpenter 설치](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-karpenter.md)

  - [노드 스케일링 테스트](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-scale-test.md)

* #9. 성능 메트릭 모니터링(Observability)
  
  - [CloudWatch Container Insight 설치](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/cloudwatch-container-insight.md)(?)
    
  - [Kubernetes 지표 서버 설치](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-metrics.md)

  - [Amazon Managed Service for Prometheus / Grafana 와 OpenTelemetry 연동하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-amp.md)

  - [모던 그라파나 대시보드 for K8S](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/grafana-eks-chart.md) 

  - [SSO 을 위한 Keycloak 서버 구축 - AMG 연동](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/sso-keycloak.md)
 
  - [OpenTelemetry 스프링 부트 메트릭 수집하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/springboot-grafana.md)

  - AMP / AMG 모니터링 확장하기 
    - [RDS MySQL](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/rds-monitoring.md)
    - [ElastiCache For Redis](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/redis-monitoring.md)


* [#10. 웹어플리케이션 성능 테스트](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/perf-locust.md)

* [#11. Istio 적용하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/k8s-istio.md)(p)

* [#12. 리소스 삭제](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/resource-drop.md)

* Appendix. [k8s 운영](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/k8s-op.md)

* Source Repo. https://github.com/gnosia93/eks-on-aws-springboot

## Revision History ##

* 2023-09-11 First Released
  
## 레퍼런스 ##

* [https://www.eksworkshop.com/](https://archive.eksworkshop.com/010_introduction/)
* [https://ecsworkshop.com/](https://ecsworkshop.com/)
* https://catalog.workshops.aws/observability/ko-KR
