FROM opensuse/tumbleweed

# TODO: Uncomment this when done
# RUN zypper ref 
RUN zypper in -y gvim go1.18 nodejs yarn npm shadow git wget sudo tar gzip openssh tmux libpython3_10-1_0

# Setup ssh server
RUN ssh-keygen -A

# Setup tmux
RUN mkdir /run/tmux
RUN chmod 777 /run/tmux

#### Setup edgevpn
RUN wget https://github.com/mudler/edgevpn/releases/download/v0.19.0/edgevpn-v0.19.0-Linux-x86_64.tar.gz
RUN tar -xvf edgevpn*.tar.gz edgevpn
RUN mv edgevpn /usr/bin/edgevpn
RUN rm edgevpn*.tar.gz

# Setup user
RUN useradd -ms /bin/bash dev

# Setup sudo
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/dev
RUN groupadd wheel
RUN usermod -aG wheel dev

USER dev
WORKDIR /home/dev

COPY dotfiles/vimrc /home/dev/.vimrc

#### Setup vim

RUN mkdir /home/dev/.vim_tmp

# Install vundle
RUN git clone https://github.com/VundleVim/Vundle.vim.git /home/dev/.vim/bundle/Vundle.vim

# Install vim plugins 
RUN vim +PluginInstall +GoInstallBinaries +qall

# Finish coc installation:
RUN cd /home/dev/.vim/bundle/coc.nvim && yarn install

COPY entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# TODO: Start tmux and automatically connect new users to that as soon as they ssh
