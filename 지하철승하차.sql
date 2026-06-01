-- 호선명별로 승차승객수합, 하차승객수합, 승하차승객수합을 보이시오
select 호선명
		,sum(승차승객수) as 승차승객수합
        ,sum(하차승객수) as 하차승객수합
        ,sum(승차승객수 + 하차승객수) as 승하차승객수합
from 지하철승하차
group by 호선명;

-- 호선명별로 역개수, 역명, 승하차승객수합, 역당 평균 승하차승객수를 보이시오, 이때 역당 평균 승하차승객수가 많은 레코드부터 순서대로 나타내시오
select 호선명
		,count(distinct 역명) as 역개수
        ,group_concat(distinct 역명) as 역명
        ,sum(승차승객수 + 하차승객수) as 승하차승객수합
        ,round(sum(승차승객수 + 하차승객수) / count(distinct 역명), 0) as 역당_평균승하차승객수
from 지하철승하차
group by 호선명
order by 5 desc;

-- 사용일자 date 타입으로 변경
create table 지하철승하차_backup as select * from 지하철승하차;

alter table 지하철승하차
add column 사용일자_new date;

set sql_safe_updates = 0;
update 지하철승하차
set 사용일자_new = str_to_date(concat(사용일자, '01'), '%Y%m%d');
set sql_safe_updates = 1;

alter table 지하철승하차
drop column 사용일자,
rename column 사용일자_new to 사용일자;

desc 지하철승하차;
select 사용일자 from 지하철승하차 limit 5;

-- 월별, 호선명별로 승하차승객수합을 보이시오
select substr(사용일자,5)
	,호선명
    ,sum(승차승객수 + 하차승객수) as 승하차승객수합
from 지하철승하차
group by month(사용일자), 호선명
order by 1, 2;

-- 어느 역, 어느 호선의 승하차승객수합이 많은지 상위 10개의 정보를 보이시오
select 역명, 호선명
		,sum(승차승객수 + 하차승객수) as 승하차승객수합
from 지하철승하차
group by 역명, 호선명
order by 3 desc
limit 10;

-- 2호선에 대하여 요일별로 승하차승객수합을 보이되 월요일부터 순서대로
select month(사용일자) as 월
		,weekday(사용일자) as 숫자요일
        ,case weekday(사용일자)
			when 0 then '월요일'
			when 1 then '화요일'
			when 2 then '수요일'
			when 3 then '목요일'
			when 4 then '금요일'
			when 5 then '토요일'
			else '일요일'
		end as 요일
        ,sum(승차승객수 + 하차승객수) as 승하차승객수합
from 지하철승하차
where 호선명 = '2호선'
group by month(사용일자)
		,weekday(사용일자)
        ,case weekday(사용일자)
			when 0 then '월요일'
			when 1 then '화요일'
			when 2 then '수요일'
			when 3 then '목요일'
			when 4 then '금요일'
			when 5 then '토요일'
			else '일요일'
		end
order by 1,2;

-- 강남역과 홍대입구역, 잠실역, 명동역의 12월 데이터에 대하여 역명, 사용일자, 승하차승객수 및 승하차승객수누적합
with 일별집계 as (
	select 역명, 사용일자, sum(승차승객수 + 하차승객수) as 승하차승객수합
    from 지하철승하차
    where 역명 in ('강남','홍대입구','잠실','명동') and month(사용일자) = 12
    group by 역명, 사용일자
)
select 역명, 사용일자, 승하차승객수합
		,sum(승하차승객수합) over(partition by 역명 order by 사용일자 asc rows between unbounded preceding and current row) as 승하차승객수누적합
from 일별집계
order by 역명, 사용일자;

select 역명, count(*) as 건수, min(사용일자) as 시작일, max(사용일자) as 종료일
from 지하철승하차
where 역명 in ('강남','홍대입구','잠실','명동') and month(사용일자) = 12
group by 역명;

select distinct 사용일자
from 지하철승하차
where 역명 = '홍대입구'
order by 사용일자;

-- 환승역에 대하여 승하차승객수합을 보이고 이때 승하차승객수합이 많은 역부터
with 환승역 as (
		select 역명, count(*) as 역개수
        from (select distinct 호선명, 역명 from 지하철승하차) as t
        group by 역명
        having count(*) >= 2
)
select 역명
	,sum(승차승객수 + 하차승객수) as 승하차승객수합
    ,group_concat(distinct 호선명) as 호선명
from 지하철승하차
where 역명 in (select 역명 from 환승역)
group by 역명
order by 2 desc;

-- 호선명, 역명, 승차승객수합, 하차승객수합, 승하차승객수합을 보이는 뷰를 지하철승하차뷰라는 이름으로 생성
create view 지하철승하차뷰
as
select 호선명, 역명
		,sum(승차승객수) as 승차승객수합
        ,sum(하차승객수) as 하차승객수합
        ,sum(승차승객수 + 하차승객수) as 승하차승객수합
from 지하철승하차
group by 호선명, 역명;

-- 호선명, 역명, 승차승객수합, 하차승객수합, 승하차승객수합 및 공기질 항목의 수치
select 승하차.*
		,공기질.미세먼지
        ,공기질.초미세먼지
        ,공기질.이산화탄소
        ,공기질.폼알데하이드
        ,공기질.일산화탄소
from 지하철승하차뷰 as 승하차
inner join 지하철공기질 as 공기질
on 승하차.호선명 = 공기질.호선명 and 승하차.역명 = 공기질.역명
order by 호선명, 역명;

-- 공기질을 측정하지 않은 역에 대하여 호선명, 역명을 보이시오
select count(*) as 공기질미측정역개수
from 지하철승하차뷰 as 승하차
where not exists (select * from 지하철공기질 as 공기질
				  where 공기질.호선명 = 승하차.호선명 and 공기질.역명 = 승하차.역명);
select 호선명, 역명
from 지하철승하차뷰 as 승하차
where not exists (select * from 지하철공기질 as 공기질
				  where 공기질.호선명 = 승하차.호선명 and 공기질.역명 = 승하차.역명);

-- 공기질 측정을 한 역을 대상으로 호선명별로 역개수, 승하차승객수합, 각 호선의 역당 평균 승하차승객수 및 공기질 각 항목에 대한 평균 수치를 보이시오. 이때 역당 평균승하차승객수가 많은 레코드부터 순서대로 나타내시오
select 승하차.호선명
		,count(승하차.역명) as 역개수
		,sum(승하차.승하차승객수합) as 승하차승객수합
        ,round(sum(승하차.승하차승객수합)/count(승하차.역명), 0) as 역당_평균_승하차인원수
        ,round(avg(공기질.미세먼지), 1) as 평균 미세먼지
from 지하철승하차뷰 as 승하차
inner join 지하철공기질 as 공기질
on 승하차.호선명 = 공기질.호선명 and 승하차.역명 = 공기질.역명
group by 승하차.호선명
order by 역당_평균_승하차인원수 desc;
