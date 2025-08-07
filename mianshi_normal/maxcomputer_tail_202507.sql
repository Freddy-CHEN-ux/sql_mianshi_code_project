--MaxCompute SQL
--********************************************************************--
--author: 陈三飞
--create time: 2025-07-03 09:29:36
--********************************************************************--


--***********************第二高的薪水*********************************************-- 
-- 需求二：编写一个SQL查询，获取Employee表中第二高的薪水（Salary)。如果不存在第二高的薪水，那么查
-- 询应返回null.
CREATE TABLE IF NOT EXISTS Employee (
    Id INT COMMENT '员工ID',
    Salary DECIMAL(10, 2) COMMENT '薪水'
)
STORED AS ALIORC
TBLPROPERTIES (
    'comment' = '员工薪水表'
);
-- 有第二高薪水的情况
INSERT INTO Employee (Id, Salary) VALUES 
(1, 3000.00),
(2, 5000.00),
(3, 4000.00);

SELECT * FROM employee ORDER BY Salary DESC;

--第二高的含义不就是吧第一高找出来，然后再从剩下的里面取出最高的就是排名第二。
SELECT  MAX(salary) as secound_salary FROM employee WHERE Salary < (SELECT MAX(salary) FROM employee);

-- 没有第二高薪水的情况
-- 清空表
TRUNCATE TABLE Employee;
INSERT INTO Employee (Id, Salary) VALUES 
(1, 3000.00);

--***********************分数排名*********************************************-- 
-- 需求：编写一个SQL查询来实现分数排名。如果两个分数相同，则两个分数排名（Rank)相同，请注意，平分后
-- 的下一个名次应该是下一个连续的整数值。换句话说，名次之间不应该有“间隔”
CREATE TABLE IF NOT EXISTS scores (
    id INT COMMENT '学生ID',
    score DECIMAL(10, 2) COMMENT '分数'
)
STORED AS ALIORC
TBLPROPERTIES (
    'comment' = '学生分数表'
);
-- 插入测试数据，包含相同分数和不同分数的情况
INSERT INTO scores (id, score) VALUES 
(1, 90.00),
(2, 85.00),
(3, 90.00),
(4, 75.00),
(5, 85.00),
(6, 95.00);

SELECT * FROM scores ORDER BY score DESC;

SELECT *,dense_rank() OVER(ORDER BY score DESC) AS rank FROM scores ;

--***********************连续出现的数字*********************************************-- 
-- 需求：编写一个SQL查询，查找所有至少连续出现三次的数字。
CREATE TABLE IF NOT EXISTS logs (
    id INT COMMENT '日志ID',
    num INT COMMENT '数字'
)
STORED AS ALIORC
TBLPROPERTIES (
    'comment' = '数字日志表'
);
-- 插入测试数据
INSERT INTO logs (id, num) VALUES 
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 1),
(6, 2),
(7, 2),
(8, 2),
(9, 3),
(10, 3),
(11, 3),
(12, 3),
(13, 4),
(14, 5),
(15, 5);

SELECT * FROM logs ORDER BY num;

SELECT num FROM logs GROUP BY num HAVING COUNT(*) >= 3;

WITH twmp AS (
    SELECT num,id,id - LAG(id) OVER (PARTITION BY num ORDER BY id ASC) as flag FROM logs
)
SELECT num FROM twmp GROUP BY num,flag HAVING COUNT(*) >= 2;

SELECT DISTINCT l1.num FROM logs l1,logs l2,logs l3 WHERE l1.num = l2.num AND l2.num = l3.num AND l1.id = l2.id + 1 AND l2.id = l3.id + 1;

--***********************连续天出现的数字*********************************************-- 
-- 需求：编写一个SQL查询，查找所有至少连续出现三天的数字。表名叫做logs_day
CREATE TABLE IF NOT EXISTS logs_day (
    id INT COMMENT '日志ID',
    log_date DATE COMMENT '日期',
    num INT COMMENT '数字'
)
STORED AS ALIORC
TBLPROPERTIES (
    'comment' = '数字日志表(按天)'
);

-- 插入测试数据
INSERT INTO logs_day (id, log_date, num) VALUES 
(1, CAST('2023-01-01' AS DATE), 1),
(2, CAST('2023-01-02' AS DATE), 1),
(3, CAST('2023-01-03' AS DATE), 1),
(4, CAST('2023-01-04' AS DATE), 2),
(5, CAST('2023-01-05' AS DATE), 1),
(6, CAST('2023-01-06' AS DATE), 2),
(7, CAST('2023-01-07' AS DATE), 2),
(8, CAST('2023-01-08' AS DATE), 2),
(9, CAST('2023-01-09' AS DATE), 3),
(10, CAST('2023-01-10' AS DATE), 3),
(11, CAST('2023-01-11' AS DATE), 3),
(12, CAST('2023-01-12' AS DATE), 3),
(13, CAST('2023-01-13' AS DATE), 4),
(14, CAST('2023-01-14' AS DATE), 5),
(15, CAST('2023-01-15' AS DATE), 5),
(16, CAST('2023-01-16' AS DATE), 5),
(17, CAST('2023-01-17' AS DATE), 5),
(18, CAST('2023-01-18' AS DATE), 1),
(19, CAST('2023-01-19' AS DATE), 1),
(20, CAST('2023-01-21' AS DATE), 1);


