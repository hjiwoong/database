select 고객회사명,담당자명
from 고객
where 마일리지 = (select max(마일리지)from 고객);

-- 주문번호 'H0250'을 주문한 고객에 대해 고객회사명과 담당자명을 보이시오
select 고객회사명,담당자명
from 고객
where 고객번호 = (select 고객번호
				from 주문
                where 주문번호 = 'H0250');
-- 조인
select 고객회사명,담당자명
from 고객
inner join 주문
on 고객.고객번호 = 주문.고객번호
where 주문번호 = 'H0250';

-- '부산광역시'고객의 최소마일리지보다 더 큰 마일리지를 가진 고객 정보를 보이시오
select 담당자명,고객회사명,마일리지
from 고객
where 마일리지 > (select min(마일리지) from 고객 where 도시 = '부산광역시');

/* 복수 행 서브쿼리(Multi-Row SubQuery): 서브쿼리의 결과가 여러 행이 나온느 쿼리 */
/* IN, ALL, ANY, SOME, EXISTS와 같은 복수 행 비교 연산자를 사용 */

-- '부산광역시'고객이 주문한 주문건수
select count(*) as 주문건수
from 주문
where 고객번호 in (select 고객번호 from 고객 where 도시 = '부산광역시'); -- in 연산자: 메인쿼리의 비교조건이 서브쿼리 결과중 일치하는 것이 하나라도 있으면 참. 서브쿼리의 각 결과값을 =연산자로 비교

-- '부산광역시'전체 고객의 마일리지보다 마일리지가 큰 고객의 정보를 보이시오
select 담당자명,고객회사명,마일리지
from 고객
where 마일리지 > any(select 마일리지 from 고객 where 도시 = '부산광역시'); -- any 연산자: 서브쿼리의 최소 결과값(min)과 비교, 하나 이상 일치하면 참(or비교)

-- 각 지역의 어느 평균 마일리지보다도 마일리지가 큰 고객의 정보를 보이시오
select 담당자명,고객회사명,마일리지
from 고객
where 마일리지 > all(select avg(마일리지) from 고객 group by 지역); -- all 연산자: 서브쿼리의 최대 결과값(max)과 비교, 모두 일치하면 참(and비교)

-- 한 번이라도 주문한 적이 있는 고객의 정보를 보이시오
select 고객번호,고객회사명
from 고객
where 고객번호 in (select distinct 고객번호 from 주문);

select 고객번호,고객회사명
from 고객
where exists (select * from 주문 where 고객번호 = 고객.고객번호); -- exists 연산자: 서브쿼리에 비교 조건을 만족하는 결과가 존재하면 참이다. 행의 존재여부로 비교

select distinct 고객.고객번호,고객회사명
from 고객
inner join 주문
on 고객.고객번호 = 주문.고객번호;

/* 정리 */
select count(*)
from 고객
where 마일리지 > any(select 마일리지 from 고객 where 도시 = '부산광역시');
select count(*)
from 고객
where 마일리지 > (select min(마일리지) from 고객 where 도시 = '부산광역시'); -- 같은 결과

select count(*)
from 고객
where 마일리지 > all(select 마일리지 from 고객 where 도시 = '부산광역시');
select count(*)
from 고객
where 마일리지 > (select max(마일리지) from 고객 where 도시 = '부산광역시'); -- 같은 결과

/* 사용 위치에 따른 서브쿼리 */
-- 고객 전체의 평균 마일리지보다 평균 마일리지가 더 큰 도시에 대해 도시명과 도시의 평균 마일리지를 보이시오
select 도시,avg(마일리지) as 평균마일리지
from 고객
group by 도시
having avg(마일리지) > (select avg(마일리지) from 고객); -- 조건절에서 사용하는 서브쿼리

