# LilyPond in Docker – “... music notation for everyone“

![Docker Image](https://github.com/Codello/docker-lilypond/workflows/Docker%20Image/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/codello/lilypond)
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/codello/lilypond)

This docker image provides an easy way do run [LilyPond](https://lilypond.org) inside docker.

## Available Tags

The tags of this image correspond to LilyPond versions. So in order to use the 2.20.0 version you can use `codello/lilypond:2.20.0`. Not all LilyPond versions are available.

There are two variants of each tag. The normal variant and the *fonts* variant. The *fonts* variant is named `<version>-fonts` (e.g. `codello/lilypond:2.20.0-fonts`) and includes some system fonts as well as all of the [Open LilyPond Fonts](https://github.com/OpenLilyPondFonts).

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

