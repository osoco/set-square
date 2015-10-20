#!/bin/bash

su - mysql -s /bin/bash -c '/usr/local/bin/process-sqls.sh -vv /var/lib/mysql-sql' >> /var/log/process-sqls.sh.log
