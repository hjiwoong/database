-- 도시를 입력하면 해당 도시의 고객 정보와 고객 수를 보이는 프로시저를 작성
delimiter $$
create procedure c_proc_도시고객정보
	(
		in city varchar(50)
	)
begin
	select *
    from 고객
    where 도시 = city collate utf8mb4_general_ci;
	
    select 도시, count(*) as 고객수
    from 고객
    where 도시 = city collate utf8mb4_general_ci
    group by 도시;
end $$
delimiter ;

call c_proc_도시고객정보('부산광역시');
drop procedure if exists c_proc_도시고객정보;

-- 주문년도와 고객의 도시를 입력하면 해당 년도에 해당 도시의 고객이 주문한 내역에 대하여 주문고객별로 주문건수를 보이는 프로시저 작성
delimiter $$
create procedure d_proc_주문년도시_고객정보
	(
		in order_year int,
        in city varchar(50)
    )
begin
	select 고객.고객번호, 고객회사명, 도시, count(*) as 주문건수
    from 고객
    inner join 주문
    on 고객.고객번호 = 주문.고객번호
    where year(주문일) = order_year and 도시 = city collate utf8mb4_general_ci
    group by 고객.고객번호, 고객회사명;
end $$
delimiter ;
call d_proc_주문년도시_고객정보(2021, '공주시');
drop procedure if exists d_proc_주문년도시_고객정보;

-- 인상률과 금액을 입력하면 인상금액을 계산하고 그 결과를 확인할 수 있는 프로시저를 작성
delimiter $$ -- 프로시저 생성
create procedure g_proc_인상금액
	(
		in increate_rate int,
        inout price int -- 프로시저 안에서 계산이 끝나면 새로운 결과값을 들고 그대로 밖으로 나간다
    )
begin
	set price = price * (1 + increate_rate / 100);
end $$
delimiter ;
set @금액 = 10000; -- 외부에서 사용할 전역 변수 @금액을 만들고 시작 값으로 10000(원)
call g_proc_인상금액(10, @금액); -- 프로시저 호출
select @금액; -- 값이 바뀐 @금액 변수를 최종 출력
drop procedure if exists g_proc_인상금액; -- 프로시저 삭제

/* 스토어드 함수 (Stored Function) */
-- 수량과 단가를 입력하면 두 수를 곱하여 금액을 반환하는 함수를 생성
delimiter $$ -- 함수생성
create function func_금액(quantity int, price int)
	returns int -- 반환 형식
    deterministic
-- MySQL에 바이너리 로그(Binary Log, 데이터 변경 이력)가 켜져 있을 때
-- 함수가 매번 똑같은 결과를 내는지(DETERMINISTIC 입력값이 같으면 항상 똑같은 결과를 반환함)
begin
	declare amount int;
    set amount = quantity * price;
	return amount;-- 반환값
end $$
delimiter ;

select func_금액(100, 4500); -- 함수 실행
drop function func_금액; -- 함수 삭제

select *, func_금액(주문수량, 단가) as 주문금액
from 주문세부;

/* 트리거 (Trigger) */
-- INSERT, UPDATE, DELETE와 같은 이벤트가 발생할 때마다 트리거에 정의된 SQL문이 자동 실행
-- 변경 이력(로그)을 자동으로 남기기

-- 제품 로그 테이블을 생성. 그리고 제품을 추가할 때마다 로그 테이블에 정보를 남기는 트리거를 작성
create table 제품로그
	(
		로그번호 int auto_increment primary key,
		-- 로그번호 int generated always as indentity primary key, -- 표준 SQL
        처리 varchar(10),
        내용 varchar(100),
        처리일 timestamp default current_timestamp()
    );
    
delimiter $$
create trigger trigger_제품추가로그
after insert on 제품 -- 제품 테이블에 새 데이터가 INSERT 된 직후에 이 트리거를 발동시켜라, before/after
for each row -- 새로 들어온 행 하나하나마다(FOR EACH ROW), 누락 없이 변경 이력(로그)을 자동으로 남기기
begin
	insert into 제품로그(처리, 내용)
    values('insert', concat('제품번호:', new.제품번호,'제품명:',new.제품명));
end $$
delimiter ;

insert into 제품(제품번호, 제품명, 단가, 재고)
values(99,'레몬캔디',2000,10);
-- 트리거 동작 여부는 제품 테이블에 레코드를 추가하고 제품로그 테이블을 검색하여 확인함

select * from 제품 where 제품번호 = 99;
select * from 제품로그;

-- 제품 테이블에서 단가나 재고가 변경되면 변경된 사항을 제품로그 테이블에 저장하는 트리거를 생성
delimiter $$
create trigger trigger_제품변경로그
after update on 제품
for each row
begin
	if(new.단가 <> old.단가) then
		insert into 제품로그(처리, 내용)
		values('update', concat('제품번호:',old.제품번호, '단가:',old.단가,'->',new.단가));
	end if;
	if(new.재고 <> old.재고) then
		insert into 제품로그(처리, 내용)
		values('update', concat('제품번호:',old.제품번호, '재고:',old.재고,'->',new.재고));
	end if;
end $$
delimiter ;

update 제품
set 단가 = 2500
where 제품번호 = 99;

select * from 제품로그;

-- 제품 테이블에서 제품 정보를 삭제하면 삭제된 레코드의 정보를 제품로그 테이블에 저장하는 트리거를 생성
delimiter $$
create trigger trigger_제품삭제로그
after delete on 제품
for each row
begin
	insert into 제품로그(처리, 내용)
    values('delete', concat('제품번호:',old.제품번호,'제품명:',old.제품명));
end $$
delimiter ;

delete from 제품
where 제품번호 = 99;

select * from 제품로그;

/* 문제1 */
-- 제품명의 일부를 입력하면 해당 제품들에 대하여 제품명별로 주문수량합, 주문금액합을 보이는 포로시저를 작성
delimiter $$
create procedure proc_제품명_주문내역(
	in product_name varchar(50)
)
begin
	select 제품명
		,sum(주문수량) as 주문수량합
        ,sum(주문세부.단가 * 주문수량) as 주문금액합
	from 제품
	inner join 주문세부
    on 제품.제품번호 = 주문세부.제품번호
    where 제품명 like concat('%',product_name collate utf8mb4_general_ci,'%')
	group by 제품명;
end $$
delimiter ;

call proc_제품명_주문내역('캔디');

/* 문제2 */
-- 생일을 입력하면 연령구분을 반환하는 함수를 생성
delimiter $$
create function func_연령구분(birthday date)
	returns varchar(20)
    deterministic
begin
	declare 나이 int;
    declare 연령구분 varchar(20);
    
    set 나이 = year(now()) - year(birthday);
    set 연령구분 = (select case
					when 나이 < 20 then '미성년'
					when 나이 < 30 then '청년'
					when 나이 < 55 then '중년층'
					when 나이 < 70 then '장년층'
					else '노년층'
				end);
	return 연령구분;
end $$
delimiter ;

select func_연령구분('2002-01-01');
select 이름, 생일, year(생일), date_format(생일, '%Y'), substring(생일,1,4)
from 사원;
select 이름, 생일, year(생일)
	, year(now()) - year(생일) as 나이
    , func_연령구분(생일) as 연령구분
from 사원;
