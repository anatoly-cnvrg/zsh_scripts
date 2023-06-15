#!/bin/bash

function display_config() {
    if [ -n "$KUBECONFIG" ] && [ -f "$KUBECONFIG" ]; then
        cat $KUBECONFIG
    else
        echo "KUBECONFIG is not set or the file does not exist."
    fi
}

function set_config() {
    if [ -f "$1" ]; then
        export KUBECONFIG=$(realpath $1)
    else
        echo "The provided file does not exist."
    fi
}

function delete_config() {
    unset KUBECONFIG
    echo "KUBECONFIG has been unset."
}

function k8s() {
    case $1 in
    -d)
        if [ -z "$2" ]; then
            display_config
        else
            echo "Invalid option with -d."
        fi
        ;;
    -u)
        if [ -z "$2" ]; then
            delete_config
        else
            echo "Invalid option with -u."
        fi
        ;;
    "")
        if [ -n "$KUBECONFIG" ]; then
            echo $KUBECONFIG
        else
            echo "KUBECONFIG is not set."
        fi
        ;;
    *)
        if [[ $1 == -* ]]; then
            echo "Invalid option: $1"
        else
            set_config $1
        fi
        ;;
    esac
}

