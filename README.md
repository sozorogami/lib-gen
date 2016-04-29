# lib-gen

Use CocoaPods to generate iOS dependency hierarchies of arbitrary complexity for science, fun, and profit. Hacked together with love by [Brian Michel](https://github.com/brianmichel) and [Tyler Tape](https://github.com/sozorogami). Details in a forthcoming Tumblr engineering article.

## Usage

Clone this repo, and in the root folder run:

`ruby lib-gen.rb <ARGS>`

The complete list of command line flags is as follows:

```
-p, --path [PATH]                Path to create dependencies
-f, --files [NUM]                Source files per dependency
-d, --depth [NUM]                Max depth of dependency tree
-n, --number [NUM]               Number of dependencies per library
-D, --delete                     Suppress prompt when deleting existing directory
```

(This can be displayed at any time by running `ruby lib-gen.rb --help`)

This will create randomized libraries at the path specified, each with its own podspec, and a `podfile_support.rb` file. Requiring this file in any CocoaPods podfile and calling `import_shared_generated_pods()` will add the entire dependency hierarchy to that project.

## Examples

`ruby lib-gen.rb -d 3 -n 2` will create a hierarchy like this:

![3-2](https://cloud.githubusercontent.com/assets/1407680/14930103/6ba83a28-0e2f-11e6-92b7-fb72da22614a.png)

`ruby lib-gen.rb -d 4 -n 1` looks like this:

![4-1](https://cloud.githubusercontent.com/assets/1407680/14930114/781f327a-0e2f-11e6-80c2-442d35e089c6.png)
