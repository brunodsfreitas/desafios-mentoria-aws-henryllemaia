FROM alpine:latest

RUN apt update
RUN apk add openssh
RUN rc-update add sshd
RUN echo "ansible:ansible" | chpasswd


CMD ["tail -f /dev/null"]
