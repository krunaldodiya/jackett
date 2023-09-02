FROM python:3.11

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# set work directory
RUN mkdir /app
WORKDIR /app

# add common packages
RUN apt update && apt install -y nano

# copy project
COPY . .

# upgrade pip
RUN pip install --upgrade pip

# install dependencies
RUN pip install -r /app/requirements.txt --no-cache

EXPOSE 5000

ENTRYPOINT ["python"]

CMD ["main.py"]
