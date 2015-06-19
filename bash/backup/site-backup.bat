@@echo off

date /t > F://sql_upload//time.txt
set /p date=< F://sql_upload//time.txt
set "prefix=%date:~0,4%%date:~5,2%%date:~8,2%"

set errorlevel=0

set path_home_mysql=E:\\xampp\\mysql

set path_home=F:\\sql_upload

set path_bin_mysql="E:\\xampp\\mysql\\bin\\"

set path_7zip="C:\\Program Files\\7-Zip\\7z.exe"

set path_upload=F:\\sql_upload\\sqlbak

set path_upload4ftp=F:\sql_upload\sqlbak

echo start to backup...

md %path_upload%\\community

set database_address=192.168.161.225

set database_community=community
set database_bugtracker=bugtracker
set database_nfscenter=nfscenter
set database_rwwb=rwwb

set user_mysql=root

set password_mysql=ztb2012

set file_path="%path_upload%\\community"



%path_bin_mysql%mysqldump.exe -h%database_address% -u%user_mysql% -p%password_mysql% %database_community% > %file_path%\\%database_community%.sql

%path_bin_mysql%mysqldump.exe -h%database_address% -u%user_mysql% -p%password_mysql% %database_bugtracker% > %file_path%\\%database_bugtracker%.sql

%path_bin_mysql%mysqldump.exe -h%database_address% -u%user_mysql% -p%password_mysql% %database_nfscenter% > %file_path%\\%database_nfscenter%.sql

%path_bin_mysql%mysqldump.exe -h%database_address% -u%user_mysql% -p%password_mysql% %database_rwwb% > %file_path%\\%database_rwwb%.sql

%path_7zip% a %path_upload%\\community-%prefix%.sql.zip %file_path%\\%database_community%.sql %file_path%\\%database_bugtracker%.sql %file_path%\\%database_nfscenter%.sql %file_path%\\%database_rwwb%.sql

rmdir /s /Q %file_path%


set ftpfilename=%path_home%//autoftp.ini 
echo open 192.168.161.222>"%ftpfilename%"

echo fengkun>>"%ftpfilename%"
echo iscasztb>>"%ftpfilename%"
echo bin>>"%ftpfilename%"
echo put %path_upload4ftp%\community-%prefix%.sql.zip>>"%ftpfilename%" 
echo bye>>"%ftpfilename%"

ftp -s:%ftpfilename%

forfiles /p %path_upload4ftp% /m *.* /d -7 /c "cmd /c del @path"
echo end backup

