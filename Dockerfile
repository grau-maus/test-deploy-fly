# This Dockerfile builds the React client and API together

# Build step #1: build the React front end
FROM node:16-alpine as build-step
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY package.json package-lock.json ./
COPY ./src ./src
COPY ./public ./public
RUN npm install
RUN npm run build

# Build step #2: build the API with the client as static files
FROM python:3.9
WORKDIR /app
COPY --from=build-step /app/build ./build

RUN mkdir ./api
# COPY api/requirements.txt api/api.py api/.flaskenv ./api/
COPY api/* ./api/
RUN pip install -r ./api/requirements.txt
ENV FLASK_ENV production

# Expose port 8080 for fly.io deployment
EXPOSE 8080
WORKDIR /app/api
CMD ["gunicorn", "-b", ":8080", "api:app"]
