## 1、安装与使用

WCDB基于WINQ，引入了Objective-C++代码，因此对于所有引入WCDB的源文件，都需要将其后缀`.m`改为`.mm`.所以不要在pch文件中引入`#import <WCDB.h>`否则报错如下：

`Since WCDB is an Objective-C++ framework, for those files in your project that includes WCDB, you should rename their extension .m to .mm.`

**设置主键**

<img src="/Users/mac/Downloads/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-12-11%20%E4%B8%8B%E5%8D%883.58.58.png" alt="屏幕快照 2019-12-11 下午3.58.58" style="zoom:50%;" />

```objective-c
WCDB_IMPLEMENTATION(WCGasUser) //映射表
WCDB_PRIMARY(WCGasUser, gas_id)//映射主键

WCDB_SYNTHESIZE(WCGasUser, mobile)//映射model->表字段
WCDB_SYNTHESIZE(WCGasUser, password)
WCDB_SYNTHESIZE(WCGasUser, last_login_ip)
WCDB_SYNTHESIZE(WCGasUser, Last_login_time)
WCDB_SYNTHESIZE(WCGasUser, create_time)
WCDB_SYNTHESIZE(WCGasUser, update_time)
WCDB_SYNTHESIZE(WCGasUser, user_name)

```

#### Method definition for 'patient_id' not found

> 字段patient_id没有WCDB_SYNTHESIZE

#### [WCDB][ERROR] Code:19, Type:SQLite, Tag:0, Op:6, ExtCode:1555, Msg:UNIQUE constraint failed: xxxTable.xxx

**UNIQUE constraint failed表示违反唯一性约束，比如重复定义主键、索引引起的**

唯一性原则：**任意一个表中不可能存在两行数据有相同的主键值**

### 关键字keyword like搜索

如果我们希望从 "Persons" 表中选取居住在包含 "B" 的城市里的人：

我们可以使用下面的 SELECT 语句：

```
SELECT * FROM Persons
WHERE City LIKE '%b%'
```

WCDB 

```
/*
 DELETE FROM message
 WHERE localID BETWEEN 10 AND 20 OR content LIKE 'Hello%'
 */
[database deleteObjectsFromtable:@"message"
                           where:Message.local.between(10, 20) 
 								 || Message.content.like("Hello%")];
```