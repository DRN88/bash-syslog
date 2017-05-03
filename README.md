### bash-syslog

Based on: http://blog.hellosa.org/2013/07/27/log-bash-history-to-syslog-on-centos-6.html  

### How To

Edit the script variables to your needs.  

#### Edit '/etc/rsyslog.conf' to test

Add the following line:  
```
local1.debug                                            /var/log/secure
```