-- from 절에서 사용하는 서브쿼리: 인라인 뷰(inline View), 별명은 테이블명처럼 사용
-- 담당자명, 고객회사명, 마일리지, 도시, 해당 도시의 평균 마일리지를 보이시오. 그리고 고객이 위치하는 도시의 평균 마일리지와 각 고객의 마일리지 간의 차이도 함께 보이시오
select 담당자명, 고객회사명, 마일리지, 고객.도시 , 도시_평균마일리지, 도시_평균마일리지 - 마일리지 as 차이
from 고객, (select 도시, avg(마일리지) as 도시_평균마일리지 from 고객 group by 도시) as 도시별요약
where 고객.도시 = 도시별요약.도시;

select 고객번호, 담당자명, (select max(주문일) from 주문 where 주문.고객번호 = 고객.고객번호) as 최종주문일
from 고객;

-- CTE: 쿼리로 만든 임시 데이터셋, WITH절에서 정의함, 파생테이블(Derived Table)처럼 사용, 재사용성이 좋음
with 도시별요약 as (select 도시, avg(마일리지) as 도시_평균마일리지 from 고객 group by 도시)
select 담당자명, 고객회사명, 마일리지, 고객.도시, 도시_평균마일리지, 도시_평균마일리지 - 마일리지 as 차이
from 고객, 도시별요약
where 고객.도시 = 도시별요약.도시;

/* 상관 서브쿼리(Correlated SubQuery): 메인 쿼리와 서브쿼리 간의 상관관계를 포함하는 형태의 쿼리 
메인 쿼리를 한 행씩 처리함, 서브쿼리에서 값을 찾음*/

-- 사원테이블에서 사원번호, 사원의 이름, 상사의 사원번호, 상사의 이름을 보이시오
select 사원번호, 이름, 상사번호,(select 이름 from 사원 as 상사 where 상사.사원번호 = 사원.상사번호) as 상사이름
from 사원;

/* 다중 컬럼 서브쿼리(Multi-Column SubQuery): 서브쿼리의 결과로 나오는 여러 컬럼을 메인 쿼리의 값과 비교 
컬럼의 순서가 같아야 된다 */

-- 각 도시마다 최고 마일리지를 보유한 고객의 정보를 보이시오
select 도시, 담당자명, 고객회사명, 마일리지
from 고객
where (도시, 마일리지) in (select 도시, max(마일리지) from 고객 group by 도시);

/* 문제1 */
-- '배재용' 사원의 부서명을 보이시오
-- 상관 서브쿼리: 서브쿼리가 메인 테이블의 컬럼을 조건으로 쓰고 있다
select (select 부서명 from 부서 where 부서.부서번호 = 사원.부서번호) as 부서명
from 사원
where 이름 = '배재용';

-- WHERE 절에서의 서브쿼리
select 부서명
from 부서
where 부서번호 = (select 부서번호 from 사원 where 이름='배재용');

-- 조인
select 부서명 from 부서 inner join 사원 on 부서.부서번호 = 사원.부서번호 where 이름 = '배재용';

/* 문제2 */
-- 한번도 주문한 적이 없는 제품의 정보를 보이시오

-- 상관 서브쿼리
select *
from 제품
where not exists(select * from 주문세부 where 주문세부.제품번호 = 제품.제품번호);

-- 외부 조인
select 제품.*
from 제품
left outer join 주문세부
on 제품.제품번호 = 주문세부.제품번호
where 주문세부.제품번호 is null;

/* 문제3 */
-- 담당자명, 고객회사명, 주문건수, 최초주문일과 최종주문일을 보이시오
select 담당자명, 고객회사명, 주문건수, 최초주문일, 최종주문일
from 고객, (select 고객번호, count(*) as 주문건수, min(주문일) as 최초주문일, max(주문일) as 최종주문일 from 주문 group by 고객번호) as 주문요약
where 고객.고객번호 = 주문요약.고객번호;

-- 조인
select 고객.담당자명, 고객.고객회사명, count(*) as 주문건수, min(주문.주문일) as 최초주문일, max(주문.주문일) as 최종주문일
from 고객
inner join 주문
on 고객.고객번호 = 주문.고객번호
group by 고객.고객번호, 고객.담당자명, 고객.고객회사명;