WITH twmp AS (
    SELECT num,id,log_date,DATEDIFF(log_date,LAG(log_date) OVER (PARTITION BY num ORDER BY log_date ASC)) AS flag FROM logs_day
    
)
SELECT DISTINCT num FROM twmp GROUP BY num,flag HAVING COUNT(*) >= 2;

SELECT DISTINCT l2.num FROM logs_day l1,logs_day l2,logs_day l3 
WHERE l1.num = l2.num AND l2.num = l3.num AND DATEDIFF(l2.log_date,l1.log_date) = 1 AND DATEDIFF(l3.log_date,l2.log_date) = 1;

--***********************超过经理收入的员工*********************************************-- 
-- 需求：Employeess表包含所有员工，他们的经理也属于员工，每个员工都有一个ld,此外还有一列对应员工的
-- 理的ld
CREATE TABLE IF NOT EXISTS employees (
    id INT COMMENT '员工ID',
    name STRING COMMENT '员工姓名',
    salary DECIMAL(10, 2) COMMENT '薪水',
    manager_id INT COMMENT '经理ID'
)
STORED AS ALIORC
TBLPROPERTIES (
    'comment' = '员工表'
);
-- 插入测试数据
INSERT INTO employees (id, name, salary, manager_id) VALUES 
(1, '张三', 70000.00, 3),
(2, '李四', 80000.00, 3),
(3, '王五', 60000.00, NULL),  -- 王五是CEO，没有经理
(4, '赵六', 90000.00, 3),
(5, '钱七', 85000.00, 1),
(6, '孙八', 75000.00, 1),
(7, '周九', 55000.00, 4),
(8, '吴十', 40000.00, 5),
(9, '郑十一', 65000.00, 2);

SELECT DISTINCT e1.id FROM employees e1,employee e2 
WHERE e1.manager_id = e2.id AND e1.salary > e2.salary;

