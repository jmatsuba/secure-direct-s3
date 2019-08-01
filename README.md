# secure-direct-s3
This is an example of how to do secure and direct to s3 uploads from a rails app. It uses the [jQuery-File-Upload](https://github.com/blueimp/jQuery-File-Upload) plugin and rails 5.2.3

## Read the Tutorial
If you want a step by step guide on how this all works check it out [here](https://github.com/jmatsuba/secure-direct-s3/blob/master/tutorial.md).

## Getting Started

1. Clone the project
2. `bundle`
3. Setup a `.env` file based on `.env.example` in the project root: `cp .env.example .env` This includes your aws keys and bucket information.
4. Setup CORS on your s3 bucket (see below)
5. `rails s` to start your rails server
6. Goto http://localhost:3000/users/new to see a demo of the uploader


### AWS S3 Bucket CORS setup
In your S3 Bucket you will need to add a CORS configuration. You can find this in the permissions tab of your S3 bucket. Learn more about CORS [here](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing).

```
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <CORSRule>
    <AllowedOrigin>http://localhost:3000</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>POST</AllowedMethod>
    <AllowedMethod>PUT</AllowedMethod>
    <AllowedHeader>*</AllowedHeader>
  </CORSRule>
</CORSConfiguration>
```
