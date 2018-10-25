FROM mhart/alpine-node:10.11.0

RUN apk update -f \
    && apk --no-cache add -f \
    openssl \
    coreutils \
    curl \
    socat \
    && rm -rf /var/cache/apk/*

ENV LE_CONFIG_HOME /acme.sh

ENV AUTO_UPGRADE 1

ADD ./ /install_acme.sh/
RUN cd /install_acme.sh && ([ -f /install_acme.sh/acme.sh ] && /install_acme.sh/acme.sh --install || curl https://get.acme.sh | sh) && rm -rf /install_acme.sh/

RUN ln -s  /root/.acme.sh/acme.sh  /usr/local/bin/acme.sh && crontab -l | grep acme.sh | sed 's#> /dev/null##' | crontab -

RUN for verb in help \ 
    version \
    install \
    uninstall \
    upgrade \
    issue \
    signcsr \
    deploy \
    install-cert \
    renew \
    renew-all \
    revoke \
    remove \
    list \
    showcsr \
    install-cronjob \
    uninstall-cronjob \
    cron \
    toPkcs \
    toPkcs8 \
    update-account \
    register-account \
    create-account-key \
    create-domain-key \
    createCSR \
    deactivate \
    deactivate-account \
    ; do \
    printf -- "%b" "#!/usr/bin/env sh\n/root/.acme.sh/acme.sh --${verb} --config-home /acme.sh \"\$@\"" >/usr/local/bin/--${verb} && chmod +x /usr/local/bin/--${verb} \
    ; done


RUN mkdir -p /var/www/chal
RUN mkdir -p /var/www/acme
WORKDIR /var/www/acme

COPY package.json .
ENV NODE_ENV production
ENV NPM_CONFIG_LOGLEVEL warn
RUN npm install --production
COPY . .

CMD ["npm", "start"]

EXPOSE 80