--***********************行程和用户*********************************************-- 
-- 需求：写一段SQL语句查出2019年10月1日至2019年10月3日期间非禁止用户的取消率。基于上表，你的SQL
-- 语句应返回如下结果，取消率（Cancellation Rate)保留两位小数。
-- 取消率的计算方式如下：(被司机或乘喜取消的非禁止用户生成的订单数量）/(非禁止用户生成的订单总数）
-- Trips表：所有出租车的行程信息。每段行程有唯一键ld,Client_ld和Driver_ld是Users表中Users_ld的外键。日
-- Status是枚举类型，枚举成员为（'completed','cancelled_by_driver','cancelled_by_client')。

-- Client_ld
-- Driver_ld
-- City_ld
-- Status
-- Request_at

-- Users表存所有用户，每个用户有唯一键Users_ld。Banned表示这个用户是否被禁止，Role则是一个标识
-- ('client','driver','partner')的枚举类型。
-- Users_ld
-- Banned
-- Cancellation Rate

-- 创建trips表
CREATE TABLE IF NOT EXISTS trips (
    id INT COMMENT '行程ID',
    client_id INT COMMENT '乘客ID',
    driver_id INT COMMENT '司机ID',
    city_id INT COMMENT '城市ID',
    status STRING COMMENT '行程状态：completed, cancelled_by_driver, cancelled_by_client',
    request_at STRING COMMENT '行程日期'
)
STORED AS ALIORC
TBLPROPERTIES (
    'comment' = '行程表'
);

-- 创建users表
CREATE TABLE IF NOT EXISTS users (
    users_id INT COMMENT '用户ID',
    banned STRING COMMENT '是否被禁止: Yes, No',
    role STRING COMMENT '角色: client, driver, partner'
)
STORED AS ALIORC
TBLPROPERTIES (
    'comment' = '用户表'
);

-- 插入trips表数据
INSERT INTO trips (id, client_id, driver_id, city_id, status, request_at) VALUES 
(1, 1, 10, 1, 'completed', '2019-10-01'),
(2, 2, 11, 1, 'cancelled_by_driver', '2019-10-01'),
(3, 3, 12, 6, 'completed', '2019-10-01'),
(4, 4, 13, 6, 'cancelled_by_client', '2019-10-01'),
(5, 1, 10, 1, 'completed', '2019-10-02'),
(6, 2, 11, 6, 'completed', '2019-10-02'),
(7, 3, 12, 6, 'completed', '2019-10-02'),
(8, 2, 12, 12, 'completed', '2019-10-03'),
(9, 3, 10, 12, 'completed', '2019-10-03'),
(10, 4, 13, 12, 'cancelled_by_driver', '2019-10-03'),
(11, 5, 14, 12, 'cancelled_by_client', '2019-10-03'),
(12, 6, 15, 12, 'completed', '2019-10-03'),
(13, 7, 16, 12, 'completed', '2019-10-04'),
(14, 8, 17, 12, 'completed', '2019-10-04');

-- 插入users表数据
INSERT INTO users (users_id, banned, role) VALUES 
(1, 'No', 'client'),
(2, 'Yes', 'client'),
(3, 'No', 'client'),
(4, 'No', 'client'),
(5, 'No', 'client'),
(6, 'No', 'client'),
(7, 'No', 'client'),
(8, 'No', 'client'),
(10, 'No', 'driver'),
(11, 'No', 'driver'),
(12, 'No', 'driver'),
(13, 'No', 'driver'),
(14, 'No', 'driver'),
(15, 'No', 'driver'),
(16, 'No', 'driver'),
(17, 'No', 'driver');

SELECT COUNT(DISTINCT CASE WHEN status != 'completed' THEN id end)/COUNT(DISTINCT id)  FROM trips
WHERE request_at BETWEEN '2019-10-01' AND '2019-10-03' 
AND driver_id IN (SELECT users_id FROM users WHERE banned = 'No' AND role = 'driver')
AND client_id IN (SELECT users_id FROM users WHERE banned = 'No' AND role = 'client')
;

--***********************游戏玩法分析*********************************************-- 
-- 需求一：写一条SQL查询语句获取每位玩家第一次登陆平台的日期。
-- 需求二：描述每一个玩家首次登陆的设备名称。
-- 需求三：编写一个SQL查询，同时报告每组玩家和日期，以及玩家到目前为止玩了多少游戏。也就是说，在此日期之前玩家所玩的游戏总数，详细情况请查看示例。
-- Activity表：显示了某些游戏的玩家的活动情况。
-- player_id
-- device_id
-- event_date
-- games_played

-- 创建Activity表
CREATE TABLE IF NOT EXISTS activity (
    player_id INT COMMENT '玩家ID',
    device_id INT COMMENT '设备ID',
    event_date DATE COMMENT '活动日期',
    games_played INT COMMENT '游戏次数'
)
COMMENT '游戏活动表';

-- 插入Activity表数据
INSERT INTO activity (player_id, device_id, event_date, games_played) VALUES 
(1, 2, CAST('2016-03-01' AS DATE), 5),
(1, 2, CAST('2016-03-02' AS DATE), 6),
(2, 3, CAST('2017-06-25' AS DATE), 1),
(3, 1, CAST('2016-03-01' AS DATE), 0),
(3, 4, CAST('2016-07-03' AS DATE), 5),
(4, 5, CAST('2018-01-01' AS DATE), 3),
(4, 5, CAST('2018-01-02' AS DATE), 4),
(5, 6, CAST('2017-05-15' AS DATE), 10),
(5, 7, CAST('2017-05-16' AS DATE), 12),
(5, 6, CAST('2017-05-17' AS DATE), 15),
(6, 8, CAST('2016-10-10' AS DATE), 2),
(7, 9, CAST('2016-12-01' AS DATE), 7),
(7, 9, CAST('2016-12-02' AS DATE), 5),
(8, 10, CAST('2017-08-01' AS DATE), 8),
(8, 10, CAST('2017-08-02' AS DATE), 9);

-- 创建Activity表
CREATE TABLE IF NOT EXISTS activity (
    player_id INT COMMENT '玩家ID',
    device_id INT COMMENT '设备ID',
    event_date DATE COMMENT '活动日期',
    games_played INT COMMENT '游戏次数'
)
COMMENT '游戏活动表';


SELECT * FROM activity ;

SELECT player_id,event_date,games_played,SUM(games_played) OVER (PARTITION BY player_id ORDER BY event_date ASC ROWS BETWEEN UNBOUNDED PRECEDING   AND CURRENT ROW  ) AS total_games
FROM (
    SELECT player_id,event_date,SUM(games_played) as games_played
    FROM activity 
    GROUP BY player_id,event_date
)
;
--***********************首次登录和首次登录的连续登录*********************************************-- 
-- 需求四：编写一个SQL查询，报告在首次登录的第二天再次登录的玩家的百分比，四舍五入到小数点后两位。换
-- 句话说，您需要计算从首次登录日期开始至少连续两天登录的玩家的数量，然后除以玩家总数。
-- 插入Activity表数据
TRUNCATE TABLE activity ;
INSERT INTO activity (player_id, device_id, event_date, games_played) VALUES 
-- 玩家1：首次登录后第二天也登录
(1, 2, CAST('2016-03-01' AS DATE), 5),
(1, 2, CAST('2016-03-02' AS DATE), 6),
(1, 2, CAST('2016-03-05' AS DATE), 2),

-- 玩家2：只登录了一天
(2, 3, CAST('2017-06-25' AS DATE), 1),

-- 玩家3：首次登录后不是第二天登录，而是几天后
(3, 1, CAST('2016-03-01' AS DATE), 0),
(3, 4, CAST('2016-07-03' AS DATE), 5),

-- 玩家4：首次登录后第二天也登录
(4, 5, CAST('2018-01-01' AS DATE), 3),
(4, 5, CAST('2018-01-02' AS DATE), 4),
(4, 5, CAST('2018-01-10' AS DATE), 2),

-- 玩家5：首次登录后第二天也登录，且还有后续登录
(5, 6, CAST('2017-05-15' AS DATE), 10),
(5, 7, CAST('2017-05-16' AS DATE), 12),
(5, 6, CAST('2017-05-17' AS DATE), 15),

-- 玩家6：只登录了一天
(6, 8, CAST('2016-10-10' AS DATE), 2),

-- 玩家7：首次登录后第二天也登录
(7, 9, CAST('2016-12-01' AS DATE), 7),
(7, 9, CAST('2016-12-02' AS DATE), 5),
(7, 9, CAST('2016-12-05' AS DATE), 3),

-- 玩家8：首次登录后第二天也登录
(8, 10, CAST('2017-08-01' AS DATE), 8),
(8, 10, CAST('2017-08-02' AS DATE), 9),

-- 玩家9：首次登录后不是第二天登录
(9, 11, CAST('2018-03-05' AS DATE), 6),
(9, 11, CAST('2018-03-10' AS DATE), 7),

-- 玩家10：只登录了一天
(10, 12, CAST('2017-12-15' AS DATE), 3);

SELECT COUNT(distinct case when flag = 1 then player_id end),COUNT(distinct player_id),COUNT(distinct case when flag = 1 then player_id end) / COUNT(distinct player_id)
FROM 
(
    SELECT player_id,event_date,FIRST_VALUE(event_date) OVER (PARTITION BY player_id ORDER BY event_date ASC ) AS first_activity_date,DATEDIFF(event_date,FIRST_VALUE(event_date) OVER (PARTITION BY player_id ORDER BY event_date ASC ), 'dd') AS flag
    FROM (
        SELECT player_id,event_date,SUM(games_played) as games_played
        FROM activity 
        GROUP BY player_id,event_date
    )
)
;

--***********************规定时间范围内的连续登录次数，不管首次登陆问题*********************************************-- 



--***********************员工累计薪水*********************************************-- 
--***********************窗口移动函数：rows between 2(unbound) preceding and (2)(unbound) following*********************************************-- 
-- 需求：查询一个员工三个月内的累计薪水，但是不包括最近一个月的薪水。
-- 创建员工薪水表
CREATE TABLE IF NOT EXISTS employee_salary (
    id INT COMMENT '员工ID',
    month INT COMMENT '月份',
    salary INT COMMENT '薪水'
)
COMMENT '员工月度薪水表';

-- 插入数据
INSERT INTO employee_salary (id, month, salary) VALUES 
-- 员工1的薪水记录
(1, 1, 20),
(1, 2, 30),
(1, 3, 40),
(1, 4, 60),
(1, 5, 50),
(1, 6, 70),

-- 员工2的薪水记录
(2, 1, 10),
(2, 2, 30),
(2, 3, 40),
(2, 4, 60),
(2, 5, 50),
(2, 6, 70),

-- 员工3的薪水记录
(3, 1, 15),
(3, 2, 25),
(3, 3, 35),
(3, 4, 40),
(3, 5, 45),
(3, 6, 55),

-- 员工4的薪水记录 (只有几个月的记录)
(4, 1, 25),
(4, 2, 35),
(4, 3, 45),

-- 员工5的薪水记录 (记录不连续)
(5, 1, 30),
(5, 3, 50),
(5, 4, 60),
(5, 6, 80),

-- 员工6的薪水记录 (只有一个月的记录)
(6, 1, 20);

SELECT id,month,salary,SUM(salary) OVER (PARTITION BY id ORDER BY month ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW ) AS cumulative_salary
FROM (
    SELECT id,month,SUM(salary) AS salary FROM employee_salary GROUP BY id,month
);

--***********************订单当月新客户数*********************************************--
-- 已知一个表STG.ORDER,有如下字段：Date,Order_id,User_id,amount,请给出sq|进行统计数据样例：2017-01-01,10029028,1000003251,33.57.
-- 1)给出2017年每个月的订单数、用户数、总成交金额。
-- 2)给出2017年11月的新客数（指在11月才有第一笔订单）
-- 表名：jd_shop
-- 创建订单表

