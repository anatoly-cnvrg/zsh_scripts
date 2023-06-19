# K8S - Kubernetes Configuration Tool (k8s.sh)

This tool provides a simple command line interface to manage your KUBECONFIG environment variable. It allows you to display the content of the KUBECONFIG file, unset the KUBECONFIG environment variable, select a KUBECONFIG file from the `~/.kube` directory, and set the KUBECONFIG environment variable to a provided file.

## Installation

1. Clone the repository: 

    ```bash
    git clone git@github.com:anatoly-cnvrg/zsh_scripts.git
    cd k8s-tool
    ```

2. Make the script executable:

    ```bash
    chmod +x k8s.sh
    ```

3. Add the script to your path. This can be done by editing the `.zshrc` file in your home directory. You can use any text editor you like, but here's an example using `vim`:

    ```bash
    vim ~/.zshrc
    ```

    Then add the following line at the end of the file:

    ```bash
    source /path/to/your/script/k8s.sh
    ```

    Replace `/path/to/your/script/` with the actual path where the `k8s.sh` script is located.

4. Reload your `.zshrc`:

    ```bash
    source ~/.zshrc
    ```

    Now, you should be able to use the `k8s` command from any directory.

## Usage

To display the content of the KUBECONFIG file:

```bash
k8s -d
```

To unset the KUBECONFIG environment variable:

```bash
k8s -u
```

To select a KUBECONFIG file from the `~/.kube` directory:

```bash
k8s -s
```

To set the KUBECONFIG environment variable to a provided file:

```bash
k8s /path/to/your/kubeconfig
```

To select a KUBECONFIG file from the ~/.kube directory and run k9s with it without changing the KUBECONFIG environment variable:

```
k8s -r
```

For help:

```bash
k8s -h
```

This will display the usage and available options.
