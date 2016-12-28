@echo off
echo Starting

REM remember current path
for /f %%i in ('cd') do set entry_path=%%i
REM path of this script
set this_path=%~d0%~p0

if [%1]==[] ( 
    echo You must pass installation path as first parameter
    exit /b
)
if [%2]==[] ( 
    echo Second parameter not given, using default port 80.
    set port_number=80
) else (
    set port_number=%2
)
if [%3]==[] ( 
    echo Third parameter not given, using fastcgi port 9123.
    set port_fastcgi_number=9123
    goto ask_to_continue
) else (
    set port_fastcgi_number=%3
    goto start
)

:ask_to_continue
echo Do you want to continue? (y/n)
set /p ans=
if %ans%== y goto start
exit /b


:start
set install_path_given=%1
set bugflux_dir=bugflux

set nginx=nginx
set nginx_ver=nginx-1.11.5
set database=database
set database_name=database
set php=php
set app=app
set composerphar=composer.phar
set hidden_console=HiddenConsole

set run_batch=run_batch
set shutdown_batch=shutdown_batch
set run_batch_dest_name=run_bugflux.bat
set shutdown_batch_dest_name=shutdown_bugflux.bat

REM if changing below don't forget to change also in run and shutdown scripts
set bugflux_vars_filename=bugflux_vars
set port_cgi_var=port_cgi
set port_bugflux_var=port_bugflux
set nginx_dirname_var=nginx_dirname

set readme_filename=README.txt

REM check if needed ps scripts and bugflux_app.zip exists
if not exist "%this_path%\bugflux_app.zip" ( 
    echo No bugflux_app.zip!
    goto back_and_exit
)
if not exist "%this_path%\download.ps1" ( 
    echo No download.ps1!
    goto back_and_exit
)
if not exist "%this_path%\replace.ps1" ( 
    echo No replace.ps1!
    goto back_and_exit
)
if not exist "%this_path%\unzip.ps1" ( 
    echo No unzip.ps1!
    goto back_and_exit
)

REM change dir and create dir for bugflux
echo Creating directory for Bugflux
if not exist "%install_path_given%" mkdir "%install_path_given%"
cd /D "%install_path_given%"
REM install_path is absolute path
for /f %%i in ('cd') do set install_path=%%i
if not exist %bugflux_dir% mkdir %bugflux_dir%


REM download needed (nginx, sqlite, php)

echo Downloading nginx
powershell.exe -file "%this_path%\download.ps1" -url https://nginx.org/download/%nginx_ver%.zip -path "%install_path%\%bugflux_dir%\%nginx%.zip"

echo Downloading php
powershell.exe -file "%this_path%\download.ps1" -url http://windows.php.net/downloads/releases/archives/php-7.0.12-Win32-VC14-x86.zip -path "%install_path%\%bugflux_dir%\%php%.zip"
powershell.exe -file "%this_path%\download.ps1" -url http://redmine.lighttpd.net/attachments/660/RunHiddenConsole.zip -path "%install_path%\%bugflux_dir%\%hidden_console%.zip"



REM check if downloaded files exists
if not exist "%install_path%\%bugflux_dir%\%nginx%.zip" (
    echo File "%install_path%\%bugflux_dir%\%nginx%.zip" does not exists
    goto back_and_exit
)

if not exist "%install_path%\%bugflux_dir%\%hidden_console%.zip" (
    echo File "%install_path%\%bugflux_dir%\%hidden_console%.zip" does not exists - you won't be able to run php-cgi and nginx automatically
    set hidden=false
)

if not exist "%install_path%\%bugflux_dir%\%php%.zip" (
    echo File "%install_path%\%bugflux_dir%\%php%.zip" does not exists
    goto back_and_exit
)

echo Downloaded all

cd %bugflux_dir%

echo Unzipping nginx
powershell.exe -file "%this_path%\unzip.ps1" -zipfile "%nginx%.zip" -outpath "%nginx%"

echo Unzipping php
powershell.exe -file "%this_path%\unzip.ps1" -zipfile "%php%.zip" -outpath "%php%"

if not defined hidden (
    powershell.exe -file "%this_path%\unzip.ps1" -zipfile "%hidden_console%.zip" -outpath "%php%"
)

echo Unzipped all


echo Configuring php

copy %php%\php.ini-production %php%\php.ini >NUL

powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find "; extension_dir = \"ext\"" -replace "extension_dir = \"ext\""
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";extension=php_curl.dll" -replace "extension=php_curl.dll"
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";extension=php_intl.dll" -replace "extension=php_intl.dll"
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";extension=php_fileinfo.dll" -replace "extension=php_fileinfo.dll"
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";extension=php_mbstring.dll" -replace extension=php_mbstring.dll"
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";extension=php_exif.dll" -replace "extension=php_exif.dll"
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";extension=php_mysqli.dll" -replace "extension=php_mysqli.dll"
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";extension=php_openssl.dll" -replace "extension=php_openssl.dll"
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";extension=php_pdo_mysql.dll" -replace "extension=php_pdo_mysql.dll"
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";extension=php_gd2.dll" -replace "extension=php_gd2.dll"
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";date.timezone =" -replace "date.timezone = \"UTC\""
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";extension=php_pdo_sqlite.dll" -replace "extension=php_pdo_sqlite.dll"
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";extension=php_sqlite3.dll" -replace "extension=php_sqlite3.dll"
powershell.exe -file "%this_path%\replace.ps1" -my_file "%php%\php.ini" -find ";cgi.fix_pathinfo=1" -replace "cgi.fix_pathinfo=0"


