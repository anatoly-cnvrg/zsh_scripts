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

function select_config() {
    local files=($(ls -p ~/.kube | grep -v /))
    local length=${#files[@]}
    local choice

    if [ $length -eq 0 ]; then
        echo "No files in ~/.kube"
        return
    fi

    echo "Select a file to set as KUBECONFIG:"
    select choice in "${files[@]}"; do
        if [[ -n $choice ]]; then
            export KUBECONFIG=~/.kube/$choice
            echo "KUBECONFIG set to $choice"
            break
        else
            echo "Invalid choice"
        fi
    done
}


function display_help() {
    echo "Usage: k8s [-d|-u|-s|-r|file]"
    echo "Options:"
    echo "-d      Display the content of the KUBECONFIG file."
    echo "-u      Unset the KUBECONFIG environment variable."
    echo "-s      Select a kubeconfig file from the ~/.kube directory."
    echo "-r      Select a kubeconfig file from the ~/.kube directory and run k9s with it. Does not change KUBECONFIG."
    echo "file    Set the KUBECONFIG environment variable to the provided file."
    echo "-h      Display this help message."
}


function select_and_run_k9s() {
    local files=($(ls -p ~/.kube | grep -v /))
    local length=${#files[@]}
    local choice

    if [ $length -eq 0 ]; then
        echo "No files in ~/.kube"
        return
    fi

    echo "Select a file to run with k9s:"
    select choice in "${files[@]}"; do
        if [[ -n $choice ]]; then
            KUBECONFIG=~/.kube/$choice k9s
            echo "k9s ran with KUBECONFIG set to $choice"
            break
        else
            echo "Invalid choice"
        fi
    done
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
    -s)
        if [ -z "$2" ]; then
            select_config
        else
            echo "Invalid option with -s."
        fi
        ;;  
    -r)
        if [ -z "$2" ]; then
            select_and_run_k9s
        else
            echo "Invalid option with -r."
        fi
        ;;
    -h)
        if [ -z "$2" ]; then
            display_help
        else
            echo "Invalid option with -h."
        fi
        ;;
    "")
        if [ -n "$KUBECONFIG" ]; then
            echo $KUBECONFIG
        else
            select_config
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