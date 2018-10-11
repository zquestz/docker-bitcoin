#!/usr/bin/env ruby

require 'erb'
require 'ostruct'
require 'yaml'

# Run external command and test success.
def run(cmd)
  puts cmd
  success = system(cmd)
  exit $?.exitstatus unless success
end

def status(msg)
  puts "\n==> #{msg}"
end

# Update docker files for a version.
def update_version(branch, version, opts={})
  dir = File.join(branch, version)
  status "Update version #{dir}"

  # initialize directory
  run "rm -rf #{dir}"
  run "mkdir -p #{dir}"

  # render Dockerfile
  opts['version'] = version
  opts['binary'] ||= 'bitcoind'
  opts['binary_cli'] ||= 'bitcoin-cli'
  opts['binary_tx'] ||= 'bitcoin-tx'
  opts['binary_test'] ||= 'test_bitcoin'

  dockerfile = ERB.new(File.read('Dockerfile.erb'), nil, '-')
  result = dockerfile.result(OpenStruct.new(opts).instance_eval { binding })
  File.write(File.join(dir, 'Dockerfile'), result)

  docker_entrypoint = ERB.new(File.read('docker-entrypoint.sh.erb'), nil, '-')
  result = docker_entrypoint.result(OpenStruct.new(opts).instance_eval { binding })
  File.write(File.join(dir, 'docker-entrypoint.sh'), result)
  run "chmod 755 #{File.join(dir, 'docker-entrypoint.sh')}"
end

def load_versions
  versions = YAML.load_file('versions.yml')
  versions.select! { |k, v| k === ENV['BRANCH'] } if ENV['BRANCH']
  versions
end

if __FILE__ == $0
  load_versions.each do |branch, versions|
    versions.each do |version, opts|
      update_version(branch, version, opts)
    end
  end
end
