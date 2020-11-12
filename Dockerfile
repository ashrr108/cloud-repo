FROM ubuntu:16.04
COPY gcloudinstances.sh /
COPY docker.sh /
COPY k8s.sh /
COPY k8s_worker.sh /
CMD ["/gcloudinstances.sh"]
