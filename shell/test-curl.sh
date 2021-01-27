#! /bin/bash
cat>curl-format.txt<<EOF
    time_namelookup:  %{time_namelookup}\n
       time_connect:  %{time_connect}\n
    time_appconnect:  %{time_appconnect}\n
      time_redirect:  %{time_redirect}\n
   time_pretransfer:  %{time_pretransfer}\n
 time_starttransfer:  %{time_starttransfer}\n
                    ----------\n
         time_total:  %{time_total}\n
#####################################################################\n
DNS 查询： %{time_namelookup}\n
TCP 连接时间：%{time_pretransfer} - %{time_namelookup}\n
服务器处理时间：%{time_starttransfer} - %{time_pretransfer}\n
内容传输时间：%{time_total} - %{time_starttransfer}\n
EOF

curl -w "@curl-format.txt" -o test-curl.log -s -L "$1"

rm -rf curl-format.txt
