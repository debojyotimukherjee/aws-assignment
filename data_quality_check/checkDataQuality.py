"""
  Purpose: Class and Methods for Data Quality check
"""

###Class defined for data validation
class DataValidation:

    def __init__(self,*args):
        pass

    def validateInt(self,spark,df,columnName):
        df.createOrReplaceTempView("integerValidation")
        validateIntDf = spark.sql("select 1 from integerValidation where cast({columnName} as int) is NULL and {columnName} is NOT NULL".format(columnName=columnName))
        validateIntDf.show()
        if validateIntDf.count() > 0:
            return False
        else:
            return True

    def validateDate(self, spark, df, columnName,format):
        df.createOrReplaceTempView("dateValidation")
        validateDateDf = spark.sql("select 1 from dateValidation where {columnName} is NOT NULL \
                                    and unix_timestamp(trim({columnName}),'{format}') is NULL".\
                                    format(columnName=columnName,format=format))
        if validateDateDf.count() > 0:
            return False
        else:
            return True

    def validateNull(self,spark,df,columnName):
        df.createOrReplaceTempView("nullValidation")
        validateNullDf = spark.sql("select 1 from nullValidation where {columnName} is NULL".format(columnName=columnName))
        if validateNullDf.count() > 0:
            return False
        else:
            return True

    def validateDuplicate(self,spark,df,columnName):
        df.createOrReplaceTempView("duplicateValidation")
        validateDuplicateDf = spark.sql("select {columnName} from duplicateValidation group by {columnName} having count(*)>1".format(columnName=columnName))
        if validateDuplicateDf.count() > 0:
            return False
        else:
            return True

