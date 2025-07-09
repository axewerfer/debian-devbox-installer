# Troubleshooting Guide

This guide covers common issues you might encounter during installation and how to resolve them.

## Installation Issues

### Permission Denied Errors

**Problem**: Getting permission denied when running scripts
```bash
bash: ./install-devbox.sh: Permission denied
```

**Solution**: Make the script executable
```bash
chmod +x scripts/*.sh
```

### Docker Group Membership

**Problem**: Docker commands fail with permission errors
```bash
docker: Got permission denied while trying to connect to the Docker daemon socket
```

**Solution**: 
1. Add user to docker group: `sudo usermod -aG docker $USER`
2. Log out and back in
3. Test: `docker run hello-world`

### Node.js Permission Issues

**Problem**: NPM global installations fail with EACCES errors

**Solution**: Use a Node version manager like nvm
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install node
```

### AWS CLI Configuration

**Problem**: AWS commands fail with credential errors

**Solution**: Configure AWS credentials
```bash
aws configure
# Enter your Access Key ID, Secret Access Key, region, and output format
```

## Service Issues

### PostgreSQL Won't Start

**Problem**: PostgreSQL service fails to start

**Solution**:
```bash
sudo systemctl status postgresql
sudo journalctl -u postgresql
sudo systemctl start postgresql
```

### VS Code Extensions Not Installing

**Problem**: VS Code extensions fail to install

**Solution**:
```bash
# Install manually
code --install-extension ms-python.python
# Or use the troubleshoot script
./scripts/troubleshoot.sh
```

## Network Issues

### Download Failures

**Problem**: Downloads fail due to network issues

**Solution**:
1. Check internet connectivity: `ping google.com`
2. Try using different DNS: `sudo systemctl restart systemd-resolved`
3. Check firewall settings

## Getting Help

If you're still having issues:

1. Run the troubleshoot script: `./scripts/troubleshoot.sh`
2. Check the installation log: `~/devbox-install.log`
3. Search existing GitHub issues
4. Create a new issue with detailed information
