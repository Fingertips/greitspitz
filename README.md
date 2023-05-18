# Greitspitz

An HTTP proxy that sits in front of S3 compatible object storage and performs image operations before serving the images.

## Operations and formats

Note that none of the operation every scale the image up.

* `fit:N[xM]`: Fit the image within a bounding box.
* `crop:N[xM]`: Crop the image to fill a bounding box.
* `format:(avif|jpeg|png)`: Specify the output format, uses `jpeg` as default.

## Encoding operations and formats

You can specify zero or more operations to apply to the image. They are performed in the specified order. You can zero or more formats, only the last one is applied.

Join the operation and value using a `:`, separate multiple parameters using `,`.

    fit:1920,format:avif

## Building a request path

The request paths contains: bucket name, key, and operations and format as described above. Encode the path components for use in a request path and join them with a `/`.

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