CREATE TABLE IF NOT EXISTS jd_shop (
    Date STRING COMMENT '订单日期',
    Order_id STRING COMMENT '订单ID',
    User_id STRING COMMENT '用户ID',
    Amount DECIMAL(10, 2) COMMENT '订单金额'
)
COMMENT '订单数据表';

-- 插入数据
INSERT INTO jd_shop (Date, Order_id, User_id, Amount) VALUES 
-- 2017年1月数据
('2017-01-01', '10029001', '1000003251', 33.57),
('2017-01-05', '10029002', '1000003252', 45.20),
('2017-01-10', '10029003', '1000003253', 22.80),
('2017-01-15', '10029004', '1000003254', 67.90),
('2017-01-20', '10029005', '1000003255', 89.30),
('2017-01-25', '10029006', '1000003251', 123.45),

-- 2017年2月数据
('2017-02-03', '10029007', '1000003252', 56.70),
('2017-02-08', '10029008', '1000003253', 43.25),
('2017-02-15', '10029009', '1000003256', 77.40),
('2017-02-22', '10029010', '1000003257', 65.30),

-- 2017年3月数据
('2017-03-05', '10029011', '1000003251', 43.70),
('2017-03-12', '10029012', '1000003254', 87.65),
('2017-03-19', '10029013', '1000003258', 29.90),
('2017-03-26', '10029014', '1000003259', 55.60),

-- 2017年10月数据
('2017-10-05', '10029015', '1000003260', 78.90),
('2017-10-12', '10029016', '1000003261', 45.30),
('2017-10-19', '10029017', '1000003262', 98.70),
('2017-10-26', '10029018', '1000003263', 123.45),

-- 2017年11月数据 (包含一些老用户)
('2017-11-03', '10029019', '1000003251', 67.80),
('2017-11-10', '10029020', '1000003255', 98.40),
('2017-11-17', '10029021', '1000003257', 76.50),

