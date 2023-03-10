FROM opensuse/tumbleweed

# TODO: Uncomment this when done
RUN zypper ref
# kcrypt-challenger deps: openssl-devel
RUN zypper in -y gvim go1.18 nodejs yarn npm shadow git wget sudo tar gzip openssh tmux libpython3_10-1_0 openssl-devel tig fzf ripgrep docker

# Make docker work without sudo (because the groups don't work as expected for some reason)
RUN mv /usr/bin/docker /usr/bin/docker-original
RUN echo '#!/bin/bash' >> /usr/bin/docker
RUN echo 'sudo /usr/bin/docker-original $@' >> /usr/bin/docker
RUN chmod +x /usr/bin/docker

# Setup ssh server
RUN ssh-keygen -A
RUN echo "AuthorizedKeysFile	.ssh/authorized_keys" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
RUN echo "UsePAM yes" >> /etc/ssh/sshd_config
RUN echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config

# Setup tmux
RUN mkdir -p /run/tmux
RUN chmod 777 /run/tmux

#### Setup edgevpn
RUN wget https://github.com/mudler/edgevpn/releases/download/v0.19.0/edgevpn-v0.19.0-Linux-x86_64.tar.gz
RUN tar -xvf edgevpn*.tar.gz edgevpn
RUN mv edgevpn /usr/bin/edgevpn
RUN rm edgevpn*.tar.gz

### Setup earthly
RUN wget https://github.com/earthly/earthly/releases/latest/download/earthly-linux-amd64
RUN chmod +x earthly-linux-amd64
RUN mv earthly-linux-amd64 /usr/bin/earthly

### Setup kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x kubectl
RUN mv kubectl /usr/bin/kubectl

# Setup user
RUN useradd -ms /bin/bash dev

# Setup sudo
# Setup docker (in case this container runs in privileged mode)
# https://docs.docker.com/engine/install/linux-postinstall/
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/dev
RUN groupadd wheel
RUN usermod -aG wheel dev
RUN usermod -aG docker dev

USER dev
WORKDIR /home/dev

COPY --chown=dev dotfiles/vimrc /home/dev/.vimrc
COPY --chown=dev dotfiles/bashrc /home/dev/.bashrc
RUN chmod 644 /home/dev/.bashrc
# https://www.babushk.in/posts/renew-environment-tmux.html
COPY --chown=dev dotfiles/tmux.conf /home/dev/.tmux.conf
RUN mkdir -p /home/dev/.vim
COPY --chown=dev dotfiles/coc-settings.json /home/dev/.vim/coc-settings.json
COPY --chown=dev dotfiles/gitconfig /home/dev/.gitconfig

RUN earthly bootstrap --with-autocomplete

# Setup git-aware-prompt
RUN mkdir -p /home/dev/.bash
RUN cd /home/dev/.bash && git clone https://github.com/jimeh/git-aware-prompt.git

#### Setup vim

RUN mkdir -p /home/dev/.vim_tmp

# Install vundle
RUN git clone https://github.com/VundleVim/Vundle.vim.git /home/dev/.vim/bundle/Vundle.vim

# Install vim plugins 
RUN vim +PluginInstall +GoInstallBinaries +qall

# Install languageclient binary
RUN cd /home/dev/.vim/bundle/LanguageClient-neovim && bash install.sh

# Finish coc installation:
RUN cd /home/dev/.vim/bundle/coc.nvim && yarn install

COPY --chown=dev entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
