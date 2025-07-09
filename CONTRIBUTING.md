# Contributing to Debian DevBox Installer

We love your input! We want to make contributing to this project as easy and transparent as possible.

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

## How to Contribute

1. **Fork the repo** and create your branch from `main`
2. **Make your changes** and test them thoroughly
3. **Ensure any install or build dependencies are documented**
4. **Make sure your code follows the existing style**
5. **Write clear commit messages**
6. **Submit a pull request**

## Pull Request Process

1. Ensure any install or build dependencies are removed before the end of the layer when doing a build
2. Update the README.md with details of changes to the interface, including new environment variables, exposed ports, useful file locations, and container parameters
3. Increase the version numbers in any examples files and the README.md to the new version that this Pull Request would represent
4. You may merge the Pull Request in once you have the sign-off of two other developers, or if you do not have permission to do that, you may request the second reviewer to merge it for you

## Testing

Please test your changes on:
- Fresh Debian 12 (Bookworm) installation
- Fresh Ubuntu 22.04 LTS installation
- Ubuntu 24.04 LTS installation

Run the troubleshoot script to ensure everything works correctly:
```bash
./scripts/troubleshoot.sh
```

## Bug Reports

We use GitHub issues to track public bugs. Report a bug by opening a new issue.

**Great Bug Reports** tend to have:
- A quick summary and/or background
- Steps to reproduce (be specific!)
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## License

By contributing, you agree that your contributions will be licensed under its MIT License.