-- 2017年11月的新客户数据 (之前没有下过单的用户)
('2017-11-05', '10029022', '1000003264', 45.60),
('2017-11-12', '10029023', '1000003265', 89.70),
('2017-11-19', '10029024', '1000003266', 34.50),
('2017-11-26', '10029025', '1000003267', 67.80),

-- 2017年12月数据
('2017-12-04', '10029026', '1000003251', 56.70),
('2017-12-11', '10029027', '1000003260', 78.90),
('2017-12-18', '10029028', '1000003264', 45.60),
('2017-12-25', '10029029', '1000003268', 123.45),

-- 2018年1月数据 (用于对比)
('2018-01-02', '10029030', '1000003251', 67.80),
('2018-01-09', '10029031', '1000003269', 89.70);

SELECT month_year,SUM(amount) AS total_amount
FROM (
    SELECT date,SUBSTR(date,1,7) as month_year,user_id,amount FROM jd_shop
)
GROUP BY month_year
;

SELECT date,order_id,user_id,amount FROM jd_shop WHERE SUBSTR(date,1,7) = '2017-11'
AND user_id NOT IN (SELECT DISTINCT user_id  FROM jd_shop WHERE SUBSTR(date,1,7) < '2017-11')
;

--***********************活跃用户*********************************************--
-- 有日志如下，请写出代码求得所有用户和活跃用户的总数及平均年龄。（活跃用户指连续两天都有访问记录的用日期用户年龄
-- 2019-02-11,test_1,23
-- 2019-02-11,test_2,19
-- 2019-02-11,test_3,39
-- 2019-02-11,test_1,23
-- 2019-02-11,test_3,39
-- 2019-02-11,test_1,23
-- 2019-02-12,test2,19
-- 2019-02-13,test_1,23
-- 2019-02-15,test_2,19
-- 2019-02-16,test_2,19

-- 1)按照日期以及用户分组，按照日期排序并给出排名
-- 2)计算日期及排名的差值
-- 3)过滤出差值大于等于2的，即为连续两天活跃的用户
-- 4)对数据进行去重处理（一个用户可以在两个不同的时间点连续登录）,例如：a用户在1月10号1月11号以及1日
-- 月20号和1月21号4天登录。
-- 5)计算活跃用户（两天连续有访问）的人数以及平均年龄
-- 6)对全量数据集进行按照用户去重
-- 7)计算所有用户的数量以及平均年龄
-- 8)将第5步以及第7步两个数据集进行unional|操作

CREATE TABLE IF NOT EXISTS user_logs (
    log_date STRING,
    user_id STRING,
    age INT
);
INSERT INTO user_logs VALUES
('2019-02-11', 'test_1', 23),
('2019-02-11', 'test_2', 19),
('2019-02-11', 'test_3', 39),
('2019-02-11', 'test_1', 23),
('2019-02-11', 'test_3', 39),
('2019-02-11', 'test_1', 23),
('2019-02-12', 'test_2', 19),
('2019-02-13', 'test_1', 23),
('2019-02-15', 'test_2', 19),
('2019-02-16', 'test_2', 19)
;


SELECT user_id,age,log_date FROM user_logs;


--***********************活跃用户，以及绝对值ABS函数*********************************************--
-- 获取客户每笔订单时间最近的用户浏览日志记录时间(客户可以浏览之后下单，也可以下单之后浏览，也有浏览了下单然后右浏览，总之浏览时间可以再下单时间的前后，最近的浏览时间，就是相差绝对值最小那个
-- 创建订单表
DROP TABLE IF EXISTS fb_orders;
CREATE TABLE IF NOT EXISTS fb_orders (
    order_id STRING COMMENT '订单ID',
    user_id STRING COMMENT '用户ID',
    product_id STRING COMMENT '产品ID',
    order_datetime DATETIME COMMENT '订单时间',
    order_amount DECIMAL(10,2) COMMENT '订单金额'
) 
STORED AS ALIORC  
TBLPROPERTIES ('columnar.nested.type'='true',
    'comment'='订单表');

DROP TABLE IF EXISTS fb_user_browsing_logs;
-- 创建用户浏览日志表
CREATE TABLE IF NOT EXISTS fb_user_browsing_logs (
    log_id STRING COMMENT '日志ID',
    user_id STRING COMMENT '用户ID',
    browse_datetime DATETIME COMMENT '浏览时间',
    product_id STRING COMMENT '产品ID'
) 
STORED AS ALIORC
TBLPROPERTIES ('columnar.nested.type'='true',
    'comment'='用户浏览日志表');

-- 插入订单数据
INSERT INTO fb_orders (order_id, user_id, product_id, order_datetime, order_amount) VALUES
('O001', 'U001', 'P001', CAST('2023-01-01 10:30:00' AS DATETIME), 99.99),
('O002', 'U001', 'P003', CAST('2023-01-03 14:20:00' AS DATETIME), 149.50),
('O003', 'U002', 'P005', CAST('2023-01-02 09:15:00' AS DATETIME), 75.25),
('O004', 'U003', 'P008', CAST('2023-01-04 16:45:00' AS DATETIME), 199.99),
('O005', 'U002', 'P007', CAST('2023-01-05 11:30:00' AS DATETIME), 50.75);
-- 插入用户浏览日志数据
INSERT INTO fb_user_browsing_logs (log_id, user_id, browse_datetime, product_id) VALUES
('L001', 'U001', CAST('2023-01-01 09:15:00' AS DATETIME), 'P001'),
('L002', 'U001', CAST('2023-01-01 12:45:00' AS DATETIME), 'P002'),
('L003', 'U001', CAST('2023-01-03 13:50:00' AS DATETIME), 'P003'),
('L004', 'U001', CAST('2023-01-03 15:00:00' AS DATETIME), 'P004'),
('L005', 'U002', CAST('2023-01-02 08:30:00' AS DATETIME), 'P005'),
('L006', 'U002', CAST('2023-01-02 09:30:00' AS DATETIME), 'P006'),
('L007', 'U002', CAST('2023-01-05 11:00:00' AS DATETIME), 'P007'),
('L008', 'U003', CAST('2023-01-04 16:30:00' AS DATETIME), 'P008'),
('L009', 'U003', CAST('2023-01-04 17:15:00' AS DATETIME), 'P009'),
('L010', 'U003', CAST('2023-01-05 09:00:00' AS DATETIME), 'P010');


SELECT *
FROM (
    SELECT order_id, user_id,order_datetime,browse_datetime,ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY flag asc) AS rn
    FROM (
        SELECT a.order_id,a.user_id,a.order_datetime,b.browse_datetime,ABS(DATEDIFF(a.order_datetime, b.browse_datetime, 'ss')) AS flag
        FROM fb_orders a  LEFT JOIN fb_user_browsing_logs b 
        ON a.product_id = b.product_id AND a.user_id = b.user_id
    )
)
WHERE rn = 1
;

