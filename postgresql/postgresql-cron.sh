#!/bin/bash

su - postgres -s /bin/bash -c '/usr/local/bin/process-sqls.sh -vv /var/lib/postgresql-sql' >> /var/log/process-sqls.sh.log
