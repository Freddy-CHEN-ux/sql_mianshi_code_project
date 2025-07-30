

# --第2题
-- 有50W个京东店铺，每个顾客访客访问任何一个店铺的任何一个商品时都会产生一条访问日志，访问日志存储的
-- 表名为Visit,访客的用户id为user_id,被访问的店铺名称为shop,请统计：
-- u1a
-- u2b
-- u1b
-- u1 a
-- u3C
-- u4b
-- u1 a
-- u2C
-- u5b
-- u4b
-- u6C
-- u2C
-- u1b
-- u2 a
-- u2 a
-- u3 a
-- u5 a
-- u5 a
-- u5 a

# --建表
create table visit (
    user_id string,
    shop string
)
;

# --插入数据
insert into visit (user_id, shop) values ();

# --每个店铺的访客数（UV）
select shop,count(distinct user_id)
from visit
group by shop
;

# --每个店铺访问次数top3的访客信息，输出店铺名称，访客id,访问次数
with t1 as (
    select shop,user_id,count(*) as ct
    from visit
    group by shop,user_id
)
, t2 as (
    select shop,user_id,ct,rank() over(partition by shop order by ct desc) as rk
    from t1
)
select shop,user_id,ct
from t2
where rk<=3
;