--***********************场景一：取当前数据的上一条和下一条，直到取到满足条件的为止*********************************************--
--***********************滑动窗口函数和sum()的用法结合*********************************************--
-- 需求描述：
-- 有一张入库成本表一个商品每次入库就会产生一条数据，里面包含商品id,入库时间，以及入库采购的成本，但由于某些某些原因，导致表中某些数据的成本是有丢失的.现在的逻辑是，
-- 当成本丢失时，有两种取成本的方式，现在需要把两种成本都取出来，最后取2次成本的平均值作为本次入库的成本。
-- 1.取同一个商品最近一次入库的有效成本（即存在成本时就为有效成本，无效成本为null)
-- 2.取同一个商品紧接着一次入库的有效成本

---1.测试表存在则删除
drop table aaa001;
---2.创建测试表
create table aaa001
(
product_id string comment '商品id',
into_warehouse_time string comment '入库时间',
cost int comment '成本'
)
STORED AS ALIORC  
TBLPROPERTIES ('columnar.nested.type'='true',
    'comment'='测试表');
---3.插入测试数据
insert into aaa001 values
('1101','2021-01-01',120),
('1102','2021-01-01',150),
('1102','2021-01-02',null),
('1102','2021-01-03',null),
('1102','2021-01-04',200),
('1102','2021-01-05',210),
('1103','2021-01-06',300),
('1103','2021-01-07',null),
('1103','2021-01-08',400),
('1104','2022-01-01',111111),
('1104','2022-01-02',null),
('1104','2022-01-03',null),
('1104','2022-01-04',22222),
('1104','2022-01-05',null)
;
---4.查询sql
select *
from aaa001
order by product_id ,into_warehouse_time 
;
--结果语句
WITH temp AS (
    select product_id,
           into_warehouse_time,
           cost,
           sum(IF(cost is not NULL ,1,0)) over(partition by product_id order by into_warehouse_time asc) as last_flag
           ,sum(IF(cost is not NULL ,1,0)) over(partition by product_id order by into_warehouse_time asc ROWS BETWEEN current row and UNBOUNDED FOLLOWING) as next_flag
    from aaa001
)
,temp1 AS (
    select product_id,
           into_warehouse_time,
           cost,
        FIRST_VALUE(cost) over(partition by product_id,last_flag order by into_warehouse_time asc) as last_cost,
        FIRST_VALUE(cost) over(partition by product_id,next_flag order by into_warehouse_time DESC) as next_cost
    from temp
)
SELECT product_id,
           into_warehouse_time,
           cost,last_cost,
           next_cost,(last_cost + next_cost)/2
FROM temp1 
;

