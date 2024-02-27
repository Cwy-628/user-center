create table if not exists paopao.user
(
    id           bigint auto_increment
    primary key,
    username     varchar(255)  null comment '昵称',
    avatarUrl    varchar(255)  null comment '头像',
    userAccount  varchar(255)  null comment '登录账号',
    gender       tinyint       null comment '性别',
    userPassword varchar(255)  not null comment '密码',
    phone        varchar(255)  null comment '手机号',
    email        varchar(255)  null comment '邮箱',
    userStatus   int           null comment '用户状态',
    createTime   datetime      null on update CURRENT_TIMESTAMP comment '创建时间',
    updateTime   datetime      null on update CURRENT_TIMESTAMP comment '修改时间',
    isDelete     tinyint       null comment '是否删除',
    userRole     int default 0 null comment '用户角色0-普通用户1-管理员2'
    );

