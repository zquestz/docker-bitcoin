#!/usr/bin/env ruby

require "./update"

def build_image(branch, version)
  dir = File.join(branch, version)
  tag = "bitcoin-#{branch}:#{version}"
  run "docker build -t #{tag} #{dir}"
  run "docker run --rm #{tag} sh -c 'test -n \"$(bitcoind -version | grep \"version v#{version}\")\"'"
end

if __FILE__ == $0
  load_versions.each do |branch, versions|
    versions.each do |version, _|
      build_image(branch, version)
    end
  end
end
