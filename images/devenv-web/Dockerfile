# syntax=docker/dockerfile:1
# ---------------------------------------------------------
# snics/devenv-web — Browser-accessible dev environment via ttyd
#
# Build:  docker build -f images/devenv-web/Dockerfile -t snics/devenv-web .
# Run:    docker run -it --rm -p 7681:7681 snics/devenv-web
# Open:   http://localhost:7681
# ---------------------------------------------------------
ARG DEVENV_TAG=latest

FROM snics/devenv:${DEVENV_TAG}

ARG TARGETARCH
ARG TTYD_VERSION=1.7.7

USER root

# Download ttyd binary (static, no archive — just a binary per arch)
RUN ARCH=$([ "${TARGETARCH}" = "arm64" ] && echo "aarch64" || echo "x86_64") \
    && curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${ARCH}" \
    -o /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd

USER dev

EXPOSE 7681

ENTRYPOINT ["ttyd", "-W", "-p", "7681", \
    "-t", "titleFixed=snics/devenv-web", \
    "-t", "fontSize=14"]
CMD ["tmux", "new-session", "-A", "-s", "main"]
