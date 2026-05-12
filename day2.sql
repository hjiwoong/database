select * from 고객;

select 고객번호,
담당자명,
고객회사명,
마일리지 as 포인트,
마일리지 * 1.1 "10% 인상된 마일리지"
from 고객;

select 고객번호, 담당자명, 마일리지
from 고객
where 마일리지 >=100000;

select 고객번호, 담당자명, 도시, 마일리지 as 포인트
from 고객
where 도시 = '서울특별시'
order by 마일리지 desc;

select * from 고객 limit 3;

select *
from 고객
order by 마일리지 desc
limit 3;
-- distinct 중복 값은 제거한 결과 
select distinct 도시
from 고객;

/* 산술연산자 */
select 23 + 5 as 더하기,
	   23 - 5 AS 빼기,
       23 * 5 AS 곱하기,
       23 / 5 AS 실수나누기,
       23 DIV 5 AS 정수나누기,
       23 % 5 AS 나머지1,
       23 MOD 5 AS 나머지2;
/* 비교연산자 */       
select 23 >= 5, -- true:1, false:0 
       23 <= 5,
       23 > 23,
       23 < 23,
       23 = 23,
       23 != 23,
       23 <> 23; -- 같지 않다
       
select * from 고객 where 담당자직위 <> '대표 이사';
/* 논리연산자 and, or, not */
select * from 고객 where 도시 = '부산광역시' and 마일리지 < 1000;

/* 합집합 연산자, 열의 갯수가 동일, 각 컬럼의 형식도 동일 */
select 고객번호, 담당자명, 마일리지, 도시 from 고객
where 도시 = '부산광역시'
union
select 고객번호, 담당자명, 마일리지, 도시 from 고객
where 마일리지 < 1000
order by 1; -- 고객번호순 정렬

/* or 연산자 */
select 고객번호, 담당자명, 마일리지, 도시 from 고객
where 도시 = '부산광역시' or 마일리지 < 1000
order by 1;

/* null 알수없는 값, 0과 빈문자열과는 다른 의미 */
select * from 고객
where 지역 is null; -- 값이 없는 것

select * from 고객
where 지역 = ''; -- csv 파일에서 테이블로 가져오기 하면 값이 없는 셀이 null이 아니라 빈문자열로 저장됨

-- 1. 안전모드 해제
set sql_safe_updates = 0;
-- 2. 원래 실행하려던 쿼리 실행
update 고객 set 지역 = null where 지역 = '';
-- 3. 안전 모드 다시 설정 (실수 방지를 위해 권장)
set sql_safe_updates = 1;

/* in, between and */
select 고객번호, 담당자명, 담당자직위 from 고객
where 담당자직위 = '영업 과장' or 담당자직위 = '마케팅 과장';

select 고객번호, 담당자명, 담당자직위 from 고객
where 담당자직위 in ('영업 과장', '마케팅 과장');

select 담당자명, 마일리지 from 고객
where 마일리지 >= 100000 and 마일리지 <=200000;

select 담당자명, 마일리지 from 고객
where 마일리지 between 100000 and 200000;

/* like 연산자, 특정문자열이 지정된 패턴과 일치하는지 확인, % _ 와일드카드 문자 */
select * from 고객
where 도시 like '%광역시'
and (고객번호 like '_c%' or 고객번호 like '__c%');

/* 문제1 */
select * from 고객 where 도시 like '서울%' and 마일리지 between 15000 and 20000;
/* 문제2 */
select distinct 지역, 도시 from 고객 order by 1, 2;
/* 문제3 */
select * from 고객 where 도시 in ('춘천시', '과천시', '광명시') and (담당자직위 like '%이사'or 담당자직위 like '%사원');
/* 문제4 */
select * from 고객 where not (도시 like '%광역시' or 도시 like '%특별시') order by 마일리지 desc limit 3;
/* 문제5 */
select * from 고객 where 지역 is not null and 담당자직위 != '대표 이사';
