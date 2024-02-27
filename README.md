# 用户管理中心回顾总结笔记



**写代码始终遵循写代码前的设计，设计中先实现再优化，设计后及时测试的原则**



## 企业做项目流程

​	需求分析 （主要为合理性和可行性）=> 设计(概要设计、详细设计) => 技术选型（主要是完成需求需要什么技术，以及技术的合适度） => 初始化/引入需要的技术  => 写 Demo => 写代码(实现业务逻辑) =>测试(单元测试、系统测试) => 代码提交/代码评审 => 部署 => 发布上线



## 需求分析

​	1.登录 /注册

​	2.用户管理（仅对管理员可见） 主要功能是对用户的查询和修改

​	3.用户校验（仅对特定的用户，例如会员用户）



## 技术选型

​	主流的开发技术

​	前端：三件套（HTML、CSS、JavaScript / JS） + React + 组件库 Ant Design + Umi + Ant Design Pro （现成的管理系统，在此基础上进行更改）

​	后端

​	⚪ java  

​	⚪ spring	依赖注入框架，帮助管理java对象，集成了一些其他的内容

​	⚪ springmvc	web 框架，提供接口访问、restful 接口等能力

​	⚪ mybatis	java操作数据库的框架，持久层框架，对jdbc的封装

​	⚪ mybatis-plus	对mybatis 的增强，不用写 sql 也能实现增删改查

​	⚪ springboot	快速启动/快速集成项目，不用自己管理spring 配置，不用自己整合各种框架

​	⚪ junit	单元测试库

​	⚪ mysql	数据库



​	部署：服务器 / 容器 （平台）

## 初始化项目

### 前端初始化

