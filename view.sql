-- 데이터베이스에서 사원 테이블을 사용하여 사원의 이름, 집전화, 입사일, 주소를 보이는 뷰를 작성
create or replace view view_사원
as
select 이름, 집전화 as 전화번호, 입사일, 주소
from 사원;

create or replace view view_사원(이름, 전화번호, 입사일, 주소)
as
select 이름, 집전화 as 전화번호, 입사일, 주소
from 사원;

select *
from view_사원;

-- 제품 테이블, 주문세부 테이블을 조인하여 제품명과 주문수량합을 보이는 뷰를 작성
create or replace view view_제품별주문수량합
as
select 제품명, sum(주문수량) as 주문수량합
from 제품
inner join 주문세부
on 제품.제품번호 = 주문세부.제품번호
group by 제품명;

-- '여'사원에 대하여 사원의 이름, 집전화, 입사일, 주소, 성별을 보이는 뷰를 작성
create or replace view view_사원_여
as
select 이름, 집전화 as 전화번호, 입사일, 주소, 성별
from 사원
where 성별 = '여';

/* 뷰 조회하기 */
select *
from view_사원_여
where 전화번호 like '%88%';

-- 'view_사원_여' 뷰로 주문사량합이 1,200개 이상인 레코드 검색
select *
from view_제품별주문수량합
where 주문수량합 >=1200;

/* 뷰 메타 정보 확인하기 */
select *
from information_schema.views
where table_name = 'view_사원';

show create view view_사원;

/* 뷰 삭제 */
drop view view_사원;

/* 뷰를 통한 데이터 삽입 */
insert into view_사원_여(이름, 전화번호, 입사일, 주소, 성별)
values('황여름','(02)587-4989','2023-02-10','서울시 강남구 청담동 23-5','여');
-- Error Code: 1423. Field of view 'company.view_사원_여' underlying table doesn't have a default value
-- 원본 테이블에는 뷰에 포함되지 않은 '필수 입력 컬럼'이 존재

create or replace view view_사원_여 -- 오류해결(표준sql)
as
select 사원번호, 이름, 집전화 as 전화번호, 입사일, 주소, 성별
from 사원
where 성별 = '여';

alter view view_사원_여 -- 오류해결(mysql)
as
select 사원번호, 이름, 집전화 as 전화번호, 입사일, 주소, 성별
from 사원
where 성별 = '여';

insert into view_사원_여(사원번호, 이름, 전화번호, 입사일, 주소, 성별)
values('E12','황여름','(02)587-4989','2023-02-10','서울시 강남구 청담동 23-5','여');

/* 데이터 삽입 조건 */
insert into view_제품별주문수량합
values('단짠 새우깡',250); -- Error Code: 1471. The target table view_제품별주문수량합 of the INSERT is not insertable-into
-- 수정이 불가능한 형태의 뷰(Non-updatable View)일 때 발생

/* with check option */
-- 'view_사원_여' 뷰를 사용하여 '남' 사원 정보를 추가하고 결과를 확인
insert into view_사원_여(사원번호, 이름, 입사일, 주소, 성별)
values('E13','강겨울','2023-02-10','서울시 성북구 장위동 123-7','남');

select *
from 사원
where 사원번호='E13';

create or replace view view_사원_여
as
select 사원번호, 이름, 집전화 as 전화번호, 입사일, 주소, 성별
from 사원
where 성별 = '여'
with check option; -- 뷰에서 사용된 조건식을 기반으로 데이터의 일관성을 보장하기 위한 제약조건, 뷰의 조건에 맞는 데이터만 승인

/* 인덱스 */
-- 날씨 테이블과 인덱스를 생성
create table 날씨
	(
		년도 int
        ,월 int
        ,일 int
        ,도시 varchar(20)
        ,기온 numeric(3,1)
        ,습도 int
        ,primary key(년도, 월, 일, 도시) -- 기본 인덱스
        ,index 기온인덱스(기온) -- 보조 인덱스
        ,index 도시인덱스(도시)
    );

/*
데이터베이스의 인덱스는 책의 맨 뒤에 있는 '찾아보기(색인)'와 똑같다.
인덱스는 조회(SELECT) 성능을 극대화하기 위한 정렬된 색인표
기본키 인덱스 (자동 생성)　WHERE 년도 = 2026 AND 월 = 5 AND 일 = 20 AND 도시 = '서울' 처럼
특정 날짜와 도시의 날씨를 찾을 때 빛의 속도로 찾아 낸다.

기온인덱스 (수동 생성)　기온 컬럼의 값들을 크기순(낮은 기온에서 높은 기온 순)으로 정렬한 별도의 색인 페이지를 만든다.
기온을 조건으로 검색하거나 정렬할 때 엄청나게 빨라진다
도시인덱스 (수동 생성)　도시 이름을 가나다순으로 정렬한 색인 페이지를 만든다.
WHERE 도시 = '부산' 처럼 특정 도시의 날씨만 모아서 보고 싶을 때 '부산' 데이터만 쏙 골라 온다.

CUD(입력/수정/삭제) 속도 저하: 새로운 날씨 데이터가 INSERT 되거나 기존 기온이 UPDATE 되면,
데이터베이스는 실제 테이블뿐만 아니라 기온인덱스와 도시인덱스 페이지도 다시 정렬하고 갱신해야 한다.
*/
/*인덱스 사용시 고려 사항
where 년도 = 2026 and 월 = 5; -- 정상
where 년도 = 2026 or 월 = 5; -- OR 조건은 인덱스를 무력화(성능 저하)
where 월 = 5 and 일 > 1; -- primary key(년도, 월, 일, 도시) 복합키일 경우는 년도 부터 지정된 순서대로
where 년도 = 2026 and 월 = 5 and 일 > 1 and 도시 = '서울' -- 정상
*/

/* 옵티마이저 */
-- 주문건수가 많은 고객 순으로 고객회사명별 주문건수를 보이는 쿼리의 실행 계뢱을 확인
explain format = tree
select 고객회사명, count(*) as 주문건수
from 고객
inner join 주문
on 고객.고객번호 = 주문.고객번호
group by 고객회사명
order by count(*) desc;

-- 주문건수가 많은 고객 순으로 고객회사명별로 주문건수를 보이는 쿼리에 대해 실행 계획 및 실행 결과에 대한 통계를 확인
explain analyze -- 실행 계획 및 실행한 쿼리에 대한 통계를 함께 확인
select 고객회사명, count(*) as 주문건수
from 고객
inner join 주문
on 고객.고객번호 = 주문.고객번호
group by 고객회사명
order by count(*) desc;

/*
cost(비용): 데이터베이스가 이 작업을 수행하기 위해 소모할 것으로 예상하는 연산 수치. 낮을수록 좋음
rows(예상 행 수): 각 단계에서 처리될 것으로 예상되는 데이터의 건수
Index Lookup: 인덱스를 통해 특정 데이터가 있는 주소로 한 번에 점프(가장 빠름)한 것
Index Scan: 인덱스 전체를 훓은 것
*/

/* 문제1 */
-- 피벗 형식으로 결과가 보이도록 뷰 작성
create or replace view view_도시_직위별_고객수
as
select 도시
	, sum(case when 담당자직위 = '대표 이사' then 1 else 0 end) as '대표 이사'
	, sum(case when 담당자직위 like '영업%' then 1 else 0 end) as '영업'
    , sum(case when 담당자직위 like '마케팅%' then 1 else 0 end) as '마케팅'
    , sum(case when 담당자직위 like '회계%' then 1 else 0 end) as'회계'
from 고객
group by 도시;