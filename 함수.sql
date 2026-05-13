/* 문자형 함수 */
select char_length('hello'), length('hello'), char_length('안녕'), length('안녕');

select concat('dreams','come','true'), concat_ws('-','2026','05','13');

/* sql은 인덱스 1부터 시작 */
select left('myhome', 3), right('my home', 4), substr('my home',2,5), substr('my home',2);

/* 지정한 구분자를 기준으로 문자열을 분리해서 가져올 때 */
select substring_index('광운대학교 kdt 취업캠프', ' ',2), substring_index('광운대학교 kdt 취업캠프', ' ', -2);

/* 지정한 길이에서 문자열을 제외한 빈칸을 특정 문자로 채울 때, lpad 왼쪽에서부터 특정 문자를 채움 */
select lpad('sql', 10, '#'), rpad('sql',5,'*');

/* 공백 제거 */
select length(ltrim(' sql ')),length(rtrim(' sql ')),length(trim(' sql '));

/* 동일 문자 제거, 양쪽 제거, 왼쪽만 제거, 오른쪽만 제거 */
select trim(both 'abc' from 'abcsqlabcabc'), trim(leading'abc' from 'abcsqlabcabc'), trim(trailing 'abc' from 'abcsqlabcabc');

/* 문자열의 위치값 반환 */
select field('java','sql','java','c'), -- 첫번째 값이 찾는 문자열의 위치 반환
	   find_in_set('java','sql,java,c'), -- ,를 기준으로 위치값 반환
       instr('행복한 하루 되세요','하루'), -- 부분 문자열의 위치값 반환 (기준 문자열, 부분 문자열)
       locate('하루','행복한 하루 되세요'); -- 부분 문자열의 위치값 반환 (부분 문자열, 기준 문자열)
       
select elt(2, 'sql', 'java','c'); -- 지정한 위치의 문자열을 반환

select repeat('*',5); -- 문자열 반복

select replace('010.1234.1234','.','-'); -- 문자열 대체

select reverse('olleh');

/* 숫자형 함수 */
select ceiling(123.12), -- 올림
	   floor(123.56), -- 버림
       round(123.56), -- 반올림
       round(123.45,1), -- 지정된 위치에서 반올림
       truncate(123.45,1); -- 지정된 위치에서 버림, 1은 소수점 위치, -1은 정수 위치

select abs(-120), abs(120), -- 절대값
	   sign(-120), sign(120); -- 양수:1, 음수:-1

select mod(203, 4), 203 % 4, 203 mod 4; -- 나머지

select power(2,3), -- 2의 3제곱
	   sqrt(16), -- 제곱근값
       rand(), rand(100), -- 0~1사이의 임의의 수, (고정 시드값)
       round(rand()*100); -- 0~100사이 정수

/* 날짜 시간형 함수 */
select now(), sysdate(), curdate(), curtime();

select now(), year(now()), quarter(now()), month(now()), day(now()),
			  hour(now()), minute(now()), second(now());

select now(), datediff('2026-12-25',now()),datediff(now(), '2025-12-25'), -- 일자 기준으로 반환
			  timestampdiff(year, now(),'2026-12-25'),
              timestampdiff(month, now(), '2026-12-25'),
              timestampdiff(day, now(), '2026-12-25');

select now(), adddate(now(), 100), adddate(now(), interval 100 day)
			, adddate(now(), interval 50 month), adddate(now(),interval 48 hour);

select now()
		,last_day(now()) -- 해당 월의 마지막 일자
        ,dayofyear(now()) -- 현재 연도에서 며칠 지났는지
        ,monthname(now()) -- 월을 영문으로
        ,weekday(now()); -- 요일을 정수로 

select if(12500 * 450 > 5000000, '초과 달성', '미달성'); -- (조건, 참, 거짓)

select ifnull(1,0) -- (수식1이 null이 아니면 수식1 값 반환, null이면 수식2 값 반환)
	   ,ifnull(null, 0)
       ,ifnull(1/0, 'ok');

