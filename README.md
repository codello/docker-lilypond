# LilyPond in Docker ... music notation for everyone

This docker image provides an easy way do run [LilyPond](https://lilypond.org) inside docker.

## Running LilyPond

To run lilypond you just need to run the image as an executable:

```shell
docker run -v $(pwd):/ly lilypond score.ly
```

When running lilypond this way you need to pay attention to the following details:

- Map your working directory (or your sources directory) to the `/ly` directory inside the container.
- Run lilypond normally using the image name instead of the `lilypond` executable. The default entrypoint of this docker image just invokes the `lilypond` executable inside of the `/ly` directory.
- Any arguments following will be passed directly to `lilypond`.
- The output will be put into the `/ly` directory as well by default. If you use other directories remember to add bind mounts for those as well.