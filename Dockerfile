FROM python:3.9-slim
RUN useradd -m flask
WORKDIR /home/flask

COPY . .

RUN pip install --no-cache-dir -r requirements.txt
RUN chmod a+x app.py test.py && chown -R flask:flask ./

ENV FLASK_APP=app.py
EXPOSE 5000

USER flask

# Changez de ./app.py à python app.py
CMD ["python", "app.py"]