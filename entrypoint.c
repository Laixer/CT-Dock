/**
 * Copyright (C) 2017 Quenza Inc.
 * All Rights Reserved
 *
 * Content can not be copied and/or distributed without the express
 * permission of the author.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define FLAG_CRON	1<<1
#define FLAG_PGSQL	1<<2
#define FLAG_REDIS	1<<3
#define FLAG_HTTPD	1<<4
#define FLAG_WORKER	1<<5

static const char cron_config[] =
    "[program:cron]\n"
    "priority=2\n"
    "command=cron -f\n"
    "autorestart=true\n";

static const char redis_config[] =
    "[program:redis]\n"
    "priority=5\n"
    "command=redis-server /etc/redis/redis.conf\n"
    "stdout_logfile=/var/log/supervisor/redis.log\n"
    "stderr_logfile=/var/log/supervisor/redis.log\n"
    "autorestart=true\n";

static const char pgsql_config[] =
    "[program:postgresql]\n"
    "priority=3\n"
    "command=/usr/lib/postgresql/9.5/bin/postgres -D /var/lib/postgresql/9.5/main/ -c config_file=/etc/postgresql/9.5/main/postgresql.conf\n"
    "stdout_logfile=/var/log/supervisor/postgres.log\n"
    "stderr_logfile=/var/log/supervisor/postgres.log\n"
    "user=postgres\n"
    "autorestart=true\n";

static const char httpd_config[] =
    "[program:apache2]\n"
    "priority=10\n"
    "command=apache2ctl -DFOREGROUND\n"
    "stdout_logfile=/var/log/supervisor/apache2.log\n"
    "stderr_logfile=/var/log/supervisor/apache2.log\n"
    "autorestart=true\n";

static const char worker_config[] =
    "[program:laravel-worker]\n"
    "process_name=%(program_name)s_%(process_num)02d\n"
    "priority=8\n"
    "command=php /var/www/ct/artisan queue:work --sleep=3\n"
    "autostart=true\n"
    "autorestart=true\n"
    "user=eve\n"
    "numprocs=2\n"
    "redirect_stderr=true\n"
    "stdout_logfile=/var/log/supervisor/worker.log\n";

void start_services(int flag, const char *config) {
    char buffer[2048];

    if (flag & FLAG_CRON) {
        puts("Starting Cron");
        snprintf(buffer, 2048, "echo \"%s\" >> %s", cron_config, config);
        system(buffer);
    }
    if (flag & FLAG_PGSQL) {
        puts("Starting PostgreSQL");
        snprintf(buffer, 2048, "echo \"%s\" >> %s", pgsql_config, config);
        system(buffer);
    }
    if (flag & FLAG_REDIS) {
        puts("Starting Redis");
        snprintf(buffer, 2048, "echo \"%s\" >> %s", redis_config, config);
        system(buffer);
    }
    if (flag & FLAG_HTTPD) {
        puts("Starting Apache2");
        snprintf(buffer, 2048, "echo \"%s\" >> %s", httpd_config, config);
        system(buffer);
    }
    if (flag & FLAG_WORKER) {
        puts("Starting Worker");
        snprintf(buffer, 2048, "echo \"%s\" >> %s", worker_config, config);
        system(buffer);
    }
}

void usage(const char *progname) {
    printf("Docker entrypoint\n");
    printf(" Usage: %s [OPTION]\n\n", progname);
    printf("Options:\n");
    printf(" --cron      Enable Cron service\n");
    printf(" --pgsql     Enable PostgreSQL service\n");
    printf(" --redis     Enable Redis service\n");
    printf(" --httpd     Enable Apache2 service\n");
    printf(" --worker    Enable Queue worker\n");
}

int main(int argc, char *argv[], char *envp[]) {
    int serviceflag = 0;

    if (argc < 2) {
        usage(argv[0]);
        return 1;
    }

    const char *configfile = argv[1];

    int i;
    for (i = 1; i < argc; ++i) {
        if (strlen(argv[i]) < 3)
            continue;

        if (argv[i][0] != '-' && argv[i][1] != '-')
            continue;

        if (!strcmp(argv[i], "--cron")) {
            serviceflag |= FLAG_CRON;
        } else if (!strcmp(argv[i], "--pgsql")) {
            serviceflag |= FLAG_PGSQL;
        } else if (!strcmp(argv[i], "--redis")) {
            serviceflag |= FLAG_REDIS;
        } else if (!strcmp(argv[i], "--httpd")) {
            serviceflag |= FLAG_HTTPD;
        } else if (!strcmp(argv[i], "--worker")) {
            serviceflag |= FLAG_WORKER;
        } else {
            usage(argv[0]);
            return 1;
        }
    }

    char **env = NULL;
    for (env = envp; *env != 0; ++env) {
        if ((*env)[0] == 'E' && (*env)[1] == 'P' && (*env)[2] == '_') {
            if (!strcmp(*env, "EP_CRON=1")) {
                serviceflag |= FLAG_CRON;
            } else if (!strcmp(*env, "EP_PGSQL=1")) {
                serviceflag |= FLAG_PGSQL;
            } else if (!strcmp(*env, "EP_REDIS=1")) {
                serviceflag |= FLAG_REDIS;
            } else if (!strcmp(*env, "EP_HTTPD=1")) {
                serviceflag |= FLAG_HTTPD;
            } else if (!strcmp(*env, "EP_WORKER=1")) {
                serviceflag |= FLAG_WORKER;
            }
        }
    }

    if (serviceflag == 0)
        return 0;

    start_services(serviceflag, configfile);
    system("php artisan optimize");
    system("/usr/bin/supervisord -n -c /etc/supervisord.conf");
    return 0;
}
