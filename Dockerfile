FROM python:3.9-slim-buster

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

RUN apt-get update \
  # dependencies for building Python packages
  && apt-get install -y build-essential \
  # psycopg2 dependencies
  && apt-get install -y libpq-dev \
  # Additional dependencies
  && apt-get install -y telnet netcat \
  # cleaning up unused files
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"


RUN pip install --upgrade pip
RUN apt-get update
RUN apt-get install git-core -y

COPY . .
# Requirements are installed here to ensure they will be cached.
#COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

RUN git clone https://github.com/JRBusiness/start_file.git start_file

RUN sed -i 's/\r$//g' /start_file/entrypoint
RUN chmod +x /start_file/entrypoint

RUN sed -i 's/\r$//g' /start_file/start
RUN chmod +x /start_file/start

RUN sed -i 's/\r$//g' /start_file/celery/worker/celery_start
RUN chmod +x /start_file/celery/worker/celery_start

WORKDIR .

ENTRYPOINT ["/start_file/entrypoint"]
