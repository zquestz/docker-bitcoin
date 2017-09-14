#!/usr/bin/env ruby

require "./update"

def build_image(branch, version, opts)
  dir = File.join(branch, version)
  tag = "bitcoin-#{branch}:#{version}"

  # some clients self-report a different formatted version
  # so we allow this to be overridden in versions.yml
  client_version = opts["client_version"] || "v#{version}"

  run "docker build -t #{tag} #{dir}"
  run "docker run --rm #{tag} sh -c 'test -n \"$(bitcoind -version | grep \"version #{client_version}\")\"'"
end

if __FILE__ == $0
  load_versions.each do |branch, versions|
    versions.each do |version, opts|
      build_image(branch, version, opts)
    end
  end
end
