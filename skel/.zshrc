## Alias
alias kk=kubectl
alias kkns=kubens
alias kkenv=kubectx
alias kknode='kubectl get node -owide'

export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
DISABLE_AUTO_UPDATE="true"

source $ZSH/oh-my-zsh.sh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

plugins=(git zsh-syntax-highlighting)

which kubectl &>/dev/null && source <(kubectl completion zsh)
which helm &>/dev/null  && source <(helm completion zsh)
