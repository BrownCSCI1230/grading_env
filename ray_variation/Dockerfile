FROM anc2001/cs1230_env:latest

WORKDIR /home/user
RUN git clone https://github.com/BrownCSCI1230/scenefiles.git

# Setup autograder
COPY run_autograder /autograder/
RUN dos2unix /autograder/run_autograder
RUN chmod +x /autograder/run_autograder