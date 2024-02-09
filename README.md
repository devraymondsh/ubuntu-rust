#### A Rust docker image built on top of Ubuntu Linux.

## Supported tags:

- 23.04, 23.04-1.76, lunar-1.76, lunar-latest, lunar, 23.04-latest, latest-1.76, 1.76, latest
- 22.04, 22.04-1.76, jammy-1.76, jammy-latest, jammy
- 20.04, 20.04-1.76, focal-1.76, focal-latest, focal

## How to use this image

### Start a Rust instance running your app

The most straightforward way to use this image is to use a Rust container as both the build and runtime environment. In your Dockerfile, writing something along the lines of the following will compile and run your project:

```Dockerfile
FROM devraymondsh/ubuntu-rust:latest

WORKDIR /usr/src/myapp
COPY . .

RUN cargo install --path .

CMD ["myapp"]
```

Then, build and run the Docker image:

`$ docker build -t my-rust-app .`<br />
`$ docker run -it --rm --name my-running-app my-rust-app`

This creates an image that has all of the rust tooling for the image. If you just want the compiled application which has a smaller size:

```Dockerfile
FROM devraymondsh/ubuntu-rust:latest as builder
WORKDIR /usr/src/myapp
COPY . .
RUN cargo install --path .

FROM debian:buster-slim
RUN apt-get update && apt-get install -y extra-runtime-dependencies && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/cargo/bin/myapp /usr/local/bin/myapp
CMD ["myapp"]
```

Note: Some shared libraries may need to be installed as shown in the installation of the extra-runtime-dependencies line above.

## Compile your app inside the Docker container

There may be occasions where it is not appropriate to run your app inside a container. To compile, but not run your app inside the Docker instance, you can write something like:<br />
`$ docker run --rm --user "$(id -u)":"$(id -g)" -v "$PWD":/usr/src/myapp -w /usr/src/myapp devraymondsh/ubuntu-rust:latest cargo build --release`<br />
This will add your current directory, as a volume, to the container, set the working directory to the volume, and run the command cargo build --release. This tells Cargo, Rust's build system, to compile the crate in myapp and output the executable to target/release/myapp.

## License

The image is licensed under the MIT license. Visit [LICENSE](https://github.com/devraymondsh/ubuntu-rust/blob/main/LICENSE) for more information.