通过 Ant Design Pro 初始化，参考官方文档进行初始化操作[开始使用 - Ant Design Pro](https://pro.ant.design/zh-CN/docs/getting-started/)

初始化项目时选择为umi3。

在终端输入 npm install安装依赖 



#### 前端项目瘦身

​	1.项目各包的作用

1. 通过 package.json 中的 i18n-remove 就可以移除国际化
2. route 路由，用户访问各个代码文件 / 通过路由跳转到不同的页面 
3. config 配置文件
4. dist 部署项目时编译完成生成的文件，初始化项目时可删除
5. mock 模拟数据，可以不使用后端数据也能进行测试，初始化项目时自带，可删除
6. public 项目的静态资源，例如图片、视频等
7. src 编写代码时主要的目录其中：components 存放组件 其中组件不唯一，每个页面都可使用同一个组件，pages 存放页面，页面是唯一的，locales 国际化目录，根据选择可以删除，e2e 测试，定义一些逻辑进行自动化测试，
8. services 下的 global.less 全局的样式文件，如果不需要统一整个项目的样式就不要动该文件！！
9. stylelintrc.js 检验CSS语法 eslintrc.js 检验js语法，prettierrc.js 美化前端代码

**当删除页面时，同时需要在route内删除对应的路由，否则会出现报错，即保证删除的文件没有被其他地方引用**

### 前端代码设计

#### 前后端交互

​			前端ajax请求后端

​			axios封装了ajax

​			request时ant design项目又封装了一次

​			追踪request源码，用到了umi的插件

```
代理逻辑
在app.tsx配置
export const request: RequestConfig = {
  //超时时间 prefix不能触发代理
  timeout: 10000,
};
在proxy.ts配置访问路径
 dev: {
    // localhost:8000/api/** -> https://preview.pro.ant.design/api/**
    '/api/': {
      // 要代理的地址
      target: 'https://localhost8080',
      // 配置了这个可以从 http 代理到 https
      // 依赖 origin 的功能可能需要这个，比如 cookie
      changeOrigin: true,
    },
    
 在api.ts中的所有请求地址都需要加上/api
 
修改接口配置之后还需要修改部分代码，即保证代码能够正常判断是否登录成功
```



#### 注册页面

把登录页面复制，然后进行页面部分更改即可。

需注意的是，当查询不到登录态的时候会自动跳转至登录页面，此时需要将注册页面加入到重定向白名单。

```
//定义一个重定向白名单
const whitePath =['/user/register',loginPath];

//调用判断
if (whitePath.includes(location.pathname)) {
    return {
      fetchUserInfo,
      settings: defaultSettings as Partial<LayoutSettings>,
    };
  }
  const currentUser = await fetchUserInfo();
    return {
      fetchUserInfo,
      currentUser,
      settings: defaultSettings as Partial<LayoutSettings>,
    };
  
}
上面两段代码类似于if..else
如果第一个 return 不执行就执行下面一个，currentUser就是判断登录态的方法
```



#### 用户登录态验证

用户登录之后需要进行用户态的验证，之后再将页面跳转至管理页面，否则仍然处于登录页面。

首先后端接收前端传入的请求，后端从session 中取出登录态，过程中因为登录态设置不同导致后端接收不到前端传入的登录态信息从而查询不到用户信息

前端在 app.tsx 中有个 getInitialState 方法获取用户信息



#### 查询页面

管理页面需要在路由位置更改子路由信息，以及需要更改管理员权限的变量名

头像需要使用render渲染出来

```ts
title: '头像',
    dataIndex: 'avatarUrl',
    copyable: true,
    render: (_, record) => (
      <div>
      <Image src={record.avatarUrl}/>
      </div>
    ),
    
//其中下划线代表需要展示的列表内的数据等，record为后端返回的数据，从record中提取头像地址，然后通过ant design自带的 image组件渲染出来 
```

组件参考文档 [图片 Image - Ant Design (antgroup.com)](https://ant-design.antgroup.com/components/image-cn)

#### Ant Design Pro (Umi框架) 权限管理

⚪ app.tsx：项目全局入口文件，定义了整个项目中使用的公共数据（比如用户信息）

⚪ access.ts：控制用户的访问权限

获取初始状态流程：首次访问页面或者刷新页面，进入 app.tsx，执行getInitialState 方法，该方法的返回值就是全局可用的状态值

 

#### ProComponents 高级表单

1. 通过columns 定义表格有哪些列
2. columns 属性
   1. dataIndex 对应返回数据对象的属性
   2. title 表格列名
   3. copyable 是否允许复制
   4. ellipsis 是否允许缩略
   5. valueType：用于声明这一列的类型（dateTime、select）



### 后端初始化

通过引入框架初始化后端项目，整合框架

1. 从 github （不建议，可能有屎山，造成不必要的麻烦）
2. springboot 官方模板生成器（[Spring Initializr](https://start.spring.io/)）
3. 直接在IDEA开发工具直接生成  **推荐！！**，生成与官方模板生成器相似

依赖原则：Lombok、spring boot devtoos（用于热更新）、spring configuration procssor（用于识别注解，读取属性文件）、mysql 驱动、spring web、mybatis（操作数据库）

4. 从mybatis-plus官方网站山按照文档进行依赖注入以及demo测试 [MyBatis-Plus (baomidou.com)](https://baomidou.com/)

   ```java
   <dependency>
           <groupId>com.baomidou</groupId>
           <artifactId>mybatis-plus-boot-starter</artifactId>
           <version>最新版本</version>
       </dependency>
   ```

5. 更改属性文件 application.properties 文件 为application.yml

   ```java
   #项目名称
   spring:
     application:
       name: user-center
       #数据库配置
     datasource:
       driver-class-name: com.mysql.cj.jdbc.Driver
       username: root
       password: 1234
       url: jdbc:mysql://localhost:3306/user-center
   #端口号
   server:
     port: 8080
   
   
   ```


## 后端设计

### 数据库设计

​	IDEA 可以直接进行数据库的设计和连接，**注解 @resource 会按照javabean 进行注入，而 @autowired 只会按照类型进行注入**  后期需补充 spring 和spring boot 知识

用户表：id（主键、非空、自增） bigint

username 昵称 varchar

gender 性别  tinyint

userAccount 账号 varchar

password 密码 varchar 

phone 电话  varchar

email 邮箱 varchar

userStatus 是否有效 tinyint  0 1  

avatarUrl 头像  varchar

createTime 创建时间 datetime   （默认值输入 CURRENT_TIMESTAMP 自动更新时间）

updateTime 更新时间 datetime	（默认值输入 CURRENT_TIMESTAMP 自动更新时间）

isDelete 是否删除（作用和业务没关系，表示逻辑删除0，1）tinyint

userRole 用户角色 0-普通用户 1-管理员

**创建数据库时最好将 ddl 语句保存至文件中**

### 逻辑设计

#### 创建架构包，实体类

使用插件 MybatisX，自动根据数据库生成：

​	⚪ domain ：实体对象

​	⚪ mapper ：操作数据库的对象

​	⚪ mapper.xml：定义了 mapper 对象的数据库的关联，可以在里面自己写 SQL 

​	⚪ service：包含常用的增删改查

​	⚪ serviceImpl：具体实现service

减少操作，提高开发效率

### 登录

#### 接口设计

请求参数：用户账户、密码

请求类型：POST

请求体：JSON格式的数据

**请求参数比较长时不建议使用 get**

返回值：用户信息（**需要脱敏，即不将用户的信息显示在前端**）



#### 登录逻辑

1. 检验用户账户和密码是否合法

   a. 非空

   当判断是否为空时，采用  apache common lang  进行封装，依赖如下

   ```
   <dependency>
       <groupId>org.apache.commons</groupId>
       <artifactId>commons-lang3</artifactId>
       <version>3.12.0</version>
   </dependency>
   
   //判断方法
   if(StringUtils.isAnyBlank(userAccount,password,checkPassword)){
               return -1;
           }
   ```

   

   b. 账户长度不小于4位

   c. 密码长度不小于8位

   d. 账户不包含特殊字符（使用正则表达式验证）

   ```
   //验证账号是特殊字符
           boolean matcher = Pattern.compile("[ _`~!@#$%^&*()+=|{}':;',\\\\[\\\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]|\\n|\\r|\\t")
                   .matcher(userAccount).find();
           //包含则为true ，不包含则为false
           if(matcher){
               return -1;
           }
   ```

   

2. 检验密码是否输入正确。要和数据库中的密文密码去对比

   对比密码之前需要将密码进行加密，创建一个盐值

   ```java
   //将密码加密,使用一个盐值进行md5加密
           String salt = "pbcode";
           String encryptPassword = DigestUtils.md5DigestAsHex((salt + password).getBytes());
   ```

   验证时使用了mybatis-plus 的条件构造器queryWrapper，参考文档[mybatis plus 条件构造器queryWrapper学习_querywapper是什么-CSDN博客](https://blog.csdn.net/bird_tp/article/details/105587582)

3. 用户信息脱敏，隐藏敏感信息，防止数据库中的字段泄露

   用户脱敏就是用一个新对象将查询到的对象部分信息接收，其余信息设为空即可。

4. 我们要记录用户的登录态（session），将其存在服务器上，（用后端 springboot 框架封装的服务器 tomcat 去记录）cookie

   ```java
   //验证通过设置用户登录态
   request.getSession().setAttribute(USER_LOGIN_STATUS,user);
   ```

   

   ---

   如何知道是哪个用户登录了？

   （java web）

   ​	1.连接服务器端后，得到一个session1状态（匿名会话），返回给前端。给后端的参数中设置一个   （HttpServletRequest request）。

   ​	2.登录成功后，得到了登录成功的session，并且给session设置一些值，比如用户信息，返回给前端一个设置cookie的“命令”

   ​	3.前端接收到后端的命令后，设置cookie，保存到浏览器内

   ​	4.前端再次请求后端的时候（相同的域名），在请求头中带上cookie去请求

   ​	5.后端拿到前端传来的cookie，找到对应的session

   ​	6.后端从session中可以取出基于该session存储的变量（用户的登录信息、登录名）

   ---

   

5. 返回脱敏后的用户信息

**在查询时若出现逻辑删除的数据时，需要进行 mybatis-plus 的逻辑删除依赖，参考官方文档[逻辑删除 | MyBatis-Plus (baomidou.com)](https://baomidou.com/pages/6b03c5/#步骤-1-配置com-baomidou-mybatisplus-core-config-globalconfig-dbconfig)**



#### 控制层

```java
控制层注解
@RestController 适用于编写restful 风格的api，返回值默认为 json 类型
    
参数注解 @RequstBoby 用于将前端传入的 json 格式数据，springMVC 进行解析
```

参数封装为一个登录类，同时继承序列化  Serializable



### 注册



#### 接口设计

接收参数：账号、密码、确认密码

请求类型：POST

请求体：JSON格式的数据

返回值：注册成功用户 id

#### 注册逻辑

与登录逻辑验证相同，多一个确认密码的长度以及两次密码输入是否相同。



#### 鉴权

用户的删改查操作应该只能管理员能执行，所以在查询数据时判断是否为管理员即判断 userRole 字段来判断



### 查询

查询直接调用service层的方法即可，调用前需要先判断是否为管理员，即鉴权



### 注销

注销本质即为将前端存储的登录态设为空，前端查询不到登录态之后就会自动退出登录，重定向至登录界面。前后端同时设计。



### 逻辑删除

因为业务需求问题，在删除数据时不直接从数据库直接将数据删除，而是通过更改字段 isDelete 来进行逻辑删除，在前面设计时以及将逻辑删除字段添加了 @TableLogic 注解，当查询到逻辑删除的数据时，查询为空。

mybatis-plus 参考文档[逻辑删除 | MyBatis-Plus (baomidou.com)](https://baomidou.com/pages/6b03c5/#常见问题)









## 代码优化

### 用户校验

仅适用于用户可信 



### 后端返回通用对象

目的：给对象补充一些信息，告诉前端这个请求在业务层面上是成功还是失败

前端已有的错误码：200、404、500、502、503

```
{
	”name“：”pb“
	
}

		↓

//成功
{
	“code”：0 //业务层面的状态码
	“data”：{
		“name“：”yupi“
	}，
	”message“：”ok“
}

//错误
{
	”code“：50001 //自己定义的业务状态码
	”data“：null
	”message“：”用户操作异常“ //自己定义的错误信息，可以详细也可以简单定义
}
```



设计

定义一个 BaseResponse 实体类继承序列化，定义三个对象 

```JAVA
/**
 * 通用返回类
 * @param <T>
 */
@Data
public class  BaseResponse<T> implements Serializable {

    private int code;

    private T data;

    private String message;

    private String description;

    public BaseResponse(int code, T data, String message,String description) {
        this.code = code;
        this.data = data;
        this.message = message;
        this.description = description;
    }

    public BaseResponse(int code, T data) {
        this.code = code;
        this.data = data;
        this.message = "";
    }

    public BaseResponse(ErrorCode errorCode){
        this(errorCode.getCode(), null,
                errorCode.getMessage(),errorCode.getDescription());
    }
}

//data 类型使用泛型，提高对象的泛用性
```

新建一个工具类 ResultUtils 帮助返回成功失败的结果

```java
public class ResultUtils {

    public static <T> BaseResponse<T> success(T data){
        return new BaseResponse<>(0,data,"ok","");
    }

    public static BaseResponse error(ErrorCode errorCode){
        return new BaseResponse<>(errorCode.getCode(),null, errorCode.getMessage(), errorCode.getDescription());
    }
}
```

调用

`````java
return ResultUtils.success(loginUser);
`````

IDEA快捷键设置，在 Live Templates 中可以更改快捷输入，例如 sout  等。

代码允许时错误原因各不相同，所以需要进行通用的错误码设计

 创建一个枚举，用来设计通用的错误码规范

```java
public enum ErroeCode {

    SUCCESS(0,"OK",""),
    PARAMS_ERROR(40000,"请求参数错误",""),
    NULL_ERROR(40001,"请求数据为空",""),
    NOT_LOGIN(40100,"未登录",""),
    NO_AUTH(40101,"无权限","");


    /**
     * 状态码
     */
    private int code;
    /**
     * 状态码信息
     */
    private final String message;
    /**
     * 状态码描述
     */
    private final String description;

    ErroeCode(int code, String message, String description) {
        this.code = code;
        this.message = message;
        this.description = description;
    }
}
```

调用

```java
return ResultUtils.error(ErrorCode.PARAMS_ERROR);
```





### 全局异常处理

#### 后端

1. 创建一个全局异常处理类 BusinessException 继承 运行时异常 RuntimeException，相对于java的异常类，支持更多字段，自定义构造函数，更灵活快捷设置字段。

```java
/**
 * 自定义异常类
 */
@Data
public class BusinessException extends RuntimeException{

    private int code;

    private final String description;

    public BusinessException(String message, int code, String description) {
        super(message);
        this.code = code;
        this.description = description;
    }

    public BusinessException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.code = errorCode.getCode();
        this.description = errorCode.getDescription();
    }

}
```

调用

```java
throw new BusinessException(ErrorCode.PARAMS_ERROR,"参数为空");
```

作用

1. 捕获代码中所有的异常，内部消化，让前端得到更详细的报错/信息
2. 同时屏蔽掉项目框架本身的异常（不暴露服务器内部状态）
3. 集中处理，比如记录日志



2. 定义全局处理器

```java
//spring 的AOP,在调用方法前后进行额外的处理

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class) //方法只捕获参数内的异常
    public BaseResponse businessExceptionHandler(BusinessException e){
        log.error("businessException: "+ e.getMessage(),e);  //集中记录日志
        return ResultUtils.error(e.getCode(),e.getMessage(),"");
    }

    @ExceptionHandler(RuntimeException.class)
    public BaseResponse runtimeExceptionHandler(RuntimeException r){
        log.error("runtimeException: ",r);  //集中记录日志
        return ResultUtils.error(ErrorCode.SYSTEM_ERROR,r.getMessage(),"");
    }
}


```



#### 前端接收异常处理

1. 对接后端的返回值，接收 data

前端同样定义通用返回值

```js
 //对接后端通用返回类
  type BaseResponse<T> = {
    code:number,
    data:T,
    message:string,
    description:string
  }
```

将前端注册方法的返回值同样用这个通用返回嵌套起来。其他方法返回值同样需要嵌套。

全局响应处理：参考文档

​		[在Ant Design Pro中Umi-request全局请求响应的处理_umi request 允许修改响应数据-CSDN博客](https://blog.csdn.net/huantai3334/article/details/116780020)

​		1.应用场景：我们需要对接口的通用响应进行统一处理，比如从response中取出data，或者根据code去集中处理错误，比如用户未登录、没权限之类的。

​		2.优势：不用每个接口请求中都去写相同的逻辑。

​		3.实现：参考使用的请求封装工具，找官方文档，比如umi-request。创建一个新的文件，在该文件中配置一个全局请求类，在发送请求时，使用我们自己的定义的全局请求类。

```java
/**
 * request 网络请求工具
 * 更详细的 api 文档: https://github.com/umijs/umi-request
 */
import {extend} from 'umi-request';
import { message } from 'antd';
import { stringify } from 'querystring';


 
/**
 * 配置request请求时的默认参数
 */
const request = extend({
  credentials: 'include', // 默认请求是否带上cookie
  // requestType: 'form',
});
 
/**
 * 所以请求拦截器
 */
request.interceptors.request.use((url, options): any => {
  console.log('do request url =${url}');
  return {
    url,
    options: {
      ...options,
      headers: {},
    },
  };
});
 
/**
 * 所有响应拦截器
 */
request.interceptors.response.use(async (response, options): Promise<any> => {
 
  const res = await response.clone().json();
  if(res.code === 0){
    return res.data;
  }
  if (res.code === 40100) {
    message.error('请先登录');
    history.replace({
      pathname: '/user/login',
      search: stringify({
        redirect: location.pathname,
      }),
    });
  } else {
    message.error(res.description);
  }
  
  return response;
});
 
export default request;
```

**定义一个新的 request 之后，需要将 api.tsx 文件中的 request 依赖改成自己定义的，而不是依赖于 umi 中** 否则定义的全局响应拦截器无法被使用

```java
//将
import { request } from '@umijs/max';

//改为
import  request  from '@/plugins/globalRequest'

```





## 本地部署

### 多环境

参考文章 [多环境设计_程序员鱼皮-多环境设计-CSDN博客](https://blog.csdn.net/weixin_41701290/article/details/120173283)

​	本地开发： localhost（127.0.0.1）

​	指：同一套项目代码在不同阶段部署到不同的机器，并且根据实际调整配置

​	为什么需要？

​		1.每个环境互不影响，不影响其他阶段的测试和使用

​		2.为了区分不同的阶段：开发 / 测试 / 生产

​		3.对项目进行优化 

​			1.本地日志级别

​			2.精简依赖，节省项目体积

​			3.项目的环境/参数可以调整，比如JVM参数

针对不同的环境做不同的事情



多环境分类：

​	1.本地环境  自己的电脑，localhost

​	2.开发环境  远程开发， 连同一台机器，为了大家卡法方便

​	3.测试环境 （测试） 开发/测试/产品，性能测试 / 功能测试 / 系统集成测试，独立的数据库、独立的服务器

​	4.预发布环境 （体验服） 和正式环境一致，正式数据库，更严谨

​	5.正式环境 （线上，公开对外访问的项目） ： 尽量不要改动

​	6.沙箱环境（实验环境）：为了做实验



### 前端的多环境

- 请求地址

  - 开发环境：localhost:8080
  - 线上环境：自定义域名，需要备案

  ```js
  //让前端识别现在本地环境还是线上环境
  startFront(env){
      if(env === 'prod'){
          //不输出注释
          //项目优化
          //修改请求地址
      }else{
          //保持本地
      }
  }
  ```

  本项目使用了 umi 框架， build 时会自动传入 NODE_ENV == production 参数， start NODE_ENV 参数为 development

  ```js
  //app.tsx
  const isDev = process.env.NODE_ENV === 'development';
  //通过 process.env 拿到参数来判断本地还是线上
  ```

- 启动方式

  - 开发环境：npm run start（本地启动，监听端口，自动更新）
  - 线上开发：npm run build （项目构建打包，可以使用serve 进行调试）serve 是一个工具，使用 npm i -g serve 安装

  ```js
  //构建之后的服务器需要连接线上的后端，在全局处理器中定义一个 prefix 指定请求前缀
  /**
   * 配置request请求时的默认参数
   */
  const request = extend({
    credentials: 'include', // 默认请求是否带上cookie
    prefix:process.env.NODE_ENV === 'production' ? 'http://user-front.code.cn' : undefined
    // requestType: 'form',
  });
  ```

- 项目配置

  不同的项目（框架）都有不同的配置文件

  不同的配置文件添加对应的后缀名来区分不同环境的配置文件

  - 开发环境：config.dev.ts
  - 生产环境：config.prod.ts 参考 umi 官方文档的 部署
  - 公共配置：config.ts

  exportStatic 页面静态化，开启的情况下打包每个页面都会生成index.html


### 后端多环境

将后端配置文件重构一个 application-prod.yml 配置文件来区分线上环境

原本的配置文件可以将公共配置全部写在里面，而线上环境配置可以只编写数据库等线上所需要的配置 

构建打包项目之后在本地启动项目 jar 包文件

```java
java -jar .\<要启动的 jar 包名称> --spring.profiles.active=prod
//可以在启动的时候传入环境变量
java -jar .\user-center-backend-0.0.1-SNAPSHOT.jar spring.profiles.active=prod
```

主要是改依赖的环境地址：

​	数据库地址

​	缓存地址

​	消息队列地址

​	项目端口号



**// TODO**

前后端部署后调试过程中出现数据库连接的仍然是本地数据库，因为没有创建线上数据库，所以不知原因，没有验证是否为因为没有线上数据库，自动连接了本地数据库，或许原因是 prod 文件中数据库地址配置没有更改，仍然是本地数据库，后期设置线上数据库后待验证。

## 部署上线

- 原始前端 / 后端项目
- 宝塔 Linux
- 容器
- 容器平台



### 从零开始部署服务器

参考文章 [如何部署网站？来比比谁的方法多 - 哔哩哔哩 (bilibili.com)](https://www.bilibili.com/read/cv16179200/?spm_id_from=333.999.0.0)

需要 Linux 服务器 （建议使用 Cent 8+ / 7.6 以上）

#### 原始部署（繁琐）

什么都自己装

##### 前端

需要 web 服务器 ： nginx 、apache 、tomcat

安装 nginx 服务器：

 1.  用系统自带的软件包管理器快速安装，如centos 的 yum

 2.  自己在官网安装

     ​		参考文章[Nginx三种安装方式 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/425790769)

     ​		注意权限

### Docker 部署

docker 是容器，可以将项目的环境（java，nginx）和项目的代码一起打包成镜像，所有同学都可以下载镜像，更容易分发和移植。

再启动项目时，不需要敲一大堆命令，而是直接下载镜像、启动镜像。  类似安装包。

步骤

1. 在宝塔安装 Docker

2. dockerfile 用于指定构建 Docker 镜像的方法，一般情况下不需要完全从 0 自己写，建议参考同类项目（spingboot等），可以在github、gitee查找。

   ```java
   //后端 dockerfile
   
   FROM maven:3.5-jdk-8-alpine as builder   //docker 镜像依赖于基础镜像,
   
   # Copy local code to the container image.
   WORKDIR /app   //指定工作目录
   COPY pom.xml .	//把本地代码复制到容器
   COPY src ./src	//源码目录复制到新的src
   
   # Build a release artifact
   RUN mvn package -DskipTests   //执行maven打包命令
   
   # Run the web service on container startup.
   CMD ["java","-jar","/app/target/user-center-backend-0.0.1-SNAPSHOT.jar","--spring.profiles.active=prod"]     //运行镜像时的命令
   //ENTRYPOINT（附加额外参数）指定运行容器时默认执行的命令
   
   ```

   ```java
   //前端 dockerfile
   FROM  nginx   	  //依赖镜像
   
   WORKDIR /user/share/nginx/html/  //工作目录
   USER root	//可不写，指定用户名
   
   
   //配置文件，将本地的复制到容器
   COPY ./docker/nginx.conf /etc/nginx/conf.d/default.conf
   
   COPY ./dist /user/share/nginx/thml/
   
   EXPOSE 80
   
   CMD [ "nginx", "-g", "daemon off;" ]	
   ```

   新建一个 docker 文件夹，在里面创建一个 nginx.conf

   ```java
   server{
       listen 80;
   
       #gzip config
       gzip on;
       gzip_min_length 1k;
       gzip_comp_level 9;
       gzip_types text/plain text/css text/javascript application/json application/javascript application/x-javascript application/xml;
       gzip_vary on;
       gzip_disable "MSIE [1-6]\.";
   
       root user/share/nginx/html;
       include /etc/nginx/mine.types;
   
       location / {
           try_files $uri /index.html;   //用户找不到文件就降一级重定向
       }
   }
   ```

   

3. 制作镜像

   1. 根据 Dockerfile 构建镜像命令：前端同理

   ```java
   sodu docker build -t user-center-backend:v0.0.1 .
   ```

   Docker 构建优化：减少尺寸、减少构建时间（比如多阶段构建，可以丢弃之前阶段不需要的内容）

4. 启动

   docker run 启动 参考菜鸟教程网站

   ```java
   docker run -p 80:80 -v /data:/data -d nginx:latest
   ```

   虚拟化

   	1. 端口映射：把本机的资源和容器内部的资源进行关联
   	1. 目录映射：把本机的端口和容器应用的端口进行关联



### 前端部署方式

前端腾讯云 web 应用托管（比容器化更傻瓜式，不需要自己写构建应用的命令，就能启动前端项目）

需要将代码放到代码托管平台上

优势：不用写命令、代码更新时自动构建

### Docker 平台

1. 云服务商的容器平台（腾讯云、阿里云）
2. 面向某个领域的容器平台（前端webify、后端微信云托管）**付费**

> [微信云托管 (qq.com)](https://cloud.weixin.qq.com/cloudrun/)

容器平台的好处：

1. 不用输命令来操作，更方便省事
2. 不用在控制台操作，更傻瓜式、更简单
3. 大厂运维，比自己运维更省心
4. 额外的能力，比如监控、告警、其他（存储、负载均衡、自动扩展容、流水线）



## 绑定域名

用户输入网址 => 域名解析服务器（把网址解析为 ip 地址 / 交给其他的域名解析服务）=>

nginx 接收请求，找到对应的文件，返回文件给前端 => 前端加载文件到浏览器（js、css）=> 渲染页面

后端项目访问：用户输入网址 => 域名解析服务器 =>（ 宝塔 防护墙，需要添加域名） 服务器 => nginx 接收请求 => 后端项目（比如 8080 端口）

经典面试题：用户在浏览器输入请求之后发生什么。

## 跨域问题解决

浏览器为了用户的安全，仅允许向 **同域名、同端口** 的服务器发送请求。

如何解决跨域？

为了检测跨域，浏览器会在发送正式请求之前发送一个预检请求。请求方式 **OPTIONS** ，用于检查是否跨域。

1. 把域名、端口改成相同的

让服务器告诉浏览器：允许跨域（返回 cross-orgin-allow 响应头）

2. 网关支持（Nginx）

   将反向代理关闭，在宝塔的站点配置文件中添加

   ```java
   #跨域配置
   location ^~ /api/ {
       proxy_pass http://127.0.0.1.8080/api/;   #反向代理配置
       add_header 'Access-Control-Allow-Origin' $http_origin; #预检查请求也需要这行
       add_header 'Access-Control-Allow-Credentials' 'true';
       add_header Access-Control-Allow-Methods 'GET, POST OPTIONS';
       add_header Access-Control-Allow-Headers '*';
   	if($request_method = 'OPTIONS'){
           add_header 'Access-Control-Allow-Credentials' 'true';
           add_header 'Access-Control-Allow-Origin' $http_origin;
           add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
           add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
           add_header 'Access-Control-Max-Age' 1728000;
           add_header 'Content-Type' 'text/plain; charset=utf-8';
           add_header 'Content-Length' 0;
           return 204;
       }
   }
   ```

3. 修改后端服务

   1. 配置 @CrossOrigin 注解

      在controller文件加注解 

      ```java
      @CrossOringin(origins = {允许跨域的地址}, methods = {可以跨域的请求方式}, allowCredentials = "true")
      ```

      

   2. 添加 web 全局请求拦截器 
   
      > [SpringBoot设置Cors跨域的四种方式 - 简书 (jianshu.com)](https://www.jianshu.com/p/b02099a435bd)
   
      ``` java
      //新建config目录，新建在该目录下
      @Configuration
      public class WebMvcConfg implements WebMvcConfigurer {
       
          @Override
          public void addCorsMappings(CorsRegistry registry) {
              //设置允许跨域的路径
              registry.addMapping("/**")
                      //设置允许跨域请求的域名
                      //当**Credentials为true时，**Origin不能为星号，需为具体的ip地址【如果接口不带cookie,ip无需设成具体ip】
                      .allowedOrigins("http://localhost:9527", "http://127.0.0.1:9527", "http://127.0.0.1:8082", "http://127.0.0.1:8083")
                      //是否允许证书 不再默认开启
                      .allowCredentials(true)
                      //设置允许的方法
                      .allowedMethods("*")
                      //跨域允许时间
                      .maxAge(3600);
          }
      }
      ```
   
   3. 定义新的 corsFilter Bean



## 项目优化点

1. 功能扩展
   1. 管理员创建用户、修改用户信息、删除用户
   2. 上传头像
   3. 按照更多条件查询
   4. 更改权限
2. 修改 Bug
3. 项目登录改为分布式 session（单点登录 - redis）
4. 通用性
   1. set-cookie domain 域名更通用，比如改为 *.xxx.com
   2. 把用户管理系统升级为用户中心（之后所有服务器都请求这个后端）
5. 后台添加全局请求拦截器 （统一去判断用户权限，统一记录请求日志）

# 过程中问题汇总

## 1.nodejs 18版本问题

使用nvm进行nodejs版本管理

详细步骤：[window下安装并使用nvm（含卸载node、卸载nvm、全局安装npm）_window安装nvm-CSDN博客](https://blog.csdn.net/HuangsTing/article/details/113857145)

## 2.mybatis-plus 自动将下划线转成驼峰

解决方法，通过配置将驼峰映射关闭。

```
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: false
```

## 3.在使用mybatis-plus自动生成xml文件时id报错

常见错误

```
<statement> or DELIMITER expected, got 'id'
```

![img](https://img-blog.csdnimg.cn/20190830165731943.png)

## 4.前端代理接口设计的时候，出现错误

```java
java.lang.IllegalArgumentException: Invalid character found in method name [0x160x030x010x01f0x010x000x01b0x030x030x7f0x10v0xc40xa00xf9<0x160xce0xa50x96^0x810xf7/0x0a#0x8fI0xf10xb70x8e0x01#0x9d0xd0|0xfc0xb50xfe0xd20x18 ]. HTTP method names must be tokens
	at org.apache.coyote.http11.Http11InputBuffer.parseRequestLine(Http11InputBuffer.java:419) ~[tomcat-embed-core-9.0.68.jar:9.0.68]
	at org.apache.coyote.http11.Http11Processor.service(Http11Processor.java:271) ~[tomcat-embed-core-9.0.68.jar:9.0.68]
	at org.apache.coyote.AbstractProcessorLight.process(AbstractProcessorLight.java:65) ~[tomcat-embed-core-9.0.68.jar:9.0.68]
	at org.apache.coyote.AbstractProtocol$ConnectionHandler.process(AbstractProtocol.java:893) ~[tomcat-embed-core-9.0.68.jar:9.0.68]
	at org.apache.tomcat.util.net.NioEndpoint$SocketProcessor.doRun(NioEndpoint.java:1789) ~[tomcat-embed-core-9.0.68.jar:9.0.68]
	at org.apache.tomcat.util.net.SocketProcessorBase.run(SocketProcessorBase.java:49) ~[tomcat-embed-core-9.0.68.jar:9.0.68]
	at org.apache.tomcat.util.threads.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1191) ~[tomcat-embed-core-9.0.68.jar:9.0.68]
	at org.apache.tomcat.util.threads.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:659) ~[tomcat-embed-core-9.0.68.jar:9.0.68]
	at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61) ~[tomcat-embed-core-9.0.68.jar:9.0.68]
	at java.base/java.lang.Thread.run(Thread.java:829) ~[na:na]
