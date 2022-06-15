# LilyPond in Docker – “... music notation for everyone“

![Docker Image](https://github.com/codello/docker-lilypond/actions/workflows/docker.yml/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/codello/lilypond)

This docker image provides an easy way do run [LilyPond](https://lilypond.org) inside docker.

## Available Tags

The tags of this image correspond to LilyPond versions. So in order to use the 2.22.0 version you can use `codello/lilypond:2.22.0`. Not all LilyPond versions are available.

### Variants

At every point there are two actively maintained versions of LilyPond. One stable and one development version. This repository follows the release cycle of LilyPond meaning there are will be two tags built based on this repository.

- `stable` and `latest` both refer to the latest stable LilyPond version (that is the latest `2.x` release where `x` is an even number)
- `dev` refers to the latest development version of LilyPond.

All images contain LilyPond, its runtime dependencies, the [Open LilyPond Fonts](https://github.com/OpenLilyPondFonts) and some commonly used build tools such as `make`.

### Legacy Tags

Before LilyPond 2.22 was released this repository contained additional tags for each version, namely a `-shell` and a `-basic` tag. These additional tags were removed as they served little to no benefit. Now all tags contain the additional fonts as well as some common CLI tools (such as `make`). The default entrypoint is the `lilypond` binary.

## Running LilyPond

To run lilypond you just need to run the image as an executable:

```shell
docker run -v $(pwd):/work codello/lilypond score.ly
```

When running lilypond this way you need to pay attention to the following details:

- Map your working directory (or your sources directory) to the `/work` directory inside the container.
- Run lilypond normally using the image name instead of the `lilypond` executable. The default entrypoint of this docker image just invokes the `lilypond` executable inside of the `/ly` directory.
- Any arguments following will be passed directly to `lilypond`.
- The output will be put into the `/work` directory as well by default. If you use other directories remember to add bind mounts for those as well.

## A note on compilation

This docker image compiles Guile and LilyPond from source. The compilation process is quite demanding on the CPU and might take a while. Compilation via GitHub Actions takes ~8 minutes.

LilyPond inside the image is compiled into the `/opt` folder. This way we can take advantage of docker’s [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) and get a smaller final image. Compilation into `/usr/local` would work as well but would require more effort in the later stages (because we need to isolate the LilyPond files from other programs in the prefix).
