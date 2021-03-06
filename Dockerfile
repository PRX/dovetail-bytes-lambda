FROM public.ecr.aws/lambda/nodejs:14

MAINTAINER PRX <sysadmin@prx.org>
LABEL org.prx.lambda="true"

WORKDIR /app

ENTRYPOINT [ "yarn", "run" ]
CMD [ "test" ]

RUN yum install -yq zip && yum clean all && rm -rf /var/cache/yum
ADD yarn.lock ./
ADD package.json ./
RUN npm install --quiet --global yarn && yarn install
ADD . .
RUN yarn run build