```



```
主要问题：java.lang.IllegalArgumentException: Invalid character found in method name 。HTTP method names must be tokens
```

意思使http请求中包含了非法字符，将https改为http即可。

[SpringBoot项目报错Invalid character found in method name. HTTP method names must be tokens解决办法_springboot http method names must be tokens-CSDN博客](https://blog.csdn.net/DengShangYu_/article/details/102460211)

## 5.出现XXX不饿能用作JSX组件

ts版本原因，在vscode右下角 {} 进行切换版本即可。

## 6.serve安装时出现无法加载文件错误

参考文档：[serve : 无法加载文件 F:\nodejs\node_global\serve.ps1，因为在此系统上禁止运行脚本。_serve : 无法加载文件 d:\program files\nodejs\node_global-CSDN博客](https://blog.csdn.net/sinat_37883343/article/details/124415158)

解决方法

```
Set-ExecutionPolicy -Scope CurrentUser
提供参数值：RemoteSigned
```

##  7.前端初始化时安装依赖使用yarn出现报错

```java
#此问题出现原因是开了代理服务器访问。在终端输入一下命令即可
yarn config set "strict-ssl" false -g
再重新进行安装
```



## 8.TS报错 "umi" 没有导出的成员” XXX ”

主要是 ts 对 umi 的识别问题 参考文档[TS 报错 “umi“没有导出的成员‘xxx‘_模块“"@umijs/max"”没有导出的成员-CSDN博客](https://blog.csdn.net/zlzbt/article/details/121075874)

1. 找到tsconfig.json文件查看引入的umi路径配置对不对

```
"paths": {
      "@/*": ["./src/*"],
      "@@/*": ["./src/.umi/*"]
    }

