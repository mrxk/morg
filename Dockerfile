FROM debian:12.0-slim as builder
RUN apt-get update
RUN apt install -y git
RUN cd /tmp && \
    git clone --depth 1 https://github.com/godlygeek/tabular.git && \
    git clone --depth 1 https://github.com/junegunn/fzf.git && \
    git clone --depth 1 https://github.com/junegunn/fzf.vim.git

FROM debian:12.0-slim
RUN apt-get update
RUN apt install -y vim fzf ripgrep
RUN apt install -y python3 python3-pygments python3-venv
RUN apt install -y doas
RUN apt install -y less

RUN python3 -m venv /usr/lib/rich
RUN /usr/lib/rich/bin/pip3 install rich
RUN echo "permit nopass morg as root" > /etc/doas.conf

COPY --from=builder /tmp/tabular /home/morg/.vim/pack/tabular/start/tabular
COPY --from=builder /tmp/fzf/plugin /home/morg/.vim/pack/fzf/start/fzf/plugin
COPY --from=builder /tmp/fzf.vim /home/morg/.vim/pack/fzf.vim/start/fzf.vim
COPY view.py /app/view.py
COPY morg.sh /app/morg.sh
COPY vimrc /home/morg/.vimrc

RUN adduser --disabled-password morg
RUN chown -R morg:morg /home/morg && \
    chown -R morg:morg /app
USER morg
ENV MORG_ROOT /morg
ENV PAGER less -RS

ENTRYPOINT ["/app/morg.sh"]
