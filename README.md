# DEPRECATED

Note, ZMK has deprecated using this, in favor of https://github.com/zmkfirmware/zmk-docker/.

# Zephyr West Github Action

A GitHub Action to allow performing actions using the [west](https://docs.zephyrproject.org/latest/guides/west/index.html) build tool.

The action includes the necessary SDK and dependencies to perform builds of [Zephyr RTOS](https://zephyrproject.org/) applications as well.

## Directory Layout Requirement

In order to properly have the full West workspace be contained within the GitHub Actions workspace, this action requires
that the Zephyr application itself be in a toplevel subdirectory of the GitHub repository, e.g. under `app/`.

## Inputs

### command

The west command to run, e.g. `init` or `build`.

### command-args

Extra parameters/arguments to pass to the west command.

# Example

The following example assumes a git repository with the Zephyr application
placed in the `app/` subdirectory, and demonstrates initalizing, updating, and
then building the application using west. This also includes caching of the
key module directories that are created in the workspace by west:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    name: Build Test
    steps:
      # To use this repository's private action,
      # you must check out the repository
      - name: Checkout
        uses: actions/checkout@v2
      - name: Cache west modules
        uses: actions/cache@v2
        env:
          cache-name: cache-zephyr-modules
        with:
          path: |
            modules/
            tools/
            zephyr/
            bootloader/
          key: ${{ runner.os }}-build-${{ env.cache-name }}-${{ hashFiles('app/west.yml') }}
          restore-keys: |
            ${{ runner.os }}-build-${{ env.cache-name }}-
            ${{ runner.os }}-build-
            ${{ runner.os }}-
      - name: West Init
        uses: zmkfirmware/zephyr-west-action@v0.1.0
        id: west-init
        with:
          command: 'init'
          command-args: '-l app'
      - name: West Update
        uses: zmkfirmware/zephyr-west-action@v0.1.0
        id: west-update
        with:
          command: 'update'
      - name: West Config Zephyr Base
        uses: zmkfirmware/zephyr-west-action@v0.1.0
        id: west-config
        with:
          command: 'config'
          command-args: '--global zephyr.base-prefer configfile'
      - name: West Zephyr Export
        uses: zmkfirmware/zephyr-west-action@v0.1.0
        id: west-zephyr-export
        with:
          command: 'zephyr-export'
      - name: West Build
        uses: zmkfirmware/zephyr-west-action@v0.1.0
        id: west-build
        with:
          command: 'build'
          command-args: '-s app'
```

# Docker Container Version

In order to avoid rebuilding the GitHub Action each time your workflow runs, which currently
takes a significant amount of time, you can instead use the equivalent published images from
Docker Hub in your workflows. There are two variants available:

* `zmkfirmware/zephyr-west-action` - Includes the full Zephyr SDK, but is 1.3GB large.
* `zmkfirmware/zephyr-west-action-arm` - Includes only the ARM toolchain, is lighter at 555MB.

When using the Docker images, the `with` section needs only one parmeters, `args` which is passed
to the docker `CMD` value at runtime. Any additional values to be passed to the west subcommand
should be surrounded by quotes (e.g. `build "-b nucleo_wb55rg"`).

## Example

```
jobs:
  build:
    runs-on: ubuntu-latest
    name: Build Test
    steps:
      # To use this repository's private action,
      # you must check out the repository
      - name: Checkout
        uses: actions/checkout@v2
      - name: Cache west modules
        uses: actions/cache@v2
        env:
          cache-name: cache-zephyr-modules
        with:
          path: |
            modules/
            tools/
            zephyr/
            bootloader/
          key: ${{ runner.os }}-build-${{ env.cache-name }}-${{ hashFiles('app/west.yml') }}
          restore-keys: |
            ${{ runner.os }}-build-${{ env.cache-name }}-
            ${{ runner.os }}-build-
            ${{ runner.os }}-
      - name: West Init
        uses: 'docker://zmkfirmware/zephyr-west-action-arm:latest'
        id: west-init
        with:
          args: 'init "-l app"'
      - name: West Update
        uses: 'docker://zmkfirmware/zephyr-west-action-arm:latest'
        id: west-update
        with:
          args: 'update'
      - name: West Config Zephyr Base
        uses: 'docker://zmkfirmware/zephyr-west-action-arm:latest'
        id: west-config
        with:
          args: 'config "--global zephyr.base-prefer configfile"'
      - name: West Zephyr Export
        uses: 'docker://zmkfirmware/zephyr-west-action-arm:latest'
        id: west-zephyr-export
        with:
          args: 'zephyr-export'
      - name: West Build
        uses: 'docker://zmkfirmware/zephyr-west-action-arm:latest'
        id: west-build
        with:
          args: 'build "-s app"'
```
