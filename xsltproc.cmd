@ECHO OFF
SET XSLT_PROC_JAR=lib\saxonhe.jar
SET JAVA=C:\ProgramData\Oracle\Java\javapath\java.exe

IF NOT EXIST %JAVA% (
  ECHO "Java not found!"
  EXIT /b 1
)

IF NOT EXIST %XSLT_PROC_JAR% (
  ECHO "XSLT processor JAR %XSLT_PROC_JAR% not found!"
  EXIT /b 1
)
  
%JAVA% -jar "%XSLT_PROC_JAR%" %*

