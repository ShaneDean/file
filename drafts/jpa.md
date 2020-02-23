# 映射关系

```
    @JoinColumn(name = "外键名称" , referencedColumnName = "参照主表的字段名称")
    
```

## 级联操作

CascadeType

-   all         所有
-   merge       更新
-   persist     保存
-   remove      删除