--***********************场景二：要计算每天每个员工当月累计的销售额，但是某些员工在某几天是没有销售记录的，需要特殊处理。*********************************************--
--***********************难点在于怎么把确实的记录数据补上，需要使用炸裂函数和自然排序函数*********************************************--
-- 需求描述:另工销售记是表我们素要每天统计每一个员工的当月累计销售额.
---1.测试表存在则删除
drop table aaa002;
--2.创建测试表
create table aaa002
(
sale_date string,
emp_id int,
emp_name string,
sale_amount int
)
;
--3.插入测试数据
insert into table aaa002 values
('2021-10-02',101,'张三',100),
('2021-10-03',101,'张三',300),
('2021-10-05',101,'张三',400),
('2021-10-01',102,'李四',111),
('2021-10-03',102,'李四',222),
('2021-10-08',102,'李四',333)
;
---4.查询sql
select
*
from aaa002
order by emp_id ,sale_date 
;
--结果SQL
with temp1 AS (
    ---得到连续日期,而且是带emp_id和emp_name的
    select t.emp_id
        ,t.emp_name
        ,start_date
        , DATEDIFF(to_date(t.end_date,'yyyy-MM-dd'), to_date(t.start_date,'yyyy-MM-dd'), 'dd') AS date_diff
    from
    (
        select emp_id
            ,emp_name
            ,MIN(sale_date) as start_date
            ,max(sale_date) as end_date
        from aaa002
        group by emp_id,emp_name
    )t
)
,temp2 AS (
select
    emp_id,
    emp_name,
     date_add(to_date(start_date), pos) AS sale_date
from temp1
lateral VIEW explode(sequence(0,date_diff)) number_table AS pos
)
, temp3 as (
    select
    temp2.emp_id,
        temp2.emp_name,
        temp2.sale_date,
        aaa002.sale_amount
    from temp2 
    LEFT JOIN aaa002 ON temp2.emp_id = aaa002.emp_id AND temp2.sale_date = aaa002.sale_date
)
select emp_id,emp_name,sale_date,SUM(IF(sale_amount IS NULL ,0,sale_amount)) OVER (PARTITION BY emp_id ORDER BY sale_date asc) AS sale_amount
from temp3
;


-***********************综合题目*********************************************--
-- 某在线购物平台的系统中，有三个主要的数据表：客户表（customers)、订单表（orders)和订单商品表（order_items)。这些表分别记录了客户的基本信息，订单信息的商品详细信息。
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT,
    email STRING,
    name STRING,
    phone STRING,
    created_at DATETIME
);
-- 插入示例数据到customers表
INSERT INTO customers (customer_id, email, name, phone, created_at) VALUES
(1, 'zhangsan@example.com', '张三', '13800138000', CAST('2023-01-01 10:00:00' AS DATETIME)),
(2, 'lisi@example.com', '李四', '13900139000', CAST('2023-02-15 14:30:00' AS DATETIME));
CREATE TABLE IF NOT EXISTS orders (
    order_id INT,
    customer_id INT,
    order_date DATETIME,
    total_amount DECIMAL(10,2)
);
-- 插入示例数据到orders表
INSERT INTO orders (order_id, customer_id, order_date, total_amount) VALUES
(101, 1, CAST('2023-01-15 13:45:00' AS DATETIME), 150.00),
(102, 2, CAST('2023-02-20 11:20:00' AS DATETIME), 200.00),
(103, 1, CAST('2023-03-25 16:10:00' AS DATETIME), 120.00);
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2)
);
-- 插入示例数据到order_items表
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price) VALUES
(1001, 101, 1, 2, 50.00),
(1002, 101, 2, 1, 50.00),
(1003, 102, 3, 2, 100.00),
(1004, 103, 1, 1, 50.00),
(1005, 103, 4, 1, 70.00);

-- 这道题目要求编写SQL查询，查询所有订单在每个客户订单中的累计总金额，并按订单日期升序排序。
SELECT o.order_id, o.customer_id, o.order_date, o.total_amount,
    SUM(o.total_amount) OVER (
      PARTITION BY o.customer_id ORDER BY o.order_date ASC
    ) AS cumulative_total_amount
FROM orders o
ORDER BY o.customer_id, o.order_date ASC;

-- 编写SQL,查询每个客户的最新订单总金额及其在客户所有订单总金额中的比例。

