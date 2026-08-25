# =============================================================================
# container.plugin.zsh
# Antidote-compatible container helpers for Zsh
# =============================================================================
#
# ~/.zsh_plugins.txt:
#
#   your-user/container.plugin.zsh
#
# Supports:
#   LXC / LXD
#   Docker
#   Podman
#
# =============================================================================

(( $+functions[container-help] )) && return 0

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

: ${CONTAINER_DEFAULT_RUNTIME:=auto}

# -----------------------------------------------------------------------------
# Colors
# -----------------------------------------------------------------------------

if [[ -t 1 ]]; then
    _CONTAINER_GREEN=$'\e[32m'
    _CONTAINER_YELLOW=$'\e[33m'
    _CONTAINER_RED=$'\e[31m'
    _CONTAINER_CYAN=$'\e[36m'
    _CONTAINER_RESET=$'\e[0m'
else
    _CONTAINER_GREEN=''
    _CONTAINER_YELLOW=''
    _CONTAINER_RED=''
    _CONTAINER_CYAN=''
    _CONTAINER_RESET=''
fi

# -----------------------------------------------------------------------------
# Runtime detection
# -----------------------------------------------------------------------------

function container-runtimes() {
    local runtime

    for runtime in lxc docker podman; do
        if (( $+commands[$runtime] )); then
            print "${_CONTAINER_GREEN}[ok]${_CONTAINER_RESET} $runtime"
        else
            print "${_CONTAINER_RED}[--]${_CONTAINER_RESET} $runtime"
        fi
    done
}

function container-runtime() {
    if [[ "$CONTAINER_DEFAULT_RUNTIME" != auto ]]; then
        command -v "$CONTAINER_DEFAULT_RUNTIME"
        return
    fi

    if (( $+commands[lxc] )); then
        print lxc
    elif (( $+commands[podman] )); then
        print podman
    elif (( $+commands[docker] )); then
        print docker
    else
        print "${_CONTAINER_RED}none${_CONTAINER_RESET}"
        return 1
    fi
}

# =============================================================================
# Generic container commands
# =============================================================================

function container-list() {
    case "$CONTAINER_DEFAULT_RUNTIME" in
        lxc)
            lxc list "$@"
            ;;
        docker)
            docker ps "$@"
            ;;
        podman)
            podman ps "$@"
            ;;
        *)
            if (( $+commands[lxc] )); then
                lxc list "$@"
            elif (( $+commands[podman] )); then
                podman ps "$@"
            elif (( $+commands[docker] )); then
                docker ps "$@"
            else
                print "${_CONTAINER_RED}[error]${_CONTAINER_RESET} no container runtime found"
                return 1
            fi
            ;;
    esac
}

function container-start() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-start <container>"
        return 1
    }

    if (( $+commands[lxc] )); then
        lxc start "$name"
    elif (( $+commands[podman] )); then
        podman start "$name"
    elif (( $+commands[docker] )); then
        docker start "$name"
    else
        print "${_CONTAINER_RED}[error]${_CONTAINER_RESET} no runtime found"
        return 1
    fi
}

function container-stop() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-stop <container>"
        return 1
    }

    if (( $+commands[lxc] )); then
        lxc stop "$name"
    elif (( $+commands[podman] )); then
        podman stop "$name"
    elif (( $+commands[docker] )); then
        docker stop "$name"
    else
        print "${_CONTAINER_RED}[error]${_CONTAINER_RESET} no runtime found"
        return 1
    fi
}

function container-restart() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-restart <container>"
        return 1
    }

    if (( $+commands[lxc] )); then
        lxc restart "$name"
    elif (( $+commands[podman] )); then
        podman restart "$name"
    elif (( $+commands[docker] )); then
        docker restart "$name"
    else
        print "${_CONTAINER_RED}[error]${_CONTAINER_RESET} no runtime found"
        return 1
    fi
}

# =============================================================================
# LXC / LXD
# =============================================================================

function container-lxc() {
    lxc "$@"
}

function container-lxc-list() {
    lxc list "$@"
}

function container-lxc-launch() {
    local image="$1"
    local name="$2"

    if [[ -z "$image" || -z "$name" ]]; then
        print "usage: container-lxc-launch <image> <name>"
        return 1
    fi

    lxc launch "$image" "$name"
}

function container-lxc-shell() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-lxc-shell <container>"
        return 1
    }

    lxc exec "$name" -- bash
}

