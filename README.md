# Greitspitz

An HTTP proxy that sits in front of S3 compatible object storage and performs image operations before serving the images.

## Instructions

Note that none of the transformations every scale up the image.

* `fit:N[xM]`: Fit the image within a bounding box.
* `crop:N[xM]`: Crop the image to fill a bounding box.
* `format:(avif|jpeg|png)`: Specify the output format, uses `jpeg` as default.
* `quality:(0-100)`: Specify the output quality as a percentage. Ignored when writing a format like PNG.

## Encoding instructions

You can specify zero or more instructions to apply to the image. They are performed in the specified order. You can specify zero or more formats, only the last one is applied.

Join the instruction and value using a `:`, separate multiple entries using `,`.

    fit:1920,format:avif

## Building a request path

The request paths contains: bucket name, key, and instructions. They are formatted as described above. Encode the path components for use in a request path and join them with a `/`.

    /avatars-production/avatars%2F6a3TaSvh944gKbcfrj2VCLC19exiGfbo/fit:1920,format:avif

## Building a URL

Get the request path as described above and prefix it with the hostname and port. By default this will be `http://localhost:1090`.

## Starting the server

Configure the object storage host, access key id, and secret access key in the environment.

* `S3_HOST`: Hostname of the object storage server
* `S3_ACCESS_KEY_ID`: The access key id to access the storage server
* `S3_SECRET_ACCESS_KEY`: The secret access key to access the storage server

After this you can start a server without further arguments:

    greitspitz

If you want to know other options, you can use the `--help` switch:

    greitspitz --help

## Logging

The server always logs to `stdout`. You can set the logging output using environment variables or a switch. Switches always have preference over environment variables.

    LOG_LEVEL=DEBUG greitspitz
    greitspitz --log-level debug

Suported levels are: `trace`, `debug`, `info`, `notice`, `warn`, `error`, `fatal`.

## Docker

Greitspitz releases a Docker image to Docker Hub named `fingertips/greitspitz`.

For small deploys you can choose to use Docker as a process manager. Start by setting up an environment file with server configuration.

Your environment file is going to contain credentials so it's best to set it up something like this:

    sudo mkdir -p /etc/greitspitz
    sudo touch /etc/greitspitz/server.env
    sudo chmod 600 /etc/greitspitz/server.env

The contents would of `/etc/greitspitz/server.env` could look something like this:

```
BIND_ADDR=tcp://0.0.0.0:1090
S3_ACCESS_KEY_ID=secret
S3_SECRET_ACCESS_KEY=secret
S3_HOST=s3.example.com
```

Note that the `BIND_ADDR` is important because `greitspitz` binds to 127.0.0.1 by default.

To start the container and ask Docker to manage it, you do the following:

	    docker run -d --restart unless-stopped --name greitspitz --env-file /etc/greitspitz/server.env -p 1090:1090/tcp fingertips/greitspitz
