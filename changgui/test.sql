
--第一题目
--创建表
create table action(
    user_id string,
    visit_date string,
    visit_count int
)
row format delimited field terminated by "t"
;
select *
from action
;
--表的数据
-- 数据：
-- u01 2017/1/21 5
-- u02 2017/1/23 6
-- u03 2017/1/22 8
-- u04 2017/1/20 3
-- u01 2017/1/23 6
-- u01 2017/2/21 8
-- u02 2017/1/23 6
-- u01 2017/2/22 4
--插入表数据
insert into action
values (),()
;
insert into action(user_id, visit_date, visit_count)
values (),();
insert into action(user_id, visit_date, visit_count)
values ();

--希望获取如下月份的数据
-- 用户id 月份 小计 累积
with t1 as (
    select user_id
         ,date_format(replace(visit_date,'/','-'),'YYYY-MM') as mn
         ,visit_count
    from action
)
, t2 as (
    select user_id
         ,mn
         ,sum(visit_count) as mn_count
    from t1
    group by user_id, mn
)
select user_id, mn, mn_count,sum(mn_count) over(partition by user_id order by mn) as
from t2
;
