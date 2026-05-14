/*ANSI SQL 표준화 기구(ANSI/ISO)에서 정한 공통 규칙*/
select 부서.부서번호, 부서명, 이름, 사원.부서번호
from 부서
cross join 사원
where 이름 = '배재용';
/*Non-ANSI SQL, 비표준, 오라클 문법*/
select 부서.부서번호, 부서명, 이름, 사원.부서번호
from 부서, 사원
where 이름 = '배재용'; -- WHERE 절에 조인 조건을 하나라도 빼먹으면 의도치 않은 카테시안 곱(데이터가 기하수급적으로 감소)이 발생alter

/*inner join*/
-- '이소미'사원의 사원번호, 직위, 부서번호, 부서명 보이기
select 사원번호, 직위, 사원.부서번호, 부서명
from 사원
inner join 부서
on 사원.부서번호 = 부서.부서번호 -- 조인 조건
where 이름 = '이소미';

/*Non-ANSI SQL*/
select 사원번호, 직위, 사원.부서번호, 부서명
from 사원, 부서
where 사원.부서번호 = 부서.부서번호 and 이름 = '이소미';

-- 고객 회사들이 주문한 주문건수를 주문건수가 많은 순서대로 보이시오
-- 이때 고객 회사의 정보로는 고객번호, 담당자명, 고객회사명을 보이시오
select 고객.고객번호, 담당자명, 고객회사명, count(*) as 주문건수
from 고객
inner join 주문
on 고객.고객번호 = 주문.고객번호
group by 고객.고객번호, 담당자명, 고객회사명
order by count(*) desc;

-- 고객별(고객번호, 담당자명, 고객회사명)로 주문금액 합을 보이되, 주문금액 합이 많은 순서대로 보이시오
select 고객.고객번호, 담당자명, 고객회사명, sum(단가 * 주문수량) as 주문금액합
from 고객
inner join 주문
on 고객.고객번호 = 주문.고객번호
inner join 주문세부
on 주문.주문번호 = 주문세부.주문번호
group by 고객.고객번호, 담당자명, 고객회사명
order by count(단가 * 주문수량) desc;

-- 고객 테이블과 마일리지등급 테이블을 크로스 조인하시오
-- 그 다음 고객 테이블에서 담당자가 '이은광'인 고객에 대하여
-- 고객번호, 담당자명, 마일리지와 마일리지등급 테이블의 모든 컬럼을 보이시오
select 고객번호, 담당자명, 마일리지, 마일리지등급.*
from 고객
cross join 마일리지등급
where 담당자명 = '이은광';

-- 고객 테이블에서 담당자가 '이은광'인 경우의
-- 고객번호, 고객회사명, 담당자명, 마일리지와 마일리지등급을 보이시오
select 고객번호, 고객회사명, 담당자명, 마일리지, 등급명
from 고객
inner join 마일리지등급
on 마일리지 between 하한마일리지 and 상한마일리지
-- on 마일리지 >= 하한마일리지 and 마일리지 <= 상한마일리지
where 담당자명 = '이은광';

/* left outer join, right outer join : 한쪽 테이블에는 데이터가 있고 다른쪽 테이블에는 데이터가 없는 것도 출력을 하기 위해서 */
-- 데이터가 있는 쪽의 테이블을 기준으로 출력함
/* full outer join은 left outer join와 right outer join을 합친 형태, union 합집합 */

select 사원번호, 이름, 부서명
from 사원
left outer join 부서 -- 사원테이블에 포함해야할 데이터가 있다
on 사원.부서번호 = 부서.부서번호 -- 사원.부서번호 없는 사원은 결과에 안나온다
where 성별 = '여';
select 사원번호, 이름, 부서명
from 부서
right outer join 사원 -- 사원테이블에 포함해야할 데이터가 있다
on 사원.부서번호 = 부서.부서번호 -- 사원.부서번호 없는 사원은 결과에 안나온다
where 성별 = '여';

-- 부서명과 해당 부서의 소속 사원 정보를 보이시오
-- 이때 사원이 한 명도 존재하지 않는 부서명이 있다면 그 부서명도 함께 보이시오

select 부서명, 사원.*
from 사원
right outer join 부서 -- 포함하야할 데이터가 있다
on 사원.부서번호 = 부서.부서번호
where 사원.부서번호 is null;

-- 사원이 한 명도 존재하지 않는 부서명을 보이시오
select 이름, 부서.*
from 사원
left outer join 부서 -- 포함해야할 데이터가 왼쪽 사원테이블에 있다
on 사원.부서번호 = 부서.부서번호
where 사원.부서번호 is null;

/* 셀프조인(Self Join) : 동일한 테이블 내에서 한 컬럼이 다른 컬럼을 참조하는 조언 */
-- 사원번호, 사원의 이름, 상사의 사원번호, 상사의 이름
select 사원.사원번호, 사원.이름, 상사.사원번호 as '상사의 사원번호', 상사.이름 as '상사의 이름'
from 사원
inner join 사원 as 상사
on 사원.상사번호 = 상사.사원번호;

-- 사원이름, 직위, 상사이름을 상사이름 순으로 정렬하여 나타내시오. 이때 상사가 없는 사원의 이름도 함께 보이시오
select 사원.이름, 사원.직위, 상사.사원번호 as '상사의 사원번호', 상사.이름 as '상사이름'
from 사원
left outer join 사원 as 상사
on 사원.상사번호 = 상사.사원번호
order by 상사이름;

/* 문제1 */
select 제품명, sum(주문수량) as 주문수량합, sum(주문수량 * 주문세부.단가) as 주문금액합
from 제품
inner join 주문세부
on 제품.제품번호 = 주문세부.제품번호
group by 제품명;

/* 문제2 */
select year(주문일) as 주문년도, 제품명, sum(주문수량) as 주문수량합
from 제품
inner join 주문세부
on 제품.제품번호 = 주문세부.제품번호
inner join 주문
on 주문.주문번호 = 주문세부.주문번호
where 제품명 like '%아이스크림'
group by year(주문일), 제품명
order by 1, 2;

/* 문제3 */
select 제품명, sum(주문수량) as 주문수량합
from 주문세부
right outer join 제품
on 제품.제품번호 = 주문세부.제품번호
group by 제품명;

/* 문제4 */
select 고객번호, 고객회사명, 담당자명, 등급명, 마일리지
from 고객
inner join 마일리지등급
on 마일리지 between 하한마일리지 and 상한마일리지
where 등급명 = 'A';
