# Greitspitz

An HTTP proxy that sits in front of S3 compatible object storage and performs image operations before serving the images.

## Operations and formats

Note that none of the operation every scale the image up.

* `fit:N[xM]`: Fit the image within a bounding box.
* `crop:N[xM]`: Crop the image to fill a bounding box.
* `format:(avif|jpeg|png)`: Specify the output format, uses `jpeg` as default.
