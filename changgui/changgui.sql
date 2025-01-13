
# --创建表
create table if not extist action_1 (
    user_id string comment '用户ID',
    visit_date string comment '访问日期',
    visit_count int comment '访问次数'
)
comment '访问表'
;

create table if not extist action_p (
    user_id string comment '用户ID',
    visit_date string comment '访问日期',
    visit_count int comment '访问次数'
)
comment '访问表'
partiton by (pt string comment '分区表')
;


# --插入表数据
-- 数据：
-- u01 2017/1/21 5
-- u02 2017/1/23 6
-- u03 2017/1/22 8
-- u04 2017/1/20 3
-- u01 2017/1/23 6
-- u01 2017/2/21 8
-- u02 2017/1/23 6
-- u01 2017/2/22 4
insert into action_1
values (),()
;
insert into action_1(user_id, visit_date, visit_count)
values (),();
insert into action_1(user_id, visit_date, visit_count)
values ();

insert into action select * from temp;
insert overwrite table action_p partiton(pt = '20250101');
insert overwrite table action_p partiton(pt);


# 更新表字段
update action_1
set user_id = '1'
where user_id = '0';

update action_1 a
left join action on a.user_id = b.user_id
set a.user_id = b.user_id1,a.b = b. 1
where a.visit_date is not null;

# 新增字段
alter table action add visit_d string comment 'd字段';

