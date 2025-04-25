FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install system packages
RUN apt-get update -qq && \
    apt-get install -y -qq \
        git \
        apt-utils \
        wget \
        python3 \
        python3-pip \
        python3-setuptools \
        ncbi-blast+ \
        libz-dev && \
    rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=teletype

# Install Python packages
RUN pip3 install -U biopython==1.73 tabulate cgecore

# Install KMA
RUN git clone --branch 1.0.1 --depth 1 https://bitbucket.org/genomicepidemiology/kma.git && \
    cd kma && make && \
    mv kma* /bin/

# Install PlasmidFinder database
RUN mkdir -p /plasmidfinder_db && \
    cd /plasmidfinder_db && \
    git clone https://bitbucket.org/genomicepidemiology/plasmidfinder_db.git . && \
    python3 INSTALL.py kma_index

# Optional: expose DB path to your script
ENV PLASMID_DB=/plasmidfinder_db

# Copy main script
COPY plasmidfinder.py /usr/src/plasmidfinder.py
RUN chmod 755 /usr/src/plasmidfinder.py

# Test setup
RUN mkdir -p /database /test
COPY test/database/ /database/
COPY test/test* /test/
RUN chmod 755 /test/test.sh

# Bash aliases for debugging (optional)
RUN echo "\
alias ls='ls -h --color=tty'\n\
alias ll='ls -lrt'\n\
alias l='less'\n\
alias du='du -hP --max-depth=1'\n\
alias cwd='readlink -f .'\n\
" >> ~/.bashrc

WORKDIR /workdir

# Add script directory to PATH
ENV PATH="$PATH:/usr/src"

# Run your tool by default
ENTRYPOINT ["/usr/src/plasmidfinder.py"]
