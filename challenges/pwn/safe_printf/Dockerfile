FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    socat \
    && rm -rf /var/lib/apt/lists/*

# Create challenge user
RUN useradd -m -s /bin/bash ctf

# Set working directory
WORKDIR /home/ctf

# Copy challenge files
COPY dist/challenge ./challenge
COPY flag.txt ./flag.txt

# Set permissions
RUN chmod +x challenge && \
    chmod 444 flag.txt && \
    chown root:root challenge flag.txt && \
    chown ctf:ctf /home/ctf && \
    chmod 755 /home/ctf

# Switch to ctf user
USER ctf

# Expose port
EXPOSE 1337

# Run with socat
CMD ["socat", "TCP-LISTEN:1337,reuseaddr,fork", "EXEC:./challenge,stderr"]
