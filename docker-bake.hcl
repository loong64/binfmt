variable "REPO" {
  default = "ghcr.io/loong64/binfmt"
}
variable "QEMU_REPO" {
  default = "https://github.com/qemu/qemu"
}
variable "QEMU_VERSION" {
  default = "v9.2.2"
}
variable "QEMU_PATCHES" {
  default = "cpu-max-arm,clang"
}

// Special target: https://github.com/docker/metadata-action#bake-definition
target "meta-helper" {
  tags = ["${REPO}:test"]
}

group "default" {
  targets = ["binaries"]
}

target "binaries" {
  output = ["./bin"]
  platforms = ["local"]
  target = "binaries"
}

target "all-arch" {
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/arm/v6",
    "linux/arm/v7",
    "linux/ppc64le",
    "linux/s390x",
    "linux/riscv64",
    "linux/386",
    "linux/loong64",
  ]
}

target "mainline" {
  inherits = ["meta-helper"]
  args = {
    QEMU_REPO = QEMU_REPO
    QEMU_VERSION = QEMU_VERSION
    QEMU_PATCHES = QEMU_PATCHES
    QEMU_PRESERVE_ARGV0 = "1"
  }
  cache-to = ["type=inline"]
  cache-from = ["${REPO}:master"]
}

target "mainline-all" {
  inherits = ["mainline", "all-arch"]
}

target "buildkit" {
  inherits = ["mainline"]
  args = {
    BINARY_PREFIX = "buildkit-"
    QEMU_PATCHES = "${QEMU_PATCHES},buildkit-direct-execve-v9.2"
    QEMU_PRESERVE_ARGV0 = ""
  }
  cache-from = ["${REPO}:buildkit-master"]
  target = "binaries"
}

target "buildkit-all" {
  inherits = ["buildkit", "all-arch"]
}

target "buildkit-test" {
  inherits = ["buildkit"]
  target = "buildkit-test"
  cache-to = []
  tags = []
}

target "desktop" {
  inherits = ["mainline"]
  args = {
    QEMU_PATCHES = "${QEMU_PATCHES},pretcode"
  }
  cache-from = ["${REPO}:desktop-master"]
}

target "desktop-all" {
  inherits = ["desktop", "all-arch"]
}

target "archive" {
  inherits = ["mainline"]
  target = "archive"
  output = ["./bin"]
}

target "archive-all" {
  inherits = ["archive", "all-arch"]
}
