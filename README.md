# LilyPond in Docker – “... music notation for everyone“

![Docker Image](https://github.com/Codello/docker-lilypond/workflows/Docker%20Image/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/codello/lilypond)
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/codello/lilypond)

This docker image provides an easy way do run [LilyPond](https://lilypond.org) inside docker.

## Available Tags

The tags of this image correspond to LilyPond versions. So in order to use the 2.20.0 version you can use `codello/lilypond:2.20.0`. Not all LilyPond versions are available.

### Variants

- The base image contains a LilyPond installation, some additional fonts as well as all of the [Open LilyPond Fonts](https://github.com/OpenLilyPondFonts). These images are tagged with the LilyPond version number (e.g. `2.20.0`). `latest` is always the latest stable version and `dev` the latest unstable one.
- The `basic` variant does not include any additional fonts. These images are tagged with a `-basic` suffix (e.g. `2.20.0-basic`). `basic` is always the latest stable version and `dev-basic` the latest unstable one.
- The `shell` variant includes all fonts but does not behave as an executable. This is useful if you want to run multiple LilyPond commands (or want to use a Makefile). You can execut LilyPond in this container just fine. These images are tagged with a `-shell` suffix (e.g. `2.20.0-shell`). `shell` is a always the latest stable version and `dev-shell` the latest unstable one.

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

## A note on compilation

This docker image compiles Guile and LilyPond from source. The compilation process is quite demanding on the CPU and might take a while. Compilation via GitHub Actions takes ~10 minutes.

Both LilyPond and Guile are compiled into the `/opt` folder. This way we can take advantage of docker’s [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) and get a smaller final image. Compilation into `/usr/local` would work just as well but would require more effort in the later stages (because we need to isolate the LilyPond files from other programs in the prefix).