REM change PATH (environment variable)
set old_path=%PATH%
set PATH=%install_path%\%bugflux_dir%\%php%;%PATH%

echo Configuring nginx

move %nginx%\%nginx_ver%\conf\nginx.conf %nginx%\%nginx_ver%\conf\nginx.conf-backup >NUL
REM touch %nginx%\%nginx_ver%\conf\nginx.conf

(echo # configuration created by Bugflux setup)                     >>%nginx%\%nginx_ver%\conf\nginx.conf
echo. >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo worker_processes  1;)                                         >>%nginx%\%nginx_ver%\conf\nginx.conf
echo. >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo events {)                                                     >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo     worker_connections  1024;)                                >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo })                                                            >>%nginx%\%nginx_ver%\conf\nginx.conf
echo. >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo http {)                                                       >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo     keepalive_timeout  65;)                                   >>%nginx%\%nginx_ver%\conf\nginx.conf
echo. >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo     server {)                                                 >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo         listen       %port_number%;)                          >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo         server_name  bugflux;)                                >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo         root         %install_path%\%bugflux_dir%\%app%\public;)       >>%nginx%\%nginx_ver%\conf\nginx.conf
echo. >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo         location / {)                                         >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo             index  index.php index.html index.htm;)           >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo             try_files $uri $uri/ /index.php?$args;)           >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo             include mime.types;)                              >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo         })                                                    >>%nginx%\%nginx_ver%\conf\nginx.conf
echo. >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo         location ~ \.php$ {)                                  >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo             fastcgi_pass   127.0.0.1:%port_fastcgi_number%;)  >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo             fastcgi_index  index.php;)                        >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo             include        fastcgi.conf;)                     >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo         })                                                    >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo     })                                                        >>%nginx%\%nginx_ver%\conf\nginx.conf
(echo })                                                            >>%nginx%\%nginx_ver%\conf\nginx.conf



echo Unzipping bugflux_app
powershell.exe -file "%this_path%\unzip.ps1" -zipfile "%this_path%\bugflux_app.zip" -outpath "%app%"
cd %app%
echo Creating .env file
copy .env.example .env >NUL
powershell.exe -file "%this_path%\replace.ps1" -my_file ".env" -find "APP_URL=http://localhost" -replace "APP_URL=http://localhost:%port_number%"
echo Creating database
cd database
php -r "$database=new SQLite3('%database_name%.sqlite');"
cd ..
echo Downloading composer
powershell.exe -file "%this_path%\download.ps1" -url "https://getcomposer.org/download/1.2.1/composer.phar" -path "%composerphar%"
echo Downloading depedencies with composer
php %composerphar% install --prefer-dist --no-dev
echo Generating app key with composer
php artisan key:generate
echo Creating tables in database (migrating)
echo yes|php artisan migrate
echo Inserting initial data into database (seeding)
echo yes|php artisan db:seed

set PATH=%old_path%
cd ..
del "%nginx%.zip"
del "%php%.zip"

if not exist "%this_path%\%readme_filename%" (
    echo File "%readme_filename%" does not exist - we recommend you to download it and read before using Bugflux.
    goto back_and_exit
)

copy "%this_path%\%readme_filename%" %readme_filename% >NUL
echo.
echo The %readme_filename% file was copied to installation directory


if defined hidden (
    goto back_and_exit
)

del "%hidden_console%.zip"

if not exist "%this_path%\%run_batch%" (
    echo File "%run_batch%.zip" which is run script, does not exist - you will have to run and shutdown php-cgi and nginx manually
    goto back_and_exit
)
if not exist "%this_path%\%shutdown_batch%" (
    echo File "%shutdown_batch%.zip" which is shutdown script, does not exist - you will have to run and shutdown php-cgi and nginx manually
    goto back_and_exit
)

copy "%this_path%\%run_batch%" %run_batch_dest_name% >NUL
copy "%this_path%\%shutdown_batch%" %shutdown_batch_dest_name% >NUL

if exist %bugflux_vars_filename% del %bugflux_vars_filename%

(echo %port_cgi_var%=%port_fastcgi_number%)                     >>%bugflux_vars_filename%
(echo %port_bugflux_var%=%port_number%)                         >>%bugflux_vars_filename%
(echo %nginx_dirname_var%=%nginx_ver%)                          >>%bugflux_vars_filename%

echo.
echo You can use %run_batch_dest_name% and %shutdown_batch_dest_name% scripts in installation directory to run and shutdown php-cgi and nginx to use Bugflux


REM go back to directory where we started
:back_and_exit
    cd /D %entry_path%
    exit /b
