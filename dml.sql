/* 데이터 조작어(Data Manipulation Language, DML): 데이터를 추가(INSERT), 변경(UPDATE), 삭제(DELETE)할 때 사용 */

-- INSERT: 테이블에 새로운 행을 삽입, 테이블의 컬럼 수와 순서가 동일
insert into 부서
values('A5','마케팅부');

insert into 제품
values(91,'연어피클소스',null, 5000, 40);

insert into 제품(제품번호, 제품명, 단가, 재고)
values(90, '연어핫소스',4000,50);

insert into 사원(사원번호, 이름, 직위, 성별, 입사일)
values('E20','김수습','수습사원','남',CURDATE()), ('E21','박수습','수습사원','여',CURDATE()), ('E22','정수습','수습사원','여',CURDATE());

-- update: 기존 행에 있는 데이터 값을 변경할 때, update문에 where절이 없으면 모든 행의 값이 변경되므로 주의
update 사원
set 이름 = '김사원'
where 사원번호 = 'E20';

update 제품
set 포장단위 = '200ml bottles'
where 제품번호 = 91;

update 제품
set 단가 = 단가 * 1.1, 재고 = 재고 - 10
where 제품번호 = 91;

-- delete: 기존에 있는 행을 삭제할 때, WHERE절이 없으면 모든 행이 삭제
delete from 제품
where 제품번호 = 91;

delete from 사원
order by 입사일 desc
limit 3; -- 입사일이 가장 늦은 사원 3명의 레코드 삭제

-- insert on duplicate key update: 레코드가 없다면 새롭게 추가하고, 이미 있다면 데이터를 변경하는 경우에 사용

-- 91번 제품이 없다면 레코드를 추가하고 이미 존재한다면 값을 변경
insert into 제품(제품번호, 제품명, 단가, 재고)
values(91, '연어피클핫소스',6000, 50)
on duplicate key update 제품명 = '연어피클핫소스', 단가=6000,재고=50;

insert into 고객(고객번호, 담당자명, 고객회사명, 도시)
values('ZAQAQ','김지현','두빛트레이드','서울특별시')
on duplicate key update 담당자명='오성균', 도시='인천광역시';

/* insert into select: select의 결과를 다른 테이블에 삽입, 컬럼수와 순서가 동일해야 됨 */
create table 고객주문요약
(고객번호 char(5)primary key
,고객회사명 varchar(50)
,주문건수 int
,최종주문일 date);

insert into 고객주문요약
select 고객.고객번호, 고객회사명, count(*), max(주문일)
from 고객, 주문
where 고객.고객번호 =주문.고객번호
group by 고객.고객번호, 고객회사명;

/* update select */
-- 제품번호가 91인 제품의 단가를 '소스'제품들의 평균단가로 변경
-- 표준 sql코드
update 제품
set 단가 = (select avg(단가) from 제품 where 제품명 like '%소스%')
where 제품번호 = 91;
-- mysql
update 제품
set 단가 = (select * from (select round(avg(단가),0)from 제품 where 제품명 like '%소스%') as t)
where 제품번호 = 91;

-- 한 번이라도 주문한 적이 있는 고객의 마일리지를 10% 인상
-- 1. 안전모드 해제
SET SQL_SAFE_UPDATES = 0;
update 고객
set 마일리지 = 마일리지 * 1.1
where 고객.고객번호 in(select 고객번호 from 주문);
-- 안전모드 다시 설정(실수 방지를 위한 권장)
SET SQL_SAFE_UPDATES = 1;

/* update join */
-- 마일리지 등급이 'S'인 고객의 마일리지에 1000점씩 추가
update 고객
inner join 마일리지등급
on 마일리지 between 하한마일리지 and 상한마일리지
set 마일리지 = 마일리지 + 1000
where 등급명 = 's';

/* delete select: 삭제할 레코드를 찾기 위하여 서브쿼리를 사용 */
-- 주문테이블에는 존재하나 주문세부 테이블에는 존재하지 않는 주문번호를 주문테이블에서 삭제
delete from 주문
where 주문번호 not in (select distinct 주문번호 from 주문세부);

/* delete join 
inner join을 사용하여 두 테이블에서 일치하는 행을 모두 삭제할 수 있음
left outer join을 사용하여 일치하지 않는 행을 삭제할 수도 있음*/

-- 주문번호 'H0248'에 대한 내역을 주문 테이블과 주문세부 테이블에서 모두 삭제
select * from 주문 where 주문번호 = 'H0248';
select * from 주문세부 where 주문번호 = 'H0248';
-- 하나의 문장으로 작업을 수행
delete 주문, 주문세부 from 주문 inner join 주문세부 on 주문.주문번호 = 주문세부.주문번호 where 주문.주문번호 = 'H0248';

-- 한번도 주문한 적이 없는 고객의 정보를 삭제
select 고객.*
from 고객
left outer join 주문
on 고객.고객번호 = 주문.고객번호
where 주문.고객번호 is null;

delete 고객
from 고객
left outer join 주문
on 고객.고객번호 = 주문.고객번호
where 주문.고객번호 is null;

/* 문제1 */
/* 문제2 */
/* 문제3 */
/* 문제4 */