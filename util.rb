#!/usr/bin/env ruby

require 'tempfile'

# args like: file1.rb file2.rb -o outfile
#  possibly: file1.rb -o outfile file2.rb -c generated.c

rb_files = []
outfile = nil
cfile = nil

while !ARGV.empty?
  arg = ARGV.shift
  if arg == '-o'
    outfile = ARGV.shift
    raise "no outfile provided with -o" unless outfile
    raise "#{outfile} is misnamed" if File.extname(outfile) == '.rb'
  elsif arg == '-c'
    cfile = File.open(ARGV.shift || 'generated.c', "w")
  else
    rb_files << arg
  end
end

raise "-o outfile is required" unless outfile

mruby_src_dir = ENV['MRUBY_SRC']
raise "env: MRUBY_SRC is required" unless mruby_src_dir
raise "bad MRUBY_SRC #{mruby_src_dir}" unless File.directory? mruby_src_dir
mruby_inc_dir = File.join(mruby_src_dir, 'include')
raise "bad MRUBY_SRC #{mruby_inc_dir}" unless File.directory? mruby_inc_dir

def rb2c(rb_filename, indent: '  ')
  c_str = File.read(rb_filename)
  size = c_str.size
  c_str = c_str.gsub("\n", '\n').gsub('"', '\"')
  c_str = File.read(rb_filename).gsub("\n", '\n').gsub('"', '\"')
  ['mrb_load_nstring(mrb, "' + c_str + '", ' + "#{size});",
   'if (mrb->exc) {',
   '  mrb_value exc = mrb_obj_value(mrb->exc);',
   '  mrb_value exc_msg = mrb_funcall(mrb, exc, "to_s", 0);',
   '  printf("Exception: %s\n", mrb_str_to_cstr(mrb, exc_msg));',
   '  exit(1);',
   '}',
  ].map { |s| indent + s }.join("\n")
end

c_code = <<EOF
#include <stdlib.h>
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/variable.h>
#include <mruby/string.h>

int
main(void)
{
  mrb_state *mrb = mrb_open();
  if (!mrb) {
    printf("mrb problem");
    exit(1);
  }
EOF

rb_files.each { |rbf|
  c_code += "\n  /* #{rbf} */\n"
  c_code += rb2c(rbf) + "\n\n"
}

c_code += <<EOF
  mrb_close(mrb);
  return 0;
}
EOF

# puts c_code + "\n"

file = cfile || Tempfile.new(['generated', '.c'])
file.write(c_code)
file.close

gcc_args = ['-std=c99', "-I", mruby_inc_dir, file.path, "-o", outfile,
            File.join(mruby_src_dir, 'build', 'host', 'lib', 'libmruby.a'),
            '-lm']

puts "compiling..."
if system('gcc', *gcc_args)
  puts "created binary executable: #{outfile}"
end
