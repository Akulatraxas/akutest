#!/bin/bash

export PATH=$PATH:/var/pretalx/.local/bin

if [ "$1" == "run" ]; then
    cd /var/pretalx

    python3 -m pretalx migrate
    python3 -m pretalx rebuild

    gunicorn pretalx.wsgi --name pretalx --workers 4 --max-requests 1200  --max-requests-jitter 50 --log-level=info --bind=0.0.0.0:8088
elif [ "$1" == "init" ]; then
    python3 -m pretalx init
elif [ "$1" == "shell" ]; then
    python3 -m pretalx shell
elif [ "$1" == "upgrade" ]; then
    python3 -m pretalx rebuild
    python3 -m pretalx regenerate_css
elif [ "$1" == "celery" ] ; then
    cd /var/pretalx
    echo "Booting Celery worker!"
    sleep 5
    celery -A pretalx.celery_app worker -l info
else
    /bin/bash
fi
