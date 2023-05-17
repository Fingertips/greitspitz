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