select nullif(12*10, 120), nullif(12*10, 1200); -- 두 수식의 값이 같으면 null 반환, 값이 다르면 수식1값 반환

select case when 12500 * 450 > 5000000 then '초과달성' -- case문 조건 비교가 여러개일때 사용
			when 2500 * 450 > 4000000 then '달성'
			else '미달성'
            end;

/* 문제1 */
select 고객회사명, concat('**', substr(고객회사명, 3)) as 고객회사명2, 전화번호, replace(substr(전화번호,2), ')', '-') as 전화번호2 from 고객;

/* 문제2 */
select*
	,단가*주문수량 as 주문금액
    ,truncate(단가 * 주문수량 * 할인율, -1) as 할인금액 -- 정수 1의 자리를 버리고 10 단위로 맞출 때
    ,단가 * 주문수량 - (단가 * 주문수량 * 할인율) as 실주문금액
from 주문세부;

/* 문제3 */
select 이름, 생일
	,timestampdiff(year, 생일, curdate()) as 만나이 -- timestampdiff(단위, 시작일, 종료일)
    ,입사일
    ,datediff(curdate(), 입사일) as 입사일수
    ,adddate(입사일, 500) as '500일 후'
from 사원;

/* 문제4 */
select 담당자명, 고객회사명, 도시
	,if(도시 like '%특별시' or 도시 like '%광역시', '대도시', '도시') as 도시구분
    ,마일리지
    ,case when 마일리지 >= 100000 then 'vvip고객'
		when 마일리지 >=10000 then 'vip고객'
        else '일반고객'
        end as '마일리지 구분'
from 고객;

/* 문제5 */
select 주문번호, 고객번호, 주문일
	,year(주문일) as 주문년도
    ,quarter(주문일) as 주문분기
    ,month(주문일) as 주문월
    ,day(주문일) as 주문일
    ,weekday(주문일) as 주문요일
    ,case weekday(주문일) when 0 then '월요일'
						when 1 then '화요일'
						when 2 then '수요일'
                        when 3 then '목요일'
                        when 4 then '금요일'
                        when 5 then '토요일'
                        else '일요일'
						end as 한글요일
from 주문;
/* 문제6 */
select *, datediff(발송일, 요청일) as 지연일수
from 주문
where datediff(발송일, 요청일) >= 7;

/* 집계 함수 */
select count(*), count(고객번호), count(도시), count(지역) from 고객;

select sum(마일리지), avg(마일리지), min(마일리지), max(마일리지) from 고객;

select sum(마일리지), avg(마일리지), min(마일리지), max(마일리지)
from 고객
where 도시 = '서울특별시';

select 도시, count(*) as 고객수, avg(마일리지) as 평균마일리지
from 고객
group by 1; -- =group by 도시

select 담당자직위, 도시, count(*) as 고객수, avg(마일리지) as 평균마일리지
from 고객
group by 담당자직위, 도시
order by 1 , 4 desc;

/* having 절 : group by 의 결과에 대해서 추가 조건을 넣을 때, select절에 있는 컬럼과 함수만 조건에 넣을 수 있다. */
select 도시, count(*) as 고객수, avg(마일리지) as 평균마일리지
from 고객
group by 도시
having count(*) >= 10;

select 도시, sum(마일리지)
from 고객
where 고객번호 like 'T%'
group by 도시
having sum(마일리지) >= 1000;

-- '광역시' 고객에 대해 담당자직위별로 최대 마일리지로 보이되, 최대 마일리지가 10,000점 이상인 레코드만 보이는 sql문
select 담당자직위, max(마일리지) as 최대마일리지
from 고객
where 도시 like '%광역시'
group by 담당자직위
having max(마일리지) >= 10000;

select ifnull(도시, '총계') as 도시, count(*) as 고객수, avg(마일리지) as 평균마일리지
from 고객
where 지역 is null
group by 도시
with rollup; -- group by 뒤에 그룹별 소계, 전체 합계를 나타냄
