#!/bin/bash

function display_config() {
    if [ -n "$KUBECONFIG" ] && [ -f "$KUBECONFIG" ]; then
        cat $KUBECONFIG
    else
        echo "KUBECONFIG is not set or the file does not exist."
    fi
}

function echo_config_path() {
    if [ -n "$KUBECONFIG" ] && [ -f "$KUBECONFIG" ]; then
        echo $KUBECONFIG
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
    echo "Usage: k8s [-d|-e|-u|-s|-r|-k|file|-h]"
    echo "Options:"
    echo "        (No option) Same as -r. Select a kubeconfig file from the ~/.kube directory and run k9s with it. Does not change KUBECONFIG."
    echo "-d      Display the content of the KUBECONFIG file."
    echo "-e      Display the path of the KUBECONFIG file."
    echo "-u      Unset the KUBECONFIG environment variable."
    echo "-s      Select a kubeconfig file from the ~/.kube directory."
    echo "-r      Select a kubeconfig file from the ~/.kube directory and run k9s with it. Does not change KUBECONFIG."
    echo "-k      Keep the specified ports open. Ports should be comma-separated and the argument should be enclosed in quotes if more than one. E.g. \"3100,9090\""
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



function keep_ports_open() {
  if [ $# -eq 0 ]; then
    echo "No ports provided."
    return 1
  fi

  ports=(${(s:,:)1})

  # Create an empty array to hold the PIDs of the background processes
  pids=()

  # Define a signal handler for SIGINT
  trap 'echo "Stopping processes: ${pids[*]}"; kill "${pids[@]}"; exit' SIGINT

  for port in "${ports[@]}"; do
    if ! [[ $port =~ ^[0-9]+$ ]] || [ $port -lt 1 ] || [ $port -gt 65535 ]; then
      echo "Invalid port number: $port"
      return 1
    fi
    {
      while true; do
        nc -vz 127.0.0.1 $port || true
        sleep 10
      done
    } & 
    pids+=("$!")  # Store the PID of the background process
    echo "Started process with PID $!"
  done

  # Wait for all background processes to finish
  wait
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
    -e)
        if [ -z "$2" ]; then
            echo_config_path
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
     -k)
        if [ -n "$2" ]; then
            keep_ports_open "$2"
        else
            echo "No ports provided with -k."
        fi
        ;;
    "")
        select_and_run_k9s
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
