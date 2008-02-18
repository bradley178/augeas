# Note that aliases must be set (to NULL here), otherwise the tree
# is not syntactically correct and can not be saved
commands="
set /system/config/sshd/AcceptEnv/10000 FOO
save
"

refresh=true
diff["/etc/ssh/sshd_config"] = <<TXT
--- /etc/ssh/sshd_config
+++ /etc/ssh/sshd_config.augnew
@@ -93,7 +93,7 @@
 # Accept locale-related environment variables
 AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES 
 AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT 
-AcceptEnv LC_IDENTIFICATION LC_ALL
+AcceptEnv LC_IDENTIFICATION LC_ALL FOO
 #AllowTcpForwarding yes
 #GatewayPorts no
 #X11Forwarding no
TXT