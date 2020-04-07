#!/usr/bin/env ruby

require 'slop'

opts = Slop.parse(ARGV, strict: true, help: true) do |o|
  o.integer '--width', default: 12
  o.integer '--height', default: 8
  o.integer '--max-ncss', default: 1000
  o.integer '--steps', default: 100
  o.integer '--circle-size', default: 8
  o.string '--summary', default: 'summary.csv'
end

data = []
File.open(opts[:summary]).read.each_line do |l|
  ncss, flag = l.strip.split(',')
  ncss = ncss.to_i
  next if ncss > opts['max-ncss']
  data << { ncss: ncss, immutable: flag == 'yes' }
end

lo = data.map { |r| r[:ncss] }.min
hi = data.map { |r| r[:ncss] }.max
step = (hi - lo).to_f / opts[:steps]

cols = []
(0..opts[:steps] - 1).each do |s|
  all = data.select { |r| r[:ncss] > s * step && r[:ncss] < s * (step + 1) }
  total = all.count
  immutable = all.select { |r| r[:immutable] }.count
  cols << {
    total: all.count,
    share: total.zero? ? 0 : immutable.to_f / total
  }
end

max = cols.map { |c| c[:total] }.max

puts "% Max: #{max}"
puts "% Lo: #{lo}"
puts "% Hi: #{hi}"
puts "% Step: #{step} (steps: #{opts[:steps]})"

puts '\begin{tikzpicture}'
puts "\\begin{axis}[width=#{opts[:width]}cm,height=#{opts[:height]}cm,"
puts 'axis lines=middle, xlabel={NCSS}, ylabel={},'
puts "xmin=#{lo}, xmax=#{hi}, ymin=0, ymax=100,"
puts 'yticklabel={\pgfmathprintnumber{\tick}\%},'
puts "extra tick style={major grid style=black},grid=major]"
cols.each_with_index do |v, i|
  puts "\\addplot [only marks, mark=*, mark options={fill=lightgray,draw=black}, mark size=#{[opts['circle-size'] * v[:total] / max,0.5].max}pt] coordinates {"
  puts "(#{lo + i * step},#{v[:share] * 100})};"
end
puts '\end{axis}\end{tikzpicture}'