-- 编写SQL,查询每个订单的总商品数量及其包含的商品列表(用逗号）。
SELECT oi.order_id,
    SUM(oi.quantity) AS total_quantity,
    WM_CONCAT(',',oi.product_id) AS product_list
FROM order_items oi
GROUP BY oi.order_id
;

-- 写SQL,查询每个客户的姓名及其上一个订单的总金额
SELECT c.name,
    LAG(o.total_amount) OVER (PARTITION BY c.name ORDER BY o.order_date ASC) AS previous_order_amount
  FROM customers c
  JOIN orders o
    ON c.customer_id = o.customer_id
 ORDER BY c.name,
          o.order_date ASC;

-- 写SQL,查询订单总金额超过其客户所有订单平均金额的订单
SELECT o1.order_id
  FROM orders o1
 WHERE o1.total_amount > (
        SELECT AVG(o2.total_amount)
          FROM orders o2 WHERE o1.customer_id = o2.customer_id
       ) ;



--***********************综合题目*********************************************************************************--
-- 背景：
-- 假设我们有一张用户观看行为日志表 ev_fss_view，记录了用户的基本信息、注册时间以及每日的观看行为。
-- 题目列表：
-- 计算总独立用户数（UV）和所有用户的平均年龄。
-- 统计每日的日活跃用户平均观看时长，以及当日的新增注册用户数。
-- 找出在每一天中，观看总时长最长的用户（“日度观看冠军”）。
-- 以用户注册日为维度，计算次日留存用户数和次日留存率。
-- （次日留存率 = (注册日后第一天仍活跃的用户数 / 注册日当天总注册用户数) * 100%）
-- 计算每个用户截至每一天的累计总观看时长。
-- 筛选出所有单日观看总时长超过20分钟的观看记录（用户和日期）。
-- 找出所有“高质量”用户，定义为：该用户在他所有有过观看记录的日子里，每天的观看总时长都超过了20分钟。

CREATE TABLE IF NOT EXISTS ev_fss_view (
    user_id INT,               -- 用户ID
    age INT,                   -- 用户年龄
    register_time VARCHAR(20), -- 用户注册时间 (格式: 'YYYY/MM/DD HH:MI:SS')
    ymd VARCHAR(8),            -- 观看日期 (格式: 'YYYYMMDD')
    view_time INT              -- 当次观看时长（单位：分钟）
);

INSERT INTO ev_fss_view (user_id, age, register_time, ymd, view_time) VALUES
-- 用户101: 2023/01/15注册, 15号和16号活跃 -> 成功留存
(101, 25, '2023/01/15 10:00:00', '20230115', 10),
(101, 25, '2023/01/15 10:00:00', '20230115', 15), -- 当天多次观看
(101, 25, '2023/01/15 10:00:00', '20230116', 30), -- 次日活跃

-- 用户102: 2023/01/15注册, 17号才活跃 -> 未能次日留存
(102, 30, '2023/01/15 11:30:00', '20230117', 15),
(102, 30, '2023/01/15 11:30:00', '20230117', 15), -- 17号观看时长冠军

-- 用户103: 2023/01/16注册, 17号活跃 -> 成功留存
(103, 22, '2023/01/16 09:00:00', '20230117', 25),

-- 用户104: 高质量用户，所有观看日的总时长都 > 20
(104, 35, '2023/01/18 14:00:00', '20230118', 25),
(104, 35, '2023/01/18 14:00:00', '20230119', 30),

-- 用户105: 非高质量用户，有一天观看总时长 < 20
(105, 28, '2023/01/18 16:00:00', '20230118', 15), -- 这天时长 < 20
(105, 28, '2023/01/18 16:00:00', '20230119', 25);

-- 计算总独立用户数（UV）和所有用户的平均年龄。
SELECT COUNT(DISTINCT user_id) as uv,AVG(age) as avg_age
FROM 
(
   SELECT user_id ,age
    FROM ev_fss_view
    group by user_id,age 
) a
;

-- 统计每日的日活跃用户平均观看时长，以及当日的新增注册用户数。
WITH t1 as (
    SELECT REPLACE(SUBSTR(register_time,1,10),'/','') AS register_date,COUNT(DISTINCT user_id) as register_cnt
    from ev_fss_view
    GROUP BY REPLACE(SUBSTR(register_time,1,10),'/','')
)
, t2 as (
    SELECT ymd,AVG(view_time) as avg_view_time
    from ev_fss_view
    GROUP BY ymd
)
SELECT t2.ymd,t2.avg_view_time,t1.register_cnt
from t2 LEFT JOIN t1
ON t2.ymd = t1.register_date
;

-- 找出在每一天中，观看总时长最长的用户（“日度观看冠军”）。
with t1 AS (
    SELECT ymd,user_id,SUM(view_time) as total_view_time
    FROM ev_fss_view
    group by ymd,user_id
)
, t2 AS (
    SELECT ymd,user_id,total_view_time,ROW_NUMBER() over(PARTITION BY ymd ORDER BY total_view_time DESC) AS rn
    FROM t1
)
SELECT ymd,user_id,total_view_time
FROM t2
WHERE rn = 1
;

-- 以用户注册日为维度，计算次日留存用户数和次日留存率。
-- （次日留存率 = (注册日后第一天仍活跃的用户数 / 注册日当天总注册用户数) * 100%）
with t1 AS (
    SELECT REPLACE(SUBSTR(register_time,1,10),'/','-') AS register_date,user_id
    FROM ev_fss_view
    group by REPLACE(SUBSTR(register_time,1,10),'/','-'),user_id
)
, t2 AS (
    SELECT CONCAT(SUBSTRING(ymd,1,4),'-',SUBSTRING(ymd,5,2),'-',SUBSTRING(ymd,7,2)) as ymd,user_id
    FROM ev_fss_view
    group by CONCAT(SUBSTRING(ymd,1,4),'-',SUBSTRING(ymd,5,2),'-',SUBSTRING(ymd,7,2)),user_id
)
, t3 AS (
    SELECT t1.register_date,t1.user_id as register_user_id,t2.user_id as retention_user_id
    FROM t1 LEFT JOIN t2
    ON t1.user_id = t2.user_id
    AND t1.register_date = DATE_SUB(t2.ymd,1) 
)
SELECT register_date,COUNT(DISTINCT retention_user_id)/COUNT(DISTINCT register_user_id) AS retention_rate
FROM t3
GROUP BY register_date
;

-- 计算每个用户截至每一天的累计总观看时长。
SELECT user_id,SUM(view_time) OVER (PARTITION BY user_id ORDER BY ymd asc ) AS cumulative_view_time
FROM ev_fss_view
;

-- 筛选出所有单日观看总时长超过20分钟的观看记录（用户和日期）。
SELECT DISTINCT user_id,ymd
FROM ev_fss_view
WHERE view_time > 20
;

-- 找出所有“高质量”用户，定义为：该用户在他所有有过观看记录的日子里，每天的观看总时长都超过了20分钟。
SELECT user_id
FROM ev_fss_view
GROUP BY user_id
HAVING COUNT(DISTINCT CASE WHEN view_time > 20 THEN ymd END) = COUNT(DISTINCT ymd)
;