drop database if exists 회사;

create database 회사 default charset utf8mb4 collate utf8mb4_general_ci;

use 회사;

create table 부서(
	부서번호 char(2) primary key,
    부서명 varchar(20)
) default charset=utf8mb4;

create table 사원(
	사원번호 char(3) primary key,
    이름 varchar(20),
    영문이름 varchar(20),
    직위 varchar(10),
    성별 char(2),
    생일 date,
    입사일 date,
    주소 varchar(50),
    도시 varchar(20),
    지역 varchar(20),
    집전화 varchar(20),
    상사번호 char(3),
    부서번호 char(2)
) default charset=utf8mb4;

create table 고객(
	고객번호 char(5) primary key,
    고객회사명 varchar(30),
    담당자명 varchar(20),
    담당자직위 varchar(20),
    주소 varchar(50),
    도시 varchar(20),
    지역 varchar(20),
    전화번호 varchar(20),
    마일리지 int
) default charset=utf8mb4;

create table 제품(
	제품번호 int primary key,
    제품명 varchar(50),
    포장단위 varchar(30),
    단가 int,
    재고 int
) default charset=utf8mb4;

create table 주문(
	주문번호 char(5) primary key,
    고객번호 char(5),
    사원번호 char(3),
    주문일 date,
    요청일 date,
    발송일 date
) default charset=utf8mb4;

create table 주문세부(
	주문번호 char(5),
    제품번호 int,
    단가 int,
    주문수량 int,
    할인율 float,
    primary key(주문번호, 제품번호) -- 복합키 설정(1:N 관계)
    /*외부 테이블의 PK를 참조하는 외래키 설정
	  foreign key (주문번호) references 주문(주문번호)
      */
) default charset=utf8mb4;

create table 마일리지등급(
	등급명 char(1) primary key,
    하한마일리지 int,
    상한마일리지 int
) default charset=utf8mb4;
