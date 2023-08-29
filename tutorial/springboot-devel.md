## springboot 어플리케이션 개발 ##

스프링 개발 방법론에 의해, 컨트롤러, 엔터티, 레포지토리 등의 클래스 들을 구현한다.  
전체 소스 코드는 https://github.com/gnosia93/eks-on-aws-springboot 를 참고 한다.

단순 테스트 목적이라면, 이 챕터를 건너뛰고 [#5. CI 구성하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-codepipe-line.md) 으로 이동한다. 

## Code Snippet ##

스프링 부트 개발에 대한 좀 더 자세한 설명은 https://goddaehee.tistory.com/238 를 참고한다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/spring-comp.png)

### 1. Controller ###

웹브라우저로 부터 요청이 오면, 컨트롤러가 받아서 URI 맵핑 기준으로 처리하고, Service 객체를 호출해서 응답 결과를 반환한다.
```
package com.example.shop.controller;

import com.example.shop.dto.MemberDto;
import com.example.shop.service.MemberService;
import com.example.shop.exception.MemberNotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RequestMapping(value="/member")
@RestController
public class MemberController {

    private final Logger logger = LoggerFactory.getLogger(this.getClass());
    @Autowired
    private MemberService memberService;

    @ResponseBody
    @RequestMapping(value="/{memberId}", method=RequestMethod.GET)
    public ResponseEntity<?> findMember(@PathVariable Integer memberId) throws MemberNotFoundException {
        MemberDto memberDto = memberService.findMember(memberId);

        // 예외를 메시지 처리하는 방법?
        // 현재는 500 에러로 트레이스 됨.
        return ResponseEntity.status(HttpStatus.OK).body(memberDto);
    }

    @ResponseBody
    @RequestMapping(value="/list", method=RequestMethod.GET)
    public ResponseEntity<List<?>> listMember() {
        List<MemberDto> memberDtolist = memberService.findAllMember();
        return ResponseEntity.status(HttpStatus.OK).body(memberDtolist);
    }

    @ResponseBody
    @RequestMapping(value="/add", method= RequestMethod.POST)
    public ResponseEntity<?> addMember(@RequestBody MemberDto memberDto) {
        MemberDto addedMemberDto = memberService.add(memberDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(addedMemberDto);
    }

    @ResponseBody
    @RequestMapping(value="/{memberId}", method=RequestMethod.PUT)
    public ResponseEntity<?> updateMember(@PathVariable Integer memberId, @RequestBody MemberDto memberDto ) throws MemberNotFoundException {
        MemberDto updatedMemberDto = memberService.updateMember(memberId, memberDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedMemberDto);
    }

}
```

### 2. Dto (Data to Object) ###
정규화 되어진 데이터베이스 테이블을 표현하는 Entity 콤포넌트와 사용자 UI 단의 입/출력을 책임지는 Request 또는 Response 객체간의 메핑을 담당하는 클래스가 바로 Dto 이다. 이 예제에서는 MemberDto 가 입력/출력을 모두 담당하고 있다. 사용자 UI 상으로 출력되는 데이터들은 데이터베이스 테이블 설계와는 달리 비즈니스 요건에 맞게 상당히 반정규화 되게 된다. 즉 여러 데이터베이스 테이블간의 조인의 결과이다. 스프링 부트에서는 여러 Entity 간의 조인의 결과에 해당하겠다. 
```
package com.example.shop.dto;

import com.example.shop.entity.Member;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class MemberDto {
    private int memberId;
    private String password;
    private String name;
    private String phoneNumber;
    private String emailAddress;

    @Builder
    public MemberDto(int memberId, String password, String name, String phoneNumber, String emailAddress ) {
        this.memberId = memberId;
        this.password = password;
        this.name = name;
        this.phoneNumber = phoneNumber;
        this.emailAddress = emailAddress;
    }

    public Member toEntity() {
        return Member.builder()
                .password(this.password)
                .name(this.name)
                .phoneNumber(this.phoneNumber)
                .emailAddress(this.emailAddress)
                .build();
    }
}
```

### 3. Service ###
요청에 대한 비즈니스 로직을 수행하는 Component 로, Controller는 해당 비즈니스 로직을 수행하기 위한 Service를 호출한다.
Service는 로직 수행 후 결과를 Controller에게 반환한다.
```
package com.example.shop.service;

import com.example.shop.entity.Member;
import com.example.shop.dto.MemberDto;
import com.example.shop.repository.MemberRepository;
import com.example.shop.exception.MemberNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@RequiredArgsConstructor
@Service
public class MemberService {

    // 서비스 메소스 호출시 In/Out 는 Dto 이다.
    // Controller 는 Entity 의 존재를 알지 못한다.
    // 서비스는 트랜잭션을 처리한다.

    @Autowired
    MemberRepository memberRepository;

    @Transactional
    public MemberDto add(MemberDto memberDto) {
        Member member = memberRepository.save(memberDto.toEntity());

        return MemberDto.builder()
                .memberId(member.getMemberId())
                .password(member.getPassword())
                .name(member.getName())
                .emailAddress(member.getEmailAddress())
                .phoneNumber(member.getPhoneNumber())
                .build();
    }

    public MemberDto findMember(Integer memberId) throws MemberNotFoundException {
        Optional<Member> optMember = memberRepository.findById(memberId);

        Member member = optMember.orElseThrow(MemberNotFoundException::new);
        return MemberDto.builder()
                .memberId(member.getMemberId())
                .password(member.getPassword())
                .name(member.getName())
                .phoneNumber(member.getPhoneNumber())
                .emailAddress(member.getEmailAddress())
                .build();
    }

    public List<MemberDto> findAllMember() {
        List<Member> memberList = memberRepository.findAll();
        List<MemberDto> memberDtoList = new ArrayList<MemberDto>();

        for (Member member : memberList ) {
            MemberDto memberDto = MemberDto.builder()
                    .memberId(member.getMemberId())
                    .password(member.getPassword())
                    .name(member.getName())
                    .phoneNumber(member.getPhoneNumber())
                    .emailAddress(member.getEmailAddress())
                    .build();
            memberDtoList.add(memberDto);
        }
        return memberDtoList;
    }

    public MemberDto updateMember(int id, final MemberDto memberDto) throws MemberNotFoundException {
        Optional<Member> optMember = memberRepository.findById(id);
        Member member = optMember.orElseThrow(MemberNotFoundException::new);

        if(memberDto.getName() != null)
            member.setName(memberDto.getName());
        if(memberDto.getPassword() != null)
            member.setPassword(memberDto.getPassword());
        if(memberDto.getPhoneNumber() != null)
            member.setPhoneNumber(memberDto.getPhoneNumber());
        if(memberDto.getEmailAddress() != null)
            member.setEmailAddress(memberDto.getEmailAddress());

        Member savedMember = memberRepository.save(member);
        return MemberDto.builder()
                .memberId(savedMember.getMemberId())
                .password(savedMember.getPassword())
                .name(savedMember.getName())
                .emailAddress(savedMember.getEmailAddress())
                .phoneNumber(savedMember.getPhoneNumber())
                .build();
    }
}
```

### 4. Repository ###
Entity 에 대한 CRUD 를 담당하는 인터페이스로 실제 구현체는 별도로 존재한다 (예-Hibernate) 
```
package com.example.shop.repository;

import com.example.shop.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MemberRepository extends JpaRepository<Member, Integer> {
}
```

### 5. Entity ###
RDB 의 테이블과 1 대 1 로 매핑되는 오브젝트 이다.
```
package com.example.shop.entity;

import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "member")
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "member_id")
    private int memberId;

    @Column(name = "password")
    private String password;

    @Column(name = "name")
    private String name;

    @Column(name = "phone_no")
    private String phoneNumber;

    @Column(name = "email_addr")
    private String emailAddress;

    @Builder
    public Member(String name, String password, String phoneNumber, String emailAddress) {
        this.name = name;
        this.password = password;
        this.phoneNumber = phoneNumber;
        this.emailAddress = emailAddress;
    }
}
```

### 6. gradle.build ###
그래들(Gradle)은 그루비(Groovy)를 기반으로 한 빌드 도구로 Ant, Maven과 같은 이전 세대 빌드 툴의 단점을 보완하고 장점을 취합하여 만든 오픈소스로 공개된 빌드 자동화 도구이다. 라이브러리를 간편하게 추가하고 관리할 수 있고, 버전도 효율적으로 동기화해서 개발자가 비즈니스 로직에 집중할 수 있게 도와준다.
```
plugins {
	id 'java'
	id 'org.springframework.boot' version '3.1.2'
	id 'io.spring.dependency-management' version '1.1.2'
}

group = 'com.example'
version = '0.0.1-SNAPSHOT'

java {
	sourceCompatibility = '17'
	targetCompatibility = '17'
}

configurations {
	compileOnly {
		extendsFrom annotationProcessor
	}
}

repositories {
	mavenCentral()
}

dependencies {
	implementation 'org.springframework.boot:spring-boot-gradle-plugin:3.1.2'
	implementation 'org.springframework.boot:spring-boot-starter-actuator'
	implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
	implementation 'org.springframework.boot:spring-boot-starter-web'
	compileOnly 'org.projectlombok:lombok'
	developmentOnly 'org.springframework.boot:spring-boot-devtools'
	annotationProcessor 'org.projectlombok:lombok'
	testImplementation 'org.springframework.boot:spring-boot-starter-test'

	runtimeOnly 'com.mysql:mysql-connector-j'
}

tasks.named('test') {
	useJUnitPlatform()
}
```

### 7. properties ###

#### application.yaml ####
```
spring:
  profiles:
    active: dev

# http://localhost:8080/actuator/health
management:
  endpoints:
    web:
      exposure:
        include: health, info
```

#### application-dev.yml ####
```
server:
  port: 8080
spring:
  application:
    name: springboot-shop-dev
  jpa:
#    database-platform: org.hibernate.dialect.MySQL5InnoDBDialect
#    hibernate:
#      ddl-auto: update
#      naming:
#        physical-strategy: org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
#    generate-ddl: false
    show-sql: true
    properties:
      hibernate:
        format_sql: true

  datasource:
    url: jdbc:mysql://localhost:3306/shop
    username: shop
    password: shop
    driver-class-name: com.mysql.cj.jdbc.Driver

logging.level.root : info
```

#### application-stage.yml ####
```
server:
  port: 8080
spring:
  application:
    name: springboot-shop-stage
#  jpa:
#    database-platform: org.hibernate.dialect.MySQL5InnoDBDialect
#    hibernate:
#      ddl-auto: update
#      naming:
#        physical-strategy: org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
#    generate-ddl: false
#    show-sql: true
#    properties:
#      hibernate:
#        format_sql: true

  datasource:
    url: jdbc:mysql://${DB_ENDPOINT}:3306/shop
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    driver-class-name: com.mysql.cj.jdbc.Driver

logging.level.root : info
```

## 참고자료 ##
* [Springboot Connection Pool 설정방법](https://oingdaddy.tistory.com/415)
  
* https://goddaehee.tistory.com/203

* [스프링 부트 로그 설정](https://goddaehee.tistory.com/206)

* [스프핑 부트 JPA](https://goddaehee.tistory.com/209)

* [ValueObject](https://tecoble.techcourse.co.kr/post/2020-06-11-value-object/)

* [[Spring Boot] @NotNull, @NotEmpty, @NotBlank 의 차이점 및 사용법](https://sanghye.tistory.com/36)
* [JSON 응답과 요청 처리](https://velog.io/@injoon2019/%EC%8A%A4%ED%94%84%EB%A7%81-%EC%8A%A4%ED%94%84%EB%A7%815-%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%B0%8D-%EC%9E%85%EB%AC%B8-16-%EC%9E%A5-JSON-%EC%9D%91%EB%8B%B5%EA%B3%BC-%EC%9A%94%EC%B2%AD-%EC%B2%98%EB%A6%AC)

* [RestAPI 예제](https://penthegom.tistory.com/29)

* [스프링부트 작업환경 분리](https://velog.io/@leesomyoung/SpringBoot-%EC%9E%91%EC%97%85-%ED%99%98%EA%B2%BD-%EB%B6%84%EB%A6%AC%ED%95%98%EA%B8%B0)
