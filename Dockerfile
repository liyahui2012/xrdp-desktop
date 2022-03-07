FROM danielguerra/ubuntu-xrdp:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=zh_CN.UTF-8

# 基本设置
RUN sed -i 's/\w*.ubuntu.com/mirrors.ustc.edu.cn/' /etc/apt/sources.list && apt update -y && \
    apt install -y curl wget telnet iputils-ping traceroute zip unzip dialog firefox dnsutils fuse libfuse2 iproute2 \
        language-pack-zh-hans *wqy* fcitx-googlepinyin fcitx-sunpinyin && \
    apt autoremove -y && \
    echo "export LANG=zh_CN.UTF-8\nexport LANGUAGE=zh_CN.UTF-8" >> /etc/profile && \
    sed -i '/%sudo/s/ALL$/NOPASSWD: ALL/' /etc/sudoers && \
    sed -i '/^#\*.*core/s/#//' /etc/security/limits.conf && \
    sed -i 's/True/False/' /etc/xdg/user-dirs.conf && \
    sed -i 's#thinclient_drives#.xrdp/thinclient_drives#' /etc/xrdp/sesman.ini && \
    mkdir /etc/skel/Desktop /etc/skel/Downloads && \
    cp /usr/share/applications/firefox.desktop /etc/skel/Desktop/ && \
    chmod +x /etc/skel/Desktop/*.desktop

# 安装一些维护工具 & zsh
RUN apt install -y mysql-client mongo-tools redis-tools ansible openjdk-11-jdk zsh zsh-syntax-highlighting git && \
    git clone https://github.com/ohmyzsh/ohmyzsh.git /etc/skel/.oh-my-zsh
COPY skel/* /etc/skel/

# 增加杀死空闲用户的任务
COPY kill_inactive_users.py /usr/bin/
COPY supervisor.d/* /etc/supervisor/conf.d/

# chrome
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
        curl -s https://dl.google.com/linux/linux_signing_key.pub -o -| apt-key add - && \
        apt update -y && apt install -y google-chrome-stable && apt autoremove -y && \
        sed -i '/Exec/s/$/ --disable-dev-shm-usage/' /usr/share/applications/google-chrome.desktop && \
        cp /usr/share/applications/google-chrome.desktop /etc/skel/Desktop/ && \
    chmod +x /etc/skel/Desktop/*.desktop
# kafka
RUN curl "https://www.kafkatool.com/download2/offsetexplorer.sh" -o kafka-clients.sh && sh kafka-clients.sh -q && \
        rm -f kafka-clients.sh && cp /opt/offsetexplorer2/Offset\ Explorer\ 2.0.desktop /etc/skel/Desktop/ && \
    chmod +x /etc/skel/Desktop/*.desktop
# vscode
RUN curl "https://vscode.cdn.azure.cn/stable/899d46d82c4c95423fb7e10e68eba52050e30ba3/code_1.63.2-1639562499_amd64.deb?1" -o vscode.deb && dpkg -i vscode.deb && \
        rm -f vscode.deb && cp /usr/share/applications/code.desktop /etc/skel/Desktop/ && \
    chmod +x /etc/skel/Desktop/*.desktop
# dbeaver
RUN curl "https://dbeaver.io/debs/dbeaver-ce/dbeaver-ce_21.3.5_amd64.deb" -o dbeaver-ce.deb && dpkg -i dbeaver-ce.deb && \
        rm -f dbeaver-ce.deb && cp /usr/share/applications/dbeaver-ce.desktop /etc/skel/Desktop/ && \
    chmod +x /etc/skel/Desktop/*.desktop

COPY 初次使用说明.md /etc/skel/Desktop/
