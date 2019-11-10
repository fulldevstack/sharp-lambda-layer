# sharp-lambda-layer
This docker container utilizes [lambci/lambda:build-nodejs10.x](https://hub.docker.com/r/lambci/lambda/tags)
as a base to build [libvips](https://github.com/libvips/libvips) and install 
[sharp](https://github.com/lovell/sharp) with PDF support. We can then upload 
the resulting zip as a Lambda layer.

## Usage
1. Clone the repository and enter the directory. 

2. Create a .env file with the following variables:
   * AWS_REGION
   * AWS_ACCESS_KEY_ID
   * AWS_SECRET_ACCESS_KEY
   * LAYER_NAME
   * ZIP_FILE_NAME
   
3. `docker-compose build sharp`

4. `docker-compose run sharp`

