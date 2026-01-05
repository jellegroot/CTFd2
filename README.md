# CTF Platform Cybermeister

A customized Capture The Flag (CTF) platform built on CTFd, designed for hosting competitive cybersecurity challenges.

## Table of Contents

- [About](#about)
- [Features](#features)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Challenges](#challenges)
- [Configuration](#configuration)
- [Development](#development)
- [Contributing](#contributing)

## About

CTFd is a Capture The Flag framework focusing on ease of use and customizability. This Cybermeister instance comes pre-configured with everything you need to run a professional CTF competition. The platform is easily customizable through plugins and themes, making it suitable for educational institutions, security teams, and CTF organizers.

## Features

- **Easy Setup**: Automated deployment script for quick installation
- **Docker-based**: Containerized deployment for consistency and portability
- **Challenge Management**: Organized challenge templates for multiple categories (Web, PWN, etc.)
- **Customizable**: Flexible plugin and theme system
- **Scalable**: Built on proven CTFd architecture
- **Competition Ready**: Complete with scoring, teams, and user management

## Requirements

Before setting up the platform, ensure you have the following installed:

- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+)
- **pipx** (will be installed during setup if not present)

### Installing Docker on Linux

If Docker is not installed, you can use the provided installation script:

```bash
./scripts/install_docker.sh
```

Or install manually following the [official Docker documentation](https://docs.docker.com/engine/install/).

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd CTFd2
```

### 2. Run the Setup Script

Make the setup script executable and run it:

```bash
chmod +x setup_cybermeister.sh
./setup_cybermeister.sh
```

The setup script will:
- Check and install required dependencies
- Configure the Docker environment
- Start the CTFd platform
- Initialize the database

### 3. Access the Platform

Once the setup is complete, access the platform at:

```
http://localhost:8000
```

Follow the on-screen instructions to complete the initial configuration.

## Project Structure

```
CTFd2/
├── CTFd/                   # Core CTFd application
│   ├── admin/              # Admin panel functionality
│   ├── api/                # REST API endpoints
│   ├── models/             # Database models
│   ├── plugins/            # Plugin system
│   └── themes/             # UI themes
├── challenges/             # Challenge templates and deployment
│   ├── web/                # Web exploitation challenges
│   ├── pwn/                # Binary exploitation challenges
│   └── template/           # Base challenge template
├── migrations/             # Database migrations
├── tests/                  # Test suite
├── docker-compose.yml      # Docker orchestration
└── setup_cybermeister.sh   # Main setup script
```

## Challenges

### Creating Challenges

Challenge templates are located in the `challenges/` directory. Each category (web, pwn, etc.) contains structured challenge templates.

To create a new challenge:

```bash
cd challenges/
./generate_template.sh <challenge-name> <category>
```

### Deploying Challenges

To deploy challenges to the platform:

```bash
cd challenges/
./deploy_ctfd_challenge.sh <challenge-path>
```

For detailed information about challenge creation and deployment, see the [challenges README](challenges/readme.md).

## Configuration

### Environment Variables

Key configuration options can be set in `.env` file or through environment variables:

- `SECRET_KEY`: Application secret key
- `DATABASE_URL`: Database connection string
- `REDIS_URL`: Redis connection for caching
- `MAIL_SERVER`: Email server configuration

### CTFd Configuration

Additional configuration can be found in:
- [CTFd/config.py](CTFd/config.py) - Application configuration
- [CTFd/config.ini](CTFd/config.ini) - Instance-specific settings

## Development

### Local Development Setup

1. Install development dependencies:

```bash
pip install -r development.txt
```

2. Run the development server:

```bash
python serve.py
```

### Running Tests

Execute the test suite:

```bash
pytest tests/
```

### Code Quality

This project uses linting tools to maintain code quality:

```bash
pip install -r linting.txt
make lint
```

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

### Reporting Issues

- Security vulnerabilities: See [SECURITY.md](SECURITY.md)
- Bug reports and feature requests: Use GitHub Issues

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Check the [CTFd Documentation](https://docs.ctfd.io/)
- Review existing issues on GitHub
- Create a new issue for bugs or feature requests

---

**Note**: This is a customized CTFd deployment for Cybermeister. For the official CTFd project, visit [CTFd/CTFd](https://github.com/CTFd/CTFd).