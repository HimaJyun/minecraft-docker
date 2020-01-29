# Vanilla Minecraft server in Docker
Minecraft server (Java Edition)

## Usage
Example.

```bash
docker run -it -d --name minecraft -p 25565:25565 -v $(pwd)/minecraft:/minecraft -e EULA="true" himajyun/minecraft
```

### Directory path

To keep the data, mount the directory on the container `/minecraft`.

```bash
docker run -v /path/to/data:/minecraft ...
```

### CLI

Use the `-it` option to `docker run` to use the command.

```bash
docker run -it himajyun/minecraft
```

Attach to the container in daemon mode with `docker attach`.

```bash
docker attach [container id]
```

Detach with Ctrl+P -> Ctrl+Q.

## Environment variables

### EULA
default: `false`

```bash
docker run -e EULA="true" ...
```

Please read [Minecraft EULA](https://account.mojang.com/documents/minecraft_eula).

### VERSION
default: `latest`

```bash
docker run -e VERSION="1.15.2" ...
```

### JVM_OPTS
default: `-XX:+UseG1GC -XX:MaxGCPauseMillis=50` ...

```bash
docker run -e JVM_OPTS="-Xmx2G -Xms2G -XX:+UseG1GC -XX:MaxGCPauseMillis=50"
```

### SERVER_OPTS
default: `nogui`

```bash
docker run -e SERVER_OPTS="nogui --forceUpgrade" ...
```