```

2. 如果配置没问题，重启 ts 服务即可

快捷键 Ctrl + Shift + p 输入

```
restart TS Server
```



## 9.后端代码在用 maven-lifecycle-package 进行 打包 jar 包后，运行报没有主清单属性

检查 pom.xml 文件中的 maven 的 build 配置，检查 版本是否和 spring boot 一致，用IDEA生成的maven项目自带的配置文件中有一项导致跳过了项目的 main属性

```java
<build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                    <encoding>UTF-8</encoding>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>2.6.13</version>
                <configuration>
                    <mainClass>com.pb.usercenterbackend.UserCenterBackendApplication</mainClass>
    //这一属性，IDEA 生成的项目中默认为 true，导致了打包之后，运行报 没有主清单属性，将该配置改为false 或者直接删除即可正常生成主清单属性
                    <skip>false</skip>   
                </configuration>
                <executions>
                    <execution>
                        <id>repackage</id>
                        <goals>
                            <goal>repackage</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
```

打包之后在资源管理器中用压缩包的方式打开 jar 包，找到其中 MANIFEST.MF 文件使用记事本打开，可以看见文件中将 main 属性添加在内。若将上述配置设置为 true，则会导致不自动生成主清单属性。

# 补充知识

1. restful 风格接口  参考文档[一文搞懂什么是RESTful API - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/334809573)

​	restful 风格接口，具有结构清晰，符合标准，易于理解，扩展方便等特点 restful 是一种软件架构风格，该风格的主要特征是**以资源为基础**，比如图片，音乐，或者一个HTML格式，一个JSON格式的实体，通过**统一接口** 对资源的操作包括增删改查等，对应HTTP协议提供的POST , PUT , GET , DELETE 方法。

2. 继承序列化接口 Serializable

什么是serializable 接口 ：一个对象序列化的接口，一个类只有实现了 serializable 接口，他的对象才能被序列化

什么是序列化：序列化是将对象状态转换为可保持或传输的格式的过程。与序列化相对的是反序列化，他将流转换成为对象。这两个过程结合起来，可以轻松存储和传输数据。

[实体类 实现 Serializable到底有什么用呢？每个实体类基本上都要实现这个Serializable接口_实体类实现serializable的作用-CSDN博客](https://blog.csdn.net/qq_40036754/article/details/100886917)

