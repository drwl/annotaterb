# Files

*a simple DSL for creating temporary files and directories*

Ever want to create a whole bunch of files at once? Like when you're writing tests for a tool that processes files? The Files gem lets you cleanly specify those files and their contents inside your test code, instead of forcing you to create a fixture directory and check it in to your repo. It puts them in a temporary directory and cleans up when your test is done.

## Usage (mixin mode)

The mixin mode is a fairly clean API, suitable for use in unit tests. After `include Files` you can call `file` or `dir` to make a temporary file or directory; it'll put them into a new temp dir that is removed on process exit. It also saves a reference to this directory inside an instance variable named `@files` (so don't use that name for your own instance variables).

    require "files"
    include Files

    file "hello.txt"     # creates file "hello.txt" containing "contents of hello.txt"

    dir "web" do              # creates directory "web"
      file "snippet.html",    # creates file "web/snippet.html"...
        "<h1>Fix this!</h1>"  # ...containing "<h1>Fix this!</h1>"
      dir "img" do            # creates directory "web/img"
        file File.new("data/hello.png")            # containing a copy of hello.png
        file "hi.png", File.new("data/hello.png")  # and a copy of hello.png named hi.png
      end
    end

    @files.root           # returns the path to the temporary directory, creating it if necessary

## Usage (bare function mode)

In bare function mode, you call the `Files` method, which doesn't pollute the current object with a `@files` instance variable. It returns a string with the path to the root temp dir that you can use later.

    require "files"

    temp_dir = Files do         # creates a temporary directory inside Dir.tmpdir
      file "hello.txt"          # creates file "hello.txt" containing "contents of hello.txt"
      dir "web" do              # creates directory "web"
        file "snippet.html",    # creates file "web/snippet.html"...
          "<h1>Fix this!</h1>"  # ...containing "<h1>Fix this!</h1>"
        dir "img" do            # creates directory "web/img"
          file File.new("data/hello.png")            # containing a copy of hello.png
          file "hi.png", File.new("data/hello.png")  # and a copy of hello.png named hi.png
        end
      end
    end                         # "Files" returns a string with the path to the directory

    src = '/path/to/some/data' # use '/path/to/some/data/.' to only copy contents of data folder, not data folder itself.

    # creates a folder called 'target/$timestamp' relative to pwd
    dir = Files.create :path => "target" do
        dir "foo", :src => src do # creates 'target/$timestamp/foo', and copies src into foo [but should it copy the dir or the contents?]
        end
    end

see `test/files_test.rb` for more usage examples

## Details

* the directory will be removed at exit
  * unless you pass `:remove => false`
* the directory name is based on the name of the source file you called Files from
* if the first argument to `file` is a String, then a new file is made
  * the content of the new file is either a short, descriptive message, or whatever you passed as the second argument
* if the argument to `file` is a Ruby `File` object, then it copies the named file into the new location
* To copy another directory to one created by this module, specifying `:src` to `dir` method
   * [Not sure if this is implemented right... should it copy the *dir* or its *contents*?]
* the `dir do` block is executed in the scope of the `Dir` object, so it can't call methods on your object directly.
  Instead, set a temporary local variable, like this:

        my_cheese = cheese()
        dir do
          file "which_cheese.txt", my_cheese
        end


## TODO

* take a hash or a YAML file or YAML string to specify the directory layout and contents
* emit a hash or a YAML file or string to serialize the directory layout and contents for later
* support symlinks (?)
* specify file write mode (?)
* play nice with FakeFS (possibly with a :fake option)
* global/default :remove option

## Credits

Written by Alex Chaffee <http://alexchaffee.com> <mailto:alex@stinky.com> <http://github.com/alexch> [@alexch](http://twitter.com/alexch)

Patches by

* [Seth Call](http://github.com/sethcall)

## License [MIT]

Copyright (C) 2012 Alex Chaffee

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
