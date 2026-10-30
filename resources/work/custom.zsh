# Work-only shell customizations: your own aliases and functions.
#
# This file lives outside the Nix repo (~/.config/zsh/work.zsh). Nix creates it
# once from this template and then never touches it again, so edit it freely.
# Every new interactive zsh sources it. Apply changes to the current terminal
# with `wreload`; open it with `wedit`.

# Open an RDP tunnel to a Windows host through AWS Session Manager.
#   ssm-rdp [instance-id] [remote-port] [local-port] [region]
# Then connect your RDP client to localhost:<local-port>.
ssm-rdp() {
  local target=${1:-i-03f2cc1d48678c742}
  local remote_port=${2:-3389}
  local local_port=${3:-13389}
  local region=${4:-us-east-2}
  aws ssm start-session \
    --region "$region" \
    --target "$target" \
    --document-name AWS-StartPortForwardingSession \
    --parameters "portNumber=${remote_port},localPortNumber=${local_port}"
}

# More examples:
# alias k8s-work='kubectl --context work'
# mything() { cd ~/Projects/mything && ./run.sh "$@"; }
