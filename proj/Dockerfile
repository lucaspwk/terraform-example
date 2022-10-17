FROM python:2.7
COPY . /proj
WORKDIR /proj/app
RUN ls -la && pwd && pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["server.py"]
