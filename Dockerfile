FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
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

# Install kma
RUN git clone --branch 1.0.1 --depth 1 https://bitbucket.org/genomicepidemiology/kma.git && \
    cd kma && make && \
    mv kma* /bin/

# Copy main script and test files
COPY plasmidfinder.py /usr/src/plasmidfinder.py
RUN chmod 755 /usr/src/plasmidfinder.py

RUN mkdir /database /test
COPY test/database/ /database/
COPY test/test* /test/
RUN chmod 755 /test/test.sh

ENV PATH="$PATH:/usr/src"

# Bash aliases for convenience
RUN echo "\
alias ls='ls -h --color=tty'\n\
alias ll='ls -lrt'\n\
alias l='less'\n\
alias du='du -hP --max-depth=1'\n\
alias cwd='readlink -f .'\n\
" >> ~/.bashrc

WORKDIR /workdir

# Set entrypoint
ENTRYPOINT ["/usr/src/plasmidfinder.py"]
