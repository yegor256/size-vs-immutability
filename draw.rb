
data = []
File.open(ARGV[0]).read.each_line do |l|
  ncss, flag = l.strip.split(',', 2)
  ncss = ncss.to_i
  next if ncss > 600
  data << { ncss: ncss, immutable: flag == 'yes' }
end

steps = 100
lo = data.map { |r| r[:ncss] }.min
hi = data.map { |r| r[:ncss] }.max
step = (hi - lo).to_f / steps

cols = []
(0..steps - 1).each do |s|
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
puts "% Step: #{step} (steps: #{steps})"

puts '\begin{tikzpicture}'
puts '\begin{axis}[width=12cm,height=8cm,'
puts 'axis lines=middle, xlabel={NCSS}, ylabel={},'
puts "xmin=#{lo}, xmax=#{hi}, ymin=0, ymax=100,"
puts 'yticklabel={\pgfmathprintnumber{\tick}\%},'
puts "extra tick style={major grid style=black},grid=major]"
cols.each_with_index do |v, i|
  puts "\\addplot [only marks, mark size=#{[8 * v[:total] / max,0.5].max}pt] coordinates {"
  puts "(#{lo + i * step},#{v[:share] * 100})};"
end
puts '\end{axis}\end{tikzpicture}'
