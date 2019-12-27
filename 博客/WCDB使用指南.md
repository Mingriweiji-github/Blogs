# 1-WCDB使用指南


## 安装

WCDB提供了多种安装方式，请参考 [README](https://github.com/Tencent/wcdb/wiki/Home)

## 类字段绑定（ORM）

在WCDB内，ORM（Object Relational Mapping）是指

- 将一个ObjC的类，映射到数据库的表和索引；
- 将类的property，映射到数据库表的字段；

这一过程。通过ORM，可以达到直接通过Object进行数据库操作，省去拼装过程的目的。

WCDB通过内建的宏实现ORM的功能。如下：

```
//Message.h
@interface Message : NSObject

@property int localID;
@property(retain) NSString *content;
@property(retain) NSDate *createTime;
@property(retain) NSDate *modifiedTime;
@property(assign) int unused; //You can only define the properties you need

@end
//Message.mm
#import "Message.h"
@implementation Message

WCDB_IMPLEMENTATION(Message)
WCDB_SYNTHESIZE(Message, localID)
WCDB_SYNTHESIZE(Message, content)
WCDB_SYNTHESIZE(Message, createTime)
WCDB_SYNTHESIZE(Message, modifiedTime)

WCDB_PRIMARY(Message, localID)

WCDB_INDEX(Message, "_index", createTime)

@end
//Message+WCTTableCoding.h
#import "Message.h"
#import <WCDB/WCDB.h>

@interface Message (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(localID)
WCDB_PROPERTY(content)
WCDB_PROPERTY(createTime)
WCDB_PROPERTY(modifiedTime)

@end
```

将一个已有的ObjC类进行ORM绑定的过程如下：

- 定义该类遵循`WCTTableCoding`协议。可以在类声明上定义，也可以通过[文件模版](https://github.com/Tencent/wcdb/wiki/ORM使用教程#WCTTableCoding文件模版)在category内定义。
- 使用`WCDB_PROPERTY`宏在头文件声明需要绑定到数据库表的字段。
- 使用`WCDB_IMPLEMENTATIO`宏在类文件定义绑定到数据库表的类。
- 使用`WCDB_SYNTHESIZE`宏在类文件定义需要绑定到数据库表的字段。

简单几行代码，就完成了将类和需要的字段绑定到数据库表的过程。这三个宏在名称和使用习惯上，也都和定义一个ObjC类相似，以此便于记忆。

除此之外，WCDB还提供了许多可选的宏，用于定义数据库索引、约束等，如：

- `WCDB_PRIMARY`用于定义主键
- `WCDB_INDEX`用于定义索引
- `WCDB_UNIQUE`用于定义唯一约束
- `WCDB_NOT_NULL`用于定义非空约束
- ...

定义完成后，只需要调用`createTableAndIndexesOfName:withClass:`接口，即可创建表和索引。

```
WCTDatabase *database = [[WCTDatabase alloc] initWithPath:path];
/*
 CREATE TABLE messsage (localID INTEGER PRIMARY KEY,
 						content TEXT,
 						createTime BLOB,
	 					modifiedTime BLOB)
 */
BOOL result = [database createTableAndIndexesOfName:@"message"
                                          withClass:Message.class];
```

接口会根据ORM的定义，创建对应表和索引。

**更多关于ORM定义，请参考：[ORM使用教程](https://github.com/Tencent/wcdb/wiki/ORM使用教程)**

## 增删改查（CRUD）

得益于ORM的定义，WCDB可以直接进行通过object进行增删改查（CRUD）操作。开发者可以通过`WCTDatabase`和`WCTTable`两个类进行一般的增删改查操作。如下：

```
//插入
Message *message = [[Message alloc] init];
message.localID = 1;
message.content = @"Hello, WCDB!";
message.createTime = [NSDate date];
message.modifiedTime = [NSDate date];
/*
 INSERT INTO message(localID, content, createTime, modifiedTime) 
 VALUES(1, "Hello, WCDB!", 1496396165, 1496396165);
 */
BOOL result = [database insertObject:message
                                into:@"message"];
//删除
//DELETE FROM message WHERE localID>0;
BOOL result = [database deleteObjectsFromTable:@"message"
                                         where:Message.localID > 0];
//修改
//UPDATE message SET content="Hello, Wechat!";
Message *message = [[Message alloc] init];
message.content = @"Hello, Wechat!";
BOOL result = [database updateRowsInTable:@"message"
		                     onProperties:Message.content
        		               withObject:message];
//查询
//SELECT * FROM message ORDER BY localID
NSArray<Message *> *message = [database getObjectsOfClass:Message.class
                                                fromTable:@"message"
                                                  orderBy:Message.localID.order()];
```

`WCTTable`相当于预设了表名和类名的`WCTDatabase`对象，接口和`WCTDatabase`基本一致。

```
WCTTable *table = [database getTableOfName:@"message"
                                 withClass:Message.class];
//查询
//SELECT * FROM message ORDER BY localID
NSArray<Message *> *message = [table getObjectsOrderBy:Message.localID.order()];
```

**更多关于增删改查的接口，请参考：[基础类、CRUD与Transaction](https://github.com/Tencent/wcdb/wiki/基础类、CRUD与Transaction)**

## 事务（Transaction）

WCDB内可通过两种方式执行事务，一是`runTransaction:`接口，如下：

```
BOOL commited = [database runTransaction:^BOOL {
	[database insertObject:message into:@"message"];
	return YES; //return YES to commit transaction and return NO to rollback transaction.
}];
```

这种方式要求数据库操作在一个BLOCK内完成，简单易用。

另一种方式则是获取`WCTTransaction`对象，如下：

```
WCTTransaction *transaction = [database getTransaction];
BOOL result = [transaction begin];
[transaction insertObject:message into:@"message"];
result = [transaction commit];
if (!result) {
    [transaction rollback];
    NSLog(@"%@", [transaction error]);
}
```

`WCTTransaction`对象可以在类或函数间传递，因此这种方式也更具灵活性。

**更多关于事务的注意事项，请参考：[基础类、CRUD与Transaction](https://github.com/Tencent/wcdb/wiki/基础类、CRUD与Transaction)。**

## WINQ（WCDB语言集成查询）

WINQ（**W**CDB **In**tegrated **Q**uery，音'wink'），是将自然查询的SQL集成到WCDB框架中的技术，基于C++实现。

传统的SQL语句，通常是开发者拼接字符串完成。这种方式不仅繁琐、易错，而且出错后很难定位到问题所在。同时也容易给SQL注入留下可乘之机。

而WINQ将查询语言集成到了C++中，可以通过类似函数调用的方式来写SQL查询。借用IDE的代码提示和编译器的语法检查，达到易用、纠错的效果。

### 字段映射与运算符

对于一个已绑定ORM的类，可以通过`className.propertyName`的方式，获得数据库内字段的映射，以此书写SQL的条件、排序、过滤等等所有语句。如下是几个例子：

```
/*
 SELECT MAX(createTime), MIN(createTime)
 FROM message
 WHERE localID>0 AND content IS NOT NULL
 */
[database getObjectsOnResults:{Message.createTime.max(), Message.createTime.min()}
                    fromTable:@"message"
                        where:Message.localID > 0 && Message.content.isNotNull()];
/*
 SELECT DISTINCT localID
 FROM message
 ORDER BY modifiedTime ASC
 LIMIT 10
 */
[database getObjectsOnResults:Message.localID.distinct()
                    fromTable:@"message"
                      orderBy:Message.modifiedTime.order(WCTOrderedAscending)
                        limit:10];
/*
 DELETE FROM message
 WHERE localID BETWEEN 10 AND 20 OR content LIKE 'Hello%'
 */
[database deleteObjectsFromtable:@"message"
                           where:Message.local.between(10, 20) 
 								 || Message.content.like("Hello%")];
```

由于WINQ通过接口调用实现SQL查询，因此在书写过程中会有IDE的代码提示和编译器的语法检查，从而提升开发效率，避免写错。

WINQ的接口包括但不限于：

- 一元操作符：+、-、!等
- 二元操作符：||、&&、+、-、*、/、|、&、<<、>>、<、<=、==、!=、>、>=等
- 范围比较：IN、BETWEEN等
- 字符串匹配：LIKE、GLOB、MATCH、REGEXP等
- 聚合函数：AVG、COUNT、MAX、MIN、SUM等
- ...

凡是SQLite支持的语法规则，WINQ基本都有其对应的接口。且接口名称与SQLite的语法规则基本保持一致。

### 字段组合

多个字段映射可通过大括号`{}`进行组合，如：

```
/*
 SELECT localID, content
 FROM message
 */
[database getAllObjectsOnResults:{Message.localID, Message.content}
 					   fromTable:@"message"];
/*
 SELECT *
 FROM message
 ORDER BY createTime ASC, localID DESC
 */
[database getObjectsOfClass:Message.class 
				  fromTable:@"message" 
				    orderBy:{Message.createTime.order(WCTOrderedAscending),  Message.localID.order(WCTOrderedDescending)}];
```

### AllProperties

在上述的组合中，大括号`{}`的语法实质是C++中列表`std::list`的隐式初始化。而`className.AllProperties`则用于获取类定义的所有字段映射的列表，如：

```
/*
 SELECT localID, content, createTime, modifiedTime
 FROM message
*/
[database getAllObjectsOnResults:Message.AllProperties
 					   fromTable:@"message"];
```

### AnyProperty

`className.AnyProperty`用于指代SQL中的`*`，如：

```
/*
 SELECT count(*)
 FROM message
 */
 [database getOneValueOnResult:Message.AnyProperty.count()
	  			  	 fromTable:@"message"];
```

WINQ的使用上接近于C函数调用。**对于熟悉SQL的开发者，无须特别学习即可立刻上手使用。**

**更多WINQ的具体实现，请参考：[WINQ原理](https://github.com/Tencent/wcdb/wiki/WINQ原理)。**

## 加密

WCDB提供基于sqlcipher的数据库加密功能，如下：

```
WCTDatabase *database = [[WCTDatabase alloc] initWithPath:path];
NSData *password = [@"MyPassword" dataUsingEncoding:NSASCIIStringEncoding];
[database setCipherKey:password];
```

## 全局监控

WCDB提供了对错误和性能的全局监控，可用于调试错误和性能。

```
//Error Monitor
[WCTStatistics SetGlobalErrorReport:^(WCTError *error) {
	NSLog(@"[WCDB]%@", error);
}];
//Performance Monitor
[WCTStatistics SetGlobalPerformanceTrace:^(WCTTag tag, NSDictionary<NSString *, NSNumber *> *sqls, NSInteger cost) {
	NSLog(@"Database with tag:%d", tag);
	NSLog(@"Run :");
	[sqls enumerateKeysAndObjectsUsingBlock:^(NSString *sqls, NSNumber *count, BOOL *) {
		NSLog(@"SQL %@ %@ times", sqls, count);
	}];
	NSLog(@"Total cost %lld nanoseconds", cost);
}];
//SQL Execution Monitor
[WCTStatistics SetGlobalSQLTrace:^(NSString *sql) {
	NSLog(@"SQL: %@", sql);
}];
```

**更多全局监控的细节，请参考：[全局监控与错误处理](https://github.com/Tencent/wcdb/wiki/全局监控与错误处理)**

## 损坏修复

WCDB内建了修复工具，以应对数据库损坏，无法使用的情况。

**开发者需要在数据库未损坏时，对数据库元信息定时进行备份**，如下：

```
NSData *backupPassword = [@"MyBackupPassword" dataUsingEncoding:NSASCIIStringEncoding];
[database backupWithCipher:backupPassword];
```

**当检测到数据库损坏，即`WCTError`的`type`为`WCTErrorTypeSQLite`，`code`为11或26（SQLITE_CORRUPT或SQLITE_NOTADB）时，可以进行修复。**

```
//Since recovering is a long time operation, you'd better call it in sub-thread.
[view startLoading];
dispatch_async(DISPATCH_QUEUE_PRIORITY_BACKGROUND, ^{
	WCTDatabase *recover = [[WCTDatabase alloc] initWithPath:recoverPath];
	NSData *password = [@"MyPassword" dataUsingEncoding:NSASCIIStringEncoding];
	NSData *backupPassword = [@"MyBackupPassword" dataUsingEncoding:NSASCIIStringEncoding];
  	int pageSize = 4096;//Default to 4096 on iOS and 1024 on macOS.
	[database close:^{
		[recover recoverFromPath:path 
         			withPageSize:pageSize 
         			backupCipher:cipher 
         		  databaseCipher:password];
	}];
	[view stopLoading];
});
```

**更多关于损坏修复的使用、原理以及修复工具2.0，请参考：TODO**

# 2ORM使用教程

本教程主要介绍WCDB-iOS/macOS中ORM的用法。

阅读本教程前，建议先阅读[iOS/macOS使用教程](https://github.com/Tencent/wcdb/wiki/iOS+macOS使用教程)。

## ORM宏

WCDB使用内置的宏来连接类、属性与表、字段。共有三类宏，分别对应数据库的字段、索引和约束。所有宏都定义在[WCTCodingMacro.h](https://github.com/Tencent/wcdb/blob/master/objc/WCDB/interface/orm/macro/WCTCodingMacro.h)中。

关于字段、索引、约束的具体描述及用法，请参考SQLite的相关文档：[Create Table](http://www.sqlite.org/lang_createtable.html)和[Create Index](http://www.sqlite.org/lang_createindex.html)。

### 字段宏

字段宏以`WCDB_SYNTHESIZE`开头，定义了类属性与字段之间的联系。支持自定义字段名和默认值。

- `WCDB_SYNTHESIZE(className, propertyName)`是最简单的用法，它直接使用`propertyName`作为数据库字段名。
- `WCDB_SYNTHESIZE_COLUMN(className, propertyName, columnName)`支持自定义字段名。
- `WCDB_SYNTHESIZE_DEFAULT(className, propertyName, defaultValue)`支持自定义字段的默认值。默认值可以是任意的C类型或`NSString`、`NSData`、`NSNumber`、`NSNull`。
- `WCDB_SYNTHESIZE_COLUMN_DEFAULT(className, propertyName, columnName, defaultValue)`为以上两者的组合。

关于字段宏的例子，请参考[WCTSampleORM](https://github.com/Tencent/wcdb/blob/master/objc/sample/orm/WCTSampleORM.mm)。

### 索引宏

索引宏以`WCDB_INDEX`开头，定义了数据库的索引属性。支持定义索引的排序方式。

- `WCDB_INDEX(className, indexSubfixName, propertyName)`是最简单的用法，它直接定义某个字段为索引。同时，WCDB会将`tableName`+`indexSubfixName`作为该索引的名称。
- `WCDB_INDEX_ASC(className, indexSubfixName, propertyName)`定义索引为升序。
- `WCDB_INDEX_DESC(className, indexSubfixName, propertyName)`定义索引为降序。
- `WCDB_UNIQUE_INDEX(className, indexSubfixName, propertyName)`定义唯一索引。
- `WCDB_UNIQUE_INDEX_ASC(className, indexSubfixName, propertyName)`定义唯一索引为升序。
- `WCDB_UNIQUE_INDEX_DESC(className, indexSubfixName, propertyName)`定义唯一索引为降序。

#### 多字段索引

WCDB通过`indexSubfixName`匹配多索引。相同的`indexSubfixName`会被组合为多字段索引。

```
WCDB_INDEX(WCTSampleORMIndex, "_multiIndexSubfix", multiIndexPart1)
WCDB_INDEX(WCTSampleORMIndex, "_multiIndexSubfix", multiIndexPart2)
```

关于索引宏的例子，请参考[WCTSampleORMIndex](https://github.com/Tencent/wcdb/blob/master/objc/sample/orm/WCTSampleORMIndex.mm)。

### 约束宏

约束宏包括字段约束和表约束。

#### 字段约束

- 主键约束以

  ```
  WCDB_PRIMARY
  ```

  开头，定义了数据库的主键，支持自定义主键的排序方式、是否自增。

  - `WCDB_PRIMARY(className, propertyName)`是最基本的用法，它直接使用`propertyName`作为数据库主键。
  - `WCDB_PRIMARY_ASC(className, propertyName)`定义主键升序。
  - `WCDB_PRIMARY_DESC(className, propertyName)`定义主键降序。
  - `WCDB_PRIMARY_AUTO_INCREMENT(className, propertyName)`定义主键自增。
  - `WCDB_PRIMARY_ASC_AUTO_INCREMENT(className, propertyName)`是主键自增和升序的组合。
  - `WCDB_PRIMARY_DESC_AUTO_INCREMENT(className, propertyName)`是主键自增和降序的组合。

- 非空约束为`WCDB_NOT_NULL(className, propertyName)`，当该字段插入数据为空时，数据库会返回错误。

- 唯一约束为`WCDB_UNIQUE(className, propertyName)`，当该字段插入数据与其他列冲突时，数据库会返回错误。

关于字段约束的例子，请参考[WCTSampleORMColumnConstraint](https://github.com/Tencent/wcdb/blob/master/objc/sample/orm/WCTSampleORMColumnConstraint.mm)

#### 表约束

- 多主键约束以

  ```
  WCDB_MULTI_PRIMARY
  ```

  开头，定义了数据库的多主键，支持自定义每个主键的排序方式。

  - `WCDB_MULTI_PRIMARY(className, constraintName, propertyName)`是最基本的用法，与索引类似，多个主键通过`constraintName`匹配。
  - `WCDB_MULTI_PRIMARY_ASC(className, constraintName, propertyName)`定义了多主键`propertyName`对应的主键升序。
  - `WCDB_MULTI_PRIMARY_DESC(className, constraintName, propertyName)`定义了多主键中`propertyName`对应的主键降序。

- 多字段唯一约束以

  ```
  WCDB_MULTI_UNIQUE
  ```

  开头，定义了数据库的多字段组合唯一，支持自定义每个字段的排序方式。

  - `WCDB_MULTI_UNIQUE(className, constraintName, propertyName)`是最基本的用法，与索引类似，多个字段通过`constraintName`匹配。
  - `WCDB_MULTI_UNIQUE_ASC(className, constraintName, propertyName)`定义了多字段中`propertyName`对应的字段升序。
  - `WCDB_MULTI_UNIQUE_DESC(className, constraintName, propertyName)`定义了多字段中`propertyName`对应的字段降序。

关于表约束的例子，请参考[WCTSampleORMTableConstraint](https://github.com/Tencent/wcdb/blob/master/objc/sample/orm/WCTSampleORMTableConstraint.mm)

## 类型



SQLite数据库的字段有整型、浮点数、字符串、二进制数据等五种类型。WCDB的ORM会自动识别property的类型，并映射到适合的数据库类型。其对应关系为：

| C类型                                                        | 数据库类型      |
| ------------------------------------------------------------ | --------------- |
| 整型（包括但不限于`int`、`unsigned`、`long`、`unsigned long`、`long long`、`unsigned long long`等所有基于整型的C基本类型） | 整型（INTEGER） |
| 枚举型（`enum`及所有基于枚举型的C基本类型）                  | 整型（INTEGER） |
| 浮点数（包括但不限于`float`、`double`、`long double`等所有基于浮点型的C基本类型） | 浮点型（ REAL） |
| 字符串（`const char *`的C字符串类型）                        | 字符串（ TEXT） |

| Objective-C类型                            | 数据库类型      |
| ------------------------------------------ | --------------- |
| `NSDate`                                   | 整型（INTEGER） |
| `NSNumber`                                 | 浮点型（ REAL） |
| `NSString`、`NSMutableString`              | 字符串（ TEXT） |
| 其他所有符合`NSCoding`协议的`NSObject`子类 | 二进制（BLOB）  |

#### 自定义类型

内置支持的类型再多，也不可能完全覆盖开发者所有的需求。因此WCDB支持开发者自定义绑定类型。

类只需实现`WCTColumnCoding`协议，即可支持绑定。

```
@protocol WCTColumnCoding
@required
+ (instancetype)unarchiveWithWCTValue:(WCTValue *)value; //value could be nil
- (id /* WCTValue* */)archivedWCTValue;                  //value could be nil
+ (WCTColumnType)columnTypeForWCDB;
@end
```

- `columnTypeForWCDB`接口定义类对应数据库中的类型。
- `unarchiveWithWCTValue:`接口定义从数据库类型反序列化到类的转换方式。
- `archivedWCTValue`接口定义从类序列化到数据库类型的转换方式。

#### WCTColumnCoding文件模版

为了简化定义，WCDB提供了Xcode文件模版来创建类字段绑定。

1. 首先需要安装文件模版。

   - 未获取 WCDB 的 Github 仓库的开发者，可以在命令执行 `curl https://raw.githubusercontent.com/Tencent/wcdb/master/tools/templates/install.sh -s | sh`
   - 已获取 WCDB 的 Github 仓库的开发者，可以手动运行 `cd path-to-your-wcdb-dir/tools/templates; sh install.sh;` 手动安装 [文件模版](https://github.com/Tencent/wcdb/blob/master/objc/xctemplate/Makefile)。

2. 安装完成后重启Xcode，选择新建文件，滚到窗口底部，即可看到对应的文件模版。

   ![img](https://github.com/Tencent/wcdb/wiki/assets/ORM/file-template.png)

3. 选择`WCTColumnCoding` ![img](https://github.com/Tencent/wcdb/wiki/assets/ORM/file-template-column-coding.png)

   - `Class`：需要进行字段绑定的类。

   - `Language`：WCDB支持绑定ObjC类和C++类，这里选择Objective-C

   - ```
     Type In DataBase
     ```

     ：类对应数据库中的类型。包括

     - `WCTColumnTypeInteger32`
     - `WCTColumnTypeInteger64`
     - `WCTColumnTypeDouble`
     - `WCTColumnTypeString`
     - `WCTColumnTypeBinary`

4. 以`NSDate`为例，NSDate可以转换为64位整型的时间戳，因此选择了Integer64。完成后点击下一步，Xcode就会自动创建如下模版。

   ```
   #import <Foundation/Foundation.h>
   #import <WCDB/WCDB.h>
   
   @interface NSDate (WCDB) <WCTColumnCoding>
   @end
   
   @implementation NSDate (WCDB)
   
   + (instancetype)unarchiveWithWCTValue:(NSNumber *)value
   {
       return <#Unarchive NSDate From NSNumber *#>;
   }
   
   - (NSNumber *)archivedWCTValue
   {
       return <#Archive NSNumber * To NSDate #>;
   }
   
   + (WCTColumnType)columnTypeForWCDB
   {
       return WCTColumnTypeInteger64;
   }
   
   @end
   ```

5. 接下来只需将`NSDate`和`NSNumber`之间的转换方式填上去即可

   ```
   #import <Foundation/Foundation.h>
   #import <WCDB/WCDB.h>
   
   @interface NSDate (WCDB) <WCTColumnCoding>
   @end
   
   @implementation NSDate (WCDB)
   
   + (instancetype)unarchiveWithWCTValue:(NSNumber *)value
   {
       return value ? [NSDate dateWithTimeIntervalSince1970:value.longLongValue] : nil;
   }
   
   - (NSNumber *)archivedWCTValue
   {
       return [NSNumber numberWithLongLong:self.timeIntervalSince1970];
   }
   
   + (WCTColumnType)columnTypeForWCDB
   {
       return WCTColumnTypeInteger64;
   }
   
   @end
   ```

#### 取消内置类型

上面提到WCDB内置对`NSData`、`NSArray`等等常用的Objective-C类型的支持，并且基于`NSCoding`协议进行序列化和反序列化。这些内置绑定的实现都在 [builtin](https://github.com/Tencent/wcdb/tree/master/objc/WCDB/interface/builtin) 目录下，这些实现也可以作为例子参考。

若开发者希望自定义基本类型的绑定，可以将内置的绑定关闭。关闭方法为：删除工程文件的`Build Settings`->`Preprocessor Macros`下各个scheme的`WCDB_BUILTIN_COLUMN_CODING`宏。

关于自定义类型的例子，请参考[sample_advance](https://github.com/Tencent/wcdb/blob/master/objc/sample/advance/sample_advance_main.mm)。

### 修改字段

SQLite支持增加字段，但不支持删除、重命名字段。因此WCDB在修改字段方面的能力也有限。

#### 增加字段

对于需要增加的字段，只需在定义处添加，并再次执行`createTableAndIndexesOfName:withClass:`即可。

```
WCDB_IMPLEMENTATION(WCTSampleAddColumn)
WCDB_SYNTHESIZE(WCTSampleAddColumn, identifier)
WCDB_SYNTHESIZE(WCTSampleAddColumn, newColumn)// Add a new column
```

#### 删除字段

对于需要删除字段，只需将其定义删除即可。

```
WCDB_IMPLEMENTATION(WCTSampleAddColumn)
WCDB_SYNTHESIZE(WCTSampleAddColumn, identifier)
//WCDB_SYNTHESIZE(WCTSampleAddColumn, deletedColumn)// delete a column
```

由于SQLite不支持删除字段，因此，删除定义后，WCDB只是将该字段忽略，其旧数据依然存在在数据库内，但新增加的数据基本不会因为该字段产生额外的性能和空间损耗。

#### 修改字段

由于SQLite不支持修改字段名称，因此WCDB使用`WCDB_SYNTHESIZE_COLUMN(className, propertyName, columnName)`重新映射宏。

对于已经定义的字段`WCDB_SYNTHESIZE(MyClass, myValue)`可以修改为`WCDB_SYNTHESIZE_COLUMN(MyClass, newMyValue, "myValue")`。

对于已经定义的字段类型，可以任意修改为其他类型。但旧数据会使用新类型的解析方式进行反序列化，因此需要确保其兼容性。

### 更多扩展性

由于ORM不可能覆盖所有用法，因此WCDB提供了 core 接口，开发者可以根据自己的需求执行SQL。请参考 [核心层接口](https://github.com/Tencent/wcdb/wiki/基础类、CRUD与Transaction#核心层接口)

如果这些接口仍不满足你的需求，欢迎给我们[提 Issue ](https://github.com/Tencent/wcdb/issues)。

#### 隔离Cpp代码

WCDB基于WINQ，引入了Objective-C++代码，因此对于所有引入WCDB的源文件，都需要将其后缀`.m`改为`.mm`。为减少影响范围，可以通过Objective-C的category特性将其隔离，达到**只在model层使用Objective-C++编译，而不影响controller和view**。

对于已有类`WCTSampleAdvance`，

```
//WCTSampleAdvance.h
#import <Foundation/Foundation.h>
#import "WCTSampleColumnCoding.h"

@interface WCTSampleAdvance : NSObject

@property(nonatomic, assign) int intValue;
@property(nonatomic, retain) WCTSampleColumnCoding *columnCoding;

@end
  
//WCTSampleAdvance.mm
@implementation WCTSampleAdvance
  
@end
```

可以创建`WCTSampleAdvance (WCTTableCoding)`专门用于定义ORM。

为简化定义代码，WCDB同样提供了文件模版

#### WCTTableCoding文件模版

为了简化定义，WCDB同样提供了Xcode文件模版来创建`WCTTableCoding`的category。

1. 首先需要安装文件模版。

   - 未获取 WCDB 的 Github 仓库的开发者，可以在命令执行 `curl https://raw.githubusercontent.com/Tencent/wcdb/master/tools/templates/install.sh -s | sh`
   - 已获取 WCDB 的 Github 仓库的开发者，可以手动运行 `cd path-to-your-wcdb-dir/tools/templates; sh install.sh;` 手动安装 [文件模版](https://github.com/Tencent/wcdb/blob/master/objc/xctemplate/Makefile)。

2. 安装完成后重启Xcode，选择新建文件，滚到窗口底部，即可看到对应的文件模版。

   ![img](https://github.com/Tencent/wcdb/wiki/assets/ORM/file-template.png)

3. 选择`WCTTableCoding` ![img](https://github.com/Tencent/wcdb/wiki/assets/ORM/file-template-table-coding.png) 输入需要实现`WCTTableCoding`的类

4. 这里以`WCTSampleAdvance`为例，Xcode会自动创建`WCTSampleAdvance+WCTTableCoding.h`文件模版：

   ```
   #import "WCTSampleAdvance.h"
   #import <WCDB/WCDB.h>
   
   @interface WCTSampleAdvance (WCTTableCoding) <WCTTableCoding>
   
   WCDB_PROPERTY(<#property1 #>)
   WCDB_PROPERTY(<#property2 #>)
   WCDB_PROPERTY(<#property3 #>)
   WCDB_PROPERTY(<#property4 #>)
   WCDB_PROPERTY(<#... #>)
   
   @end
   ```

5. 加上类的ORM实现即可。

   ```
   //WCTSampleAdvance.h
   #import <Foundation/Foundation.h>
   #import "WCTSampleColumnCoding.h"
   
   @interface WCTSampleAdvance : NSObject
   
   @property(nonatomic, assign) int intValue;
   @property(nonatomic, retain) WCTSampleColumnCoding *columnCoding;
   
   @end
     
   //WCTSampleAdvance.mm
   @implementation WCTSampleAdvance
     
   WCDB_IMPLEMENTATION(WCTSampleAdvance)
   WCDB_SYNTHESIZE(WCTSampleAdvance, intValue)
   WCDB_SYNTHESIZE(WCTSampleAdvance, columnCoding)
   
   WCDB_PRIMARY_ASC_AUTO_INCREMENT(WCTSampleAdvance, intValue)
   
   @end
     
   //WCTSampleAdvance+WCTTableCoding.h
   #import "WCTSampleAdvance.h"
   #import <WCDB/WCDB.h>
   
   @interface WCTSampleAdvance (WCTTableCoding) <WCTTableCoding>
   
   WCDB_PROPERTY(intValue)
   WCDB_PROPERTY(columnCoding)
   
   @end
   ```

此时，原来的`WCTSampleAdvance.h`中不包含任何C++的代码。因此，其他文件对其引用时，不需要修改文件名后缀。只有Model层需要使用WCDB接口的类，才需要包含`WCTSampleAdvance+WCTTableCoding.h`，并修改文件名后缀为`.mm`。

示例代码请参考：[WCTSampleAdvance](https://github.com/Tencent/wcdb/blob/master/objc/sample/advance/WCTSampleAdvance.h)和[WCTSampleNoObjectiveCpp](https://github.com/Tencent/wcdb/blob/master/objc/sample/advance/WCTSampleNoObjectiveCpp.h)

#### 其他注意事项

1. 由于`WCDB_SYNTHESIZE(className, propertyName)`宏默认使用`propertyName`作为字段名，因此在修改`propertyName`后，会导致错误，需用`WCDB_SYNTHESIZE_COLUMN(className, newPropertyName, "oldPropertyName")`重新映射。
2. **每个进行ORM的property，都必须实现getter/setter**。因为ORM会在初始化时通过objc-runtime获取property的getter/setter的`IMP` ，以此实现通过object存取数据库的特性。getter/setter不必须是公开的，也可以是私有接口。



# 3-WINQ原理



sanhuazhang edited this page on 14 Jun 2017 · [1 revision](https://github.com/Tencent/wcdb/wiki/WINQ原理/_history)

## 背景

高效、完整、易用是WCDB的基本原则。本篇将更深入地聊聊WCDB在易用性上的思考和实践。

对于各类客户端数据库，似乎都绕不开拼接字符串这一步。即便在Realm这样的NoSQL的数据库中，在进行查询时，也依赖于字符串的语法：

```
//Realm code
[Dog objectsWhere:@"age < 2"]
```

别看小小的字符串拼接，带来的麻烦可不小：

- 代码冗余。为了拼接出匹配的SQL语句，业务层往往要写许多胶水代码来format字符串。这些代码冗长且没有什么“营养”。
- 难以查错。对于编译器而言，SQL只是一个字符串。这就意味着即便你只写错了一个字母，也得在代码run起来之后，通过log或断点才能发现错误。倘若SQL所在的代码文件依赖较多，即使改正一个敲错的字母，就得将整个工程重新编译一遍，简直是浪费生命。
- SQL注入。举一个简单的例子：

```
- (BOOL)insertMessage:(NSString*)message
{
    NSString* sql = [NSString stringWithFormat:@"INSERT INTO message VALUES('%@')", message];
    return [db executeUpdate:sql];
}
```

这是插入消息的SQL。倘若对方发来这样的消息：`');DELETE FROM message;--`，那么这个插入的SQL就会被分成三段进行解析：

```
INSERT INTO message VALUES('');
DELETE FROM message;
--')
```

它会在插入一句空消息后，将message表内的所有消息删除。若App内存在这样的漏洞被坏人所用，后果不堪设想。

反注入的通常做法是，

- 利用SQLite的绑定参数。通过绑定参数避免字符串拼接。

```
- (BOOL)insertMessage:(NSString*)message
{
    return [db executeUpdate:@"INSERT INTO message VALUES(?)", message];
}
```

- 对于不适用绑定参数的SQL，则可以将单引号替换成双单引号，避免传入的单引号提前截断SQL。

```
- (BOOL)insertMessage:(NSString*)message
{
    NSString* sql = [NSString stringWithFormat:@"INSERT INTO message VALUES('%@')", [message stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
    return [db executeUpdate:sql];
}
```

尽管反注入并不难，但要求业务开发都了解、并且在开发过程中时时刻刻都警惕着SQL注入，是不现实的。

一旦错过了在框架层统一解决这些问题的机会，后面再通过代码规范、Code Review等等人为的方式去管理，就难免会发生疏漏。

因此，WCDB的原则是，问题应当更早发现更早解决。

- 能在编译期发现的问题，就不要拖到运行时；
- 能在框架层解决的问题，就不要再让业务去分担。

基于这个原则，我开始进行对SQLite的接口的抽象。

### SQL的组合能力

思考的过程注定不会是一片坦途，我遇到的第一个挑战就是：

### 问题一：SQL应该怎么抽象？

SQL是千变万化的，它可以是一个很简单的查询，例如：

```
SELECT * FROM message;
```

这个查询只是取出message表中的所有元素。假设我们可以封装成接口：

```
StatementSelect getAllFromTable(const char* tableName);
```

但SQL也可以是一个很复杂的查询，例如：

```
SELECT max(localID), count(content) FROM message
WHERE content IS NOT NULL 
    AND createTime!=modifiedTime 
    OR type NOT BETWEEN 0 AND 2
GROUP BY type
HAVING localID>0
ORDER BY createTime ASC
LIMIT (SELECT count(*) FROM contact, contact_ext
	   WHERE contact.username==contact_ext.username)
```

这个查询包含了条件、分组、分组过滤、排序、限制、聚合函数、子查询，多表查询。什么样的接口才能兼容这样的SQL？

遇到这种两极分化的问题，我的思路通常是二八原则。即

- 封装常用操作，覆盖80%的使用场景。
- 暴露底层接口，适配剩余20%的特殊情况。

但更多的问题出现：

### 问题二：怎么定义常用操作？

- 对于微信常用的操作，是否也适用于所有开发者？
- 现在不使用的操作，以后是否会变成常用？

### 问题三：常用操作与常用操作的组合，是否仍属于常用操作？

查询某个字段的最大值或最小值，应该属于常用操作的：

```
SELECT max(localID) FROM message;
SELECT min(localID) FROM message;
```

假设可以封装为

```
StatementSelect getMaxOfColumnFromTable(const char* columnName, const char* tableName);
StatementSelect getMinOfColumnFromTable(const char* columnName, const char* tableName);
```

但，SQL是存在组合的能力的。同时查询最大值和最小值，是否仍属于常用操作？

```
SELECT max(localID), min(localID) FROM message;
```

若以此规则，继续封装为：

```
StatementSelect getMaxAndMinOfColumnFromTable(const char* columnName, const char* tableName);
```

那同时查询最大值、最小值和总数怎么办？

```
SELECT max(localID), min(localID), count(localID) FROM message;
```

显然，“常用接口”的定义在不断地扩大，接口的复杂性也在增加。以后维护起来，就会疲于加新接口，并且没有边界。

### 问题四：特殊场景所暴露的底层接口，应该以什么形式存在？

若底层接口还是接受字符串参数的传入，那么前面所思考的一切都是徒劳。

因此，这里就需要一个理论的基础，去支持WCDB封装是合理的，而不仅仅是堆砌接口。

于是，我就去找了SQL千变万化组合的根源 --- SQL语法规则。

### SQL语法规则

SQLite官网提供了SQL的语法规则：http://www.sqlite.org/lang.html

例如，这是一个`SELECT`语句的语法规则：

![img](https://github.com/Tencent/wcdb/wiki/assets/WINQ/select.jpg)

SQLite按照图示箭头流向的语法规则解析传入的SQL字符串。每个箭头都有不同的流向可选。

例如，`SELECT`后，可以直接接`result-column`，也可以插入`DISTINCT`或者`ALL`。

语法规则中的每个字段都有其对应涵义，其中

- `SELECT`、`DISTINCT`、`ALL`等等大写字母是`keyword`，属于SQL的保留字。
- `result-column、``table-or-subquery`、`expr`等等小写字母是token。token可以再进一步地展开其构成的语法规则。

例如，在`WHERE`、`GROUP BY`、`HAVING`、`LIMIT`、`OFFSET`后所跟的参数都是`expr`，它的展开如下：

![img](https://github.com/Tencent/wcdb/wiki/assets/WINQ/expr.jpg)

可以看到，`expr`有很多种构成方式，例如：

`expr`: `literal-value`。`literal-value`可以进一步展开，它是纯粹的数值。

- 如数字1、数字30、字符串"Hello"等都是`literal-value`，因此它们也是`expr`

`expr`: `expr (binary operator) expr`。两个`expr`通过二元操作符进行连接，其结果依然属于`expr`。

- 如1+"Hello"。1和"Hello"都是`literal-value`，因此它们都是`expr`，通过二元操作符"+"号连接，其结果仍然是一个`expr`。尽管1+"Hello"看上去没有实质的意义，但它仍是SQL正确的语法。

以刚才那个复杂的SQL中的查询语句为例：

```
content IS NOT NULL 
AND createTime!=modifiedTime 
OR type NOT BETWEEN 0 AND 2
```

1. `content IS NOT NULL`，符合 `expr IS NOT NULL`的语法，因此其可以归并为`expr`
2. `createTime!=modifiedTime`，符合 `expr (binary operator) expr`的语法，因此其可以归并为`expr`
3. `type NOT BETWEEN 0 AND 2`，符合 `expr NOT BETWEEN expr AND expr`的语法，因此其可以归并为`expr`
4. `1. AND 2.`，符合`expr (binary operator) expr`的语法，因此其可以归并为`expr`
5. `4. OR 3.`，符合`expr (binary operator) expr`的语法，因此其可以归并为`expr`

最终，这么长的条件语句归并为了一个`expr`，符合`SELECT`语法规则中`WHERE expr`的语法，因此是正确的SQL条件语句。

也正是基于此，可以得出：只要按照SQL的语法封装，就可以保留其组合的能力，就不会错过任何接口，落入疲于加接口的陷阱。

### WCDB的具体做法是：

1. 将固定的keyword，封装为函数名，作为连接。
2. 将可以展开的token，封装为类，并在类内实现其不同的组合。

以SELECT语句为例：

```
class StatementSelect : public Statement {
public:
    //...
    StatementSelect &where(const Expr &where);
    StatementSelect &limit(const Expr &limit);
    StatementSelect &having(const Expr &having);
    //...
};
```

在语法规则中，`WHERE`、`LIMIT`等都接受`expr`作为参数。因此，不管SQL多么复杂，`StatementSelect`也只接受`Expr`的参数。而其组合的能力，则在`Expr`类内实现。

```
class Expr : public Describable {
public:
    Expr(const Column &column);
    template <typename T>
    Expr(const T &value,
         typename std::enable_if<std::is_arithmetic<T>::value ||
                                 std::is_enum<T>::value>::type * = nullptr)
        : Describable(literalValue(value))
    {
    }
    Expr(const std::string &value);

    Expr operator||(const Expr &operand) const;
    Expr operator&&(const Expr &operand) const;
    Expr operator!=(const Expr &operand) const;

    Expr between(const Expr &left, const Expr &right) const;
    Expr notBetween(const Expr &left, const Expr &right) const;

    Expr isNull() const;
    Expr isNotNull() const;
    
    //...
};
```

`Expr`通过构造函数和C++的偏特化模版，实现了从字符串和数字等进行初始化的效果。同时，通过C++运算符重载的特性，可以将SQL的运算符无损地移植到过来，使得语法上也可以更接近于SQL。

在对应函数里，再进行SQL的字符串拼接即可。同时，所有传入的字符串都会在这一层预处理，以防注入。如：

```
Expr::Expr(const std::string &value) : Describable(literalValue(value))
{
}

std::string Expr::literalValue(const std::string &value)
{
  //SQL anti-injection
    return "'" + stringByReplacingOccurrencesOfString(value, "'", "''") + "'";
}

Expr Expr::operator&&(const Expr &operand) const
{
    Expr expr;
    expr.m_description.append("(" + m_description + " AND " +
                              operand.m_description + ")");
    return expr;
}
```

基于这个抽象方式，就可以对复杂查询中的条件语句进行重写为：

```
Column content("content");
Column createTime("createTime");
Column modifiedTime("modifiedTime");
Column type("type");
StatementSelect select;
//...
//WHERE content IS NOT NULL 
//      AND createTime!=modifiedTime 
//      OR type NOT BETWEEN 0 AND 2
select.where(Expr(content).isNotNull()
            &&Expr(createTime)!=Expr(modifiedTime)
            ||Expr(type).notBetween(0, 2));
//...
```

首先通过`Column`创建对应数据库字段的映射，再转换为`Expr`，调用对应封装的函数或运算符，即可完成字符串拼接操作。

这个抽象便是WCDB的语言集成查询的特性 --- WINQ（**W**CDB **In**tegrated **Q**uery）。

更进一步，由于WCDB在接口层的ORM封装，使得开发者可以直接通过`className.propertyName`的方式，拿到字段的映射。因此连上述的转换操作也可以省去，查询代码可以在一行代码内完成。

以下是WCDB在接口层和WINQ的支持下，对前面所提到的SQL语句的代码示例：

```
//SELECT * FROM message;
[db getAllObjectsOfClass:Message.class
               fromTable:@"message"];

/*
 SELECT max(localID), count(content) 
 FROM message
 WHERE content IS NOT NULL 
       AND createTime!=modifiedTime 
       OR type NOT BETWEEN 0 AND 2
 GROUP BY type
 HAVING localID>0
 ORDER BY createTime ASC
 LIMIT (SELECT count(*) 
        FROM contact, contact_ext
        WHERE contact.username==contact_ext.username)
 */
[[[[[[db prepareSelectRowsOnResults:{Message.localID.max(), Message.content.count()}
                          fromTable:@"message"]
                              where:Message.content.isNotNull() 
                                    && Message.createTime != Message.modifiedTime 
                                    || Message.type.notBetween(0, 2)]
                            groupBy:{Message.type}]
                             having:Message.localID > 0]
                            orderBy:Message.createTime.order(WCTOrderedAscending)]
                              limit:[[[WCTSelectBase alloc] initWithResultList:Contact.AnyProperty.count()
                                                                    fromTables:@[ @"contact", @"contact_ext" ]]
                                                                         where:Contact.username.inTable(@"contact") == ContactExt.username.inTable(@"contact_ext")]];

/*
 SELECT max(localID) FROM message;
 */
[db getOneValueOnResult:Message.localID.max()
              fromTable:@"message"];
/*
 SELECT min(localID) FROM message;
 */
[db getOneValueOnResult:Message.localID.min()
              fromTable:@"message"];
/*
 SELECT max(localID), min(localID) FROM message;
 */
[db getOneRowOnResults:{Message.localID.max(), Message.localID.min()}
             fromTable:@"message"];
/*
 SELECT max(localID), min(localID), count(localID) FROM message
 */
[db getOneRowOnResults:{Message.localID.max(), Message.localID.min(), Message.localID.count()}
             fromTable:@"message"];
```

### 总结

WCDB通过WINQ抽象SQLite语法规则，使得开发者可以告别字符串拼接的胶水代码。通过和接口层的ORM结合，使得即便是很复杂的查询，也可以通过一行代码完成。并借助IDE的代码提示和编译检查的特性，大大提升了开发效率。同时还内建了反注入的保护。

![img](https://github.com/Tencent/wcdb/wiki/assets/WINQ/hint.jpg)

代码提示

![img](https://github.com/Tencent/wcdb/wiki/assets/WINQ/error.jpg)

编译时检查

虽然WINQ在实现上使用了C++11特性和模版等，但在使用过程并不需要涉及。对于熟悉SQL的开发，只需按照本能即可写出SQL对应的WINQ语句。最终达到提高WCDB易用性的目的。

# 4-基础类、CRUD与Transaction

## 基础类

WCDB提供了三个基础类进行数据库操作：`WCTDatabase`、`WCTTable`、`WCTTransaction`。它们的接口都是线程安全的。

## WCTDatabase

`WCTDatabase`表示一个数据库，可以进行所有数据库操作，包括增删查改、表操作、事务、文件操作、损坏修复等。

### 创建

`WCTDatabase`通过`initWithPath:`接口进行创建。该接口会同时创建`path`中不存在的目录。

```
NSString* path = @"~/Intermediate/Directories/Will/Be/Created/sample.db";
WCTDatabase *database = [[WCTDatabase alloc] initWithPath:path];
database.tag = 1;
```

### 打开

WCDB大量使用延迟初始化（Lazy initialization）的方式管理对象，因此SQLite连接会在第一次被访问时被打开。开发者不需要手动打开数据库。

通过`canOpen`接口可测试数据库是否能够打开。通过`isOpened`接口可测试数据库是否已经打开。

```
if ([database canOpen]) {
  //...
}
if ([database isOpened]) {
  //...
}
```

### 关闭

WCDB通过`close`接口直接关闭数据库

```
[database close];
```

由于WCDB支持多线程访问数据库，因此，该接口会阻塞等待所有数据库操作结束，以确保数据库完全关闭。

对于一个特定路径的数据库，WCDB会在所有对象对其的引用结束时，自动关闭数据库，并且回收内存和SQLite连接。因此，大部分情况下开发者不需要手动关闭数据库。

### 加密

WCDB提供基于sqlcipher的数据库加密功能，如下：

```
WCTDatabase *database = [[WCTDatabase alloc] initWithPath:path];
NSData *password = [@"MyPassword" dataUsingEncoding:NSASCIIStringEncoding];
[database setCipherKey:password];
```

### 文件操作

WCDB提供了删除数据库、移动数据库、获取数据库占用空间和使用路径的文件操作接口。

```
- (BOOL)removeFilesWithError:(WCTError **)error;
- (BOOL)moveFilesToDirectory:(NSString *)directory withExtraFiles:(NSArray<NSString *> *)extraFiles andError:(WCTError **)error;
- (NSArray<NSString *> *)getPaths;
- (NSUInteger)getFilesSizeWithError:(WCTError **)error;
```

文件操作不是一个原子操作。若一个线程正在操作数据库，而另一个线程进行移动数据库文件，可能导致数据库损坏。因此，文件操作的最佳实践是确保数据库已关闭。

```
[database close:^{
  WCTError *error = nil;
  BOOL ret = [database moveFilesToDirectory:otherDirectory withError:&error];
  if (!ret) {
      NSLog(@"Move files Error %@", error);
  }
}];
```

关于文件操作的例子，可以参考[Sample-file](https://github.com/Tencent/wcdb/blob/master/objc/sample/file/sample_file_main.mm)。

### 事务

`WCTDatabase`不支持跨线程事务。事务内的操作必须在同一个线程运行完。可以通过两种方式运行事务：

1. `beginTransaction `、`commitTransaction`、`rollbackTransaction`

   ```
   //[beginTransaction], [commitTransaction], [rollbackTransaction] and all interfaces inside this transaction should run in same thread
   BOOL ret = [database beginTransaction];
   WCTSampleTransaction *object = [[WCTSampleTransaction alloc] init];
   ret = [database insertObject:object
                           into:tableName];
   if (ret) {
       ret = [database commitTransaction];
   } else {
       ret = [database rollbackTransaction];
   }
   ```

2. `runTransaction:`

   ```
   BOOL commited = [database runTransaction:^BOOL {
     WCTSampleTransaction *object = [[WCTSampleTransaction alloc] init];
     BOOL ret = [database insertObject:object
                                  into:tableName];
     //return YES to do a commit and return NO to do a rollback
     if (ret) {
         return YES;
     }
     return NO;
   }
       event:^(WCTTransactionEvent event) {
         NSLog(@"Event %d", event);
       }];
   ```

跨线程事务可以参考[WCTTransaction](https://github.com/Tencent/wcdb/wiki/基础类、CRUD与Transaction#WCTTransaction)。

关于事务的例子，可以参考[Sample-transaction](https://github.com/Tencent/wcdb/blob/master/objc/sample/transaction/sample_transaction_main.mm)。

## WCTTable

`WCTTable`表示一个表。它等价于预设了`class`和`tableName`的`WCTDatabase`，仅可以进行数据的增删查改等。

```
WCTTable* table = [database getTableOfName:tableName
                                 withClass:WCTSampleTable.class];
```

## WCTTransaction

`WCTTransaction`表示一个事务。

```
WCTTransaction *transaction = [database getTransaction];
```

与`WCTDatabase`的事务不同，`WCTTransaction`可以在函数和对象之间传递，实现跨线程的事务。

```
//You can do a transaction in different threads using WCTTransaction.
//But it's better to run serially, or an inner thread mutex will guarantee this.
BOOL ret = [transaction begin];
dispatch_async(dispatch_queue_create("other thread", DISPATCH_QUEUE_SERIAL), ^{
  WCTSampleTransaction *object = [[WCTSampleTransaction alloc] init];
  BOOL ret = [transaction insertObject:object
                                  into:tableName];
  if (ret) {
      [transaction commit];
  } else {
      [transaction rollback];
  }
});
```

关于事务的例子，可以参考[Sample-transaction](https://github.com/Tencent/wcdb/blob/master/objc/sample/transaction/sample_transaction_main.mm)。

## 基础类共享

对于同一个路径的数据库，不同的`WCTDatabase`、`WCTTable`、`WCTTransaction`对象共享同一个WCDB核心。因此，你可以在代码的不同位置、不同线程任意创建不同的基础类对象，WCDB会自动管理它们的共享数据和线程并发。

```objective-c
WCTDatabase* database1 = [[WCTDatabase alloc] initWithPath:path];
WCTDatabase* database2 = [[WCTDatabase alloc] initWithPath:path];
database1.tag = 1;
NSLog(@"%d", database2.tag);//print 1
```

关于WCDB的架构和实现，可以参考：TODO

## CRUD

WCDB的增删改查分为表操作和数据操作两种。

### 表操作

表操作包括创建/删除 表/索引、判断表、索引是否存在等。`WCTDatabase`和`WCTransaction`都支持表操作的接口。

开发者可以根据ORM的定义创建表或索引：

```objective-c
BOOL ret = [database createTableAndIndexesOfName:tableName
                                       withClass:WCTSampleTable.class];
```

也可以通过WINQ自定义表或索引：

```objective-c
BOOL ret = [database createTableOfName:tableName
                     withColumnDefList:{
                     WCTSampleTable.intValue.def(WCTColumnTypeInteger32),
                     WCTSampleTable.stringValue.def(WCTColumnTypeString)
           }];
```

关于表操作的例子，可以参考[Sample-table](https://github.com/Tencent/wcdb/blob/master/objc/sample/table/sample_table_main.mm)

### 数据操作

数据操作分为便捷接口和链式接口两种。`WCTDatabase`、`WCTTable`、`WCTTransaction`均支持数据操作接口。

#### 便捷接口

便捷接口的设计原则为，通过一行代码即可完成数据的操作。

##### 插入

- `insertObject:into:`和`insertObjects:into:`，插入单个或多个对象
- `insertOrReplaceObject:into`和`insertOrReplaceObjects:into`，插入单个或多个对象。当对象的主键在数据库内已经存在时，更新数据；否则插入对象。
- `insertObject:onProperties:into:`和`insertObjects:onProperties:into:`，插入单个或多个对象的部分属性
- `insertOrReplaceObject:onProperties:into`和`insertOrReplaceObjects:onProperties:into`，插入单个或多个对象的部分属性。当对象的主键在数据库内已经存在时，更新数据；否则插入对象。

##### 删除

- `deleteAllObjectsFromTable:`删除表内的所有数据
- `deleteObjectsFromTable:`后可组合接 `where`、`orderBy`、`limit`、`offset`以删除部分数据

##### 更新

- `updateAllRowsInTable:onProperties:withObject:`，通过object更新数据库中所有指定列的数据
- `updateRowsInTable:onProperties:withObject:`后可组合接 `where`、`orderBy`、`limit`、`offset`以通过object更新指定列的部分数据
- `updateAllRowsInTable:onProperty:withObject:`，通过object更新数据库某一列的数据
- `updateRowsInTable:onProperty:withObject:`后可组合接 `where`、`orderBy`、`limit`、`offset`以通过object更新某一列的部分数据
- `updateAllRowsInTable:onProperties:withRow:`，通过数组更新数据库中的所有指定列的数据
- `updateRowsInTable:onProperties:withRow:`后可组合接 `where`、`orderBy`、`limit`、`offset`以通过数组更新指定列的部分数据
- `updateAllRowsInTable:onProperty:withRow:`，通过数组更新数据库某一列的数据
- `updateRowsInTable:onProperty:withRow:`后可组合接 `where`、`orderBy`、`limit`、`offset`以通过数组更新某一列的部分数

##### 查找

- `getOneObjectOfClass:fromTable:`后可接 `where`、`orderBy`、`limit`、`offset`以从数据库中取出一行数据并组合成object
- `getOneObjectOnResults:fromTable:`后可接 `where`、`orderBy`、`limit`、`offset`以从数据库中取出一行数据的部分列并组合成object
- `getOneRowOnResults:fromTable:`后可接 `where`、`orderBy`、`limit`、`offset`以从数据库中取出一行数据的部分列并组合成数组
- `getOneColumnOnResult:fromTable:`后可接 `where`、`orderBy`、`limit`、`offset`以从数据库中取出一列数据并组合成数组
- `getOneDistinctColumnOnResult:fromTable:`后可接 `where`、`orderBy`、`limit`、`offset`以从数据库中取出一列数据，并取distinct后组合成数组。
- `getOneValueOnResult:fromTable:`后可接 `where`、`orderBy`、`limit`、`offset`以从数据库中取出一行数据的某一列
- `getAllObjectsOfClass:fromTable:`，取出所有数据，并组合成object
- `getObjectsOfClass:fromTable:`后可接 `where`、`orderBy`、`limit`、`offset`以从数据库中取出一部分数据，并组合成object
- `getAllObjectsOnResults:fromTable:`，取出所有数据的指定列，并组合成object
- `getObjectsOnResults:fromTable:`后可接`where`、`orderBy`、`limit`、`offset`以从数据库中取出一部分数据的指定列，并组合成object
- `getAllRowsOnResults:fromTable:`，取出所有数据的指定列，并组合成数组
- `getRowsOnResults:fromTable:`后可接`where`、`orderBy`、`limit`、`offset`以从数据库中取出一部分数据的指定列，并组合成数组

具体例子可直接参考[Sample-convenience](https://github.com/Tencent/wcdb/blob/master/objc/sample/convenient/sample_convenient_main.mm)

#### 链式接口

链式调用是指对象的接口返回一个对象，从而允许在单个语句中将调用链接在一起，而不需要变量来存储中间结果。

WCDB对于增删改查操作，都提供了对应的类以实现链式调用

- `WCTInsert`
- `WCTDelete`
- `WCTUpdate`
- `WCTSelect`
- `WCTRowSelect`
- `WCTMultiSelect`

```objective-c
WCTSelect *select = [database prepareSelectObjectsOnResults:Message.localID.max()
                                                  fromTable:@"message"];
NSArray<Message *> *objects = [[[[select where:Message.localID > 0] 
                               			groupBy:{Message.content}]
                                	    orderBy:Message.createTime.order()] 
                               		      limit:10].allObjects;
```

`where`、`orderBy`、`limit`等接口的返回值均为`self`，因此可以通过链式调用，更自然更灵活的写出对应的查询。

开发者可以通过链式接口获取数据库操作的耗时、错误信息；也可以通过遍历逐个生成object。

```objective-c
//Error message
WCTError *error = select.error;
//Performance
int cost = select.cost;
//Iteration
Message *message;
while ((message = [select nextObject])) {
    //...
}
```

关于链式接口的例子，请参考[Sample-chaincall](https://github.com/Tencent/wcdb/blob/master/objc/sample/chaincall/sample_chaincall_main.mm)。

## 核心层接口

WCDB封装了常用的增删查改操作，但不可能覆盖所有SQL的用法。因此核心层提供了执行为封装的SQL的能力。

```
- (BOOL)exec:(const WCDB::Statement &)statement;
- (WCTStatement *)prepare:(const WCDB::Statement &)statement;
```

结合WINQ，开发者可以用核心层接口执行其他未封装的复杂SQL。

```objective-c
//run unwrapped SQL
//PRAGMA case_sensitive_like=1
[database exec:WCDB::StatementPragma().pragma(WCDB::Pragma::CaseSensitiveLike, true)];

//get value from unwrapped SQL
//PRAGMA case_sensitive
WCTStatement *statement = [database prepare:WCDB::StatementPragma().pragma(WCDB::Pragma::CacheSize)];
if (statement && statement.step) {
    NSLog(@"Cache size %@", [statement getValueAtIndex:0]);
}

//complex statement
//EXPLAIN CREATE TABLE message(localID INTEGER PRIMARY KEY ASC, content TEXT);
NSLog(@"Explain:");
WCDB::ColumnDef localIDColumnDef(WCDB::Column("localID"), WCDB::ColumnType::Integer32);
localIDColumnDef.makePrimary(WCDB::OrderTerm::ASC);
WCDB::ColumnDef contentColumnDef(WCDB::Column("content"), WCDB::ColumnType::Text);
WCDB::ColumnDefList columnDefList = {localIDColumnDef, contentColumnDef};
WCDB::StatementCreateTable statementCreate = WCDB::StatementCreateTable().create("message", columnDefList);
WCTStatement *statementExplain = [database prepare:WCDB::StatementExplain().explain(statementCreate)];
if (statementExplain && [statementExplain step]) {
    for (int i = 0; i < [statementExplain getCount]; ++i) {
        NSString *columnName = [statementExplain getNameAtIndex:i];
        WCTValue *value = [statementExplain getValueAtIndex:i];
        NSLog(@"%@:%@", columnName, value);
    }
}
```

### 调试SQL

`[WCTStatistics SetGlobalSQLTrace:]`会监控所有执行的SQL，该接口可用于调试，确定SQL是否执行正确。

```objective-c
//SQL Execution Monitor
[WCTStatistics SetGlobalSQLTrace:^(NSString *sql) {
	NSLog(@"SQL: %@", sql);
}];
```

关于核心层接口的例子，请参考[Sample-core](https://github.com/Tencent/wcdb/blob/master/objc/sample/core/sample_core_main.mm)。

## 高级用法

### 主键自增(Auto Increment)

对于主键自增的类，需要在ORM定义`WCDB_PRIMARY_AUTO_INCREMENT(className, propertyName)`，然后通过`isAutoIncrement`接口设置自增属性，并通过`lastInsertedRowID`接口获取插入的`RowID`。

```objective-c
WCTSampleConvenient *object = [[WCTSampleConvenient alloc] init];
object.isAutoIncrement = YES;
object.stringValue = @"Insert auto increment";
[database insertObject:object
                  into:tableName];
long long lastInsertedRowID = object.lastInsertedRowID;
```

### as重定向

基于ORM的支持，我们可以从数据库直接取出一个Object。然而，有时候需要取出并非是某个字段，而是有一些组合。例如：

```objective-c
NSNumber *maxModifiedTime = [database getOneValueOnResult:Message.modifiedTime.max()
                                                fromTable:@"message"];
Message *message = [[Message alloc] init];
message.createTime = [NSDate dateWithTimeIntervalSince1970:maxModifiedTime.doubleValue];
```

这段代码从数据库中取出了消息的最新的修改时间，并以此将此时间作为消息的创建时间，新建了一个message。这种情况下，就可以使用as重定向。

as重定向，它可以将一个查询结果重定向到某一个字段，如下：

```objective-c
Message *message = [database getOneObjectOnResults:Message.modifiedTime.max().as(Message.createTime)
                                         fromTable:@"message"];
```

通过`as(Message.createTime)`的语法，将查询结果重新指向了createTime。因此只需一行代码便可完成原来的任务。

### 多表查询

SQLite支持联表查询，在某些特定的场景下，可以起到优化性能、简化表结构的作用。

WCDB同样提供了对应的接口，并在ORM的支持下，通过WCTMultiSelect的链式接口，可以同时从表中取出多个类的对象。

```objective-c
/*
 SELECT contact.nickname, contact_ext.headImg
 FROM contact, contact_ext
 WHERE contact.name==contact_ext.name
 */
WCTMultiSelect *multiSelect = [[database prepareSelectMultiObjectsOnResults:{
    Contact.nickname.inTable(@"contact"),
	ContactExt.nickname.inTable(@"contact_ext")
} fromTables:@[ @"contact", @"contact_ext" ]] where:Contact.name.inTable(@"contact") == ContactExt.name.inTable(@"contact_ext")];

while ((multiObject = [multiSelect nextMultiObject])) {
    Contact *contact = (Contact *) [multiObject objectForKey:@"contact"];
    ContactExt *contact = (ContactExt *) [multiObject objectForKey:@"contact_ext"];
    //...
}
```

# 5-错误处理

WCDB可以对所有错误进行统一的监控，也可以获取某个特定操作的错误信息。所有错误都以`WCTError`的形式出现。

## WCTError

`WCTError`继承自`NSError`，包含了WCDB错误的所有信息，以供调试或发现问题。

`type`表示错误的类型，不同类型的错误其错误码和拥有的信息不同。其对应关系如下

| Type                                                         | Code                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| **SQLite**，表示该错误来自SQLite接口                         | 请参考[rescode](http://www.sqlite.org/rescode.html)          |
| **SystemCall**，表示该错误来自系统调用                       | 请参考[errno](http://man7.org/linux/man-pages/man3/errno.3.html) |
| **Core**，表示该错误来自WCDB Core层                          | 请参考源码的[error.hpp](https://github.com/Tencent/wcdb/blob/master/objc/WCDB/util/error.hpp) |
| **Interface**，表示该错误来自WCDB Interface层                | 请参考源码的[error.hpp](https://github.com/Tencent/wcdb/blob/master/objc/WCDB/util/error.hpp) |
| **Abort**，表示中断，该错误一般是开发错误，应该在发布前修复  | /                                                            |
| **Warning**，表示警告，建议修复                              | /                                                            |
| **SQLiteGlobal**，表示该信息来自SQLite的log接口，一般只作为debug log | 请参考[rescode](http://www.sqlite.org/rescode.html)          |

其他错误信息通过`infoForKey`接口获得，包括：

1. **Tag**，正在操作的数据库的tag
2. **Operation**，正在进行的操作，请参考[error.hpp](https://github.com/Tencent/wcdb/blob/master/objc/WCDB/util/error.hpp)
3. **Extended Code**，SQLite的扩展码，请参考[rescode](http://www.sqlite.org/rescode.html)
4. **Message**，错误信息
5. **SQL**，发生错误时正在执行的SQL
6. **Path**，发生错误时正在操作的文件的路径。

## 获取错误

由于便捷接口的设计原则是易用，因此不提供获取错误的方式。错误处理需使用链式接口

```
WCTSelect *select = [database prepareSelectObjectsOfClass:Message.class
                                                fromTable:@"message"];
NSArray<Message *> *objects = [[[select where:Message.localID > 0] 
                                	  orderBy:Message.createTime.order()] 
                               			limit:10].allObjects;
WCTError *error = select.error;
```

开发者也可以注册全局的错误接口，以调试、上报、打log

```
//Error Monitor
[WCTStatistics SetGlobalErrorReport:^(WCTError *error) {
	NSLog(@"[WCDB]%@", error);
}];
```

# 6-性能监控

WCDB支持获取单次操作的耗时，也支持对单个DB或全局注册统一接口监控性能。

**所有性能监控都会有少量的性能损坏，请根据需求开启。**

## 操作耗时

由于便捷接口的设计原则是易用，因此不提供获取错误的方式。操作耗时需使用链式接口。

首先安通过`setStatisticsEnabled:`打开耗时监控

```
WCTSelect *select = [database prepareSelectObjectsOfClass:Message.class
                                                fromTable:@"message"];
[select setStatisticsEnabled:YES];//You should call this before all other operations.
```

在操作执行完成后，通过`cost`接口获取耗时

```
NSArray<Message *> *objects = [[[select where:Message.localID > 0] 
                                	  orderBy:Message.createTime.order()] 
                               			limit:10].allObjects;
NSLog(@"%f", select.cost);//You should call this after all other operations.
```

## 监控耗时

WCDB支持对所有SQL操作进行全局监控，也支持监控单个特定的数据库。

所有监控的返回数据都相同，包括三个数据：

- **Tag**，执行操作的数据库的tag

- sqls

  ，执行的SQL和对应的次数。

  - 对于非事务操作，则为单条SQL
  - 对于事务操作，则为该次事务所执行的所有SQL和每个sql执行的次数

- **cost**，耗时

### 全局监控

监控所有db的数据库操作耗时，该接口需要在所有db打开、操作之前调用。

```
[WCTStatistics SetGlobalTrace:^(WCTTag tag, NSDictionary<NSString *, NSNumber *> *sqls, NSInteger cost) {
    NSLog(@"Tag: %d", tag);
    [sqls enumerateKeysAndObjectsUsingBlock:^(NSString *sql, NSNumber *count, BOOL *) {
      NSLog(@"SQL: %@ Count: %d", sql, count.intValue);
    }];
    NSLog(@"Total cost %ld nanoseconds", (long) cost);
}];
```

### 特定数据库监控

对于特定的数据库，该接口会覆盖全局监控的注册。

```
[db setTrace:^(WCTTag tag, NSDictionary<NSString *, NSNumber *> *sqls, NSInteger cost) {
    NSLog(@"Tag: %d", tag);
    [sqls enumerateKeysAndObjectsUsingBlock:^(NSString *sql, NSNumber *count, BOOL *) {
      NSLog(@"SQL: %@ Count: %d", sql, count.intValue);
    }];
    NSLog(@"Total cost %ld nanoseconds", (long) cost);
}];
```

## 操作耗时与监控耗时的不同

- 操作耗时的`cost`返回的耗时为浮点数的秒，监控耗时的`cost`返回的耗时为整型的纳秒。
- 监控耗时仅包括SQL在SQLite层面的耗时，包括SQL的编译、I/O等。而操作耗时除以上之外，还包括了WCDB层面对类封装等产生的耗时

# 7-SQL执行监控

WCDB可以监控所有SQL的执行，以确定代码符合预期

```
//SQL Execution Monitor
[WCTStatistics SetGlobalSQLTrace:^(NSString *sql) {
	NSLog(@"SQL: %@", sql);
}];
```

# 8-从FMDB迁移到WCDB

WCDB依托于微信上亿用户的实际场景，解决了许多在开发和线上遇到的共性问题，在性能、易用性、功能完整性以及兼容性上都有较好的表现。并且，**开发者可以平滑地从FMDB升级到WCDB。**

## 高效

WCDB在并发、ORM以及SQLite源码都做了许多针对性的优化，使得在写入、多线程并发、初始化等方面比FMDB有**30%-280%的性能提升**。

#### 读操作性能对比

![img](https://github.com/Tencent/wcdb/wiki/assets/benchmark/baseline_read.png)

#### 写操作性能对比

![img](https://github.com/Tencent/wcdb/wiki/assets/benchmark/baseline_write.png)

#### 批量写操作性能对比

![img](https://github.com/Tencent/wcdb/wiki/assets/benchmark/baseline_batch_write.png)

#### 多线程读写操作性能对比

![img](https://github.com/Tencent/wcdb/wiki/assets/benchmark/multithread_read_write.png)

#### 初始化性能对比

![img](https://github.com/Tencent/wcdb/wiki/assets/benchmark/initialization.png)

更多benchmark的数据和测试代码，请参考：[性能数据与Benchmark](https://github.com/Tencent/wcdb/wiki/性能数据与Benchmark)。

## 易用

WCDB通过WINQ和ORM，使得从拼接SQL、获取数据、拼装Object的整个过程，**只需要一行代码即可完成**。

```objective-c
/*
 FMDB Code
 */
FMResultSet *resultSet = [fmdb executeQuery:@"SELECT * FROM message"];
NSMutableArray<Message *> *messages = [[NSMutableArray alloc] init];
while ([resultSet next]) {
    Message *message = [[Message alloc] init];
    message.localID = [resultSet intForColumnIndex:0];
    message.content = [resultSet stringForColumnIndex:1];
    message.createTime = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumnIndex:2]];
    message.modifiedTime = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumnIndex:3]];
    [messages addObject:message];
}
/*
 WCDB Code
 */
NSArray<Message *> *messages = [wcdb getAllObjectsOfClass:Message.class fromTable:@"message"];
```

## 完整

WCDB基于微信的真实场景，对数据库的常见需求都提供了对应的解决方案，包括：

- 错误统计
- 性能统计
- 损坏修复
- 反注入
- 加密
- ...

# 9-对比与迁移



## 安装

首先在工程的配置`Build Phases`->`Link Binary With Libraries`中，将FMDB以及SQLite的库移出工程。

![img](https://github.com/Tencent/wcdb/wiki/assets/migration/remove_lib.png)

然后参考[安装教程](https://github.com/Tencent/wcdb/wiki/Home)选择适合方式链入WCDB的库。

## 创建数据库

`WCTDatabase`通过指定路径进行创建。同时，该接口会自动创建路径中未创建的目录。

```objective-c
NSString* path = @"intermediate/directory/will/be/created/automatically/wcdb";
WCTDatabase* wcdb = [[WCTDatabase alloc] initWithPath:path];
```

临时数据库可以创建在iOS/macOS的临时目录上

```objective-c
NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.db"];
WCTDatabase* wcdb = [[WCTDatabase alloc] initWithPath:path];
```

WCDB暂不支持创建内存数据库。由于移动平台的磁盘介质大多为SSD，其性能与纯内存操作差别不大。同时内存数据库会占用大量内存，从而导致FOOM。

## 打开数据库

WCDB会在第一次访问数据库时，自动打开数据库，不需要开发者主动操作。

`canOpen`接口可用于测试数据库能否正常打开，`isOpened`接口可用于测试数据库是否已打开。

```objective-c
if (![wcdb canOpen]) {
  NSLog(@"open failed");
}

if ([wcdb isOpened]) {
  NSLog(@"database is already opened");
}
```

## 建表与ORM

FMDB不支持ORM，而WCDB可以通过绑定类与表绑定起来，从而大幅度减少代码量。

对于在FMDB已经定义的类：

```objective-c
//Message.h
@interface Message : NSObject

@property int localID;
@property(retain) NSString *content;
@property(retain) NSDate *createTime;
@property(retain) NSDate *modifiedTime;

@end
```

和表：

```objective-c
FMDatabase* fmdb = [[FMDatabase alloc] initWithPath:path];
[fmdb executeUpdate:@"CREATE TABLE message(localID INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, createTime INTEGER, db_modifiedTime INTEGER)"];
[fmdb executeUpdate:@"CREATE INDEX message_index ON message(createTime)"];
```

可以将其建模为

```objective-c
//Message.h
@interface Message : NSObject <WCTTableCoding>

@property int localID;
@property(retain) NSString *content;
@property(retain) NSDate *createTime;
@property(retain) NSDate *modifiedTime;

WCDB_PROPERTY(localID)
WCDB_PROPERTY(content)
WCDB_PROPERTY(createTime)
WCDB_PROPERTY(modifiedTime)

@end

//Message.mm
@implementation Message

WCDB_IMPLEMENTATION(Message)
WCDB_SYNTHESIZE(Message, localID)
WCDB_SYNTHESIZE(Message, content)
WCDB_SYNTHESIZE(Message, createTime)
WCDB_SYNTHESIZE_COLUMN(Message, modifiedTime, "db_modifiedTime")

WCDB_PRIMARY_AUTO_INCREMENT(Message, localID)
WCDB_INDEX(Message, "_index", createTime)

@end
```

其中：

- `WCDB_IMPLEMENTATION(className)`用于定义进行绑定的类

- `WCDB_PROPERTY(propertyName)`和`WCDB_SYNTHESIZE(className, propertyName)`用于声明和定义字段。

- ```objective-c
  WCDB_SYNTHESIZE(className, propertyName)
  ```

  默认使用属性名作为数据库表的字段名。对于属性名与字段名不同的情况，可以使用

  ```objective-c
  WCDB_SYNTHESIZE_COLUMN(className, propertyName, columnName)
  ```

  进行映射。

  - **对于在FMDB已经创建的表，若属性名与字段名不同，则可以用`WCDB_SYNTHESIZE_COLUMN`宏进行映射，如例子中的db_modifiedTime字段**

- `WCDB_PRIMARY_AUTO_INCREMENT(className, propertyName)`用于定义主键且自增。

- `WCDB_INDEX(className, indexNameSubfix, propertyName)`用于定义索引。

定义完成后，调用`createTableAndIndexesOfName:withClass:`即可完成创建。

```objective-c
WCTDatabase* wcdb = [[WCTDatabase alloc] initWithPath:path];
[wcdb createTableAndIndexesOfName:@"message" withClass:Message.class]
```

**注：该接口使用的是`IF NOT EXISTS`的SQL，因此可以用重复调用。不需要在每次调用前判断表或索引是否已经存在。**

更多关于ORM的定义，请参考：[ORM使用方法](https://github.com/Tencent/wcdb/wiki/ORM使用教程)。

## 数据库升级

`createTableAndIndexesOfName:withClass:`会根据ORM的定义，创建表或索引。

当定义发生变化时，该接口也会对应的增加字段或索引。

因此，该接口可用于数据库表的升级。

```objective-c
//Message.h
@interface Message : NSObject <WCTTableCoding>

@property int localID;
@property(assign) const char *newContent;
//@property(retain) NSDate *createTime;
@property(retain) NSDate *modifiedTime;
@property(retain) NSDate *newProperty;

WCDB_PROPERTY(localID)
WCDB_PROPERTY(newContent)
//WCDB_PROPERTY(createTime)
WCDB_PROPERTY(modifiedTime)
WCDB_PROPERTY(newProperty)

@end

//Message.mm
@implementation Message

WCDB_IMPLEMENTATION(Message)
WCDB_SYNTHESIZE(Message, localID)
WCDB_SYNTHESIZE_COLUMN(Message, newContent, "content")
//WCDB_SYNTHESIZE(Message, createTime)
WCDB_SYNTHESIZE_COLUMN(Message, modifiedTime, "db_modifiedTime")
WCDB_SYNTHESIZE(Message, newProperty)

WCDB_PRIMARY_AUTO_INCREMENT(Message, localID)
WCDB_INDEX(Message, "_index", createTime)
WCDB_UNIQUE(Message, modifiedTime)
WCDB_INDEX(Message, "_newIndex", newProperty)

@end
WCTDatabase* db = [[WCTDatabase alloc] initWithPath:path];
[db createTableAndIndexesOfName:@"message" withClass:Message.class]
```

#### 删除字段

如例子中的`createTime`字段，删除字段只需直接将ORM中的定义删除即可。

**注：由于SQLite不支持删除字段，因此该操作只是将对应字段忽略。**

#### 增加字段

如例子中的`newProperty`字段，增加字段只需直接在ORM定义出添加，并再次调用`createTableAndIndexesOfName:withClass:`。

#### 修改字段

如例子中的`newContent`字段，字段类型可以直接修改，但需要确保新类型与旧类型兼容；字段名称则需要通过`WCDB_SYNTHESIZE_COLUMN(className, proeprtyName, columnName)`重新映射到旧字段。

**注：由于SQLite不支持修改字段名，因此该操作只是将新的属性映射到原来的字段名。**

#### 增加约束

如例子中的`WCDB_UNIQUE(Message, modifiedTime)`，新的约束只需直接在ORM中添加，并再次调用`createTableAndIndexesOfName:withClass:`。

#### 增加索引

如例子中的`WCDB_INDEX(Message, "_newIndex", newProperty)`，新的索引只需直接在ORM添加，并再次调用`createTableAndIndexesOfName:withClass:`。

## 访问数据库

得益于ORM的定义，开发者无需使用类似`intForColumnIndex:`的接口手动组装Object。以下是增删查改的代码示例。

#### 查询

```objective-c
/*
 FMDB Code
 */
FMResultSet *resultSet = [fmdb executeQuery:@"SELECT * FROM message"];
NSMutableArray<Message *> *messages = [[NSMutableArray alloc] init];
while ([resultSet next]) {
    Message *message = [[Message alloc] init];
    message.localID = [resultSet intForColumnIndex:0];
    message.content = [resultSet stringForColumnIndex:1];
    message.createTime = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumnIndex:2]];
    message.modifiedTime = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumnIndex:3]];
    [messages addObject:message];
}
/*
 WCDB Code
 */
NSArray<Message *> *messages = [wcdb getAllObjectsOfClass:Message.class fromTable:@"message"];
```

#### 插入

```objective-c
/*
 FMDB Code
 */
[fmdb executeUpdate:@"INSERT INTO message VALUES(?, ?, ?, ?)", @(message.localID), message.content, @(message.createTime.timeIntervalSince1970), @(message.modifiedTime.timeIntervalSince1970)];
/*
 WCDB Code
 */
[wcdb insertObject:message into:@"message"];
```

#### 修改

```objective-c
/*
 FMDB Code
 */
[fmdb executeUpdate:@"UPDATE message SET modifiedTime=?", @(message.modifiedTime.timeIntervalSince1970)];
/*
 WCDB Code
 */
[wcdb updateAllRowsInTable:@"message" onProperties:Message.modifiedTime withObject:message];
```

#### 删除

```objective-c
/*
 FMDB Code
 */
[fmdb executeUpdate:@"DELETE FROM message"];
/*
 WCDB Code
 */
[wcdb deleteAllObjects];
```

## 条件语句

WCDB通过WINQ完成条件语句，以减轻了拼装SQL的繁琐，并提供一系列优化和反注入等特性。

### WINQ和字段映射

对于已定义ORM的类，通过`className.propertyName`获取数据库字段的映射。

以下是SQL和WINQ之间转换的一些例子。

| 类型              | SQL示例                                        | WINQ示例                                                     |
| ----------------- | ---------------------------------------------- | ------------------------------------------------------------ |
| 排序              | `ORDER BY localID ASC`                         | `Message.localID.order(WCTOrderedAscending)`                 |
| 多字段排序        | `ORDER BY localID ASC, content DESC`           | `{Message.localID.order(WCTOrderedAscending), Message.content.order(WCTOrderedDescending)}` |
| 聚合函数          | `MAX(localID)`                                 | `Message.localID.max()`                                      |
| 条件语句          | `localID==2 AND content IS NOT NULL`           | `Message.localID==2&&Message.content.isNotNull()`            |
| 多个字段组合      | `localID, content`                             | `{Message.localID, Message.content}`                         |
| `*`               | `COUNT(*)`                                     | `Message.AnyProperty.count()`                                |
| 所有ORM定义的字段 | `(localID, content, createTime, modifiedTime)` | `Message.AllProperties`                                      |
| 指定table         | `myTable.localID`                              | `Message.localID.inTable("myTable")`                         |

### 改写条件语句

了解了WINQ，就可以完成更复杂的增删查改操作了。

#### 部分查询

```objective-c
/*
 FMDB Code
 */
NSMutableArray<Message *> *messages = [[NSMutableArray alloc] init];
FMResultSet* resultSet = [fmdb executeQuery:@"SELECT localID, createTime FROM message WHERE localID>=1 OR modified!=createTime"];
while (resultSet && [resultSet next]) {
    Message *message = [[Message alloc] init];
    message.localID = [resultSet intForColumnIndex:0];
    message.createTime = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumnIndex:2]];
    [messages addObject:message];
}
/*
 WCDB Code
 */
NSArray *messages = [wcdb getObjectsOnResults:{Message.localID, Message.createTime} 
                                    fromTable:@"message"
                                        where:Message.localID>1||Message.modifiedTime!=Message.createTime];
```

#### 自增插入

```objective-c
/*
 FMDB Code
 */
[fmdb executeUpdate:@"INSERT INTO message(localID, content) VALUES(?, ?)", nil, message.content];
/*
 WCDB Code
 */
message.isAutoIncrement = YES;
[wcdb insertObject:message 
          onProperties:{Message.localID, Message.content} 
                  into:@"message"];
```

#### 数值更新

```objective-c
/*
 FMDB Code
 */
[fmdb executeUpdate:@"UPDATE message SET modifiedTime=? WHERE localID==?", @([NSDate date].timeIntervalSince1970), @(1)];
/*
 WCDB Code
 */
[wcdb updateRowsInTable:@"message" 
             onProperty:Message.modifiedTime 
              withValue:[NSDate date]
                  where:Message.localID==1];
```

#### 部分删除

```objective-c
/*
 FMDB Code
 */
[fmdb executeUpdate:@"DELETE FROM message WHERE localID>0 AND content IS NULL LIMIT ?", @(1)];
/*
 WCDB Code
 */
[wcdb deleteObjectsFromTable:@"messsage" 
                           where:Message.localID>0&&Message.content!=nil
                           limit:1];
```

更多关于增删查改接口的用法，可参考：[CRUD教程](https://github.com/Tencent/wcdb/wiki/基础类、CRUD与Transaction#CRUD)

## 特殊语句和核心层接口

WCDB的ObjC层接口封装了绝大部分场景下适用的增删查改语句。但SQL千变万化，接口层不可能覆盖全部场景。对于这种情况，可以通过WINQ的核心层接口进行调用。

对于SQL：`EXPLAIN QUERY PLAN CREATE TABLE message(localID INTEGER)`。

1. 找到其对应的[sql-stmt](http://www.sqlite.org/syntax/sql-stmt.html)，然后通过以`WCDB::Statement`开头的类进行调用。如例子中，其对应的sql-stmt为`WCDB::StatementExplain`和`WCDB::StatementCreateTable`。

2. 获取字段映射。对于已经定义ORM的字段，可以通过`className.propertyName`获取，如：`Message.localID`。对于未定义ORM的字段，可以通过`WCDB::Column columnName("columnName")`创建，如 `WCDB::Column localID("localID")`。

3. 根据`Statement`内的定义，按照**与SQL同名的函数**调用获得完整的WINQ语句。如例子中，其对应的WINQ语句为

   ```objective-c
   WCDB::ColumnDefList columnDefList = {WCTSampleORM.identifier.def(WCTColumnTypeInteger32, true)};
   WCDB::StatementExplain statementExplain = WCDB::StatementExplain().explainQueryPlan(WCDB::StatementCreateTable().create("message", columnDefList));
   ```

4. 通过`getDescription()`打印log，调试确保SQL正确

   ```objective-c
   NSLog(@"SQL: %s", statementExplain.getDescription().c_str());
   ```

#### 执行WINQ

通过`exec:`执行WINQ statement。

```objective-c
[wcdb exec:statement];
```

#### 获取WINQ运行结果

通过`prepare:`运行WINQ statement，获得`WCTStatement`，并以此获取返回值。

```objective-c
WCTStatement *statement = [wcdb prepare:statementExplain];
if (statement && [statement step]) {
    for (int i = 0; i < [statement getCount]; ++i) {
        NSString *columnName = [statement getNameAtIndex:i];
        WCTValue *value = [statement getValueAtIndex:i];
        NSLog(@"%@:%@", columnName, value);
    }
}
```

该接口风格与FMDB类似。

更多关于示例代码，可以参考[核心层接口](https://github.com/Tencent/wcdb/wiki/基础类、CRUD与Transaction#核心层接口)

## 事务

WCDB的基础事务接口与FMDB的接口类似。

```objective-c
/*
 FMDB Code
 */
BOOL result = [fmdb beginTransaction];
if (!result) {
    //failed
}
//do sth...
if (![fmdb commit]) {
    //failed
    [fmdb rollback];
}
/*
 WCDB Code
 */
BOOL result = [wcdb beginTransaction];
if (!result) {
    //failed
}
//do sth...
if (![wcdb commitTransaction]) {
    [wcdb rollbackTransaction];
}
```

#### 便捷事务接口

`runTransaction:`接口会在commit失败时自动rollback事务。开发者也可以在`BLOCK`结束时返回`YES`或`NO`来决定commit或rollback事务，以此减少代码量。

```objective-c
[wcdb runTransaction:^BOOL{
    //do sth...
    return result;//YES to commit transaction and NO to rollback transaction
}];
```

## 多重语句和批处理

WCDB不支持多重语句。多个语句需拆分单独写。

WCDB对于涉及批量操作的接口，都有内置的事务。如`createTableAndIndexesOfName:withClass:`和`insertObjects:into:`等，这类接口通常不止执行一条SQL，因此WCDB会自动嵌入事务，以提高性能。

## 线程安全与并发

FMDB通过`FMDatabasePool`完成多线程任务。

而对于WCDB，`WCTDatabase`、`WCTTable`和`WCTTransaction`的所有SQL操作接口都是线程安全，并且自动管理并发的。

*WCDB的连接池会根据数据库访问所在的线程、是否处于事务、并发状态等，自动分发合适的SQLite连接进行操作，并在完成后回收以供下一次再利用。*

因此，开发者既不需要使用一个新的类来完成多线程任务，也不需要过多关注线程安全的问题。同时，还能获得更高的性能表现。

```objective-c
/*
 FMDB Code
 */
//thread-1 read
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [fmdbPool inDatabase:^(FMDatabase *_Nonnull db) {
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM message"];
        while ([resultSet next]) {
            Message *message = [[Message alloc] init];
            message.localID = [resultSet intForColumnIndex:0];
            message.content = [resultSet stringForColumnIndex:1];
            message.createTime = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumnIndex:2]];
            message.modifiedTime = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumnIndex:3]];
            [messages addObject:message];
        }
        //...
    }];
});
//thread-2 write
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [fmdbPool inDatabase:^(FMDatabase *_Nonnull db) {
		[db beginTransaction]
        for (Message *message in messages) {
            [db executeUpdate:@"INSERT INTO message VALUES(?, ?, ?, ?)", @(message.localID), message.content, @(message.createTime.timeIntervalSince1970), @(message.modifiedTime.timeIntervalSince1970)];
        }
        if (![db commit]) {
            [db rollback];
        }
    }];
});
/*
 WCDB Code
 */
//thread-1 read
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSArray *messages = [wcdb getAllObjectsOfClass:Message.class fromTable:@"message"];
    //...
});
//thread-2 write
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [wcdb insertObjects:messages into:@"message"];
});
```

## 配置

在使用数据库时，通常会对其设置一些默认的配置，如`cache_size`、`journal_mode`等。

FMDB通过`FMDatabasePoolDelegate`进行配置，但其只能在SQLite Handle创建时进行配置。对于已经产生的SQLite handle，很难再次更改配置。

而WCDB可以随时灵活地对其设置或变更。

```objective-c
/*
 FMDB Code
 */
- (BOOL)databasePool:(FMDatabasePool *)pool shouldAddDatabaseToPool:(FMDatabase *)database
{
    FMResultSet* resultSet = [database executeQuery:@"PRAGMA cache_size=-2000"];
	[result next];
}
/*
 WCDB Code
 */
[wcdb setConfig:^BOOL(std::shared_ptr<WCDB::Handle> handle, WCDB::Error &error) {
    return handle->exec(WCDB::StatementPragma().pragma(WCDB::Pragma::CacheSize, -2000));
} forName:@"CacheSizeConfig"]'
```

## 关闭数据库

关闭数据库通常有两种场景：

1. 数据库使用结束，回收对象。
2. 数据库进行某些操作，需要临时关闭数据库。如移动、复制数据库文件。

### 回收对象

对于这种情况，开发者无需手动操作。WCDB会自动管理这个过程。对于某一路径的数据库，WCDB会在所有对其的引用释放时，自动关闭数据库，并回收资源。

对于iOS平台，当内存不足时，WCDB会自动关闭空闲的SQLite连接，以节省内存。开发者也可以手动调用`[db purgeFreeHandles]`对清理单个数据库的空闲SQLite连接。或调用`[WCTDatabase PurgeFreeHandlesInAllDatabases]`清理所有数据库的空闲SQLite连接。

### 手动关闭数据库

无论是WCDB的多线程管理，还是FMDB的FMDatabasePool，都存在多线程关闭数据库的问题。

即，当一个线程希望关闭数据库时，另一个线程还在继续执行操作。

而某些特殊的操作需要确保数据库完全关闭，例如移动、重命名、删除数据库等文件层面的操作。

例如，若在A线程进行插入操作的执行过程中，B线程尝试复制数据库，则复制后的新数据库很可能是一个损坏的数据库。

因此，WCDB提供了`close:`接口确保完全关闭数据库，并阻塞其他线程的访问。

```objective-c
 [wcdb close:^(){
    //do something on this closed database
 }];
```

## 隔离Objective-C++代码

WCDB基于WINQ，引入了Objective-C++代码，因此对于所有引入WCDB的源文件，都需要将其后缀`.m`改为`.mm`。为减少影响范围，可以通过Objective-C的category特性将其隔离，达到**只在model层使用Objective-C++编译，而不影响controller和view**。

对于已有类`WCTSampleAdvance`，

```objective-c
//WCTSampleAdvance.h
#import <Foundation/Foundation.h>
#import "WCTSampleColumnCoding.h"

@interface WCTSampleAdvance : NSObject

@property(nonatomic, assign) int intValue;
@property(nonatomic, retain) WCTSampleColumnCoding *columnCoding;

@end
  
//WCTSampleAdvance.mm
@implementation WCTSampleAdvance
  
@end
```

可以创建`WCTSampleAdvance (WCTTableCoding)`专门用于定义ORM。

为简化定义代码，WCDB同样提供了文件模版

### WCTTableCoding文件模版

为了简化定义，WCDB同样提供了Xcode文件模版来创建`WCTTableCoding`的category。

1. 首先需要安装文件模版。

   - 安装脚本集成在WCDB的编译脚本中，只需编译一次WCDB，就会自动安装文件模版。
   - 也可以手动运行`cd path-to-your-wcdb-dir/objc/templates; sh install.sh;`手动安装 [文件模版](https://github.com/Tencent/wcdb/blob/master/objc/xctemplate/Makefile)。

2. 安装完成后重启Xcode，选择新建文件，滚到窗口底部，即可看到对应的文件模版。

   ![img](https://github.com/Tencent/wcdb/wiki/assets/ORM/file-template.png)

3. 选择`WCTTableCoding` ![img](https://github.com/Tencent/wcdb/wiki/assets/ORM/file-template-table-coding.png) 输入需要实现`WCTTableCoding`的类

4. 这里以`WCTSampleAdvance`为例，Xcode会自动创建`WCTSampleAdvance+WCTTableCoding.h`文件模版：

   ```objective-c
   #import "WCTSampleAdvance.h"
   #import <WCDB/WCDB.h>
   
   @interface WCTSampleAdvance (WCTTableCoding) <WCTTableCoding>
   
   WCDB_PROPERTY(<#property1 #>)
   WCDB_PROPERTY(<#property2 #>)
   WCDB_PROPERTY(<#property3 #>)
   WCDB_PROPERTY(<#property4 #>)
   WCDB_PROPERTY(<#... #>)
   
   @end
   ```

5. 加上类的ORM实现即可。

   ```objective-c
   //WCTSampleAdvance.h
   #import <Foundation/Foundation.h>
   #import "WCTSampleColumnCoding.h"
   
   @interface WCTSampleAdvance : NSObject
   
   @property(nonatomic, assign) int intValue;
   @property(nonatomic, retain) WCTSampleColumnCoding *columnCoding;
   
   @end
     
   //WCTSampleAdvance.mm
   @implementation WCTSampleAdvance
     
   WCDB_IMPLEMENTATION(WCTSampleAdvance)
   WCDB_SYNTHESIZE(WCTSampleAdvance, intValue)
   WCDB_SYNTHESIZE(WCTSampleAdvance, columnCoding)
   
   WCDB_PRIMARY_ASC_AUTO_INCREMENT(WCTSampleAdvance, intValue)
   
   @end
     
   //WCTSampleAdvance+WCTTableCoding.h
   #import "WCTSampleAdvance.h"
   #import <WCDB/WCDB.h>
   
   @interface WCTSampleAdvance (WCTTableCoding) <WCTTableCoding>
   
   WCDB_PROPERTY(intValue)
   WCDB_PROPERTY(columnCoding)
   
   @end
   ```

此时，原来的`WCTSampleAdvance.h`中不包含任何C++的代码。因此，其他文件对其引用时，不需要修改文件名后缀。只有Model层需要使用WCDB接口的类，才需要包含`WCTSampleAdvance+WCTTableCoding.h`，并修改文件名后缀为`.mm`。

示例代码请参考：[WCTSampleAdvance](https://github.com/Tencent/wcdb/blob/master/objc/sample/advance/WCTSampleAdvance.h)和[WCTSampleNoObjectiveCpp](https://github.com/Tencent/wcdb/blob/master/objc/sample/advance/WCTSampleNoObjectiveCpp.h)

更多教程和示例代码，请参考WCDB的[wiki](https://github.com/Tencent/wcdb/wiki)和[sample](https://github.com/Tencent/wcdb/tree/master/objc/sample)

# 10-全文搜索介绍

全文搜索 ( **F**ull-**T**ext **S**erach )，是SQLite提供的功能之一，支持更快速、更便捷地搜索数据库内的信息。更多信息可参考[SQLite的官方文档](http://www.sqlite.org/fts3.html)。

WCDB内建FTS的支持，使用更简便，搜索更智能，分词更适合中文、日文等非空格分割的语言搜索。

## 基本用法

### ORM

```
//WCTSampleFTSData.h
@interface WCTSampleFTSData : NSObject

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *content;

@end

//WCTSampleFTSData+WCTTableCoding.h
@interface WCTSampleFTSData (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(name)
WCDB_PROPERTY(content)

@end

//WCTSampleFTSData.mm
@implementation WCTSampleFTSData

WCDB_IMPLEMENTATION(WCTSampleFTSData)
WCDB_SYNTHESIZE(WCTSampleFTSData, name)
WCDB_SYNTHESIZE(WCTSampleFTSData, content)

WCDB_VIRTUAL_TABLE_MODULE(WCTSampleFTSData, WCTModuleNameFTS3)
WCDB_VIRTUAL_TABLE_TOKENIZE(WCTSampleFTSData, WCTTokenizerNameWCDB)

@end
```

FTS的ORM与普通表的ORM很类似。

将一个已有的ObjC类进行FTS的ORM绑定的过程如下：

- 使用`WCDB_PROPERTY`宏在头文件声明需要绑定到数据库表的字段。
- 使用`WCDB_IMPLEMENTATIO`宏在类文件定义绑定到数据库表的类。
- 使用`WCDB_SYNTHESIZE`宏在类文件定义需要绑定到数据库表的字段。
- 使用`WCDB_VIRTUAL_TABLE_MODULE`定义使用的虚拟表的模块。
- 使用`WCDB_VIRTUAL_TABLE_TOKENIZE`定义使用搜索使用的分词器。

如无特殊需求，模块和分词器可使用默认的`WCTModuleNameFTS3`和`WCTTokenizerNameWCDB`即可。后面会进一步讨论模块和分词器。

### ORM的限制

SQLite的FTS是使用虚拟表实现的，因此其与虚拟表有同样的限制

- 不支持创建触发器
- 不支持、也不需要创建索引
- 不支持通过`ALTER TABLE`为虚拟表添加新的字段

### 建表

```
WCTDatabase *databaseFTS = [[WCTDatabase alloc] initWithPath:pathFTS];
[databaseFTS setTokenizer:WCTTokenizerNameWCDB];
[databaseFTS createVirtualTableOfName:tableNameFTS withClass:WCTSampleFTSData.class];
```

建FTS表与建普通表也很类似。对于已经定义FTS-ORM的类`WCTSampleFTSData`和已创建的数据`databaseFTS`

- 通过`- setTokenizer:`接口对当前数据库注册分词器，这里需与ORM定义的分词器一致。开发者也可以通过`- setTokenizers:`注册多个分词器。
- 通过`- createVirtualTableOfName:withClass:`接口创建FTS表。

### 建立FTS索引

```
WCTSampleFTSData *object = [[WCTSampleFTSData alloc] init];
object.name = @"English";
object.content = @"This is sample content";
object.isAutoIncrement = YES;
[databaseFTS insertObject:object into:tableNameFTS];
```

开发者只需要将数据插入到FTS表中，即可建立FTS索引。插入方式与普通表没有区别。

### FTS搜索

```
NSArray<WCTSampleFTSData *> *ftsDatas = [databaseFTS getObjectsOfClass:WCTSampleFTSData.class fromTable:tableNameFTS where:WCTSampleFTSData.name.match("Eng*")];
for (WCTSampleFTSData *ftsData in ftsDatas) {
    NSLog(@"Match name:%@ content:%@", ftsData.name, ftsData.content);
}
```

FTS搜索与普通表的方式类似，只是在`where`语句中，需要用`match`来搜索。

#### 全表搜索

FTS表不仅可以针对某个字段进行搜索，也可以使用内置的隐藏字段进行全表搜索。隐藏字段与表名一致，可以通过`className.PropertyNamed(tableName)`获取。

```
NSArray<WCTSampleFTSData *> *ftsDatas = [databaseFTS getObjectsOfClass:WCTSampleFTSData.class fromTable:tableNameFTS where:WCTSampleFTSData.PropertyNamed(tableNameFTS).match("Eng*")];
for (WCTSampleFTSData *ftsData in ftsDatas) {
    NSLog(@"Match name:%@ content:%@", ftsData.name, ftsData.content);
}
```

FTS搜索的示例代码请参考：[sample_fts_main](https://github.com/Tencent/wcdb/blob/master/objc/sample/fts/sample_fts_main.mm)

## FTS模块

SQLite支持`FTS3`、`FTS5`两种搜索模块，可通过`WCDB_VIRTUAL_TABLE_MODULE(WCTSampleFTSData, WCTModuleNameFTS3)`或`WCDB_VIRTUAL_TABLE_MODULE(WCTSampleFTSData, @"FTS5")`进行定义。WCDB默认使用`FTS3`。

关于 `FTS3` 和 `FTS5` 的差异，可参考SQLite的官方文档 [SQLite FTS3 and FTS4 Extensions](http://www.sqlite.org/fts3.html) 和 [SQLite FTS5 Extension](http://www.sqlite.org/fts5.html)

## FTS分词器

若只用一句话概括，FTS搜索的原理是将文字信息通过分词器切断为字词组成的数组，并以此建立搜索树。因此，分词器是搜索效率、准确度的关键。

SQLite内置了`simple`、`porter`、`unicode61`等多个分词器，但其适合场景有限，这里不做深入讨论，开发者可自行搜索。

这里重点讨论WCDB内置的分词器， `WCTTokenizerNameApple` 和 `WCTTokenizerNameWCDB` 。

### Apple分词器

`WCTTokenizerNameApple`是WCDB内置的一个分词器，它使用 `CoreFoundation` 内置的 `CFStringTokenizer` 对语句进行分割。

`CFStringTokenizer` 会过滤符号，并根据语言、语义对语句进行分割。

在iOS的任一输入框的文字中长按，并在弹出菜单中点击 "选择"，iOS会智能地根据当前游标选择附近的一个词组。这个就是 `CFStringTokenizer` 的分词效果。

以一个词组 "苹果树" 为例，`CFStringTokenizer` 根据语义，会将其分割为 "苹果" 和 "树" 两个词组。

因此，使用 Apple分词器 的 FTS 表内会有该两个字段。开发者只需使用 `className.PropertyNamed(tableName).match("苹果")`即可搜索到对应的数据。

### Apple分词器的局限性

上面提到，FTS搜索是将字段切断后组成B树，也就是说，搜索是根据切割后词组的首字符逐个匹配过去的。

因此，以"苹果树"的例子来说，"果树" 这一关键词因为无法首字匹配 "苹果" 和 "树"，它无法被搜索到。而在中文中，这一例子里有"苹果"、"果树"、"树"、"苹果树"等多个有意义的词组。因此，虽然Apple分词器可以智能地基于语义进行分词，但其并不符合部分场景和部分语言。

同时，FTS通常用于app内搜索，其使用场景与搜索引擎不同。搜索引擎只要求将最符合条件的前几页数据搜索出来，因此搜索"果树"但结果中没有"苹果树"是符合场景的。而FTS要求的触达率要求是100%，即只要app内有这个数据，就应该被搜索出来。

## WCDB分词器

`WCTTokenizerNameWCDB`是WCDB内置分词器，也是我们优先推荐的分词器。

### 符号

WCDB分词器会过滤所有Unicode编码中符号、空格、制表符、不可见和非法字符等。即Unicode编码字集中的 [ Cc, Cf, Z*, U000A ~ U000D, U0085, M*, P*, S* ]，详情可参考 [Unicode Character Categories](http://www.fileformat.info/info/unicode/category/index.htm)

### 英文

WCDB分词器会将英文按照单词进行词形还原。

以句子"WCDB is a cross-platform database framework developed by WeChat."为例，由于英文存在多种变形和时态，传统的分词器无法通过"are"搜索到"is"，无法通过"develop"搜索到"developed"。而词形还原会将单词还原为一般形态，从而使得WCDB分词器有更强的英文搜索能力。

### 中文

包括中文、日文在内的多种语言，都是通过语义，而不是空格或符号进行分割。WCDB分词器会将他们按照单双字符的逻辑进行分词。

同样以"苹果树"的逻辑为例，WCDB分词器会按照顺序，将其分割为："苹果"、"苹"、"果树"、"果"、"树"。因此其可以确保各种组合都能正确匹配到。

### 自定义分词器



若开发者对已有的分词器不满意，也可以自定义新的分词器。

WCDB提供了文件模版用来定义分词器，开发者可参考 [Apple分词器](https://github.com/Tencent/wcdb/blob/master/objc/WCDB/interface/fts/WCTTokenizer%2BApple.mm) 和 [WCDB分词器](https://github.com/Tencent/wcdb/blob/master/objc/WCDB/core/tokenizer.cpp) 实现。

![img](https://github.com/Tencent/wcdb/wiki/assets/fts/WCTTokenizer.png)

![img](https://github.com/Tencent/wcdb/wiki/assets/fts/WCTokenizer_Apple.png)

# 11-iOS/macOS - Swift



WCDB Swift 是一个易用、高效、完整的移动数据库框架，它基于 SQLite 和 SQLCipher 开发。

## 易用性



**One line of code** 是 WCDB Swift 设计的基本原则之一。通过更现代的数据库开发模式，减少开发者所需使用的代码量，绝大部分增删查改都只需一行代码即可完成：

```
let objects: [Sample] = try database.getObjects(fromTable: myTable, 
                                                where: Sample.Property.identifier > 10)
```

1. **模型绑定**。基于 Swift 4.0 的 `Codable` 协议，建立 Swift 类型与数据库表之间的映射关系，从而使得开发者可以通过类对象直接操作数据库。
2. **范型与类型推导**。WCDB Swift 的接口与 Swift 的语法相结合，使复杂的数据库操作可以以简明的方式表达出来。因此，代码不仅易于编写，而且更易于阅读和维护。
3. **语言集成查询**。深度结合 Swift 和 SQL 的语法，使得纯字符串的 SQL 可以以代码的形式表达出来。结合代码提示及纠错，极大地提高了开发效率。

## 高效性



WCDB Swift 基于 SQLite，并深入其**源码进行了性能优化**，以适配移动终端的场景。同时，对于常用且性能消耗较大的场景，如批量插入等，也做了针对性的优化。 在多线程方面，WCDB Swift 不仅可以**安全地在任意线程进行数据库操作**，且其内部会智能地根据操作类型调配资源，使其能够**并发执行**，进一步提升效率。

## 完整性



WCDB Swift 总结实践中常见的问题，为数据库开发提供更完整、全面的使用体验：

1. **加密**。基于 SQLCipher 的加密机制，为数据安全提供保障。
2. **全文搜索**。WCDB Swift 提供简单易用的全文搜索接口，并包含适配多种语言的分词器，使得数据搜索更精准。
3. **反注入**。内建在语言集成查询中的反注入机制，可以避免第三方从输入框注入 SQL，进行预期之外的恶意操作。
4. **字段升级**。数据库模型与类定义绑定，使得字段的增加、删除、修改都与类变量的定义保持一致，不需要开发者额外地管理字段的版本。
5. **损坏修复**。修复工具可以在系统错误、磁盘故障等情况下，尽最大限度 地将损坏的数据找回并导出。

WCDB Swift 提供 Cocoapods、Carthage 和 源码 三种安装方式。

##基本要求

- **Swift 4.0** 及以上
- **Xcode 9.0** 及以上
- 系统要求
  - **iOS 8.0** 及以上
  - **macOS 10.9** 及以上
  - **tvOS 9.0** 及以上
  - **watchOS 2.0** 及以上

## 通过 Cocoapods 安装

### 安装 Cocoapods 工具

可参考 [Cocoapods 官方教程](https://guides.cocoapods.org/using/getting-started.html#installation)进行安装。

### 更新本地的 Cocoapods 缓存

在命令行中执行：

```
pod repo update
```

### 添加 Podfile 配置

在工程目录下创建 `podfile` 文件，并在对应 target 下添加 `pod 'WCDB.swift'` 和 `use_frameworks!`。以下是一份示例 `podfile` 文件：

```
platform :ios, '8.0'
use_frameworks!

target 'Sample' do
    pod 'WCDB.swift'
end
```

然后在 `podfile` 同目录下命令行执行：

```
pod install --verbose
```

### 引入 WCDBSwift

在项目中使用 Cocoapods 生成的 `.xcworkspace` 文件打开工程，并在需要使用 WCDB Swift 的源代码文件头通过 `import WCDBSwift` 引入即可。

## 通过 Carthage 安装

### 安装 Carthage 工具

可参考 [Carthage 官方教程](https://github.com/Carthage/Carthage#installing-carthage)进行安装。

### 添加 cartfile 配置

在工程目录下创建 `cartfile` 文件，并添加 `github "Tencent/WCDB"`。以下是一份示例 `cartfile` 文件：

```
github "Tencent/WCDB"
```

### 编译生成动态库

在工程目录命令行执行：

```
carthage update
```

> 对于不需要 bitcode 的开发者，可以指定 `--configuration WithoutBitcode`，以降低二进制的包大小。

完成后可以在 `Carthage/Build` 目录下找到生成的对应 iOS 或 macOS 平台动态库 `WCDBSwift.framework`

### 链入动态库

打开工程，并将对应 iOS 或 macOS 平台的动态库，拖入工程设置的 `Build Phases` -> `Link Binary and Libraries` 中。

同样在 `Build Phases` 中，选择 `+` 选项，在弹出菜单中选择 `New Run Script Phase`。在创建的脚本中添加

```
carthage copy-frameworks
```

并在 `Input Files` 中添加对应 iOS 或 macOS 平台的动态库路径，如

- iOS：
  - `$(SRCROOT)/Carthage/Build/iOS/WCDBSwift.framework`
- macOS：
  - `$(SRCROOT)/Carthage/Build/Mac/WCDBSwift.framework`

以下是一份 iOS 平台工程的配置示例：

![carthage_sample](https://github.com/Tencent/wcdb/wiki/assets/swift/carthage_sample.png)

### 引入 WCDBSwift

在需要使用 WCDB Swift 的源代码文件头通过 `import WCDBSwift` 引入即可。

## 通过源码安装

### 获取 WCDB Swift 源码

WCDB Swift 包含了 sqlcipher 的子模块，因此也需对其进行更新。在命令行中执行：

```
git clone https://github.com/Tencent/wcdb.git
cd wcdb
git submodule update --init sqlcipher
```

### 链入工程文件

将 `wcdb/swift` 目录下的 `WCDB.swift.xcodeproj` 拖入你的工程文件中，并在工程配置的 `Build Phases` -> `Target Dependencies` 中添加 `WCDBSwift`

### 链入动态库

同样在工程配置的 `General` -> `Enbedded Binaries` 中添加 `WCDBSwift.framework`。

以下是一个完成链入的配置示例：

![git_clone_sample](https://github.com/Tencent/wcdb/wiki/assets/swift/git_clone_sample.png)

### 引入 WCDBSwift

在需要使用 WCDB Swift 的源代码文件头通过 `import WCDBSwift` 引入即可

# 12-快速入门Swift WCDB

WCDB 的最基础的调用过程大致分为三个步骤：

1. 模型绑定
2. 创建数据库与表
3. 操作数据

## 模型绑定

WCDB 基于 Swift 4.0 的 `Codable` 协议实现模型绑定的过程。

对于已经存在的 `Sample` 类：

```
class Sample {
    var identifier: Int? = nil
    var description: String? = nil
}
```

可通过以下代码将 `Sample` 类的 `identifier` 和 `description` 两个变量绑定到了表中同名字段：

```
class Sample: TableCodable {
    var identifier: Int? = nil
    var description: String? = nil
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = Sample
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case identifier
        case description
    }
}
```

这部分代码基本都是固定模版，暂时不用理解其每一句的具体含义，我们会在[模型绑定](https://github.com/Tencent/wcdb/wiki/Swift-模型绑定)一章中进行进一步介绍。

## 创建数据库与表



**One line of code** 是 WCDB 接口设计的一个基本原则，绝大部分的便捷接口都可以通过一行代码完成。

### 创建数据库对象

```
let database = Database(withPath: "~/Intermediate/Directories/Will/Be/Created/sample.db")
```

WCDB 会在创建数据库文件的同时，创建路径中所有未创建文件夹。

### 创建数据库表

```
// 以下代码等效于 SQL：CREATE TABLE IF NOT EXISTS sampleTable(identifier INTEGER, description TEXT)
try database.create(table: "sampleTable", of: Sample.self)
```

对于已进行模型绑定的类，同样只需一行代码完成。

## 操作数据

基本的增删查改同样是 **One line of code**

### 插入操作

```
//Prepare data
let object = Sample()
object.identifier = 1
object.description = "sample_insert"
//Insert
try database.insert(objects: object, intoTable: "sampleTable")
```

### 查找操作

```
let objects: [Sample] = try database.getObjects(fromTable: "sampleTable")
```

### 更新操作

```
//Prepare data
let object = Sample()
object.description = "sample_update"
//Update
try database.update(table: "sampleTable",
                       on: Sample.Properties.description,
                     with: object,
                    where: Sample.Properties.identifier > 0)
```

> 类似 `Sample.Properties.identifier > 0` 的语法是 WCDB 的特性，它能通过 Swift 语法来进行 SQL 操作，我们将在[语言集成查询](https://github.com/Tencent/wcdb/wiki/Swift-语言集成查询)一章中进行进一步的介绍。

### 删除操作

```
try database.delete(fromTable: "sampleTable")
```

# 更多教程

本章简单介绍了 WCDB Swift 进行操作的过程，并展示了基本的用法。 后续将对里面的逐个细节进行详细介绍。建议**按照顺序阅读基础教程部分**，而进阶教程则可以按照个人需求选择阅读。

# 完整目录



## iOS/macOS - Objective-C

- 中文
  - [iOS/macOS使用教程](https://github.com/Tencent/wcdb/wiki/iOS-macOS使用教程)
  - [ORM使用教程](https://github.com/Tencent/wcdb/wiki/ORM使用教程)
  - [WINQ原理](https://github.com/Tencent/wcdb/wiki/WINQ原理)
  - [基础类、CRUD与Transaction](https://github.com/Tencent/wcdb/wiki/基础类、CRUD与Transaction)
  - [全局监控与错误处理](https://github.com/Tencent/wcdb/wiki/全局监控与错误处理)
  - [从FMDB迁移到WCDB](https://github.com/Tencent/wcdb/wiki/从FMDB迁移到WCDB)
  - [性能数据与Benchmark](https://github.com/Tencent/wcdb/wiki/性能数据与Benchmark)
  - [FTS全文搜索使用教程](https://github.com/Tencent/wcdb/wiki/全文搜索使用教程)
- In English
  - [iOS/macOS Tutorial](https://github.com/Tencent/wcdb/wiki/iOS-macOS-Tutorial)
  - [WCDB Benchmark](https://github.com/Tencent/wcdb/wiki/WCDB-iOS-benchmark)

## iOS/macOS - Swift

- 中文
  - 欢迎使用 WCDB
    - [关于 WCDB Swift](https://github.com/Tencent/wcdb/wiki/Swift-关于 WCDB Swift)
    - [安装与兼容性](https://github.com/Tencent/wcdb/wiki/Swift-安装与兼容性)
  - 基础教程
    - [快速入门](https://github.com/Tencent/wcdb/wiki/Swift-快速入门)
    - [模型绑定](https://github.com/Tencent/wcdb/wiki/Swift-模型绑定)
    - [增删查改](https://github.com/Tencent/wcdb/wiki/Swift-增删查改)
    - [数据库、表、事务](https://github.com/Tencent/wcdb/wiki/Swift-数据库、表、事务)
    - [语言集成查询](https://github.com/Tencent/wcdb/wiki/Swift-语言集成查询)
  - 进阶教程
    - [加密与配置](https://github.com/Tencent/wcdb/wiki/Swift-加密与配置)
    - [高级接口](https://github.com/Tencent/wcdb/wiki/Swift-高级接口)
    - [监控与错误处理](https://github.com/Tencent/wcdb/wiki/Swift-监控与错误处理)
    - [自定义字段映射类型](https://github.com/Tencent/wcdb/wiki/Swift-自定义字段映射类型)
    - [全文搜索](https://github.com/Tencent/wcdb/wiki/Swift-全文搜索)
    - [损坏、备份、修复](https://github.com/Tencent/wcdb/wiki/Swift-损坏、备份、修复)
  - 技术文档
    - [Benchmark 与性能](https://github.com/Tencent/wcdb/wiki/Swift-Benchmark 与性能)
    - 修复原理
    - [API Reference](https://tencent.github.io/wcdb/references/apple_swift/)
- English

## Android

- [接入和迁移](https://github.com/Tencent/wcdb/wiki/Android接入与迁移)
- [接入Room ORM](https://github.com/Tencent/wcdb/wiki/Android-WCDB-使用-Room-ORM-与数据绑定)
- [数据库修复](https://github.com/Tencent/wcdb/wiki/Android数据库修复)
- [Benchmark](https://github.com/Tencent/wcdb/wiki/Android-Benchmark)

## API 文档

- [iOS/macOS Objective-C API](https://tencent.github.io/wcdb/references/apple_objc/)
- [iOS/macOS Swift API](https://tencent.github.io/wcdb/references/apple_swift/)
- [Android API](https://tencent.github.io/wcdb/references/android/)

## 常见问题

- [常见问题解答](https://github.com/Tencent/wcdb/wiki/常见问题)

##### Clone this wiki locally