function container-lxc-exec() {
    local name="$1"
    shift

    if [[ -z "$name" || $# -eq 0 ]]; then
        print "usage: container-lxc-exec <container> <command> [args...]"
        return 1
    fi

    lxc exec "$name" -- "$@"
}

function container-lxc-delete() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-lxc-delete <container>"
        return 1
    }

    lxc delete "$name"
}

# =============================================================================
# Docker
# =============================================================================

function container-docker() {
    docker "$@"
}

function container-docker-list() {
    docker ps "$@"
}

function container-docker-all() {
    docker ps -a "$@"
}

function container-docker-shell() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-docker-shell <container>"
        return 1
    }

    docker exec -it "$name" /bin/sh
}

function container-docker-bash() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-docker-bash <container>"
        return 1
    }

    docker exec -it "$name" /bin/bash
}

function container-docker-logs() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-docker-logs <container>"
        return 1
    }

    docker logs -f "$name"
}

# =============================================================================
# Podman
# =============================================================================

function container-podman() {
    podman "$@"
}

function container-podman-list() {
    podman ps "$@"
}

function container-podman-all() {
    podman ps -a "$@"
}

function container-podman-shell() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-podman-shell <container>"
        return 1
    }

    podman exec -it "$name" /bin/sh
}

function container-podman-bash() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-podman-bash <container>"
        return 1
    }

    podman exec -it "$name" /bin/bash
}

function container-podman-logs() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-podman-logs <container>"
        return 1
    }

    podman logs -f "$name"
}

# =============================================================================
# Generic shell
# =============================================================================

function container-shell() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-shell <container>"
        return 1
    }

    if (( $+commands[lxc] )); then
        lxc exec "$name" -- bash
    elif (( $+commands[podman] )); then
        podman exec -it "$name" /bin/bash
    elif (( $+commands[docker] )); then
        docker exec -it "$name" /bin/bash
    else
        print "${_CONTAINER_RED}[error]${_CONTAINER_RESET} no runtime found"
        return 1
    fi
}

# =============================================================================
# Images
# =============================================================================

function container-images() {
    if (( $+commands[lxc] )); then
        lxc image list "$@"
    elif (( $+commands[podman] )); then
        podman images "$@"
    elif (( $+commands[docker] )); then
        docker images "$@"
    else
        print "${_CONTAINER_RED}[error]${_CONTAINER_RESET} no runtime found"
        return 1
    fi
}

# =============================================================================
# Logs
# =============================================================================

function container-logs() {
    local name="$1"

    [[ -n "$name" ]] || {
        print "usage: container-logs <container>"
        return 1
    }

    if (( $+commands[podman] )); then
        podman logs -f "$name"
    elif (( $+commands[docker] )); then
        docker logs -f "$name"
    elif (( $+commands[lxc] )); then
        lxc console "$name"
    else
        print "${_CONTAINER_RED}[error]${_CONTAINER_RESET} no runtime found"
        return 1
    fi
}

# =============================================================================
# Short aliases
# =============================================================================

alias ctr='container'
alias ctrls='container-list'
alias ctrstart='container-start'
alias ctrstop='container-stop'
alias ctrrestart='container-restart'
alias ctrsh='container-shell'
alias ctrimg='container-images'
alias ctrlogs='container-logs'

alias lx='lxc'
alias d='docker'
alias p='podman'

# =============================================================================
# Help
# =============================================================================

function container-help() {
    cat <<'EOF'
Container Zsh Plugin
====================

Runtime:
  container-runtimes       Detect installed runtimes
  container-runtime        Select runtime

Generic:
  container-list            List containers
  container-start NAME      Start container
  container-stop NAME       Stop container
  container-restart NAME    Restart container
  container-shell NAME      Open shell
  container-images          List images
  container-logs NAME       Show logs

LXC/LXD:
  container-lxc
  container-lxc-list
  container-lxc-launch IMAGE NAME
  container-lxc-shell NAME
  container-lxc-exec NAME COMMAND
  container-lxc-delete NAME

Docker:
  container-docker
  container-docker-list
  container-docker-all
  container-docker-shell NAME
  container-docker-bash NAME
  container-docker-logs NAME

Podman:
  container-podman
  container-podman-list
  container-podman-all
  container-podman-shell NAME
  container-podman-bash NAME
  container-podman-logs NAME

Aliases:
  ctr       container
  ctrls      container-list
  ctrstart   container-start
  ctrstop    container-stop
  ctrrestart container-restart
  ctrsh      container-shell
  ctrimg     container-images
  ctrlogs    container-logs

  lx         lxc
  d          docker
  p          podman

Antidote:
  Add to ~/.zsh_plugins.txt:

    your-user/container.plugin.zsh

EOF
}

# =============================================================================
# End
# =============================================================================