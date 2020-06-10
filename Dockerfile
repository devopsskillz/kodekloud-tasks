FROM alpine:3.10

ENV ANSIBLE_VERSION=2.9.9 \
    ANSIBLE_DISPLAY_SKIPPED_HOSTS=false \
    ANSIBLE_GATHERING=explicit \
    ANSIBLE_HOST_KEY_CHECKING=false \
    ANSIBLE_INVENTORY=hosts \
    ANSIBLE_LIBRARY=/ansible/library \
    ANSIBLE_LOG_PATH=/log/tasks.log \
    ANSIBLE_PYTHON_INTERPRETER=auto_silent \
    ANSIBLE_REMOTE_TEMP=/tmp/.ansible/tmp \
    ANSIBLE_RETRY_FILES_ENABLED=false \
    ANSIBLE_ROLES_PATH=roles \
    ANSIBLE_SSH_PIPELINING=true \
    PATH=/ansible/bin:$PATH \
    PYTHONPATH=/ansible/lib

RUN set -euxo pipefail && \
    apk add --no-cache --update bash python3 ca-certificates openssh-client sshpass && \
    apk add --no-cache --update --virtual .build-deps python3-dev build-base libffi-dev openssl-dev && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    pip3 install --no-cache ansible==${ANSIBLE_VERSION} && \
    apk del --no-cache --purge .build-deps  && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    mkdir -p /etc/ansible /ansible /log && \
    echo -e "[control_node]\nlocalhost ansible_connection=local" >> /etc/ansible/hosts

COPY group_vars/ /ansible/group_vars/
COPY host_vars/ /ansible/host_vars/
COPY roles/ /ansible/roles/
COPY conf/hosts linux-user-noshell.yml /ansible/

WORKDIR /ansible

ENTRYPOINT ["ansible-playbook"]
