

DbFacade

    维护了两个表
    
    第一个是 businessentities Entity 到 Dao的映射mapEntityToDao，通过getDaoForEntity 根据entity来获取操作它的Dao。
    
    第二个是 通过cdi注入到Instance<Dao> daos的DaoImpl，在DbFacade的后半部分全部是 getXXXDao的访问方法，提供外部对注入进来的DaoImpl的访问。
    


DbFacadeLocator
    
    单例的定位器，用来会寻找和初始化DbFacade实例。


DbEngineDialect ，数据库引擎方言接口，处理所有db引擎特定的问题，比如 参数前缀，搜索参数
    

    JdbcTemplate createJdbcTemplate(DataSource dataSource);    

    SimpleJdbcCall createJdbcCallForQuery(JdbcTemplate jdbcTemplate);

    String getParamNamePrefix();

    String getFunctionReturnKey();

    String createSqlCallCommand(String procSchemaFromDB, String procNameFromDB, String params);



PostgresDbEngineDialect

SimpleJdbcCallsHandler

JdbcTemplate

BaseDao   所有impl 继承的父类

GenericDao

SearchDao

StatusAwareDao