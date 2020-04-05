#!/usr/bin/env ruby

STDOUT.sync = true

require 'octokit'

github = Octokit::Client.new
(0..50).each do |p|
  json = github.search_repositories('stars:>=1000 size:>200 language:java is:public mirror:false archived:false', page: p)
  json[:items].each do |i|
    puts i[:full_name]
  end
end
