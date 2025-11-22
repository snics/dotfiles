#!/usr/bin/env bash

echo -e "Install asdf plugins..."

asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin add deno https://github.com/asdf-community/asdf-deno.git
asdf plugin add rust https://github.com/asdf-community/asdf-rust.git
asdf plugin add python https://github.com/danhper/asdf-python.git
asdf plugin add kubectl https://github.com/asdf-community/asdf-kubectl.git
asdf plugin-add helm https://github.com/virtualstaticvoid/asdf-helm.git

echo -e "Install asdf plugins done!"
