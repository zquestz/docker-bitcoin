#!/usr/bin/env ruby

require "erb"
require "ostruct"

VALID_FORKS = %w(core xt)
VERSIONS = [
  ["core", "0.10.3"],
  ["core", "0.11.1"],
  ["core", "0.11.2"],
  ["xt", "0.11B", "0.11.0-B", "3c51c03e28118e4846267075b150810e35c450462ce2483639e766643ed78fe1"],
  ["xt", "0.11C", "0.11.0-C", "d879c701f500303ef807b3f49a6aa1ab021ad9e86b3f4a6f7a0bf3d5ce05e545"],
  ["xt", "0.11D", "0.11.0-D", "ba0e8d553271687bc8184a4a7070e5d350171036f13c838db49bb0aabe5c5e49"],
]

# run external command and test success
def run(cmd)
  puts "#{cmd}"
  out = `#{cmd}`

  if !$?.success?
    print out
    exit 1
  end
end

def status(msg)
  puts "\n==> #{msg}"
end

def version_dir(bitcoin, version)
  dir = version
  dir = File.join("xt", dir) if bitcoin == "xt"
  dir
end

# update docker files for version
def update_version(bitcoin, version, file_version = nil, sha256 = nil)
  unless VALID_FORKS.include?(bitcoin)
    fail "invalid fork #{bitcoin}"
  end

  file_version = version if file_version.nil?
  dir = version_dir(bitcoin, version)
  status "Update version #{dir}"

  if bitcoin == "xt"
    url = "https://github.com/bitcoinxt/bitcoinxt/releases/download/v#{version}/bitcoin-xt-#{file_version}-linux64.tar.gz"
  else
    url = "https://bitcoin.org/bin/bitcoin-core-#{version}/bitcoin-#{version}-linux64.tar.gz"
  end

  # check that version is valid
  # run "curl -fsSLI #{url}"

  # initialize directory
  run "rm -rf #{dir}"
  run "mkdir -p #{dir}"
  run "cp docker-entrypoint.sh #{dir}"

  # render Dockerfile
  vars = {
    bitcoin: bitcoin,
    version: version,
    url: url,
    sha256: sha256,
  }

  dockerfile = ERB.new(File.read("Dockerfile.erb"), nil, "-")
  result = dockerfile.result(OpenStruct.new(vars).instance_eval { binding })
  File.write(File.join(dir, "Dockerfile"), result)

  major = version.match(/^\d+\.\d+/).to_s
  major_dir = version_dir(bitcoin, major)
  if update_major?(version, major, major_dir)
    status "Update major version #{major_dir}"
    run "rm -rf #{major_dir}"
    run "cp -R #{dir} #{major_dir}"
  end
end

# check if we need to update major version directory
def update_major?(version, major, major_dir)
  dockerfile = File.join(major_dir, "Dockerfile")
  return true unless File.exist?(dockerfile)

  current = File.read(dockerfile).match(/BITCOIN_VERSION\s+(.*)$/)
  current = current[1] if current

  Gem::Version.new(version) >= Gem::Version.new(current)
end

VERSIONS.each do |ver|
  update_version(*ver)
end
