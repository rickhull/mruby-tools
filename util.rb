#!/usr/bin/env ruby

require 'tempfile'

# args like: file1.rb file2.rb -o outfile
#  possibly: file1.rb -o outfile file2.rb

rb_files = []
outfile = nil

while !ARGV.empty?
  arg = ARGV.shift
  if arg == '-o'
    outfile = ARGV.shift
    raise "no outfile provided with -o" unless outfile
    raise "#{outfile} is misnamed" if File.extname(outfile) == '.rb'
  else
    rb_files << arg
  end
end

raise "-o outfile is required" unless outfile

rb_code = rb_files.map { |f|
  File.read(f)
}.join("\n").gsub("\n", '\n').gsub('"', '\"')

mruby_src_dir = ENV['MRUBY_SRC']
raise "env: MRUBY_SRC is required" unless mruby_src_dir
raise "bad MRUBY_SRC #{mruby_src_dir}" unless File.directory? mruby_src_dir
mruby_inc_dir = File.join(mruby_src_dir, 'include')
raise "bad MRUBY_SRC #{mruby_inc_dir}" unless File.directory? mruby_inc_dir

c_code = <<EOF
#include <stdlib.h>
#include <mruby.h>
#include <mruby/compile.h>

int
main(void)
{
  mrb_state *mrb = mrb_open();
  if (!mrb) {
    printf("mrb problem");
    exit(1);
  }
EOF

c_code += '  mrb_load_string(mrb, "'
c_code += rb_code
c_code += '");'
c_code += "\n"

c_code += <<EOF
  mrb_load_string(mrb, "puts :goodbye_world");
  mrb_close(mrb);
  return 0;
}
EOF

# puts c_code + "\n"

file = Tempfile.new(['c_code', '.c'])
file.write(c_code)
file.close

gcc_args = ['-std=c99', "-I", mruby_inc_dir, file.path, "-o", outfile,
            File.join(mruby_src_dir, 'build', 'host', 'lib', 'libmruby.a'),
            '-lm']

puts "compiling..."
if system('gcc', *gcc_args)
  puts "created binary executable: #{outfile}"
end