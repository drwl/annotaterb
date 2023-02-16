require "wrong"
include Wrong

def windows?
  require 'rbconfig'
  RbConfig::CONFIG["host_os"] =~
      %r!(msdos|mswin|djgpp|mingw|[Ww]indows)!
end

Wrong.config.verbose
Wrong.config.color unless windows?

here = File.expand_path(File.dirname __FILE__)
$LOAD_PATH.unshift File.join(here, '..', 'lib')
require "files"

## Testing the Files object

files = Files.create        # creates a temporary directory inside Dir.tmpdir

assert { files.root }

files.file "hello.txt"    # creates file "hello.txt" containing "contents of hello.txt"
files.dir "web" do        # creates directory "web"
  file "snippet.html",    # creates file "web/snippet.html", with content
    "<h1>File under F for fantastic!</h1>"
  dir "img" do            # creates directory "web/img"
    file File.new("#{here}/data/cheez_doing_it_wrong.jpg")  # containing a copy of cheez_doing_it_wrong.jpg
    file "other.jpg",     # and a different named file...
      File.new("#{here}/data/cheez_doing_it_wrong.jpg")  # containing the content of cheez_doing_it_wrong.jpg
  end
end

dir = files.root
assert { dir.split('/').last =~ /^files_test/ }

assert { dir =~ /^#{Dir::tmpdir}/}

assert { File.read("#{dir}/hello.txt") == "contents of hello.txt" }
assert { File.read("#{dir}/web/snippet.html") == "<h1>File under F for fantastic!</h1>" }
assert {
  File.read("#{dir}/web/img/cheez_doing_it_wrong.jpg") ==
  File.read("#{here}/data/cheez_doing_it_wrong.jpg")
}
assert {
  File.read("#{dir}/web/img/other.jpg") ==
  File.read("#{here}/data/cheez_doing_it_wrong.jpg")
}

files.remove
assert("remove removes the root dir and all contents") { !File.exist?(dir) }
assert("after remove, the object is bogus") do
  rescuing { (files.file "uhoh.txt") }.is_a? Errno::ENOENT
end

## Testing the Files method (which is the recommended public API)

dir = Files do
  file "hello.txt"
  dir("web") { file "hello.html" }
end
assert { dir }
assert { File.read("#{dir}/hello.txt") == "contents of hello.txt" }
assert { File.read("#{dir}/web/hello.html") == "contents of hello.html" }
assert { dir.split('/').last =~ /^files_test/ }

assert { Files.called_from(0) == "files_test" }

dir = Files do
  dir "foo" do
    file "foo.txt"
  end
  dir "bar" do
    file "bar.txt"
    dir "baz" do
      file "baz.txt"
    end
    dir "baf" do
      file "baf.txt"
    end
  end
end

assert { File.read("#{dir}/foo/foo.txt") == "contents of foo.txt" }
assert { File.read("#{dir}/bar/bar.txt") == "contents of bar.txt" }
assert { File.read("#{dir}/bar/baz/baz.txt") == "contents of baz.txt" }
assert { File.read("#{dir}/bar/baf/baf.txt") == "contents of baf.txt" }

# test for data directory copy
src = File.expand_path("#{here}/data")

files = Files.create do
  dir "foo", :src => src do
    # note: I'm not sure if this is desired behavior...
    # shouldn't it put the *contents* of data into foo?
    assert { File.exist?(File.join(Dir.pwd, 'data/cheez_doing_it_wrong.jpg'))}
  end
end

# todo: test :target option

dir = Files()
assert { File.exist? dir and File.directory? dir}

dir = Files do
  dir "a"
end
assert { File.exist? "#{dir}/a" and File.directory? "#{dir}/a"}

# the file and dir methods return the path, suitable for storing in a predeclared local var
stuff = nil
hello = nil
files_dir = Files do
  stuff = dir "stuff" do
    hello = file "hello.txt"
  end
end

assert { stuff == "#{files_dir}/stuff" }
assert { hello == "#{files_dir}/stuff/hello.txt" }

dir_inside_do_block = nil
dir = Files do
  dir_inside_do_block = Dir.pwd
  dir "xyzzy" do
    assert("sets the current directory inside the dir block") { File.basename(Dir.pwd) == "xyzzy" }
  end
end
assert("sets the current directory inside the Files block") { File.basename(dir_inside_do_block) == File.basename(dir) }
# note that we can't just compare the full paths because some OS's hard link their temp dir to different base paths

## Testing the Mixin interface (which is the alternate public API)
class FilesMixinTest
  include Files
  def go
    assert {@files.nil?}
    file "foo.txt"
    assert("calling file creates an instance var") { @files and @files.root }
    assert("the method 'files' returns the instance var") { @files.object_id == files.object_id }

    assert("calling file creates a file") { File.exist?("#{@files.root}/foo.txt") }
    assert("the created file contains a nice message") { File.read("#{@files.root}/foo.txt") == "contents of foo.txt" }

    dir "bar" do
      file "bar.txt"
      assert("the current directory is set inside a dir block") { File.read("bar.txt") == "contents of bar.txt" }
      dir "sub" do
        file "sub.txt"
        assert("the current directory is set inside a nested dir block") { File.read("sub.txt") == "contents of sub.txt" }
      end
    end
    assert("a file created inside the dir block exists under the root dir") {
      File.read("#{@files.root}/bar/bar.txt") == "contents of bar.txt"
    }

    subdir = dir "baz"
    assert("the dir method creates the dir") { File.exist?("#{@files.root}/baz")}
    assert("the dir method returns the created dir") { subdir == "#{@files.root}/baz"}
    assert { File.directory?("#{@files.root}/baz")}

    # this behavior is kind of a bug
    begin
      @content = "breakfast"
      dir "stuff" do
        assert("instance variables are *not* preserved in a dir block") { @content.nil? }
      end
    end

  end
end
FilesMixinTest.new.go

# TODO: allow options to be set in mixin mode
# TODO: test options from function mode and mixin mode
# files = Files.create :dummy => true
# assert { files.options[:dummy] == true }

