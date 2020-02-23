# 前言
engine在起前台提供了一个可以写 query String的搜索框，直接搜索查找需要的数据，并且提供自动补全功能

# 分析


    SearchQuery
    
    SearchParameters
        String _searchPattern    前台传来的search string
        SearchType  _searchType     根据这个type 指定对应的DAO去run，因为每个dao中定义了不同的rowMapper对象
    
    initQueryData
    
    IAutoCompleter
        
        getCompletion
        validateWord
        validateCompletion
        changeCaseDisplay

    //两个子接口        
    
    IConditionFieldAutoCompleter
        
        validateFiledValue
        getDbFieldName
        getSortableDbField
        GetDbFieldType
        getFieldRelationshipAutoCompleter
        getFieldValueAutoCompleter
        buildFreeTextConditionSql
        getMatchingSyntax
        getWildcard
        buildConditionSql
        formatValue
    
    IConditionValueAutoCompleter
    
        convertFieldEnumValueToActualValue
        
        //主要包括
        BitValueAutoCompleter
        DateEnumValueAutoCompleter
        EnumNameAutoCompleter
        EnumValueAutoComleter
        NullableStringAutoCompleter
        OsValueAutoCompleter
    
    实现 IAutoCompleter 的父类  BaseAutoCompleter  
    
    QueryData
    
    ISyntaxChecker
    
    SyntaxChecker
    
        getCompletion
        analyzeSyntaxState
            IAutoCompleter curCrossRefObjAC;// 当前引用对象补全器
            IConditionFieldAutoCompleter curConditionFieldAC;// 当前条件字段补全器
            IAutoCompleter curConditionRelationAC;// 当前条件运算符补全器
            IConditionValueAutoCompleter curConditionValueAC;// 当前条件值补全器
            int curStartPos = 0;    //当前的游标的位置
            int curEndPos = 1;      //当前目标的最后一个位置
            String curCrossRefObj;// 当前引用对象名称
            String curConditionField;// 当前条件字段名称
        
            begin:
                SearchObjectAutoCompleter.validateWord
                SearchObjectAutoCompleter.validateCompletion
        
        generateQueryFromSyntaxContainer
        
        generateConditionStatment
        
        buildCustomizedRelation
        
        buildCustomizedValue
        
        buildCondition
    
    SyntaxContainer     //词法分析结果容器
    
    
    SyntaxObject
    
    SyntaxObjectType
        
        BEGIN(0),//开始
        SEARCH_OBJECT(1),//搜索对象
        COLON(2),//冒号
        CROSS_REF_OBJ(3),//关联对象
        DOT(4),//点号
        CONDITION_FIELD(5),//条件字段
        CONDITION_RELATION(6),//条件关系
        CONDITION_VALUE(7),//条件值
        OR(8),//或
        AND(9),//且
        SORTBY(10),//排序终止符
        SORT_FIELD(11),//排序字段
        SORT_DIRECTION(12),//排序方向
        PAGE(13),//分页终止符
        PAGE_VALUE(14),//页号
        END(15);//结束
    
    SyntaxError     //语法错误类
    
    ConditionData
    
    
    ValueValidationFunction
    
        validCharacters
        validDateTime
        validTimeSpan
        validInteger
        validDecimal
        validateDateEnumValueByValueAC
        validateFieldByValueAC