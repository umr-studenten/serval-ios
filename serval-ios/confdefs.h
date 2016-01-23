// These were taken from the confdefs section of the config.log. This file might have to be regenerated in the future.
#define SERVALD_VERSION "iOS"
#define SERVALD_COPYRIGHT "Jonas Höchst"
#define LOCALSTATEDIR ""
#define SYSCONFDIR ""

#define __thread // ignores the presence of local thread variables, as they are not supported by apple-clang
                 // Attention: this is a DIRTY HACK!

//#define SERVAL_ETC_PATH sandboxPath("/Library/etc")
//#define SYSTEM_LOG_PATH sandboxPath("/Library/syslog")
//#define SERVAL_LOG_PATH sandboxPath("/Library/log")

#define IOS
#define INSTANCE_PATH sandboxPath("/Library")

//#define SERVAL_RUN_PATH SANDBOX_ROOT
//#define SYSTEM_LOG_PATH strcat(SANDBOX_ROOT, "/Library/syslog")
//#define SERVAL_LOG_PATH strcat(SANDBOX_ROOT, "/Library/log")
//#define SERVAL_CACHE_PATH strcat(SANDBOX_ROOT, "/Library/cache")
//#define SERVAL_TMP_PATH strcat(SANDBOX_ROOT, "/Library/tmp")
//#define RHIZOME_STORE_PATH strcat(SANDBOX_ROOT, "/Library/rhizome")

#define PACKAGE_NAME "servald"
#define PACKAGE_TARNAME "servald"
#define PACKAGE_VERSION "0.9"
#define PACKAGE_STRING "servald 0.9"
#define PACKAGE_BUGREPORT ""
#define PACKAGE_URL ""
#define STDC_HEADERS 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
#define HAVE_MEMORY_H 1
#define HAVE_STRINGS_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_STDINT_H 1
#define HAVE_UNISTD_H 1
#define HAVE_PTHREAD_PRIO_INHERIT 1
#define HAVE_PTHREAD 1
#define HAVE_MATH_H 1
#define HAVE_FLOAT_H 1
#define HAVE_LIBC 1
#define HAVE_GETPEEREID 1
#define HAVE_BCOPY 1
#define HAVE_BZERO 1
#define HAVE_BCMP 1
#define SIZEOF_OFF_T 8
#define HAVE_STDIO_H 1
#define HAVE_ERRNO_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRINGS_H 1
#define HAVE_UNISTD_H 1
#define HAVE_STRING_H 1
#define HAVE_ARPA_INET_H 1
#define HAVE_SYS_SOCKET_H 1
#define HAVE_SYS_MMAN_H 1
#define HAVE_SYS_TIME_H 1
#define HAVE_SYS_UCRED_H 1
#define HAVE_POLL_H 1
#define HAVE_NETDB_H 1
#define HAVE_NET_IF_H 1
#define HAVE_NETINET_IN_H 1
#define HAVE_IFADDRS_H 1
#define HAVE_SIGNAL_H 1
#define HAVE_SYS_FILIO_H 1
#define HAVE_SYS_SOCKIO_H 1
#define HAVE_SYS_SOCKET_H 1
#define HAVE_SINF 1
#define HAVE_COSF 1
#define HAVE_TANF 1
#define HAVE_ASINF 1
#define HAVE_ACOSF 1
#define HAVE_ATANF 1
#define HAVE_ATAN2F 1
#define HAVE_CEILF 1
#define HAVE_FLOORF 1
#define HAVE_POWF 1
#define HAVE_EXPF 1
#define HAVE_LOGF 1
#define HAVE_LOG10F 1
#define HAVE_STRLCPY 1
#define HAVE_LSEEK 1

